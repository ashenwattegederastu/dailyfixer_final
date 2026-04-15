package com.dailyfixer.servlet.payment;

import com.dailyfixer.dao.DeliveryRateDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.dao.StoreOrderDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.DeliveryRate;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.StoreOrder;
import com.dailyfixer.model.User;
import com.dailyfixer.util.DeliveryFeeCalculator;
import com.dailyfixer.util.PurchaseLimitUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * RedirectToPaymentServlet - Handles checkout form submission from
 * checkout.jsp.
 * Creates an order from cart items and redirects to PayHere payment gateway.
 *
 * URL: /redirectToPayment
 * Method: POST
 */
@WebServlet("/redirectToPayment")
public class RedirectToPaymentServlet extends HttpServlet {

    private static final String SESSION_USER_LAT = "userLat";
    private static final String SESSION_USER_LNG = "userLng";
    private static final double PURCHASE_RADIUS_KM = 10.0;

    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private StoreDAO storeDAO;
    private StoreOrderDAO storeOrderDAO;
    private DeliveryRateDAO deliveryRateDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
        storeDAO = new StoreDAO();
        storeOrderDAO = new StoreOrderDAO();
        deliveryRateDAO = new DeliveryRateDAO();
        System.out.println("RedirectToPaymentServlet initialized");
    }

    /**
     * Handle POST request from checkout form.
     * Creates order from cart items and redirects to PayHereServlet.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== RedirectToPaymentServlet: Processing checkout ===");

        // Check if user is logged in
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        try {
            // Get form parameters
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String province = request.getParameter("province");
            String district = request.getParameter("district");
            String latitude = request.getParameter("latitude");
            String longitude = request.getParameter("longitude");
                boolean doorstepDropConsent = "on".equalsIgnoreCase(request.getParameter("doorstepDropConsent"))
                    || "true".equalsIgnoreCase(request.getParameter("doorstepDropConsent"));

            // Parse customer delivery coordinates
            double customerLat = 0;
            double customerLng = 0;
            try {
                if (latitude != null && !latitude.isBlank()) customerLat = Double.parseDouble(latitude);
                if (longitude != null && !longitude.isBlank()) customerLng = Double.parseDouble(longitude);
            } catch (NumberFormatException e) {
                System.err.println("Invalid delivery coordinates: " + latitude + ", " + longitude);
            }

            // Load delivery rates once for this request
            List<DeliveryRate> activeRates = deliveryRateDAO.getActiveRates();
            BigDecimal weightedRate    = DeliveryFeeCalculator.calculateWeightedRate(activeRates);
            BigDecimal weightedBaseFee = DeliveryFeeCalculator.calculateWeightedBaseFee(activeRates);

            // Get cart items from session
            @SuppressWarnings("unchecked")
            Map<String, CartItem> itemsToCheckout = (Map<String, CartItem>) session.getAttribute("itemsToCheckout");

            // Store form data in session for repopulation on error
            session.setAttribute("checkout_name", name);
            session.setAttribute("checkout_phone", phone);
            session.setAttribute("checkout_email", email);
            session.setAttribute("checkout_address", address);
            session.setAttribute("checkout_city", city);
            session.setAttribute("checkout_province", province);
            session.setAttribute("checkout_district", district);
            session.setAttribute("checkout_doorstep_consent", doorstepDropConsent);

            // Validate required fields
            if (isEmpty(name) || isEmpty(phone) || isEmpty(email) || isEmpty(address) || isEmpty(city)) {
                System.err.println("Missing required fields");
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=missing_fields");
                return;
            }

            if (!doorstepDropConsent) {
                System.err.println("Doorstep drop consent was not accepted");
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=terms_not_accepted");
                return;
            }

            // Validate email format
            if (!isValidEmail(email)) {
                System.err.println("Invalid email format");
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=invalid_email");
                return;
            }

            // Validate cart items
            if (itemsToCheckout == null || itemsToCheckout.isEmpty()) {
                System.err.println("No items in cart");
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=empty_cart");
                return;
            }

            for (CartItem item : itemsToCheckout.values()) {
                if (PurchaseLimitUtil.isLineTotalOverLimit(item)) {
                    response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=item_price_limit_exceeded");
                    return;
                }
            }

            if (PurchaseLimitUtil.isOrderTotalOverLimit(itemsToCheckout.values())) {
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=order_price_limit_exceeded");
                return;
            }

            if (customerLat == 0 || customerLng == 0) {
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=location_required");
                return;
            }

            for (CartItem item : itemsToCheckout.values()) {
                Product product = productDAO.getProductById(item.getProductId());
                if (product == null) {
                    response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=invalid_cart");
                    return;
                }

                Store itemStore = null;
                if (product.getStoreId() > 0) {
                    itemStore = storeDAO.getStoreById(product.getStoreId());
                } else if (product.getStoreUsername() != null && !product.getStoreUsername().isBlank()) {
                    itemStore = storeDAO.getStoreByUsername(product.getStoreUsername());
                }

                if (itemStore == null || itemStore.getLatitude() == 0 || itemStore.getLongitude() == 0) {
                    response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=store_location_unavailable");
                    return;
                }

                double distanceKm = haversineKm(customerLat, customerLng, itemStore.getLatitude(), itemStore.getLongitude());
                if (distanceKm > PURCHASE_RADIUS_KM) {
                    response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=outside_purchase_radius");
                    return;
                }
            }

            // Split name into firstName and lastName
            String firstName;
            String lastName;
            String[] nameParts = name.trim().split("\\s+", 2);
            if (nameParts.length == 1) {
                firstName = nameParts[0];
                lastName = "";
            } else {
                firstName = nameParts[0];
                lastName = nameParts[1];
            }

            // Group cart items by store_username
            Map<String, List<CartItem>> itemsByStore = new HashMap<>();
            Map<String, String> storeProductNames = new HashMap<>();

            for (CartItem item : itemsToCheckout.values()) {
                // Use store_username already stored in CartItem; fall back to DB lookup if missing
                String storeUsername = item.getStoreUsername();
                if (storeUsername == null || storeUsername.isEmpty()) {
                    try {
                        Product product = productDAO.getProductById(item.getProductId());
                        if (product != null && product.getStoreUsername() != null
                                && !product.getStoreUsername().isEmpty()) {
                            storeUsername = product.getStoreUsername();
                        } else {
                            System.err.println(
                                    "Warning: Could not find store_username for product: " + item.getProductId());
                            continue; // Skip items without valid store_username
                        }
                    } catch (Exception e) {
                        System.err.println("Error getting product info for productId: " + item.getProductId() + " - "
                                + e.getMessage());
                        continue;
                    }
                }

                // Group items by store
                itemsByStore.computeIfAbsent(storeUsername, k -> new ArrayList<>()).add(item);

                // Build product names per store with variant information
                String storeProducts = storeProductNames.getOrDefault(storeUsername, "");
                if (!storeProducts.isEmpty()) {
                    storeProducts += ", ";
                }
                String itemDisplayName = item.getName();

                // Add variant information if available
                StringBuilder variantInfo = new StringBuilder();
                if (item.getVariantColor() != null && !item.getVariantColor().isEmpty()) {
                    variantInfo.append(" - Color: ").append(item.getVariantColor());
                }
                if (item.getVariantSize() != null && !item.getVariantSize().isEmpty()) {
                    variantInfo.append(" - Size: ").append(item.getVariantSize());
                }
                if (item.getVariantPower() != null && !item.getVariantPower().isEmpty()) {
                    variantInfo.append(" - Power: ").append(item.getVariantPower());
                }

                if (variantInfo.length() > 0) {
                    itemDisplayName += variantInfo.toString();
                }

                if (item.getQuantity() > 1) {
                    itemDisplayName += " (x" + item.getQuantity() + ")";
                }

                storeProducts += itemDisplayName;
                storeProductNames.put(storeUsername, storeProducts);
            }

            if (itemsByStore.isEmpty()) {
                System.err.println("No valid store items found in cart");
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=invalid_cart");
                return;
            }

            // Create separate orders for each store
            List<Order> createdOrders = new ArrayList<>();
            String primaryOrderId = null; // Use first order for payment

            for (Map.Entry<String, List<CartItem>> storeEntry : itemsByStore.entrySet()) {
                String storeUsername = storeEntry.getKey();
                List<CartItem> storeItems = storeEntry.getValue();

                // Calculate store total and build product names for this store
                BigDecimal storeTotal = BigDecimal.ZERO;
                for (CartItem item : storeItems) {
                    BigDecimal itemTotal = BigDecimal.valueOf(item.getPrice() * item.getQuantity());
                    storeTotal = storeTotal.add(itemTotal);
                }

                // Truncate product name if too long
                String storeProductName = storeProductNames.get(storeUsername);
                if (storeProductName.length() > 200) {
                    storeProductName = storeProductName.substring(0, 197) + "...";
                }

                // Generate unique order ID for this store
                String storeOrderId = generateOrderId();
                if (primaryOrderId == null) {
                    primaryOrderId = storeOrderId; // Use first order ID for payment redirect
                }

                System.out.println("Creating order for store: " + storeUsername);
                System.out.println("  Order ID: " + storeOrderId);
                System.out.println("  Products: " + storeProductName);
                System.out.println("  Store Total: " + storeTotal);

                // Get store_id from store_username
                Store store = storeDAO.getStoreByUsername(storeUsername);
                if (store == null) {
                    System.err.println("Store not found for username: " + storeUsername);
                    continue;
                }
                int storeId = store.getStoreId();

                // Calculate delivery fee for this store leg
                BigDecimal deliveryFee = BigDecimal.ZERO;
                if (customerLat != 0 && customerLng != 0 && store.getLatitude() != 0 && store.getLongitude() != 0) {
                    double distKm = DeliveryFeeCalculator.haversineDistance(
                            store.getLatitude(), store.getLongitude(), customerLat, customerLng);
                    deliveryFee = DeliveryFeeCalculator.calculateDeliveryFee(distKm, weightedBaseFee, weightedRate);
                    System.out.println("  Delivery distance: " + String.format("%.2f", distKm) + " km, fee: " + deliveryFee);
                } else {
                    System.err.println("  Warning: missing coordinates for store '" + storeUsername + "' or customer — delivery fee = 0");
                }

                // Create Order object for this store (amount = items total + delivery fee)
                BigDecimal orderTotal = storeTotal.add(deliveryFee);
                Order storeOrder = new Order(storeOrderId, firstName, lastName, email,
                        phone, address, city, storeProductName, orderTotal);
                storeOrder.setStatus("PENDING");
                storeOrder.setStoreUsername(storeUsername);
                storeOrder.setStoreId(storeId);
                storeOrder.setBuyerId(currentUser.getUserId());
                storeOrder.setDeliveryFee(deliveryFee);
                storeOrder.setDoorstepDropConsent(doorstepDropConsent);
                if (customerLat != 0) storeOrder.setDeliveryLatitude(customerLat);
                if (customerLng != 0) storeOrder.setDeliveryLongitude(customerLng);

                // Save order to database
                try {
                    boolean saved = orderDAO.createOrder(storeOrder);
                    if (!saved) {
                        System.err.println("Failed to save order for store: " + storeUsername);
                        continue;
                    }
                    createdOrders.add(storeOrder);
                    System.out.println("Order saved successfully for store: " + storeUsername);

                    // Create order_items entries for each cart item
                    for (CartItem item : storeItems) {
                        // Build product name with variant information
                        String itemProductName = item.getName();
                        StringBuilder variantInfo = new StringBuilder();
                        if (item.getVariantColor() != null && !item.getVariantColor().isEmpty()) {
                            variantInfo.append(" - Color: ").append(item.getVariantColor());
                        }
                        if (item.getVariantSize() != null && !item.getVariantSize().isEmpty()) {
                            variantInfo.append(" - Size: ").append(item.getVariantSize());
                        }
                        if (item.getVariantPower() != null && !item.getVariantPower().isEmpty()) {
                            variantInfo.append(" - Power: ").append(item.getVariantPower());
                        }
                        if (variantInfo.length() > 0) {
                            itemProductName += variantInfo.toString();
                        }

                        BigDecimal unitPrice = BigDecimal.valueOf(item.getPrice());
                        BigDecimal totalPrice = BigDecimal.valueOf(item.getPrice() * item.getQuantity());

                        OrderItem orderItem = new OrderItem(
                                storeOrderId,
                                storeId,
                                item.getProductId(),
                                item.getVariantId(),
                                itemProductName,
                                item.getQuantity(),
                                unitPrice,
                                totalPrice);
                        orderItem.setStatus("PENDING");

                        boolean itemSaved = orderDAO.createOrderItem(orderItem);
                        if (itemSaved) {
                            System.out.println(
                                    "Order item created: " + itemProductName + " (Qty: " + item.getQuantity() + ")");
                        } else {
                            System.err.println("Failed to create order item for: " + itemProductName);
                        }
                    }

                    // Create store_orders entry
                    StoreOrder storeOrderEntry = new StoreOrder(
                            storeOrderId, storeId, storeTotal,
                            BigDecimal.ZERO, storeTotal); // commission=0 for now
                    storeOrderEntry.setDeliveryFee(deliveryFee);
                    storeOrderEntry.setStatus("PENDING");
                    boolean soSaved = storeOrderDAO.createStoreOrder(storeOrderEntry);
                    if (soSaved) {
                        System.out.println("Store order entry created for store: " + storeUsername);
                    } else {
                        System.err.println("Failed to create store order entry for store: " + storeUsername);
                    }
                } catch (Exception dbEx) {
                    System.err.println("Database exception for store " + storeUsername + ": " + dbEx.getMessage());
                    dbEx.printStackTrace();
                }
            }

            if (createdOrders.isEmpty()) {
                System.err.println("Failed to create any orders");
                response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=database_error");
                return;
            }

            // Calculate combined total and product names for payment gateway
            BigDecimal combinedTotal = BigDecimal.ZERO;
            StringBuilder combinedProductNames = new StringBuilder();
            int productCount = 0;

            for (Order storeOrder : createdOrders) {
                combinedTotal = combinedTotal.add(storeOrder.getAmount());

                if (productCount > 0) {
                    combinedProductNames.append(", ");
                }
                combinedProductNames.append(storeOrder.getProductName());
                productCount++;
            }

            // Truncate combined product name if too long
            String combinedProductName = combinedProductNames.toString();
            if (combinedProductName.length() > 200) {
                combinedProductName = combinedProductName.substring(0, 197) + "...";
            }

            System.out.println("Combined total for payment: " + combinedTotal);
            System.out.println("Combined products: " + combinedProductName);

            // Create a payment order with combined total and all product names
            // Use the primary order but update it with combined totals for payment gateway
            Order paymentOrder = createdOrders.get(0); // Use first order as base
            paymentOrder.setAmount(combinedTotal); // Update with combined total
            paymentOrder.setProductName(combinedProductName); // Update with all product names

            // Store payment order in session for PayHere servlet
            request.getSession().setAttribute("currentOrder", paymentOrder);
            request.getSession().setAttribute("allOrderIds", createdOrders.stream()
                    .map(Order::getOrderId)
                    .collect(java.util.stream.Collectors.toList())); // Store all order IDs

            // Redirect to PayHere servlet for payment processing (using primary order ID)
            response.sendRedirect("payhere?order_id=" + primaryOrderId);

        } catch (Exception e) {
            System.err.println("Error processing checkout: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp?error=server_error");
        }
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

    /**
     * Validate email format.
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        // Simple email validation regex
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        return email.matches(emailRegex);
    }

    private Double getSessionDouble(HttpSession session, String key) {
        Object value = session.getAttribute(key);
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        if (value instanceof String) {
            try {
                return Double.parseDouble((String) value);
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private double haversineKm(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return 6371.0 * c;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to checkout page
        response.sendRedirect(request.getContextPath() + "/pages/stores/checkout.jsp");
    }
}
