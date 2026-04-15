package com.dailyfixer.dao;

import com.dailyfixer.model.Volunteer;
import com.dailyfixer.util.DBConnection;
import java.sql.*;

public class VolunteerDAO {

    // Register volunteer (insert into users first, then volunteers)
    public boolean registerVolunteer(Volunteer volunteer) {
        String insertUserSQL = "INSERT INTO users (first_name, last_name, username, email, password, phone_number, city, role) VALUES (?, ?, ?, ?, ?, ?, ?, 'volunteer')";
        String insertVolunteerSQL = "INSERT INTO volunteers (user_id, expertise, agreement) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psVolunteer = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Step 1: Insert into users table
            psUser = conn.prepareStatement(insertUserSQL, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, volunteer.getFirstName());
            psUser.setString(2, volunteer.getLastName());
            psUser.setString(3, volunteer.getUsername());
            psUser.setString(4, volunteer.getEmail());
            psUser.setString(5, volunteer.getPassword());
            psUser.setString(6, volunteer.getPhoneNumber());
            psUser.setString(7, volunteer.getCity());

            int userRows = psUser.executeUpdate();

            // Step 2: Retrieve generated user_id
            int userId = -1;
            rs = psUser.getGeneratedKeys();
            if (rs.next()) {
                userId = rs.getInt(1);
                System.out.println("✅ Generated user_id = " + userId);
            } else {
                throw new SQLException("❌ Failed to retrieve user_id after insert.");
            }

            // Step 3: Insert into volunteers table
            psVolunteer = conn.prepareStatement(insertVolunteerSQL);
            psVolunteer.setInt(1, userId);
            psVolunteer.setString(2, volunteer.getExpertise());
            psVolunteer.setBoolean(3, volunteer.isAgreement());

            int volRows = psVolunteer.executeUpdate();

            // Step 4: Commit transaction
            if (userRows > 0 && volRows > 0) {
                conn.commit();
                System.out.println("✅ Volunteer registered successfully");
                return true;
            } else {
                conn.rollback();
                System.out.println("⚠️ Rollback — failed to insert volunteer or user");
                return false;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (psUser != null) psUser.close(); } catch (Exception ignored) {}
            try { if (psVolunteer != null) psVolunteer.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.setAutoCommit(true); conn.close(); } catch (Exception ignored) {}
        }
    }

    // Check if username exists
    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Check if email exists
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
