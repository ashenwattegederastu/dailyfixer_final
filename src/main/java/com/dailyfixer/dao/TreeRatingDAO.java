package com.dailyfixer.dao;

import com.dailyfixer.model.TreeRating;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for tree ratings.
 */
public class TreeRatingDAO {

    /**
     * Add or update a rating (upsert).
     * Uses INSERT ... ON DUPLICATE KEY UPDATE for atomic upsert.
     */
    public boolean addOrUpdateRating(TreeRating rating) throws Exception {
        String sql = "INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback) " +
                "VALUES (?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE rating = VALUES(rating), feedback = VALUES(feedback)";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, rating.getTreeId());
            ps.setInt(2, rating.getUserId());
            ps.setInt(3, rating.getRating());
            ps.setString(4, rating.getFeedback());

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get average rating for a tree.
     */
    public double getAverageRating(int treeId) throws Exception {
        String sql = "SELECT COALESCE(AVG(rating), 0) FROM diagnostic_ratings WHERE tree_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        }
        return 0.0;
    }

    /**
     * Get rating count for a tree.
     */
    public int getRatingCount(int treeId) throws Exception {
        String sql = "SELECT COUNT(*) FROM diagnostic_ratings WHERE tree_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Get a user's rating for a specific tree.
     */
    public TreeRating getUserRating(int treeId, int userId) throws Exception {
        String sql = "SELECT * FROM diagnostic_ratings WHERE tree_id = ? AND user_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRating(rs);
                }
            }
        }
        return null;
    }

    /**
     * Check if a user has rated a tree.
     */
    public boolean hasUserRated(int treeId, int userId) throws Exception {
        return getUserRating(treeId, userId) != null;
    }

    /**
     * Get all ratings for a tree with usernames.
     */
    public List<TreeRating> getRatingsForTree(int treeId) throws Exception {
        List<TreeRating> ratings = new ArrayList<>();
        String sql = "SELECT r.*, u.username FROM diagnostic_ratings r " +
                "JOIN users u ON r.user_id = u.user_id " +
                "WHERE r.tree_id = ? ORDER BY r.created_at DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TreeRating rating = mapResultSetToRating(rs);
                    rating.setUsername(rs.getString("username"));
                    ratings.add(rating);
                }
            }
        }
        return ratings;
    }

    /**
     * Delete a rating.
     */
    public boolean deleteRating(int treeId, int userId) throws Exception {
        String sql = "DELETE FROM diagnostic_ratings WHERE tree_id = ? AND user_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get rating statistics for a tree.
     * Returns an array where index i-1 contains count of i-star ratings.
     */
    public int[] getRatingDistribution(int treeId) throws Exception {
        int[] distribution = new int[5]; // indexes 0-4 for ratings 1-5
        String sql = "SELECT rating, COUNT(*) as count FROM diagnostic_ratings " +
                "WHERE tree_id = ? GROUP BY rating";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int rating = rs.getInt("rating");
                    int count = rs.getInt("count");
                    if (rating >= 1 && rating <= 5) {
                        distribution[rating - 1] = count;
                    }
                }
            }
        }
        return distribution;
    }

    private TreeRating mapResultSetToRating(ResultSet rs) throws SQLException {
        TreeRating rating = new TreeRating();
        rating.setRatingId(rs.getInt("rating_id"));
        rating.setTreeId(rs.getInt("tree_id"));
        rating.setUserId(rs.getInt("user_id"));
        rating.setRating(rs.getInt("rating"));
        rating.setFeedback(rs.getString("feedback"));
        rating.setCreatedAt(rs.getTimestamp("created_at"));
        return rating;
    }
}
