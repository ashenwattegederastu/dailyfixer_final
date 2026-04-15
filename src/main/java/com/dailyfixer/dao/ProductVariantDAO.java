package com.dailyfixer.dao;

import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductVariantDAO {

    // Get all variants for a product
    public List<ProductVariant> getVariantsByProductId(int productId) throws Exception {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT * FROM product_variants WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, productId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ProductVariant variant = new ProductVariant();
                variant.setVariantId(rs.getInt("variant_id"));
                variant.setProductId(rs.getInt("product_id"));
                variant.setColor(rs.getString("color"));
                variant.setSize(rs.getString("size"));
                variant.setPower(rs.getString("power"));
                variant.setPrice(rs.getBigDecimal("price"));
                variant.setQuantity(rs.getInt("quantity"));
                variant.setImagePath(rs.getString("image_path"));
                variants.add(variant);
            }

        }
        return variants;
    }

    // Get a variant by ID
    public ProductVariant getVariantById(int variantId) throws Exception {
        String sql = "SELECT * FROM product_variants WHERE variant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, variantId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                ProductVariant variant = new ProductVariant();
                variant.setVariantId(rs.getInt("variant_id"));
                variant.setProductId(rs.getInt("product_id"));
                variant.setColor(rs.getString("color"));
                variant.setSize(rs.getString("size"));
                variant.setPower(rs.getString("power"));
                variant.setPrice(rs.getBigDecimal("price"));
                variant.setQuantity(rs.getInt("quantity"));
                variant.setImagePath(rs.getString("image_path"));
                return variant;
            }
        }
        return null;
    }

    // Add a new variant
    public int addVariantAndReturnId(ProductVariant variant) throws Exception {
        String sql = "INSERT INTO product_variants (product_id, color, size, power, price, quantity, image_path) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, variant.getProductId());
            stmt.setString(2, variant.getColor());
            stmt.setString(3, variant.getSize());
            stmt.setString(4, variant.getPower());
            stmt.setBigDecimal(5, variant.getPrice());
            stmt.setInt(6, variant.getQuantity());
            stmt.setString(7, variant.getImagePath());
            stmt.executeUpdate();

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public void addVariant(ProductVariant variant) throws Exception {
        addVariantAndReturnId(variant);
    }

    // Update a variant
    public void updateVariant(ProductVariant variant) throws Exception {
        String sql = "UPDATE product_variants SET color = ?, size = ?, power = ?, price = ?, quantity = ?, image_path = ? WHERE variant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, variant.getColor());
            stmt.setString(2, variant.getSize());
            stmt.setString(3, variant.getPower());
            stmt.setBigDecimal(4, variant.getPrice());
            stmt.setInt(5, variant.getQuantity());
            stmt.setString(6, variant.getImagePath());
            stmt.setInt(7, variant.getVariantId());
            stmt.executeUpdate();
        }
    }

    /**
     * Reduce variant quantity by the specified amount.
     * 
     * @param variantId The variant ID
     * @param quantityToReduce The quantity to reduce
     * @return true if successful, false otherwise
     */
    public boolean reduceVariantQuantity(int variantId, int quantityToReduce) {
        String sql = "UPDATE product_variants SET quantity = quantity - ? WHERE variant_id = ? AND quantity >= ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantityToReduce);
            stmt.setInt(2, variantId);
            stmt.setInt(3, quantityToReduce);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Reduced stock for variant ID " + variantId + " by " + quantityToReduce);
                return true;
            }
            System.err.println("Insufficient stock for variant ID " + variantId + " (requested: " + quantityToReduce + ")");
            return false;
        } catch (Exception e) {
            System.err.println("Error reducing variant quantity: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean restoreVariantQuantity(int variantId, int quantityToRestore) {
        String sql = "UPDATE product_variants SET quantity = quantity + ? WHERE variant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantityToRestore);
            stmt.setInt(2, variantId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Restored stock for variant ID " + variantId + " by " + quantityToRestore);
                return true;
            }
            System.err.println("Failed to restore stock for variant ID " + variantId);
            return false;
        } catch (Exception e) {
            System.err.println("Error restoring variant quantity: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Delete a variant
    public void deleteVariant(int variantId) throws Exception {
        String sql = "DELETE FROM product_variants WHERE variant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, variantId);
            stmt.executeUpdate();
        }
    }

    // Delete all variants for a product
    public void deleteVariantsByProductId(int productId) throws Exception {
        String sql = "DELETE FROM product_variants WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, productId);
            stmt.executeUpdate();
        }
    }
}
