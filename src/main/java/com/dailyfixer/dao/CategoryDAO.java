package com.dailyfixer.dao;

import com.dailyfixer.model.Category;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for diagnostic categories.
 */
public class CategoryDAO {

    /**
     * Get all main categories (categories with no parent).
     */
    public List<Category> getAllMainCategories() throws Exception {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM diagnostic_categories WHERE parent_id IS NULL ORDER BY name";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(mapResultSetToCategory(rs));
            }
        }
        return categories;
    }

    /**
     * Get all sub-categories for a given main category.
     */
    public List<Category> getSubCategories(int parentId) throws Exception {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM diagnostic_categories WHERE parent_id = ? ORDER BY name";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    categories.add(mapResultSetToCategory(rs));
                }
            }
        }
        return categories;
    }

    /**
     * Get a category by its ID.
     */
    public Category getCategoryById(int categoryId) throws Exception {
        String sql = "SELECT * FROM diagnostic_categories WHERE category_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all categories (both main and sub) with their hierarchy.
     */
    public List<Category> getAllCategoriesWithChildren() throws Exception {
        List<Category> mainCategories = getAllMainCategories();
        for (Category main : mainCategories) {
            main.setChildren(getSubCategories(main.getCategoryId()));
        }
        return mainCategories;
    }

    /**
     * Create a new category.
     * Returns the generated category ID, or -1 on failure.
     */
    public int createCategory(Category category) throws Exception {
        String sql = "INSERT INTO diagnostic_categories (name, parent_id) VALUES (?, ?)";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, category.getName());
            if (category.getParentId() != null) {
                ps.setInt(2, category.getParentId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

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
     * Update a category's name.
     */
    public boolean updateCategory(int categoryId, String newName) throws Exception {
        String sql = "UPDATE diagnostic_categories SET name = ? WHERE category_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newName);
            ps.setInt(2, categoryId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete a category.
     * Note: This will cascade delete all sub-categories and related trees.
     */
    public boolean deleteCategory(int categoryId) throws Exception {
        String sql = "DELETE FROM diagnostic_categories WHERE category_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Check if a category name already exists (within the same parent).
     */
    public boolean categoryExists(String name, Integer parentId) throws Exception {
        String sql;
        if (parentId == null) {
            sql = "SELECT category_id FROM diagnostic_categories WHERE name = ? AND parent_id IS NULL";
        } else {
            sql = "SELECT category_id FROM diagnostic_categories WHERE name = ? AND parent_id = ?";
        }

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            if (parentId != null) {
                ps.setInt(2, parentId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Get parent category name for a sub-category.
     */
    public String getParentCategoryName(int categoryId) throws Exception {
        String sql = "SELECT p.name FROM diagnostic_categories c " +
                "JOIN diagnostic_categories p ON c.parent_id = p.category_id " +
                "WHERE c.category_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }
        }
        return null;
    }

    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setCategoryId(rs.getInt("category_id"));
        category.setName(rs.getString("name"));
        int parentId = rs.getInt("parent_id");
        category.setParentId(rs.wasNull() ? null : parentId);
        category.setCreatedAt(rs.getTimestamp("created_at"));
        return category;
    }
}
