package com.dailyfixer.dao;

import com.dailyfixer.model.DriverRequest;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DriverRequestDAO {

    /**
     * Submit a new driver request. Returns the generated request_id, or -1 on failure.
     */
    public int submitRequest(DriverRequest request) {
        String sql = "INSERT INTO driver_requests (full_name, username, email, phone, password_hash, city, "
                + "nic_number, nic_front_path, nic_back_path, profile_picture_path, "
                + "license_front_path, license_back_path, policy_accepted) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, request.getFullName());
            ps.setString(2, request.getUsername());
            ps.setString(3, request.getEmail());
            ps.setString(4, request.getPhone());
            ps.setString(5, request.getPasswordHash());
            ps.setString(6, request.getCity());
            ps.setString(7, request.getNicNumber());
            ps.setString(8, request.getNicFrontPath());
            ps.setString(9, request.getNicBackPath());
            ps.setString(10, request.getProfilePicturePath());
            ps.setString(11, request.getLicenseFrontPath());
            ps.setString(12, request.getLicenseBackPath());
            ps.setBoolean(13, request.isPolicyAccepted());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Get all driver requests, optionally filtered by status.
     */
    public List<DriverRequest> getRequestsByStatus(String status) {
        String sql;
        if (status != null && !status.isEmpty()) {
            sql = "SELECT * FROM driver_requests WHERE status = ? ORDER BY submitted_date DESC";
        } else {
            sql = "SELECT * FROM driver_requests ORDER BY submitted_date DESC";
        }

        List<DriverRequest> requests = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (status != null && !status.isEmpty()) {
                ps.setString(1, status);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRequest(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return requests;
    }

    /**
     * Get a single driver request by ID.
     */
    public DriverRequest getRequestById(int requestId) {
        String sql = "SELECT * FROM driver_requests WHERE request_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRequest(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Approve a driver request.
     * Creates a user record with role='driver', copies ID docs, updates request status.
     */
    public boolean approveRequest(int requestId, int adminUserId) {
        String getRequestSQL = "SELECT * FROM driver_requests WHERE request_id = ? AND status = 'PENDING'";
        String insertUserSQL = "INSERT INTO users (first_name, last_name, username, email, password, phone_number, city, role, "
                + "profile_picture_path, nic_number, nic_front_path, nic_back_path, license_front_path, license_back_path) "
                + "VALUES (?, '', ?, ?, ?, ?, ?, 'driver', ?, ?, ?, ?, ?, ?)";
        String updateRequestSQL = "UPDATE driver_requests SET status = 'APPROVED', reviewed_date = CURRENT_TIMESTAMP, reviewed_by = ? WHERE request_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Step 1: Get the pending request
            DriverRequest request;
            try (PreparedStatement ps = conn.prepareStatement(getRequestSQL)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    request = mapRequest(rs);
                }
            }

            // Step 2: Insert into users with all identification fields
            try (PreparedStatement ps = conn.prepareStatement(insertUserSQL)) {
                ps.setString(1, request.getFullName());
                ps.setString(2, request.getUsername());
                ps.setString(3, request.getEmail());
                ps.setString(4, request.getPasswordHash());
                ps.setString(5, request.getPhone());
                ps.setString(6, request.getCity());
                ps.setString(7, request.getProfilePicturePath());
                ps.setString(8, request.getNicNumber());
                ps.setString(9, request.getNicFrontPath());
                ps.setString(10, request.getNicBackPath());
                ps.setString(11, request.getLicenseFrontPath());
                ps.setString(12, request.getLicenseBackPath());
                ps.executeUpdate();
            }

            // Step 3: Update request status
            try (PreparedStatement ps = conn.prepareStatement(updateRequestSQL)) {
                ps.setInt(1, adminUserId);
                ps.setInt(2, requestId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {}
        }
    }

    /**
     * Reject a driver request with a reason.
     */
    public boolean rejectRequest(int requestId, String reason, int adminUserId) {
        String sql = "UPDATE driver_requests SET status = 'REJECTED', rejection_reason = ?, reviewed_date = CURRENT_TIMESTAMP, reviewed_by = ? WHERE request_id = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, adminUserId);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if username already exists in users or pending driver_requests.
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ? UNION SELECT 1 FROM driver_requests WHERE username = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if email already exists in users or pending driver_requests.
     */
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ? UNION SELECT 1 FROM driver_requests WHERE email = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get count of pending driver requests (for admin dashboard badge).
     */
    public int getPendingCount() {
        String sql = "SELECT COUNT(*) FROM driver_requests WHERE status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Find a driver request by username and password hash (for login feedback).
     */
    public DriverRequest findByUsernameAndPassword(String username, String hashedPassword) {
        String sql = "SELECT * FROM driver_requests WHERE username = ? AND password_hash = ? ORDER BY submitted_date DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashedPassword);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRequest(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private DriverRequest mapRequest(ResultSet rs) throws SQLException {
        DriverRequest r = new DriverRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setFullName(rs.getString("full_name"));
        r.setUsername(rs.getString("username"));
        r.setEmail(rs.getString("email"));
        r.setPhone(rs.getString("phone"));
        r.setPasswordHash(rs.getString("password_hash"));
        r.setCity(rs.getString("city"));
        r.setNicNumber(rs.getString("nic_number"));
        r.setNicFrontPath(rs.getString("nic_front_path"));
        r.setNicBackPath(rs.getString("nic_back_path"));
        r.setProfilePicturePath(rs.getString("profile_picture_path"));
        r.setLicenseFrontPath(rs.getString("license_front_path"));
        r.setLicenseBackPath(rs.getString("license_back_path"));
        r.setPolicyAccepted(rs.getBoolean("policy_accepted"));
        r.setStatus(rs.getString("status"));
        r.setRejectionReason(rs.getString("rejection_reason"));
        r.setSubmittedDate(rs.getTimestamp("submitted_date"));
        r.setReviewedDate(rs.getTimestamp("reviewed_date"));
        r.setReviewedBy(rs.getInt("reviewed_by"));
        return r;
    }
}
