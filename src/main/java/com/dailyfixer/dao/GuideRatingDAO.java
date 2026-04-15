package com.dailyfixer.dao;

import java.sql.*;
import com.dailyfixer.util.DBConnection;

public class GuideRatingDAO {

    /**
     * Add or update a rating. Each user can only have one rating per guide.
     */
    public boolean addOrUpdateRating(int guideId, int userId, String rating) {
        // Use INSERT ... ON DUPLICATE KEY UPDATE for upsert
        String sql = "INSERT INTO guide_ratings (guide_id, user_id, rating) VALUES (?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE rating = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            ps.setString(3, rating);
            ps.setString(4, rating);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get a user's rating for a specific guide.
     * 
     * @return "UP", "DOWN", or null if not rated
     */
    public String getUserRating(int guideId, int userId) {
        String sql = "SELECT rating FROM guide_ratings WHERE guide_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("rating");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Remove a user's rating.
     */
    public boolean removeRating(int guideId, int userId) {
        String sql = "DELETE FROM guide_ratings WHERE guide_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get rating counts for a guide.
     * 
     * @return int array: [upCount, downCount]
     */
    public int[] getRatingCounts(int guideId) {
        int[] counts = { 0, 0 };
        String sql = "SELECT rating, COUNT(*) as count FROM guide_ratings WHERE guide_id = ? GROUP BY rating";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String rating = rs.getString("rating");
                int count = rs.getInt("count");
                if ("UP".equals(rating)) {
                    counts[0] = count;
                } else if ("DOWN".equals(rating)) {
                    counts[1] = count;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }
}
