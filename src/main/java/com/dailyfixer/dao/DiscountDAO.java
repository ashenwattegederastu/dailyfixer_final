package com.dailyfixer.dao;

import com.dailyfixer.model.Discount;
import com.dailyfixer.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DiscountDAO {

    // Create a new discount
    public int addDiscount(Discount discount) throws Exception {
        String sql = "INSERT INTO discounts (discount_name, discount_type, discount_value, start_date, end_date, store_username, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, discount.getDiscountName());
            stmt.setString(2, discount.getDiscountType());
            stmt.setBigDecimal(3, discount.getDiscountValue());
            stmt.setTimestamp(4, discount.getStartDate());
            stmt.setTimestamp(5, discount.getEndDate());
            stmt.setString(6, discount.getStoreUsername());
            stmt.setBoolean(7, discount.isActive());
            
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    // Get all discounts for a store
    public List<Discount> getAllDiscounts(String storeUsername) throws Exception {
        List<Discount> discounts = new ArrayList<>();
        String sql = "SELECT * FROM discounts WHERE store_username = ? ORDER BY discount_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, storeUsername);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                discounts.add(mapResultSetToDiscount(rs));
            }
        }
        return discounts;
    }

    // Get active discount for a product
    public Discount getActiveDiscountForProduct(int productId) throws Exception {
        String sql = "SELECT d.* FROM discounts d " +
                     "INNER JOIN discount_products dp ON d.discount_id = dp.discount_id " +
                     "WHERE dp.product_id = ? AND d.is_active = 1 " +
                     "AND (d.start_date IS NULL OR d.start_date <= NOW()) " +
                     "AND (d.end_date IS NULL OR d.end_date >= NOW()) " +
                     "ORDER BY d.discount_id DESC LIMIT 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, productId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToDiscount(rs);
            }
        }
        return null;
    }

    // Get active discount for a variant
    public Discount getActiveDiscountForVariant(int variantId) throws Exception {
        String sql = "SELECT d.* FROM discounts d " +
                     "INNER JOIN discount_variants dv ON d.discount_id = dv.discount_id " +
                     "WHERE dv.variant_id = ? AND d.is_active = 1 " +
                     "AND (d.start_date IS NULL OR d.start_date <= NOW()) " +
                     "AND (d.end_date IS NULL OR d.end_date >= NOW()) " +
                     "ORDER BY d.discount_id DESC LIMIT 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, variantId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToDiscount(rs);
            }
        }
        return null;
    }

    // Get discount by ID
    public Discount getDiscountById(int discountId) throws Exception {
        String sql = "SELECT * FROM discounts WHERE discount_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, discountId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToDiscount(rs);
            }
        }
        return null;
    }

    // Update discount
    public void updateDiscount(Discount discount) throws Exception {
        String sql = "UPDATE discounts SET discount_name = ?, discount_type = ?, discount_value = ?, " +
                     "start_date = ?, end_date = ?, is_active = ? WHERE discount_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, discount.getDiscountName());
            stmt.setString(2, discount.getDiscountType());
            stmt.setBigDecimal(3, discount.getDiscountValue());
            stmt.setTimestamp(4, discount.getStartDate());
            stmt.setTimestamp(5, discount.getEndDate());
            stmt.setBoolean(6, discount.isActive());
            stmt.setInt(7, discount.getDiscountId());
            
            stmt.executeUpdate();
        }
    }

    // Delete discount
    public void deleteDiscount(int discountId) throws Exception {
        String sql = "DELETE FROM discounts WHERE discount_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, discountId);
            stmt.executeUpdate();
        }
    }

    // Link discount to products
    public void linkDiscountToProducts(int discountId, List<Integer> productIds) throws Exception {
        // First, remove existing links
        String deleteSql = "DELETE FROM discount_products WHERE discount_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
            
            deleteStmt.setInt(1, discountId);
            deleteStmt.executeUpdate();
        }

        // Then, add new links
        if (productIds != null && !productIds.isEmpty()) {
            String insertSql = "INSERT INTO discount_products (discount_id, product_id) VALUES (?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                
                for (Integer productId : productIds) {
                    insertStmt.setInt(1, discountId);
                    insertStmt.setInt(2, productId);
                    insertStmt.addBatch();
                }
                insertStmt.executeBatch();
            }
        }
    }

    // Link discount to variants
    public void linkDiscountToVariants(int discountId, List<Integer> variantIds) throws Exception {
        // First, remove existing links
        String deleteSql = "DELETE FROM discount_variants WHERE discount_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
            
            deleteStmt.setInt(1, discountId);
            deleteStmt.executeUpdate();
        }

        // Then, add new links
        if (variantIds != null && !variantIds.isEmpty()) {
            String insertSql = "INSERT INTO discount_variants (discount_id, variant_id) VALUES (?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                
                for (Integer variantId : variantIds) {
                    insertStmt.setInt(1, discountId);
                    insertStmt.setInt(2, variantId);
                    insertStmt.addBatch();
                }
                insertStmt.executeBatch();
            }
        }
    }

    // Get product IDs linked to a discount
    public List<Integer> getProductIdsForDiscount(int discountId) throws Exception {
        List<Integer> productIds = new ArrayList<>();
        String sql = "SELECT product_id FROM discount_products WHERE discount_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, discountId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                productIds.add(rs.getInt("product_id"));
            }
        }
        return productIds;
    }

    // Get variant IDs linked to a discount
    public List<Integer> getVariantIdsForDiscount(int discountId) throws Exception {
        List<Integer> variantIds = new ArrayList<>();
        String sql = "SELECT variant_id FROM discount_variants WHERE discount_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, discountId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                variantIds.add(rs.getInt("variant_id"));
            }
        }
        return variantIds;
    }

    // Helper method to map ResultSet to Discount object
    private Discount mapResultSetToDiscount(ResultSet rs) throws SQLException {
        Discount discount = new Discount();
        discount.setDiscountId(rs.getInt("discount_id"));
        discount.setDiscountName(rs.getString("discount_name"));
        discount.setDiscountType(rs.getString("discount_type"));
        discount.setDiscountValue(rs.getBigDecimal("discount_value"));
        discount.setStartDate(rs.getTimestamp("start_date"));
        discount.setEndDate(rs.getTimestamp("end_date"));
        discount.setStoreUsername(rs.getString("store_username"));
        discount.setActive(rs.getBoolean("is_active"));
        return discount;
    }
}
