package com.dailyfixer.dao;

import java.sql.*;
import java.util.*;
import com.dailyfixer.model.GuideComment;
import com.dailyfixer.util.DBConnection;

public class GuideCommentDAO {

    /**
     * Add a new comment to a guide.
     * 
     * @return The generated comment ID, or -1 on failure
     */
    public int addComment(int guideId, int userId, String comment) {
        String sql = "INSERT INTO guide_comments (guide_id, user_id, comment) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            ps.setString(3, comment);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Get all comments for a guide, ordered by creation date (newest first).
     */
    public List<GuideComment> getCommentsByGuide(int guideId) {
        List<GuideComment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.first_name FROM guide_comments c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "WHERE c.guide_id = ? ORDER BY c.created_at ASC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                GuideComment comment = new GuideComment();
                comment.setCommentId(rs.getInt("comment_id"));
                comment.setGuideId(rs.getInt("guide_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setComment(rs.getString("comment"));
                comment.setCreatedAt(rs.getTimestamp("created_at"));
                comment.setReply(rs.getString("reply"));
                comment.setReplyAt(rs.getTimestamp("reply_at"));
                comment.setUsername(rs.getString("username"));
                comment.setUserFirstName(rs.getString("first_name"));
                comments.add(comment);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return comments;
    }

    /**
     * Edit the text of an existing comment. Only the comment owner can edit.
     *
     * @return true if updated successfully
     */
    public boolean updateComment(int commentId, int userId, String newText) {
        String sql = "UPDATE guide_comments SET comment = ? WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newText);
            ps.setInt(2, commentId);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Add or update the guide creator's reply on a comment.
     * The JOIN ensures only the actual guide creator can set a reply.
     *
     * @return true if updated successfully
     */
    public boolean addOrUpdateReply(int commentId, int creatorId, String reply) {
        String sql = "UPDATE guide_comments c " +
                "JOIN guides g ON c.guide_id = g.guide_id " +
                "SET c.reply = ?, c.reply_at = NOW() " +
                "WHERE c.comment_id = ? AND g.created_by = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reply);
            ps.setInt(2, commentId);
            ps.setInt(3, creatorId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete the guide creator's reply from a comment.
     * The JOIN ensures only the actual guide creator can remove a reply.
     *
     * @return true if updated successfully
     */
    public boolean deleteReply(int commentId, int creatorId) {
        String sql = "UPDATE guide_comments c " +
                "JOIN guides g ON c.guide_id = g.guide_id " +
                "SET c.reply = NULL, c.reply_at = NULL " +
                "WHERE c.comment_id = ? AND g.created_by = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            ps.setInt(2, creatorId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete a comment. Only the comment owner can delete.
     * 
     * @return true if deleted successfully
     */
    public boolean deleteComment(int commentId, int userId) {
        String sql = "DELETE FROM guide_comments WHERE comment_id = ? AND user_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get the count of comments for a guide.
     */
    public int getCommentCount(int guideId) {
        String sql = "SELECT COUNT(*) FROM guide_comments WHERE guide_id = ?";

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
     * Get all comments for all guides created by a specific user (e.g. volunteer).
     * Ordered by creation date (newest first).
     */
    public List<GuideComment> getCommentsByGuideOwner(int ownerId) {
        List<GuideComment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.first_name, g.title as guide_title FROM guide_comments c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "JOIN guides g ON c.guide_id = g.guide_id " +
                "WHERE g.created_by = ? ORDER BY c.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                GuideComment comment = new GuideComment();
                comment.setCommentId(rs.getInt("comment_id"));
                comment.setGuideId(rs.getInt("guide_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setComment(rs.getString("comment"));
                comment.setCreatedAt(rs.getTimestamp("created_at"));
                comment.setReply(rs.getString("reply"));
                comment.setReplyAt(rs.getTimestamp("reply_at"));
                comment.setUsername(rs.getString("username"));
                comment.setUserFirstName(rs.getString("first_name"));
                comment.setGuideTitle(rs.getString("guide_title"));
                comments.add(comment);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return comments;
    }
}
