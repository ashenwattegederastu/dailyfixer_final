package com.dailyfixer.servlet.cart;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.model.CartItem;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.util.PurchaseLimitUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.Map;

@WebServlet("/updateCartQuantity")
public class UpdateCartQuantityServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            String variantIdStr = request.getParameter("variantId");
            String cartKeyStr = request.getParameter("cartKey");

            if (productIdStr == null || quantityStr == null ||
                    productIdStr.isBlank() || quantityStr.isBlank()) {
                out.print("{\"error\":\"Invalid request\"}");
                return;
            }

            int productId = Integer.parseInt(productIdStr);
            int quantity = Integer.parseInt(quantityStr);

            if (quantity < 1) {
                out.print("{\"error\":\"Quantity must be at least 1\"}");
                return;
            }

            HttpSession session = request.getSession();
            @SuppressWarnings("unchecked")
            Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");

            if (cart == null || cart.isEmpty()) {
                out.print("{\"error\":\"Cart is empty\"}");
                return;
            }

            // Resolve String cart key — prefer explicit cartKey param, then derive from variant/product
            String cartKey;
            if (cartKeyStr != null && !cartKeyStr.isBlank()) {
                // Accept both legacy numeric and new prefixed format
                cartKey = cartKeyStr.startsWith("V-") || cartKeyStr.startsWith("P-")
                        ? cartKeyStr
                        : (variantIdStr != null && !variantIdStr.isBlank()
                                ? "V-" + variantIdStr
                                : "P-" + productId);
            } else if (variantIdStr != null && !variantIdStr.isBlank()) {
                cartKey = "V-" + variantIdStr;
            } else {
                cartKey = "P-" + productId;
            }

            if (!cart.containsKey(cartKey)) {
                out.print("{\"error\":\"Item not found in cart\"}");
                return;
            }

            CartItem item = cart.get(cartKey);
            
            // Validate stock - check variant stock if variant exists, otherwise check product stock
            int stock;
            if (item.getVariantId() != null) {
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                ProductVariant variant = variantDAO.getVariantById(item.getVariantId());
                
                if (variant == null) {
                    out.print("{\"error\":\"Variant not found\"}");
                    return;
                }
                
                stock = variant.getQuantity();
            } else {
                ProductDAO dao = new ProductDAO();
                Product product = dao.getProductById(productId);
                
                if (product == null) {
                    out.print("{\"error\":\"Product not found\"}");
                    return;
                }
                
                stock = product.getQuantity();
            }

            if (stock <= 0) {
                out.print("{\"error\":\"Product is out of stock\"}");
                return;
            }

            if (quantity > stock) {
                out.print("{\"error\":\"Requested quantity exceeds stock\"}");
                return;
            }

            if (PurchaseLimitUtil.isLineTotalOverLimit(item.getPrice(), quantity)) {
                out.print("{\"error\":\"This item exceeds the Rs 10,000 purchase limit\"}");
                return;
            }

            BigDecimal cartSubtotal = PurchaseLimitUtil.cartSubtotal(cart.values())
                    .subtract(PurchaseLimitUtil.lineTotal(item.getPrice(), item.getQuantity()));
            BigDecimal proposedSubtotal = cartSubtotal.add(PurchaseLimitUtil.lineTotal(item.getPrice(), quantity));
            if (proposedSubtotal.compareTo(PurchaseLimitUtil.PURCHASE_LIMIT) > 0) {
                out.print("{\"error\":\"This order exceeds the Rs 10,000 purchase limit\"}");
                return;
            }

            item.setQuantity(quantity);

            session.setAttribute("cart", cart);

            int cartCount = 0;
            for (CartItem ci : cart.values()) {
                cartCount += ci.getQuantity();
            }

            out.print("{\"cartCount\":" + cartCount + ",\"quantity\":" + item.getQuantity() + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}

