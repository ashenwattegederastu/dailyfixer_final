package com.dailyfixer.dao;

import com.dailyfixer.model.Review;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    // Add a new review
    public void addReview(Review review) throws Exception {
        String sql = "INSERT INTO product_reviews (product_id, user_id, rating, comment, created_at) VALUES (?, ?, ?, ?, NOW())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, review.getProductId());
            ps.setInt(2, review.getUserId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getComment());
            ps.executeUpdate();

            // Get generated review ID
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    review.setReviewId(rs.getInt(1));
                }
            }
        }
    }

    // Get all reviews for a product
    public List<Review> getReviewsByProductId(int productId) throws Exception {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.*, u.username " +
                     "FROM product_reviews r " +
                     "LEFT JOIN users u ON r.user_id = u.user_id " +
                     "WHERE r.product_id = ? " +
                     "ORDER BY r.created_at DESC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Review review = new Review();
                review.setReviewId(rs.getInt("review_id"));
                review.setProductId(rs.getInt("product_id"));
                review.setUserId(rs.getInt("user_id"));
                review.setUsername(rs.getString("username"));
                review.setRating(rs.getInt("rating"));
                review.setComment(rs.getString("comment"));
                review.setCreatedAt(rs.getTimestamp("created_at"));
                reviews.add(review);
            }
        }
        return reviews;
    }

    // Get average rating for a product
    public double getAverageRating(int productId) throws Exception {
        String sql = "SELECT AVG(rating) as avg_rating FROM product_reviews WHERE product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                double avg = rs.getDouble("avg_rating");
                return rs.wasNull() ? 0.0 : avg;
            }
        }
        return 0.0;
    }

    // Get review count for a product
    public int getReviewCount(int productId) throws Exception {
        String sql = "SELECT COUNT(*) as count FROM product_reviews WHERE product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

    // Check if user has already reviewed this product
    public boolean hasUserReviewed(int productId, int userId) throws Exception {
        String sql = "SELECT COUNT(*) as count FROM product_reviews WHERE product_id = ? AND user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        }
        return false;
    }

    /**
     * Get all reviews for products in a specific store
     * @param storeUsername The username of the store owner
     * @return List of reviews with product information
     */
    public List<Review> getReviewsByStoreUsername(String storeUsername) throws Exception {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.*, u.username, p.name as product_name, p.product_id " +
                     "FROM product_reviews r " +
                     "INNER JOIN products p ON r.product_id = p.product_id " +
                     "LEFT JOIN users u ON r.user_id = u.user_id " +
                     "WHERE p.store_username = ? " +
                     "ORDER BY r.created_at DESC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, storeUsername);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Review review = new Review();
                review.setReviewId(rs.getInt("review_id"));
                review.setProductId(rs.getInt("product_id"));
                review.setUserId(rs.getInt("user_id"));
                review.setUsername(rs.getString("username"));
                review.setProductName(rs.getString("product_name"));
                review.setRating(rs.getInt("rating"));
                review.setComment(rs.getString("comment"));
                review.setCreatedAt(rs.getTimestamp("created_at"));
                reviews.add(review);
            }
        }
        return reviews;
    }
}
