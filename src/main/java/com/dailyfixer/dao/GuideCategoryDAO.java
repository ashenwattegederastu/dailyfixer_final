package com.dailyfixer.dao;

import com.dailyfixer.model.GuideCategory;
import com.dailyfixer.model.GuideSubCategory;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for guide categories and sub-categories.
 */
public class GuideCategoryDAO {

    /**
     * Get all main categories.
     */
    public List<GuideCategory> getAllCategories() {
        List<GuideCategory> categories = new ArrayList<>();
        String sql = "SELECT category_id, name, created_at FROM guide_categories ORDER BY name";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                GuideCategory cat = new GuideCategory();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setName(rs.getString("name"));
                cat.setCreatedAt(rs.getTimestamp("created_at"));
                categories.add(cat);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return categories;
    }

    /**
     * Get sub-categories for a specific main category.
     */
    public List<GuideSubCategory> getSubCategoriesByCategoryId(int categoryId) {
        List<GuideSubCategory> subCategories = new ArrayList<>();
        String sql = "SELECT sub_category_id, category_id, name, created_at " +
                "FROM guide_sub_categories WHERE category_id = ? ORDER BY name";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, categoryId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    GuideSubCategory sub = new GuideSubCategory();
                    sub.setSubCategoryId(rs.getInt("sub_category_id"));
                    sub.setCategoryId(rs.getInt("category_id"));
                    sub.setName(rs.getString("name"));
                    sub.setCreatedAt(rs.getTimestamp("created_at"));
                    subCategories.add(sub);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return subCategories;
    }

    /**
     * Get all sub-categories grouped by category (for filters page).
     */
    public List<GuideSubCategory> getAllSubCategories() {
        List<GuideSubCategory> subCategories = new ArrayList<>();
        String sql = "SELECT sub_category_id, category_id, name, created_at " +
                "FROM guide_sub_categories ORDER BY category_id, name";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                GuideSubCategory sub = new GuideSubCategory();
                sub.setSubCategoryId(rs.getInt("sub_category_id"));
                sub.setCategoryId(rs.getInt("category_id"));
                sub.setName(rs.getString("name"));
                sub.setCreatedAt(rs.getTimestamp("created_at"));
                subCategories.add(sub);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return subCategories;
    }

    /**
     * Add a new main category.
     * 
     * @return The new category ID, or -1 on failure.
     */
    public int addCategory(String name) {
        String sql = "INSERT INTO guide_categories (name) VALUES (?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, name.trim());
            int affected = stmt.executeUpdate();

            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Add a new sub-category under a main category.
     * 
     * @return The new sub-category ID, or -1 on failure.
     */
    public int addSubCategory(int categoryId, String name) {
        String sql = "INSERT INTO guide_sub_categories (category_id, name) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, categoryId);
            stmt.setString(2, name.trim());
            int affected = stmt.executeUpdate();

            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Get a category by its name.
     */
    public GuideCategory getCategoryByName(String name) {
        String sql = "SELECT category_id, name, created_at FROM guide_categories WHERE name = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, name);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    GuideCategory cat = new GuideCategory();
                    cat.setCategoryId(rs.getInt("category_id"));
                    cat.setName(rs.getString("name"));
                    cat.setCreatedAt(rs.getTimestamp("created_at"));
                    return cat;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get a category by its ID.
     */
    public GuideCategory getCategoryById(int categoryId) {
        String sql = "SELECT category_id, name, created_at FROM guide_categories WHERE category_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, categoryId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    GuideCategory cat = new GuideCategory();
                    cat.setCategoryId(rs.getInt("category_id"));
                    cat.setName(rs.getString("name"));
                    cat.setCreatedAt(rs.getTimestamp("created_at"));
                    return cat;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
