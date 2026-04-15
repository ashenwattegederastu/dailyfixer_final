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

/**
 * PayHereServlet - Generates PayHere payment form and redirects to payment
 * gateway.
 *
 * URL: /payhere
 * Method: GET (with order_id parameter)
 *
 * PayHere Hash Formula:
 * hash = MD5(merchant_id + order_id + amount + currency +
 * MD5(merchant_secret).toUpperCase()).toUpperCase()
 */
@WebServlet("/payhere")
public class PayHereServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        System.out.println("PayHereServlet initialized");
    }

    /**
     * Handle GET request - generate PayHere form and auto-submit.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== PayHereServlet: Generating payment form ===");

        String orderId = request.getParameter("order_id");

        if (orderId == null || orderId.isEmpty()) {
            System.err.println("Missing order_id parameter");
            response.sendRedirect("checkout.html?error=missing_order");
            return;
        }

        // Get order from session or database
        Order order = (Order) request.getSession().getAttribute("currentOrder");

        if (order == null || !order.getOrderId().equals(orderId)) {
            // Fetch from database
            order = orderDAO.findOrderById(orderId);
        }

        if (order == null) {
            System.err.println("Order not found: " + orderId);
            response.sendRedirect("checkout.html?error=order_not_found");
            return;
        }

        // Build dynamic base URL from request
        String baseUrl = buildBaseUrl(request);
        System.out.println("Dynamic base URL: " + baseUrl);

        // Generate PayHere form with dynamic URLs
        String html = generatePayHereForm(order, baseUrl);

        // Send response
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println(html);
        out.flush();
    }

    /**
     * Build base URL dynamically from the incoming request.
     * This ensures URLs work regardless of deployment configuration.
     */
    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);

        // Only include port if it's not default (80 for http, 443 for https)
        if ((scheme.equals("http") && serverPort != 80) ||
                (scheme.equals("https") && serverPort != 443)) {
            url.append(":").append(serverPort);
        }

        url.append(contextPath);
        return url.toString();
    }

    /**
     * Generate auto-submitting HTML form for PayHere.
     *
     * @param order   The order to process
     * @param baseUrl Dynamic base URL from request context
     */
    private String generatePayHereForm(Order order, String baseUrl) {

        // PayHere configuration
        String merchantId = PayHereConfig.getMerchantId();
        String merchantSecret = PayHereConfig.getMerchantSecret();
        String payhereUrl = PayHereConfig.getPayHereUrl();

        // Build dynamic URLs based on actual deployment context
        String returnUrl = baseUrl + "/pages/stores/Success.jsp?order_id=" + order.getOrderId();
        String cancelUrl = baseUrl + "/pages/stores/Cancel.jsp?order_id=" + order.getOrderId();
        String notifyUrl = baseUrl + "/notify";

        System.out.println("Dynamic URLs:");
        System.out.println("  Return URL: " + returnUrl);
        System.out.println("  Cancel URL: " + cancelUrl);
        System.out.println("  Notify URL: " + notifyUrl);

        // Order details
        String orderId = order.getOrderId();
        String amount = order.getFormattedAmount();
        String currency = order.getCurrency();
        String itemName = order.getProductName();

        // Customer details
        String firstName = order.getFirstName();
        String lastName = order.getLastName();
        String email = order.getEmail();
        String phone = order.getPhone();
        String address = order.getAddress();
        String city = order.getCity();

        // Generate hash
        String hash = generateHash(merchantId, orderId, amount, currency, merchantSecret);

        System.out.println("PayHere Form Details:");
        System.out.println("  Merchant ID: " + merchantId);
        System.out.println("  Order ID: " + orderId);
        System.out.println("  Amount: " + amount + " " + currency);
        System.out.println("  Hash: " + hash);

        // Build auto-submit HTML form
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>\n");
        html.append("<html lang=\"en\">\n");
        html.append("<head>\n");
        html.append("    <meta charset=\"UTF-8\">\n");
        html.append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n");
        html.append("    <title>Redirecting to PayHere...</title>\n");
        html.append("    <link rel=\"stylesheet\" href=\"css/framework.css\">\n");
        html.append("    <link rel=\"stylesheet\" href=\"css/checkout.css\">\n");
        html.append(
                "    <link href=\"https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap\" rel=\"stylesheet\">\n");
        html.append("</head>\n");
        html.append("<body class=\"dark redirect-page\">\n");
        html.append("    <div class=\"redirect-content\">\n");
        html.append("        <div class=\"spinner\"></div>\n");
        html.append("        <h2>Redirecting to Payment Gateway</h2>\n");
        html.append("        <p>Please wait while we connect you to PayHere...</p>\n");
        html.append("    </div>\n");

        // PayHere form (hidden, auto-submitted)
        html.append("    <form id=\"payhere-form\" method=\"POST\" action=\"").append(payhereUrl).append("\">\n");

        // Required PayHere fields
        html.append("        <input type=\"hidden\" name=\"merchant_id\" value=\"").append(merchantId).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"return_url\" value=\"").append(returnUrl).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"cancel_url\" value=\"").append(cancelUrl).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"notify_url\" value=\"").append(notifyUrl).append("\">\n");

        // Order details
        html.append("        <input type=\"hidden\" name=\"order_id\" value=\"").append(orderId).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"items\" value=\"").append(escapeHtml(itemName))
                .append("\">\n");
        html.append("        <input type=\"hidden\" name=\"currency\" value=\"").append(currency).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"amount\" value=\"").append(amount).append("\">\n");

        // Customer details
        html.append("        <input type=\"hidden\" name=\"first_name\" value=\"").append(escapeHtml(firstName))
                .append("\">\n");
        html.append("        <input type=\"hidden\" name=\"last_name\" value=\"").append(escapeHtml(lastName))
                .append("\">\n");
        html.append("        <input type=\"hidden\" name=\"email\" value=\"").append(escapeHtml(email)).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"phone\" value=\"").append(phone).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"address\" value=\"").append(escapeHtml(address))
                .append("\">\n");
        html.append("        <input type=\"hidden\" name=\"city\" value=\"").append(escapeHtml(city)).append("\">\n");
        html.append("        <input type=\"hidden\" name=\"country\" value=\"Sri Lanka\">\n");

        // Hash
        html.append("        <input type=\"hidden\" name=\"hash\" value=\"").append(hash).append("\">\n");

        html.append("    </form>\n");

        // Auto-submit script
        html.append("    <script>\n");
        html.append("        // Auto-submit after short delay for visual feedback\n");
        html.append("        setTimeout(function() {\n");
        html.append("            document.getElementById('payhere-form').submit();\n");
        html.append("        }, 1500);\n");
        html.append("    </script>\n");

        html.append("</body>\n");
        html.append("</html>\n");

        return html.toString();
    }

    /**
     * Generate PayHere hash using MD5.
     * Formula: MD5(merchant_id + order_id + amount + currency +
     * MD5(merchant_secret).toUpperCase()).toUpperCase()
     *
     * @param merchantId     PayHere merchant ID
     * @param orderId        Order ID
     * @param amount         Amount (formatted with 2 decimals)
     * @param currency       Currency code (LKR)
     * @param merchantSecret Merchant secret (Base64 encoded)
     * @return Generated hash in uppercase
     */
    private String generateHash(String merchantId, String orderId, String amount,
                                String currency, String merchantSecret) {
        try {
            // Step 1: MD5 hash of merchant secret
            String secretHash = md5(merchantSecret).toUpperCase();

            // Step 2: Concatenate all values
            String concat = merchantId + orderId + amount + currency + secretHash;

            // Step 3: MD5 hash of concatenated string
            String hash = md5(concat).toUpperCase();

            System.out.println("Hash generation:");
            System.out.println("  Secret hash: " + secretHash);
            System.out.println("  Concat string: " + merchantId + orderId + amount + currency + "***");
            System.out.println("  Final hash: " + hash);

            return hash;

        } catch (Exception e) {
            System.err.println("Error generating hash: " + e.getMessage());
            e.printStackTrace();
            return "";
        }
    }

    /**
     * Calculate MD5 hash of a string.
     *
     * @param input String to hash
     * @return Hex string representation of MD5 hash
     */
    private String md5(String input) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("MD5");
        byte[] hashBytes = md.digest(input.getBytes(StandardCharsets.UTF_8));

        // Convert to hex string
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
     * Escape HTML special characters.
     */
    private String escapeHtml(String input) {
        if (input == null)
            return "";
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}

