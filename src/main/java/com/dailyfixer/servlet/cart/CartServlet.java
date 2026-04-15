package com.dailyfixer.servlet.cart;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;
import com.dailyfixer.util.ProductDisplayUtil;
import com.dailyfixer.util.PurchaseLimitUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/addToCart")
public class CartServlet extends HttpServlet {

    private static final String SESSION_USER_LAT = "userLat";
    private static final String SESSION_USER_LNG = "userLng";
    private static final double PURCHASE_RADIUS_KM = 10.0;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        // Check if user is logged in
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("{\"error\":\"Please login before purchasing products\"}");
            return;
        }

        Map<String, CartItem> cart;
        Object obj = session.getAttribute("cart");

        if (obj instanceof Map<?, ?>) {
            Map<?, ?> rawMap = (Map<?, ?>) obj;
            if (!rawMap.isEmpty() && !(rawMap.keySet().iterator().next() instanceof String)) {
                // Old integer-keyed cart from before the fix — discard it
                cart = new HashMap<>();
            } else {
                @SuppressWarnings("unchecked")
                Map<String, CartItem> tempCart = (Map<String, CartItem>) rawMap;
                cart = tempCart;
            }
        } else {
            cart = new HashMap<>();
        }

        try {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            String variantIdStr = request.getParameter("variantId");

            if (productIdStr == null || quantityStr == null ||
                    productIdStr.isBlank() || quantityStr.isBlank()) {
                out.print("{\"error\":\"Invalid request\"}");
                return;
            }

            int productId = Integer.parseInt(productIdStr);
            int quantity = Integer.parseInt(quantityStr);
            Integer variantId = null;
            if (variantIdStr != null && !variantIdStr.isBlank()) {
                variantId = Integer.parseInt(variantIdStr);
            }

            ProductDAO dao = new ProductDAO();
            Product product = dao.getProductById(productId);

            if (product == null) {
                out.print("{\"error\":\"Product not found\"}");
                return;
            }

            Double userLat = getSessionDouble(session, SESSION_USER_LAT);
            Double userLng = getSessionDouble(session, SESSION_USER_LNG);
            if (userLat == null || userLng == null) {
                out.print("{\"error\":\"Set your location to enable purchases\"}");
                return;
            }

            StoreDAO storeDAO = new StoreDAO();
            Store store = null;
            if (product.getStoreId() > 0) {
                store = storeDAO.getStoreById(product.getStoreId());
            } else if (product.getStoreUsername() != null && !product.getStoreUsername().isBlank()) {
                store = storeDAO.getStoreByUsername(product.getStoreUsername());
            }

            if (store == null || store.getLatitude() == 0.0 || store.getLongitude() == 0.0) {
                out.print("{\"error\":\"Purchase is unavailable because this store location is not configured\"}");
                return;
            }

            double distanceKm = haversineKm(userLat, userLng, store.getLatitude(), store.getLongitude());
            if (distanceKm > PURCHASE_RADIUS_KM) {
                out.print("{\"error\":\"This store is outside your 10km purchase radius\"}");
                return;
            }

            double price = product.getPrice();
            int stock = product.getQuantity();
            String variantColor = null;
            String variantSize = null;
            String variantPower = null;
            ProductVariant selectedVariant = null;

            // If variant is selected, use variant price and stock
            if (variantId != null) {
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                selectedVariant = variantDAO.getVariantById(variantId);

                if (selectedVariant == null || selectedVariant.getProductId() != productId) {
                    out.print("{\"error\":\"Invalid variant\"}");
                    return;
                }

                price = selectedVariant.getPrice().doubleValue();
                stock = selectedVariant.getQuantity();
                variantColor = selectedVariant.getColor();
                variantSize = selectedVariant.getSize();
                variantPower = selectedVariant.getPower();
            }

            String cartImagePath = ProductDisplayUtil.resolveCartThumbnailPath(product, selectedVariant);

            // Stock check
            if (stock <= 0) {
                out.print("{\"error\":\"Product is out of stock\"}");
                return;
            }

            if (quantity > stock) {
                out.print("{\"error\":\"Requested quantity exceeds stock\"}");
                return;
            }

            // Use prefixed string keys to prevent variant/product ID collision
            String cartKey = variantId != null ? "V-" + variantId : "P-" + productId;

            // Resolve store info — use store_id from product, fall back to StoreDAO lookup
            int storeId = product.getStoreId();
            String storeUsername = product.getStoreUsername();
            if (store != null && storeId <= 0) {
                storeId = store.getStoreId();
            } else if (storeId <= 0 && storeUsername != null && !storeUsername.isBlank()) {
                Store fallbackStore = storeDAO.getStoreByUsername(storeUsername);
                if (fallbackStore != null) {
                    storeId = fallbackStore.getStoreId();
                }
            }

            // Check for active discount
            double originalPrice = price;
            double discountedPrice = price;
            double discountAmount = 0;
            String discountName = null;
            String discountType = null;
            
            try {
                DiscountDAO discountDAO = new DiscountDAO();
                Discount discount = null;
                
                if (variantId != null) {
                    // First check for variant-specific discount
                    discount = discountDAO.getActiveDiscountForVariant(variantId);
                    // If no variant discount, check for product-level discount
                    if (discount == null || !discount.isValid()) {
                        discount = discountDAO.getActiveDiscountForProduct(productId);
                    }
                } else {
                    discount = discountDAO.getActiveDiscountForProduct(productId);
                }
                
                if (discount != null && discount.isValid()) {
                    originalPrice = price;
                    discountedPrice = discount.calculateDiscountedPrice(price);
                    discountAmount = originalPrice - discountedPrice;
                    discountName = discount.getDiscountName();
                    discountType = discount.getDiscountType();
                }
            } catch (Exception e) {
                // If discount check fails, use original price
                e.printStackTrace();
            }

            CartItem item = cart.get(cartKey);
            int proposedQuantity = item == null ? quantity : item.getQuantity() + quantity;

            if (PurchaseLimitUtil.isLineTotalOverLimit(discountedPrice, proposedQuantity)) {
                out.print("{\"error\":\"This item exceeds the Rs 10,000 purchase limit\"}");
                return;
            }

            BigDecimal cartSubtotal = PurchaseLimitUtil.cartSubtotal(cart.values());
            if (item != null) {
                cartSubtotal = cartSubtotal.subtract(PurchaseLimitUtil.lineTotal(item.getPrice(), item.getQuantity()));
            }
            BigDecimal proposedSubtotal = cartSubtotal.add(PurchaseLimitUtil.lineTotal(discountedPrice, proposedQuantity));
            if (proposedSubtotal.compareTo(PurchaseLimitUtil.PURCHASE_LIMIT) > 0) {
                out.print("{\"error\":\"This order exceeds the Rs 10,000 purchase limit\"}");
                return;
            }

            if (item == null) {
                item = new CartItem(
                        product.getProductId(),
                        product.getName(),
                        discountedPrice,
                        originalPrice,
                        quantity,
                        cartImagePath,
                        variantId,
                        variantColor,
                        variantSize,
                        variantPower,
                        discountAmount,
                        discountName,
                        discountType
                );
                item.setStoreId(storeId);
                item.setStoreUsername(storeUsername);
                cart.put(cartKey, item);
            } else {
                item.setQuantity(Math.min(proposedQuantity, stock));
                item.setImagePath(cartImagePath);
                // Update discount info if it changed
                if (discountName != null) {
                    item.setOriginalPrice(originalPrice);
                    item.setPrice(discountedPrice);
                    item.setDiscountAmount(discountAmount);
                    item.setDiscountName(discountName);
                    item.setDiscountType(discountType);
                }
            }

            session.setAttribute("cart", cart);

            int cartCount = cart.values()
                    .stream()
                    .mapToInt(CartItem::getQuantity)
                    .sum();

            out.print("{\"cartCount\":" + cartCount + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
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
}
