package com.dailyfixer.servlet.payment;

import com.dailyfixer.config.PayHereConfig;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.model.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Enumeration;

/**
 * NotifyServlet - Handles PayHere server-to-server payment notifications.
 *
 * URL: /notify
 * Method: POST (from PayHere server)
 *
 * PayHere sends payment status updates to this endpoint.
 * This updates the order status in the database.
 *
 * Payment Status Codes:
 * 2 = Success (payment received)
 * 0 = Pending
 * -1 = Canceled
 * -2 = Failed
 * -3 = Charged back
 */
@WebServlet("/notify")
public class NotifyServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        System.out.println("NotifyServlet initialized");
    }

    /**
     * Handle POST notification from PayHere.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== NotifyServlet: Received payment notification ===");

        // Log all parameters for debugging
        logAllParameters(request);

        try {
            // Get notification parameters
            String merchantId = request.getParameter("merchant_id");
            String orderId = request.getParameter("order_id");
            String payhereAmount = request.getParameter("payhere_amount");
            String payhereCurrency = request.getParameter("payhere_currency");
            String statusCode = request.getParameter("status_code");
            String md5sig = request.getParameter("md5sig");
            String paymentId = request.getParameter("payment_id");

            System.out.println("Notification Details:");
            System.out.println("  Order ID: " + orderId);
            System.out.println("  Amount: " + payhereAmount + " " + payhereCurrency);
            System.out.println("  Status Code: " + statusCode);
            System.out.println("  Payment ID: " + paymentId);
            System.out.println("  MD5 Signature: " + md5sig);

            // Verify the notification is from PayHere
            boolean isValid = verifyNotification(
                    merchantId, orderId, payhereAmount, payhereCurrency, statusCode, md5sig);

            if (!isValid) {
                System.err.println("ERROR: Invalid notification signature!");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendResponse(response, "Invalid signature");
                return;
            }

            System.out.println("Notification signature verified successfully");

            // Parse status code
            int status = Integer.parseInt(statusCode);
            String newOrderStatus;

            switch (status) {
                case 2:
                    newOrderStatus = "PAID";
                    System.out.println("Payment SUCCESSFUL for order: " + orderId);
                    break;
                case 0:
                    newOrderStatus = "PENDING";
                    System.out.println("Payment PENDING for order: " + orderId);
                    break;
                case -1:
                    newOrderStatus = "CANCELLED";
                    System.out.println("Payment CANCELLED for order: " + orderId);
                    break;
                case -2:
                    newOrderStatus = "FAILED";
                    System.out.println("Payment FAILED for order: " + orderId);
                    break;
                case -3:
                    newOrderStatus = "FAILED"; // Chargeback
                    System.out.println("Payment CHARGED BACK for order: " + orderId);
                    break;
                default:
                    newOrderStatus = "PENDING";
                    System.out.println("Unknown status code: " + status);
            }

            // PAID: atomic PENDING→PAID so duplicate webhooks / Success.jsp cannot double-reduce stock
            boolean updated;
            if ("PAID".equals(newOrderStatus)) {
                boolean claimed = orderDAO.claimOrderPaidFromPending(orderId, paymentId);
                if (claimed) {
                    try {
                        boolean stockReduced = orderDAO.reduceStockForOrder(orderId);
                        if (stockReduced) {
                            System.out.println("Stock reduced successfully for order: " + orderId);
                        } else {
                            System.err.println("Warning: Stock reduction failed or incomplete for order: " + orderId);
                        }
                    } catch (Exception e) {
                        System.err.println("Error reducing stock for order " + orderId + ": " + e.getMessage());
                        e.printStackTrace();
                    }
                } else {
                    System.out.println("NotifyServlet: PAID claim skipped for " + orderId
                            + " (already paid, not pending, or unknown order — no stock change)");
                }

                // Multi-store: other PENDING orders for same checkout
                try {
                    Order mainOrder = orderDAO.findOrderById(orderId);
                    if (mainOrder != null && mainOrder.getEmail() != null) {
                        java.util.List<Order> relatedOrders = orderDAO.getOrdersByStatus("PENDING");
                        for (Order relatedOrder : relatedOrders) {
                            if (relatedOrder.getEmail() != null
                                    && relatedOrder.getEmail().equals(mainOrder.getEmail())
                                    && !relatedOrder.getOrderId().equals(orderId)) {
                                long timeDiff = Math.abs(
                                        relatedOrder.getCreatedAt().getTime() - mainOrder.getCreatedAt().getTime());
                                if (timeDiff < 300000) {
                                    boolean relClaimed = orderDAO.claimOrderPaidFromPending(relatedOrder.getOrderId(), null);
                                    if (relClaimed) {
                                        System.out.println("Updated related order to PAID: " + relatedOrder.getOrderId());
                                        try {
                                            boolean stockReduced = orderDAO.reduceStockForOrder(relatedOrder.getOrderId());
                                            if (stockReduced) {
                                                System.out.println("Stock reduced successfully for related order: "
                                                        + relatedOrder.getOrderId());
                                            } else {
                                                System.err.println("Warning: Stock reduction failed for related order: "
                                                        + relatedOrder.getOrderId());
                                            }
                                        } catch (Exception e) {
                                            System.err.println("Error reducing stock for related order "
                                                    + relatedOrder.getOrderId() + ": " + e.getMessage());
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Warning: Could not update related orders: " + e.getMessage());
                }

                Order verify = orderDAO.findOrderById(orderId);
                updated = verify != null && verify.getStatus() != null
                        && "PAID".equalsIgnoreCase(verify.getStatus().trim());
            } else {
                updated = orderDAO.updateOrderStatus(orderId, newOrderStatus, paymentId);
            }

            if (updated) {
                System.out.println("Order status updated to: " + newOrderStatus);
                response.setStatus(HttpServletResponse.SC_OK);
                sendResponse(response, "OK");
            } else {
                System.err.println("Failed to update order status");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                sendResponse(response, "Database update failed");
            }

        } catch (Exception e) {
            System.err.println("Error processing notification: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendResponse(response, "Error: " + e.getMessage());
        }
    }

    /**
     * Verify PayHere notification signature.
     *
     * Formula: MD5(merchant_id + order_id + payhere_amount + payhere_currency +
     * status_code + MD5(merchant_secret).toUpperCase()).toUpperCase()
     */
    private boolean verifyNotification(String merchantId, String orderId,
                                       String amount, String currency,
                                       String statusCode, String receivedMd5sig) {
        try {
            String merchantSecret = PayHereConfig.getMerchantSecret();

            // Step 1: MD5 hash of merchant secret
            String secretHash = md5(merchantSecret).toUpperCase();

            // Step 2: Concatenate all values
            String concat = merchantId + orderId + amount + currency + statusCode + secretHash;

            // Step 3: MD5 hash of concatenated string
            String calculatedHash = md5(concat).toUpperCase();

            System.out.println("Signature verification:");
            System.out.println("  Calculated: " + calculatedHash);
            System.out.println("  Received: " + receivedMd5sig);

            // Compare hashes
            return calculatedHash.equalsIgnoreCase(receivedMd5sig);

        } catch (Exception e) {
            System.err.println("Error verifying signature: " + e.getMessage());
            return false;
        }
    }

    /**
     * Calculate MD5 hash of a string.
     */
    private String md5(String input) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("MD5");
        byte[] hashBytes = md.digest(input.getBytes(StandardCharsets.UTF_8));

        StringBuilder hexString = new StringBuilder();
        for (byte b : hashBytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }

    /**
     * Log all request parameters for debugging.
     */
    private void logAllParameters(HttpServletRequest request) {
        System.out.println("--- All Notification Parameters ---");
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            String value = request.getParameter(name);
            // Mask sensitive data
            if (name.contains("md5") || name.contains("secret")) {
                value = value.substring(0, Math.min(8, value.length())) + "...";
            }
            System.out.println("  " + name + " = " + value);
        }
        System.out.println("-----------------------------------");
    }

    /**
     * Send text response to PayHere.
     */
    private void sendResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        out.print(message);
        out.flush();
    }

    /**
     * Handle GET request (for testing).
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        out.println("PayHere Notify Endpoint");
        out.println("This endpoint receives POST notifications from PayHere.");
        out.flush();
    }
}

