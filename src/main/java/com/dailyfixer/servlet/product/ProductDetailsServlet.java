package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.util.PurchaseLimitUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/product_details")
public class ProductDetailsServlet extends HttpServlet {

    private static final String SESSION_USER_LAT = "userLat";
    private static final String SESSION_USER_LNG = "userLng";
    private static final double PURCHASE_RADIUS_KM = 10.0;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productIdParam = request.getParameter("productId");
        if (productIdParam == null || productIdParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/pages/stores/store_main.jsp");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/pages/stores/store_main.jsp");
            return;
        }

        try {
            ProductDAO productDAO = new ProductDAO();
            ProductVariantDAO variantDAO = new ProductVariantDAO();
            DiscountDAO discountDAO = new DiscountDAO();

            Product product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/pages/stores/store_main.jsp");
                return;
            }

            List<ProductVariant> variants = new ArrayList<>();
            try {
                List<ProductVariant> loaded = variantDAO.getVariantsByProductId(productId);
                if (loaded != null) {
                    variants = loaded;
                }
            } catch (Exception ignored) {
                // Keep page usable even if variants fail to load.
            }

            boolean hasVariants = !variants.isEmpty();
            boolean outOfStock = product.getQuantity() <= 0;
            if (hasVariants) {
                outOfStock = true;
                for (ProductVariant v : variants) {
                    if (v.getQuantity() > 0) {
                        outOfStock = false;
                        break;
                    }
                }
            }

            Set<String> colors = new LinkedHashSet<>();
            Set<String> sizes = new LinkedHashSet<>();
            Set<String> powers = new LinkedHashSet<>();
            for (ProductVariant v : variants) {
                if (v.getColor() != null && !v.getColor().trim().isEmpty()) {
                    colors.add(v.getColor());
                }
                if (v.getSize() != null && !v.getSize().trim().isEmpty()) {
                    sizes.add(v.getSize());
                }
                if (v.getPower() != null && !v.getPower().trim().isEmpty()) {
                    powers.add(v.getPower());
                }
            }

            Discount activeDiscount = null;
            double originalPrice = product.getPrice();
            double displayPrice = product.getPrice();

            if (hasVariants && product.getPrice() == 0.00) {
                ProductVariant firstVariant = variants.get(0);
                if (firstVariant.getPrice() != null) {
                    originalPrice = firstVariant.getPrice().doubleValue();
                    displayPrice = originalPrice;

                    activeDiscount = discountDAO.getActiveDiscountForVariant(firstVariant.getVariantId());
                    if (activeDiscount != null && activeDiscount.isValid()) {
                        displayPrice = activeDiscount.calculateDiscountedPrice(originalPrice);
                    } else {
                        activeDiscount = discountDAO.getActiveDiscountForProduct(product.getProductId());
                        if (activeDiscount != null && activeDiscount.isValid()) {
                            displayPrice = activeDiscount.calculateDiscountedPrice(originalPrice);
                        }
                    }
                }
            } else {
                activeDiscount = discountDAO.getActiveDiscountForProduct(product.getProductId());
                if (activeDiscount != null && activeDiscount.isValid()) {
                    originalPrice = product.getPrice();
                    displayPrice = activeDiscount.calculateDiscountedPrice(originalPrice);
                }
            }

            User currentUser = (User) request.getSession().getAttribute("currentUser");
            boolean isLoggedIn = currentUser != null;

            String currentPageUrl = request.getRequestURI();
            if (request.getQueryString() != null && !request.getQueryString().isEmpty()) {
                currentPageUrl += "?" + request.getQueryString();
            }
            String loginUrl = request.getContextPath() + "/pages/authentication/login.jsp?redirect=" +
                    URLEncoder.encode(currentPageUrl, StandardCharsets.UTF_8);

            StoreDAO storeDAO = new StoreDAO();
            Store store = null;
            if (product.getStoreId() > 0) {
                store = storeDAO.getStoreById(product.getStoreId());
            }
            if (store == null && product.getStoreUsername() != null && !product.getStoreUsername().isBlank()) {
                store = storeDAO.getStoreByUsername(product.getStoreUsername());
            }
            String storePhone = null;
            if (store != null) {
                try {
                    User storeUser = new UserDAO().getUserById(store.getUserId());
                    if (storeUser != null) {
                        storePhone = storeUser.getPhoneNumber();
                    }
                } catch (Exception ignored) {
                }
            }
            Double userLat = getSessionDouble(request, SESSION_USER_LAT);
            Double userLng = getSessionDouble(request, SESSION_USER_LNG);

            boolean hasLocation = userLat != null && userLng != null;
            boolean hasStoreCoordinates = store != null && store.getLatitude() != 0.0 && store.getLongitude() != 0.0;
            boolean canPurchase = false;
            String purchaseLockMessage;
            double currentCartTotal = getCartSubtotal(request);

            if (!hasLocation) {
                purchaseLockMessage = "Set your location to enable purchases.";
            } else if (!hasStoreCoordinates) {
                purchaseLockMessage = "Purchase is unavailable because this store location is not configured.";
            } else {
                double distanceKm = haversineKm(userLat, userLng, store.getLatitude(), store.getLongitude());
                canPurchase = distanceKm <= PURCHASE_RADIUS_KM;
                if (canPurchase) {
                    purchaseLockMessage = "";
                } else {
                    purchaseLockMessage = "This store is outside your " + ((int) PURCHASE_RADIUS_KM) + "km purchase radius.";
                }
            }

            request.setAttribute("product", product);
            request.setAttribute("variants", variants);
            request.setAttribute("hasVariants", hasVariants);
            request.setAttribute("outOfStock", outOfStock);
            request.setAttribute("colors", colors);
            request.setAttribute("sizes", sizes);
            request.setAttribute("powers", powers);
            request.setAttribute("activeDiscount", activeDiscount);
            request.setAttribute("displayPrice", displayPrice);
            request.setAttribute("originalPrice", originalPrice);
            request.setAttribute("isLoggedIn", isLoggedIn);
            request.setAttribute("loginUrl", loginUrl);
            request.setAttribute("canPurchase", canPurchase);
            request.setAttribute("purchaseLockMessage", purchaseLockMessage);
            request.setAttribute("currentCartTotal", currentCartTotal);
            request.setAttribute("purchaseLimit", PurchaseLimitUtil.purchaseLimitValue());
            request.setAttribute("variantDataJson", buildVariantDataJson(variants, product.getProductId(), discountDAO));
            request.setAttribute("baseDiscountJson", buildDiscountJson(activeDiscount));
            request.setAttribute("store", store);
            request.setAttribute("storePhone", storePhone);

            request.getRequestDispatcher("/pages/stores/product_details.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Failed to load product details", e);
        }
    }

    private String buildVariantDataJson(List<ProductVariant> variants, int productId, DiscountDAO discountDAO) {
        StringBuilder sb = new StringBuilder();
        sb.append("[");

        for (int i = 0; i < variants.size(); i++) {
            ProductVariant v = variants.get(i);
            Discount variantDiscount = null;
            Discount productDiscount = null;

            try {
                variantDiscount = discountDAO.getActiveDiscountForVariant(v.getVariantId());
                if (variantDiscount == null || !variantDiscount.isValid()) {
                    productDiscount = discountDAO.getActiveDiscountForProduct(productId);
                }
            } catch (Exception ignored) {
                // Keep building JSON even when discount lookup fails.
            }

            Discount active = (variantDiscount != null && variantDiscount.isValid())
                    ? variantDiscount
                    : ((productDiscount != null && productDiscount.isValid()) ? productDiscount : null);

            double variantPrice = v.getPrice() != null ? v.getPrice().doubleValue() : 0.0;
            double variantDisplayPrice = active != null ? active.calculateDiscountedPrice(variantPrice) : variantPrice;

            sb.append("{")
              .append("\"id\":").append(v.getVariantId()).append(",")
              .append("\"color\":\"").append(escapeJson(v.getColor())).append("\",")
              .append("\"size\":\"").append(escapeJson(v.getSize())).append("\",")
              .append("\"power\":\"").append(escapeJson(v.getPower())).append("\",")
              .append("\"price\":").append(variantPrice).append(",")
              .append("\"displayPrice\":").append(variantDisplayPrice).append(",")
              .append("\"quantity\":").append(v.getQuantity()).append(",")
              .append("\"discount\":").append(buildDiscountJson(active)).append(",")
              .append("\"imagePath\":\"").append(escapeJson(v.getImagePath())).append("\"")
              .append("}");

            if (i < variants.size() - 1) {
                sb.append(",");
            }
        }

        sb.append("]");
        return sb.toString();
    }

    private String buildDiscountJson(Discount discount) {
        if (discount == null || !discount.isValid()) {
            return "null";
        }

        BigDecimal value = discount.getDiscountValue() != null ? discount.getDiscountValue() : BigDecimal.ZERO;

        return "{"
                + "\"name\":\"" + escapeJson(discount.getDiscountName()) + "\"," 
                + "\"type\":\"" + escapeJson(discount.getDiscountType()) + "\"," 
                + "\"value\":" + value.doubleValue() + ","
                + "\"isValid\":true"
                + "}";
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private Double getSessionDouble(HttpServletRequest request, String key) {
        Object value = request.getSession().getAttribute(key);
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

    private double getCartSubtotal(HttpServletRequest request) {
        Object cartObj = request.getSession().getAttribute("cart");
        if (!(cartObj instanceof Map<?, ?>)) {
            return 0.0;
        }

        Map<?, ?> rawCart = (Map<?, ?>) cartObj;
        if (!rawCart.isEmpty() && !(rawCart.keySet().iterator().next() instanceof String)) {
            return 0.0;
        }

        @SuppressWarnings("unchecked")
        Map<String, CartItem> cart = (Map<String, CartItem>) rawCart;
        return PurchaseLimitUtil.cartSubtotal(cart.values()).doubleValue();
    }
}
