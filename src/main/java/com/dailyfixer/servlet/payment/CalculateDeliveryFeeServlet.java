package com.dailyfixer.servlet.payment;

import com.dailyfixer.dao.DeliveryRateDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.DeliveryRate;
import com.dailyfixer.model.Store;
import com.dailyfixer.util.DeliveryFeeCalculator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * AJAX endpoint: calculates per-store delivery fees for the checkout preview.
 *
 * GET /calculateDeliveryFee?customerLat=X&customerLng=Y
 *
 * Returns JSON array:
 * [{"storeUsername":"...","storeName":"...","distanceKm":4.2,"deliveryFee":457.00}, ...]
 */
@WebServlet("/calculateDeliveryFee")
public class CalculateDeliveryFeeServlet extends HttpServlet {

    private DeliveryRateDAO deliveryRateDAO;
    private StoreDAO storeDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        deliveryRateDAO = new DeliveryRateDAO();
        storeDAO = new StoreDAO();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Not logged in\"}");
            return;
        }

        String latStr = request.getParameter("customerLat");
        String lngStr = request.getParameter("customerLng");

        if (latStr == null || latStr.isBlank() || lngStr == null || lngStr.isBlank()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Missing customerLat or customerLng\"}");
            return;
        }

        double customerLat;
        double customerLng;
        try {
            customerLat = Double.parseDouble(latStr);
            customerLng = Double.parseDouble(lngStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid coordinates\"}");
            return;
        }

        // Read cart from session (itemsToCheckout takes priority, fall back to cart)
        @SuppressWarnings("unchecked")
        Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("itemsToCheckout");
        if (cart == null || cart.isEmpty()) {
            @SuppressWarnings("unchecked")
            Map<String, CartItem> mainCart = (Map<String, CartItem>) session.getAttribute("cart");
            cart = mainCart;
        }

        if (cart == null || cart.isEmpty()) {
            out.print("[]");
            return;
        }

        // Collect unique stores from cart items
        Map<String, String> storeUserToName = new LinkedHashMap<>(); // username -> storeName
        for (CartItem item : cart.values()) {
            String su = item.getStoreUsername();
            if (su == null || su.isBlank()) {
                // Fallback: look up product in DB to get its store_username
                try {
                    Product product = productDAO.getProductById(item.getProductId());
                    if (product != null) su = product.getStoreUsername();
                } catch (Exception e) {
                    System.err.println("CalculateDeliveryFeeServlet: product lookup failed for id="
                            + item.getProductId() + ": " + e.getMessage());
                }
            }
            if (su != null && !su.isBlank() && !storeUserToName.containsKey(su)) {
                storeUserToName.put(su, su); // placeholder; overwrite below with real name
            }
        }

        // Get active delivery rates once
        List<DeliveryRate> rates = deliveryRateDAO.getActiveRates();
        BigDecimal weightedRate    = DeliveryFeeCalculator.calculateWeightedRate(rates);
        BigDecimal weightedBaseFee = DeliveryFeeCalculator.calculateWeightedBaseFee(rates);

        // Build JSON response
        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        for (String storeUsername : storeUserToName.keySet()) {
            Store store = storeDAO.getStoreByUsername(storeUsername);

            double storeLat = 0;
            double storeLng = 0;
            String storeName = storeUsername;

            if (store != null) {
                storeLat  = store.getLatitude();
                storeLng  = store.getLongitude();
                storeName = store.getStoreName();
            }

            BigDecimal deliveryFee;
            double distanceKm = 0;

            if (storeLat == 0 && storeLng == 0) {
                // Store has no coordinates — charge Rs 0 and flag it
                deliveryFee = BigDecimal.ZERO;
                System.err.println("CalculateDeliveryFeeServlet: store '" + storeUsername
                        + "' has no coordinates set. Delivery fee set to 0.");
            } else {
                distanceKm  = DeliveryFeeCalculator.haversineDistance(storeLat, storeLng, customerLat, customerLng);
                deliveryFee = DeliveryFeeCalculator.calculateDeliveryFee(distanceKm, weightedBaseFee, weightedRate);
            }

            if (!first) json.append(",");
            first = false;

            json.append("{")
                .append("\"storeUsername\":\"").append(escapeJson(storeUsername)).append("\",")
                .append("\"storeName\":\"").append(escapeJson(storeName)).append("\",")
                .append("\"distanceKm\":").append(String.format("%.2f", distanceKm)).append(",")
                .append("\"deliveryFee\":").append(deliveryFee.toPlainString())
                .append("}");
        }

        json.append("]");
        out.print(json.toString());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
