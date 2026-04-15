package com.dailyfixer.servlet.order;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.model.User;
import com.dailyfixer.util.PurchaseLimitUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.UUID;

/**
 * CheckoutServlet - Handles customer form submission from checkout page.
 * Creates an order in the database and redirects to PayHere payment.
 *
 * URL: /checkout
 * Method: POST
 */
@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        System.out.println("CheckoutServlet initialized");
    }

    /**
     * Handle POST request from checkout form.
     * Reads cart from session, validates stock, creates order + order_items,
     * then redirects to PayHereServlet.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== CheckoutServlet: Processing checkout ===");

        try {
            HttpSession session = request.getSession();

            // --- 1. Read and validate cart from session ---
            Map<String, CartItem> cart = getCartFromSession(session);
            if (cart == null || cart.isEmpty()) {
                System.err.println("Checkout attempted with empty cart");
                response.sendRedirect("checkout.html?error=empty_cart");
                return;
            }

            for (CartItem item : cart.values()) {
                if (PurchaseLimitUtil.isLineTotalOverLimit(item)) {
                    response.sendRedirect("checkout.html?error=item_price_limit_exceeded");
                    return;
                }
            }

            if (PurchaseLimitUtil.isOrderTotalOverLimit(cart.values())) {
                response.sendRedirect("checkout.html?error=order_price_limit_exceeded");
                return;
            }

            // --- 2. Validate form fields ---
            String firstName = request.getParameter("firstName");
            String lastName  = request.getParameter("lastName");
            String email     = request.getParameter("email");
            String phone     = request.getParameter("phone");
            String address   = request.getParameter("address");
            String city      = request.getParameter("city");

            if (isEmpty(firstName) || isEmpty(lastName) || isEmpty(email) ||
                    isEmpty(phone) || isEmpty(address) || isEmpty(city)) {
                System.err.println("Missing required checkout fields");
                response.sendRedirect("checkout.html?error=missing_fields");
                return;
            }

            // --- 3. Re-validate stock for every cart item before committing ---
            ProductDAO productDAO = new ProductDAO();
            ProductVariantDAO variantDAO = new ProductVariantDAO();

            for (CartItem item : cart.values()) {
                try {
                    if (item.getVariantId() != null) {
                        ProductVariant variant = variantDAO.getVariantById(item.getVariantId());
                        if (variant == null || variant.getQuantity() < item.getQuantity()) {
                            String encoded = URLEncoder.encode(item.getName(), StandardCharsets.UTF_8);
                            response.sendRedirect("checkout.html?error=out_of_stock&product=" + encoded);
                            return;
                        }
                    } else {
                        com.dailyfixer.model.Product product = productDAO.getProductById(item.getProductId());
                        if (product == null || product.getQuantity() < item.getQuantity()) {
                            String encoded = URLEncoder.encode(item.getName(), StandardCharsets.UTF_8);
                            response.sendRedirect("checkout.html?error=out_of_stock&product=" + encoded);
                            return;
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Stock check error for product " + item.getProductId() + ": " + e.getMessage());
                    response.sendRedirect("checkout.html?error=server_error");
                    return;
                }
            }

            // --- 4. Compute total and product summary from cart ---
            BigDecimal totalAmount = BigDecimal.ZERO;
            StringBuilder productNames = new StringBuilder();
            int storeId = 0;
            String storeUsername = null;

            for (CartItem item : cart.values()) {
                BigDecimal unitPrice = BigDecimal.valueOf(item.getPrice()).setScale(2, RoundingMode.HALF_UP);
                totalAmount = totalAmount.add(unitPrice.multiply(BigDecimal.valueOf(item.getQuantity())));
                if (productNames.length() > 0) productNames.append(", ");
                productNames.append(item.getName());
                if (storeId == 0 && item.getStoreId() > 0) {
                    storeId = item.getStoreId();
                    storeUsername = item.getStoreUsername();
                }
            }

            // --- 5. Create the order ---
            String orderId = generateOrderId();
            System.out.println("Generated Order ID: " + orderId);

            Order order = new Order(orderId, firstName, lastName, email,
                    phone, address, city, productNames.toString(), totalAmount);

            if (storeUsername != null) order.setStoreUsername(storeUsername);
            if (storeId > 0) order.setStoreId(storeId);

            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser != null) {
                order.setBuyerId(currentUser.getUserId());
                System.out.println("Order linked to user ID: " + currentUser.getUserId());
            }

            boolean saved = orderDAO.createOrder(order);
            if (!saved) {
                System.err.println("Failed to save order to database");
                response.sendRedirect("checkout.html?error=database_error");
                return;
            }
            System.out.println("Order saved: " + orderId);

            // --- 6. Create order_items for each cart item ---
            for (CartItem item : cart.values()) {
                if (item.getStoreId() <= 0) {
                    System.err.println("Skipping order_item for product " + item.getProductId() + " — no store_id");
                    continue;
                }
                try {
                    BigDecimal unitPrice = BigDecimal.valueOf(item.getPrice()).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal itemTotal = unitPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
                    OrderItem orderItem = new OrderItem(
                            orderId,
                            item.getStoreId(),
                            item.getProductId(),
                            item.getVariantId(),
                            item.getName(),
                            item.getQuantity(),
                            unitPrice,
                            itemTotal
                    );
                    orderDAO.createOrderItem(orderItem);
                } catch (Exception e) {
                    System.err.println("Failed to create order_item for product " + item.getProductId() + ": " + e.getMessage());
                }
            }

            // Store order in session for PayHere servlet
            session.setAttribute("currentOrder", order);

            // Redirect to PayHere servlet for payment processing
            response.sendRedirect("payhere?order_id=" + orderId);

        } catch (Exception e) {
            System.err.println("Error processing checkout: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("checkout.html?error=server_error");
        }
    }

    /**
     * Safely read the cart from the session, handling both the old integer-keyed
     * format and the current String-keyed format.
     */
    @SuppressWarnings("unchecked")
    private Map<String, CartItem> getCartFromSession(HttpSession session) {
        Object obj = session.getAttribute("cart");
        if (!(obj instanceof Map<?, ?>)) return null;
        Map<?, ?> rawMap = (Map<?, ?>) obj;
        if (rawMap.isEmpty()) return (Map<String, CartItem>) rawMap;
        if (!(rawMap.keySet().iterator().next() instanceof String)) return null;
        return (Map<String, CartItem>) rawMap;
    }

    /**
     * Generate a unique order ID.
     * Format: DF-XXXXXXXX (8 character hex)
     */
    private String generateOrderId() {
        String uuid = UUID.randomUUID().toString().replace("-", "");
        return "DF-" + uuid.substring(0, 8).toUpperCase();
    }

    /**
     * Check if a string is null or empty.
     */
    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to checkout page
        response.sendRedirect("checkout.html");
    }
}
