package com.dailyfixer.servlet.order;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.dao.StoreOrderDAO;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * UpdateOrderStatusServlet - Handles AJAX requests to update order status.
 * 
 * URL: /UpdateOrderStatusServlet
 * Method: POST
 * Parameters: orderId, status
 */
@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private StoreOrderDAO storeOrderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        storeOrderDAO = new StoreOrderDAO();
        System.out.println("UpdateOrderStatusServlet initialized");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // --- 1. Require login ---
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\":false,\"message\":\"Authentication required\"}");
                return;
            }

            String orderId = request.getParameter("orderId");
            String status  = request.getParameter("status");

            if (orderId == null || orderId.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Order ID is required\"}");
                return;
            }
            if (status == null || status.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Status is required\"}");
                return;
            }

            String statusUpper = status.trim().toUpperCase();
            if (!isValidStatus(statusUpper)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Invalid status: " + status + "\"}");
                return;
            }

            // --- 2. Load the order ---
            Order order = orderDAO.findOrderById(orderId.trim());
            if (order == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Order not found\"}");
                return;
            }

            boolean isAdmin = "admin".equals(currentUser.getRole());

            if (!isAdmin) {
                // --- 3. Ownership check: caller must be the store that owns the order ---
                if (!"store".equals(currentUser.getRole())) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"success\":false,\"message\":\"Not authorised to update orders\"}");
                    return;
                }

                boolean ownsOrder = currentUser.getUsername().equals(order.getStoreUsername());
                if (!ownsOrder && order.getStoreId() != null) {
                    StoreDAO storeDAO = new StoreDAO();
                    Store callerStore = storeDAO.getStoreByUsername(currentUser.getUsername());
                    ownsOrder = callerStore != null && callerStore.getStoreId() == order.getStoreId();
                }

                if (!ownsOrder) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"success\":false,\"message\":\"Not authorised to update this order\"}");
                    return;
                }

                // --- 4. Status transition validation (store users only) ---
                String currentStatus = order.getStatus() != null ? order.getStatus().toUpperCase() : "PENDING";
                if (!isValidTransition(currentStatus, statusUpper)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\":false,\"message\":\"Cannot transition order from "
                            + currentStatus + " to " + statusUpper + "\"}");
                    return;
                }
            }

            // --- 5. Apply the update ---
            boolean updated = orderDAO.updateStatus(orderId.trim(), statusUpper);
            if (updated) {
                System.out.println("Order status updated: " + orderId + " -> " + statusUpper
                        + " by " + currentUser.getUsername());

                // Apply 10% commission when order is marked DELIVERED
                if ("DELIVERED".equals(statusUpper)) {
                    storeOrderDAO.updateCommission(orderId.trim());
                }

                // Restore stock only if a post-payment order is being cancelled
                if ("CANCELLED".equals(statusUpper)) {
                    String preCancelStatus = order.getStatus() != null ? order.getStatus().toUpperCase() : "";
                    if ("PAID".equals(preCancelStatus) || "PROCESSING".equals(preCancelStatus)
                            || "OUT_FOR_DELIVERY".equals(preCancelStatus)) {
                        try {
                            orderDAO.restoreStockForOrder(orderId.trim());
                        } catch (Exception e) {
                            System.err.println("Warning: stock restoration failed for cancelled order "
                                    + orderId + ": " + e.getMessage());
                        }
                    }
                }

                out.print("{\"success\":true,\"message\":\"Status updated successfully\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Failed to update order status\"}");
            }

        } catch (Exception e) {
            System.err.println("Error updating order status: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        } finally {
            out.close();
        }
    }

    /** Allowed status values. */
    private boolean isValidStatus(String status) {
        return "PENDING".equals(status) || "PAID".equals(status) ||
               "PROCESSING".equals(status) || "OUT_FOR_DELIVERY".equals(status) ||
               "DELIVERED".equals(status) || "CANCELLED".equals(status);
    }

    /**
     * Enforce forward-only status transitions for store users.
     * Admins bypass this check entirely.
     */
    private boolean isValidTransition(String current, String next) {
        Map<String, List<String>> allowed = new HashMap<>();
        allowed.put("PENDING",           Arrays.asList("PAID", "CANCELLED"));
        allowed.put("PAID",              Arrays.asList("PROCESSING", "CANCELLED"));
        allowed.put("PROCESSING",        Arrays.asList("OUT_FOR_DELIVERY", "CANCELLED"));
        allowed.put("OUT_FOR_DELIVERY",  Arrays.asList("DELIVERED"));
        List<String> targets = allowed.get(current);
        return targets != null && targets.contains(next);
    }
}
