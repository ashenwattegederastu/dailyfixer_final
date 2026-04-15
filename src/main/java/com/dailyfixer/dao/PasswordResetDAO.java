package com.dailyfixer.dao;

import com.dailyfixer.model.PasswordResetToken;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.time.Instant;


public class PasswordResetDAO {

    public void saveToken(int userId, String token, Timestamp expiry) throws Exception {
        String sql = "INSERT INTO password_reset_tokens (user_id, token, expiry) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, token);
            ps.setTimestamp(3, expiry);
            ps.executeUpdate();
        }
    }

    public PasswordResetToken getToken(String token) throws Exception {
        String sql = "SELECT user_id, expiry, used FROM password_reset_tokens WHERE token = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PasswordResetToken prt = new PasswordResetToken();
                    prt.setUserId(rs.getInt("user_id"));
                    prt.setExpiry(rs.getTimestamp("expiry"));
                    prt.setUsed(rs.getBoolean("used"));
                    prt.setToken(token);
                    return prt;
                }
            }
        }
        return null;
    }

    public void markTokenAsUsed(String token) throws Exception {
        String sql = "UPDATE password_reset_tokens SET used = TRUE WHERE token = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }
}