package com.dailyfixer.dao;

import com.dailyfixer.model.ServiceCategory;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceCategoryDAO {

    public List<ServiceCategory> getAllCategories() throws Exception {
        List<ServiceCategory> list = new ArrayList<>();
        String sql = "SELECT * FROM service_categories ORDER BY name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ServiceCategory category = new ServiceCategory();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("name"));
                category.setDescription(rs.getString("description"));
                category.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(category);
            }
        }
        return list;
    }

    public ServiceCategory getCategoryById(int categoryId) throws Exception {
        String sql = "SELECT * FROM service_categories WHERE category_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ServiceCategory category = new ServiceCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("name"));
                    category.setDescription(rs.getString("description"));
                    category.setCreatedAt(rs.getTimestamp("created_at"));
                    return category;
                }
            }
        }
        return null;
    }

    public ServiceCategory getCategoryByName(String name) throws Exception {
        String sql = "SELECT * FROM service_categories WHERE name = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ServiceCategory category = new ServiceCategory();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("name"));
                    category.setDescription(rs.getString("description"));
                    category.setCreatedAt(rs.getTimestamp("created_at"));
                    return category;
                }
            }
        }
        return null;
    }

    public void addCategory(ServiceCategory category) throws Exception {
        String sql = "INSERT INTO service_categories (name, description) VALUES (?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    category.setCategoryId(rs.getInt(1));
                }
            }
        }
    }
}
