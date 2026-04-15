package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.model.ProductVariant;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.dailyfixer.util.DBConnection;

public class DeleteProductServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("productId"));
            
            // First, delete discount links for variants of this product
            List<Integer> discountIdsToCheck = new ArrayList<>();
            try {
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                List<ProductVariant> variants = variantDAO.getVariantsByProductId(id);
                if (variants != null && !variants.isEmpty()) {
                    // Delete discount links for each variant
                    String deleteVariantDiscountsSql = "DELETE FROM discount_variants WHERE variant_id = ?";
                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement stmt = conn.prepareStatement(deleteVariantDiscountsSql)) {
                        for (ProductVariant variant : variants) {
                            stmt.setInt(1, variant.getVariantId());
                            stmt.addBatch();
                        }
                        stmt.executeBatch();
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                // Continue even if discount link deletion fails
            }
            
            // Delete discount links for the product itself and get discount IDs to check
            try {
                // First, get all discount IDs linked to this product
                String getDiscountIdsSql = "SELECT DISTINCT discount_id FROM discount_products WHERE product_id = ?";
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement stmt = conn.prepareStatement(getDiscountIdsSql)) {
                    stmt.setInt(1, id);
                    ResultSet rs = stmt.executeQuery();
                    while (rs.next()) {
                        discountIdsToCheck.add(rs.getInt("discount_id"));
                    }
                }
                
                // Delete discount links for the product
                String deleteProductDiscountsSql = "DELETE FROM discount_products WHERE product_id = ?";
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement stmt = conn.prepareStatement(deleteProductDiscountsSql)) {
                    stmt.setInt(1, id);
                    stmt.executeUpdate();
                }
            } catch (Exception e) {
                e.printStackTrace();
                // Continue even if discount link deletion fails
            }
            
            // Delete all variants associated with this product
            try {
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                variantDAO.deleteVariantsByProductId(id);
            } catch (Exception e) {
                e.printStackTrace();
                // Continue with product deletion even if variant deletion fails
            }
            
            // Finally, delete the product
            new ProductDAO().deleteProduct(id);
            
            // Delete discounts that have no products or variants left
            try {
                DiscountDAO discountDAO = new DiscountDAO();
                for (Integer discountId : discountIdsToCheck) {
                    // Check if discount has any products or variants left
                    List<Integer> remainingProducts = discountDAO.getProductIdsForDiscount(discountId);
                    List<Integer> remainingVariants = discountDAO.getVariantIdsForDiscount(discountId);
                    
                    if ((remainingProducts == null || remainingProducts.isEmpty()) && 
                        (remainingVariants == null || remainingVariants.isEmpty())) {
                        // No products or variants left, delete the discount
                        discountDAO.deleteDiscount(discountId);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                // Continue even if discount deletion fails
            }
            
            response.sendRedirect(request.getContextPath() + "/ListProductsServlet?deleted=success");

        } catch (Exception e) { 
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ListProductsServlet?deleted=error");
        }
    }
}
