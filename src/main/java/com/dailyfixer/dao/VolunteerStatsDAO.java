package com.dailyfixer.dao;

import java.sql.*;
import java.util.*;
import com.dailyfixer.model.Guide;
import com.dailyfixer.model.VolunteerStats;
import com.dailyfixer.util.DBConnection;
import com.dailyfixer.util.ReputationUtils;

public class VolunteerStatsDAO {

    public VolunteerStats getStats(int volunteerId) {
        VolunteerStats stats = new VolunteerStats();

        // 1. Get total guides and views
        String guideSql = "SELECT COUNT(*) as total_guides, SUM(view_count) as total_views " +
                "FROM guides WHERE created_by = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(guideSql)) {
            ps.setInt(1, volunteerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.setTotalGuides(rs.getInt("total_guides"));
                stats.setTotalViews(rs.getInt("total_views"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. Get total likes and dislikes
        String ratingSql = "SELECT r.rating, COUNT(*) as count FROM guide_ratings r " +
                "JOIN guides g ON r.guide_id = g.guide_id " +
                "WHERE g.created_by = ? GROUP BY r.rating";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(ratingSql)) {
            ps.setInt(1, volunteerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String rating = rs.getString("rating");
                int count = rs.getInt("count");
                if ("UP".equalsIgnoreCase(rating)) {
                    stats.setTotalLikes(count);
                } else if ("DOWN".equalsIgnoreCase(rating)) {
                    stats.setTotalDislikes(count);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 3. Calculate Approval Rating
        int totalRatings = stats.getTotalLikes() + stats.getTotalDislikes();
        if (totalRatings > 0) {
            double rating = ((double) stats.getTotalLikes() / totalRatings) * 100.0;
            // Round to 1 decimal place
            stats.setApprovalRating(Math.round(rating * 10.0) / 10.0);
        } else {
            stats.setApprovalRating(0.0);
        }

        // 4. Calculate Reputation Score
        ReputationUtils.calculateReputation(stats);

        // Update DB with new score
        updateReputation(volunteerId, stats.getReputationScore());

        // Check and award badges
        checkAndAwardBadges(volunteerId, stats.getReputationScore());

        return stats;
    }

    private void updateReputation(int volunteerId, double score) {
        String sql = "UPDATE volunteers SET reputation_score = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, score);
            ps.setInt(2, volunteerId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void checkAndAwardBadges(int volunteerId, double score) {
        String badgeName = ReputationUtils.getBadgeForScore(score);
        if ("New Volunteer".equals(badgeName))
            return;

        // Get badge_id
        String getBadgeIdSql = "SELECT badge_id FROM badges WHERE name = ?";
        // Insert if not exists
        String insertBadgeSql = "INSERT IGNORE INTO volunteer_badges (volunteer_id, badge_id) VALUES (?, ?)";

        int realVolunteerId = getVolunteerIdFromUserId(volunteerId);
        if (realVolunteerId == -1)
            return;

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement psGet = conn.prepareStatement(getBadgeIdSql);
                PreparedStatement psInsert = conn.prepareStatement(insertBadgeSql)) {

            psGet.setString(1, badgeName);
            ResultSet rs = psGet.executeQuery();
            if (rs.next()) {
                int badgeId = rs.getInt("badge_id");

                psInsert.setInt(1, realVolunteerId);
                psInsert.setInt(2, badgeId);
                psInsert.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private int getVolunteerIdFromUserId(int userId) {
        String sql = "SELECT volunteer_id FROM volunteers WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getInt("volunteer_id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<Guide> getTopRatedGuides(int volunteerId, int limit) {
        List<Guide> guides = new ArrayList<>();
        // Query to get guides ordered by likes
        // This assumes we want to sort by number of UP ratings
        String sql = "SELECT g.*, " +
                "(SELECT COUNT(*) FROM guide_ratings r WHERE r.guide_id = g.guide_id AND r.rating = 'UP') as like_count "
                +
                "FROM guides g " +
                "WHERE g.created_by = ? " +
                "ORDER BY like_count DESC, g.view_count DESC " +
                "LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, volunteerId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Guide g = new Guide();
                g.setGuideId(rs.getInt("guide_id"));
                g.setTitle(rs.getString("title"));
                g.setMainImagePath(rs.getString("main_image_path"));
                g.setMainCategory(rs.getString("main_category"));
                g.setViewCount(rs.getInt("view_count"));
                // We'll store the like count in the guide object temporarily if needed,
                // but for now we just need the guide details.
                // You could add a 'likeCount' transient field to Guide if you wanted to display
                // it.
                guides.add(g);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return guides;
    }
}
