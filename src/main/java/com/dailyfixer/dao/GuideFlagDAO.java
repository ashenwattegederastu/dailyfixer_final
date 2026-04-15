package com.dailyfixer.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.dailyfixer.model.GuideFlag;
import com.dailyfixer.util.DBConnection;

public class GuideFlagDAO {

    private static final int FLAG_THRESHOLD = 3;

    /**
     * Add a flag for a guide. Each user can only flag a guide once.
     * Returns true if the flag was added successfully.
     */
    public boolean addFlag(int guideId, int userId, String reason, String description) {
        String sql = "INSERT INTO guide_flags (guide_id, user_id, reason, description) VALUES (?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE reason = VALUES(reason), description = VALUES(description)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            ps.setString(3, reason);
            ps.setString(4, description);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if a user has already flagged a specific guide.
     */
    public boolean hasUserFlagged(int guideId, int userId) {
        String sql = "SELECT 1 FROM guide_flags WHERE guide_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            return ps.executeQuery().next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get the total flag count for a guide.
     */
    public int getFlagCount(int guideId) {
        String sql = "SELECT COUNT(*) FROM guide_flags WHERE guide_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get all flags for a specific guide (for admin review).
     */
    public List<GuideFlag> getFlagsByGuide(int guideId) {
        List<GuideFlag> flags = new ArrayList<>();
        String sql = "SELECT f.*, u.username, u.first_name FROM guide_flags f " +
                "JOIN users u ON f.user_id = u.user_id " +
                "WHERE f.guide_id = ? ORDER BY f.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                GuideFlag flag = new GuideFlag();
                flag.setFlagId(rs.getInt("flag_id"));
                flag.setGuideId(rs.getInt("guide_id"));
                flag.setUserId(rs.getInt("user_id"));
                flag.setReason(rs.getString("reason"));
                flag.setDescription(rs.getString("description"));
                flag.setCreatedAt(rs.getTimestamp("created_at"));
                flag.setUsername(rs.getString("username"));
                flag.setUserFirstName(rs.getString("first_name"));
                flags.add(flag);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return flags;
    }

    /**
     * Delete all flags for a guide (when admin dismisses flags).
     */
    public boolean clearFlags(int guideId) {
        String sql = "DELETE FROM guide_flags WHERE guide_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get the flag threshold.
     */
    public int getFlagThreshold() {
        return FLAG_THRESHOLD;
    }

    // ==================== MODERATION ====================

    /**
     * Hide a guide (admin action). Updates guide status and logs the action.
     */
    public boolean hideGuide(int guideId, int adminId, String reason) {
        String updateSql = "UPDATE guides SET status = 'HIDDEN', hide_reason = ?, hidden_at = NOW(), hidden_by = ? WHERE guide_id = ?";
        String logSql = "INSERT INTO guide_moderation_log (guide_id, admin_id, action, reason) VALUES (?, ?, 'HIDDEN', ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, reason);
                ps.setInt(2, adminId);
                ps.setInt(3, guideId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setInt(1, guideId);
                ps.setInt(2, adminId);
                ps.setString(3, reason);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Dismiss flags on a guide (admin decides flags are not warranted).
     * Clears all flags and logs the action.
     */
    public boolean dismissFlags(int guideId, int adminId) {
        String logSql = "INSERT INTO guide_moderation_log (guide_id, admin_id, action, reason) VALUES (?, ?, 'DISMISSED', 'Flags dismissed by admin')";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Clear flags
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM guide_flags WHERE guide_id = ?")) {
                ps.setInt(1, guideId);
                ps.executeUpdate();
            }

            // Log the action
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setInt(1, guideId);
                ps.setInt(2, adminId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Unhide a guide (admin approves edited guide).
     * Clears all flags, resets status to ACTIVE, and logs the action.
     */
    public boolean unhideGuide(int guideId, int adminId) {
        String updateSql = "UPDATE guides SET status = 'ACTIVE', hide_reason = NULL, hidden_at = NULL, hidden_by = NULL WHERE guide_id = ?";
        String logSql = "INSERT INTO guide_moderation_log (guide_id, admin_id, action, reason) VALUES (?, ?, 'UNHIDDEN', 'Guide approved after edit')";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, guideId);
                ps.executeUpdate();
            }

            // Clear flags
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM guide_flags WHERE guide_id = ?")) {
                ps.setInt(1, guideId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setInt(1, guideId);
                ps.setInt(2, adminId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Mark guide as pending review (creator edited a hidden guide).
     */
    public boolean markPendingReview(int guideId) {
        String sql = "UPDATE guides SET status = 'PENDING_REVIEW' WHERE guide_id = ? AND status = 'HIDDEN'";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
