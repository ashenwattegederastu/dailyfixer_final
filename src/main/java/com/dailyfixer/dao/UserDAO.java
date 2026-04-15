package com.dailyfixer.dao;

import com.dailyfixer.model.User;
import com.dailyfixer.util.DBConnection;
import com.dailyfixer.util.HashUtil;

import java.sql.*;

public class UserDAO {

    public boolean isUsernameTaken(String username) throws Exception {
        String sql = "SELECT user_id FROM users WHERE username = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean isEmailTaken(String email) throws Exception {
        String sql = "SELECT user_id FROM users WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Saves a user and returns the generated user_id.
     * Returns -1 on failure.
     */
    public int saveUser(User user) {
        String sql = "INSERT INTO users (first_name, last_name, username, email, password, phone_number, city, role) VALUES (?,?,?,?,?,?,?,?)";
        int userId = -1;

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getUsername());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPassword());
            ps.setString(6, user.getPhoneNumber());
            ps.setString(7, user.getCity());
            ps.setString(8, user.getRole());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                        user.setUserId(userId); // also set on the object
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            userId = -1;
        }

        return userId;
    }

    public boolean updateUserInfo(int userId, String firstName, String lastName, String phoneNumber, String city,
            String bio) {
        String sql = "UPDATE users SET first_name=?, last_name=?, phone_number=?, city=?, bio=? WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, phoneNumber);
            ps.setString(4, city);
            ps.setString(5, bio);
            ps.setInt(6, userId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProfilePicture(int userId, String picturePath) {
        String sql = "UPDATE users SET profile_picture_path=? WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, picturePath);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePassword(int userId, String newHashedPassword) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newHashedPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void resetPasswordByUserId(int userId, String newPassword) throws Exception {
        // 1. Hash the new password using your existing HashUtil
        String hashedPassword = HashUtil.sha256(newPassword);

        String sql = "UPDATE users SET password = ? WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);

            int rowsAffected = ps.executeUpdate();

            // Debugging logs to help you see it in the console
            if (rowsAffected > 0) {
                System.out.println("SUCCESS: Password reset in DB for user_id: " + userId);
            } else {
                System.out.println("FAILURE: No user found with user_id: " + userId);
            }
        }
    }

    public boolean updateHomeLocation(int userId, double latitude, double longitude) {
        String sql = "UPDATE users SET latitude = ?, longitude = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, latitude);
            ps.setDouble(2, longitude);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setPhoneNumber(rs.getString("phone_number"));
        u.setCity(rs.getString("city"));
        u.setBio(rs.getString("bio"));
        u.setProfilePicturePath(rs.getString("profile_picture_path"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getString("status"));
        double lat = rs.getDouble("latitude");
        if (!rs.wasNull()) u.setLatitude(lat);
        double lng = rs.getDouble("longitude");
        if (!rs.wasNull()) u.setLongitude(lng);
        u.setNicNumber(rs.getString("nic_number"));
        u.setNicFrontPath(rs.getString("nic_front_path"));
        u.setNicBackPath(rs.getString("nic_back_path"));
        u.setLicenseFrontPath(rs.getString("license_front_path"));
        u.setLicenseBackPath(rs.getString("license_back_path"));
        return u;
    }

    public User getUserByEmail(String email) throws Exception {
        String sql = "SELECT user_id, username, email, password FROM users WHERE email = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    return user;
                }
            }
        }
        return null; // email not found
    }

    public User findByUsernameAndPassword(String username, String hashedPassword) throws Exception {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND status = 'active'";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashedPassword);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean softDeleteUser(int userId) {
        String archive = "INSERT INTO deleted_users (user_id, first_name, last_name, username, email, phone_number, city, role) "
                       + "SELECT user_id, first_name, last_name, username, email, phone_number, city, role "
                       + "FROM users WHERE user_id = ?";
        String suspend = "UPDATE users SET status = 'suspended' WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(archive)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(suspend)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
