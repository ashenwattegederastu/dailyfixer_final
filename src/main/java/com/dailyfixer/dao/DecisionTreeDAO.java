package com.dailyfixer.dao;

import com.dailyfixer.model.DecisionTree;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for decision trees.
 */
public class DecisionTreeDAO {

    /**
     * Get all trees (admin view).
     */
    public List<DecisionTree> getAllTrees() throws Exception {
        List<DecisionTree> trees = new ArrayList<>();
        String sql = "SELECT t.*, " +
                "u.first_name, u.last_name, u.username, " +
                "c.name AS category_name, " +
                "pc.name AS main_category_name, " +
                "COALESCE((SELECT AVG(rating) FROM diagnostic_ratings WHERE tree_id = t.tree_id), 0) AS avg_rating, " +
                "(SELECT COUNT(*) FROM diagnostic_ratings WHERE tree_id = t.tree_id) AS rating_count " +
                "FROM diagnostic_trees t " +
                "JOIN users u ON t.creator_id = u.user_id " +
                "JOIN diagnostic_categories c ON t.category_id = c.category_id " +
                "LEFT JOIN diagnostic_categories pc ON c.parent_id = pc.category_id " +
                "ORDER BY t.created_at DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                trees.add(mapResultSetToTree(rs));
            }
        }
        return trees;
    }

    /**
     * Get published trees by category (user view).
     */
    public List<DecisionTree> getTreesByCategory(int categoryId) throws Exception {
        List<DecisionTree> trees = new ArrayList<>();
        String sql = "SELECT t.*, " +
                "u.first_name, u.last_name, u.username, " +
                "c.name AS category_name, " +
                "pc.name AS main_category_name, " +
                "COALESCE((SELECT AVG(rating) FROM diagnostic_ratings WHERE tree_id = t.tree_id), 0) AS avg_rating, " +
                "(SELECT COUNT(*) FROM diagnostic_ratings WHERE tree_id = t.tree_id) AS rating_count " +
                "FROM diagnostic_trees t " +
                "JOIN users u ON t.creator_id = u.user_id " +
                "JOIN diagnostic_categories c ON t.category_id = c.category_id " +
                "LEFT JOIN diagnostic_categories pc ON c.parent_id = pc.category_id " +
                "WHERE t.category_id = ? AND t.status = 'published' " +
                "ORDER BY avg_rating DESC, t.created_at DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trees.add(mapResultSetToTree(rs));
                }
            }
        }
        return trees;
    }

    /**
     * Get a tree by ID with full metadata.
     */
    public DecisionTree getTreeById(int treeId) throws Exception {
        String sql = "SELECT t.*, " +
                "u.first_name, u.last_name, u.username, " +
                "c.name AS category_name, " +
                "pc.name AS main_category_name, " +
                "COALESCE((SELECT AVG(rating) FROM diagnostic_ratings WHERE tree_id = t.tree_id), 0) AS avg_rating, " +
                "(SELECT COUNT(*) FROM diagnostic_ratings WHERE tree_id = t.tree_id) AS rating_count " +
                "FROM diagnostic_trees t " +
                "JOIN users u ON t.creator_id = u.user_id " +
                "JOIN diagnostic_categories c ON t.category_id = c.category_id " +
                "LEFT JOIN diagnostic_categories pc ON c.parent_id = pc.category_id " +
                "WHERE t.tree_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTree(rs);
                }
            }
        }
        return null;
    }

    /**
     * Search trees by title or description (published only).
     */
    public List<DecisionTree> searchTrees(String query) throws Exception {
        List<DecisionTree> trees = new ArrayList<>();
        String sql = "SELECT t.*, " +
                "u.first_name, u.last_name, u.username, " +
                "c.name AS category_name, " +
                "pc.name AS main_category_name, " +
                "COALESCE((SELECT AVG(rating) FROM diagnostic_ratings WHERE tree_id = t.tree_id), 0) AS avg_rating, " +
                "(SELECT COUNT(*) FROM diagnostic_ratings WHERE tree_id = t.tree_id) AS rating_count " +
                "FROM diagnostic_trees t " +
                "JOIN users u ON t.creator_id = u.user_id " +
                "JOIN diagnostic_categories c ON t.category_id = c.category_id " +
                "LEFT JOIN diagnostic_categories pc ON c.parent_id = pc.category_id " +
                "WHERE t.status = 'published' AND (t.title LIKE ? OR t.description LIKE ?) " +
                "ORDER BY avg_rating DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trees.add(mapResultSetToTree(rs));
                }
            }
        }
        return trees;
    }

    /**
     * Create a new tree.
     * Returns the generated tree ID, or -1 on failure.
     */
    public int createTree(DecisionTree tree) throws Exception {
        String sql = "INSERT INTO diagnostic_trees (title, description, category_id, creator_id, status) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, tree.getTitle());
            ps.setString(2, tree.getDescription());
            ps.setInt(3, tree.getCategoryId());
            ps.setInt(4, tree.getCreatorId());
            ps.setString(5, tree.getStatus() != null ? tree.getStatus() : "draft");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Update tree metadata.
     */
    public boolean updateTree(DecisionTree tree) throws Exception {
        String sql = "UPDATE diagnostic_trees SET title = ?, description = ?, category_id = ?, status = ? " +
                "WHERE tree_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, tree.getTitle());
            ps.setString(2, tree.getDescription());
            ps.setInt(3, tree.getCategoryId());
            ps.setString(4, tree.getStatus());
            ps.setInt(5, tree.getTreeId());

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Update tree status only.
     */
    public boolean updateTreeStatus(int treeId, String status) throws Exception {
        String sql = "UPDATE diagnostic_trees SET status = ? WHERE tree_id = ?";
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(true); // Ensure auto-commit is on
            ps = con.prepareStatement(sql);

            ps.setString(1, status);
            ps.setInt(2, treeId);

            int rowsAffected = ps.executeUpdate();
            System.out.println(
                    "updateTreeStatus: treeId=" + treeId + ", status=" + status + ", rowsAffected=" + rowsAffected);

            return rowsAffected > 0;
        } finally {
            if (ps != null)
                try {
                    ps.close();
                } catch (Exception e) {
                }
            if (con != null)
                try {
                    con.close();
                } catch (Exception e) {
                }
        }
    }

    /**
     * Delete a tree.
     * Note: This will cascade delete all nodes and ratings.
     */
    public boolean deleteTree(int treeId) throws Exception {
        String sql = "DELETE FROM diagnostic_trees WHERE tree_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get trees created by a specific user.
     */
    public List<DecisionTree> getTreesByCreator(int creatorId) throws Exception {
        List<DecisionTree> trees = new ArrayList<>();
        String sql = "SELECT t.*, " +
                "u.first_name, u.last_name, u.username, " +
                "c.name AS category_name, " +
                "pc.name AS main_category_name, " +
                "COALESCE((SELECT AVG(rating) FROM diagnostic_ratings WHERE tree_id = t.tree_id), 0) AS avg_rating, " +
                "(SELECT COUNT(*) FROM diagnostic_ratings WHERE tree_id = t.tree_id) AS rating_count " +
                "FROM diagnostic_trees t " +
                "JOIN users u ON t.creator_id = u.user_id " +
                "JOIN diagnostic_categories c ON t.category_id = c.category_id " +
                "LEFT JOIN diagnostic_categories pc ON c.parent_id = pc.category_id " +
                "WHERE t.creator_id = ? " +
                "ORDER BY t.created_at DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, creatorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trees.add(mapResultSetToTree(rs));
                }
            }
        }
        return trees;
    }

    /**
     * Count total trees (for admin stats).
     */
    public int countAllTrees() throws Exception {
        String sql = "SELECT COUNT(*) FROM diagnostic_trees";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    private DecisionTree mapResultSetToTree(ResultSet rs) throws SQLException {
        DecisionTree tree = new DecisionTree();
        tree.setTreeId(rs.getInt("tree_id"));
        tree.setTitle(rs.getString("title"));
        tree.setDescription(rs.getString("description"));
        tree.setCategoryId(rs.getInt("category_id"));
        tree.setCreatorId(rs.getInt("creator_id"));
        tree.setStatus(rs.getString("status"));
        tree.setCreatedAt(rs.getTimestamp("created_at"));
        tree.setUpdatedAt(rs.getTimestamp("updated_at"));

        // Display fields
        tree.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
        tree.setCreatorUsername(rs.getString("username"));
        tree.setCategoryName(rs.getString("category_name"));
        tree.setMainCategoryName(rs.getString("main_category_name"));
        tree.setAverageRating(rs.getDouble("avg_rating"));
        tree.setRatingCount(rs.getInt("rating_count"));

        return tree;
    }
}
