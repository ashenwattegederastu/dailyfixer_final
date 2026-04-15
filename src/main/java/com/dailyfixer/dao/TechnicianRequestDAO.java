package com.dailyfixer.dao;

import com.dailyfixer.model.TechnicianRequest;
import com.dailyfixer.model.TechnicianRequestFile;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TechnicianRequestDAO {

    /**
     * Submit a new technician request. Returns the generated request_id, or -1 on failure.
     */
    public int submitRequest(TechnicianRequest request) {
        String insertRequest = "INSERT INTO technician_requests "
                + "(first_name, last_name, username, email, phone, password_hash, city, profile_picture_path, "
                + "has_qualifications, has_experience, experience_company, experience_role, experience_years, "
                + "emp_id_card_path, emp_id_card_name) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String insertFile = "INSERT INTO technician_request_files (request_id, file_type, file_path, original_filename) "
                + "VALUES (?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int requestId;
            try (PreparedStatement ps = conn.prepareStatement(insertRequest, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, request.getFirstName());
                ps.setString(2, request.getLastName());
                ps.setString(3, request.getUsername());
                ps.setString(4, request.getEmail());
                ps.setString(5, request.getPhone());
                ps.setString(6, request.getPasswordHash());
                ps.setString(7, request.getCity());
                ps.setString(8, request.getProfilePicturePath());
                ps.setBoolean(9, request.isHasQualifications());
                ps.setBoolean(10, request.isHasExperience());
                ps.setString(11, request.getExperienceCompany());
                ps.setString(12, request.getExperienceRole());
                if (request.getExperienceYears() != null) {
                    ps.setInt(13, request.getExperienceYears());
                } else {
                    ps.setNull(13, Types.INTEGER);
                }
                ps.setString(14, request.getEmpIdCardPath());
                ps.setString(15, request.getEmpIdCardName());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return -1;
                    }
                    requestId = rs.getInt(1);
                }
            }

            if (request.getFiles() != null && !request.getFiles().isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(insertFile)) {
                    for (TechnicianRequestFile file : request.getFiles()) {
                        ps.setInt(1, requestId);
                        ps.setString(2, file.getFileType());
                        ps.setString(3, file.getFilePath());
                        ps.setString(4, file.getOriginalFilename());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            conn.commit();
            return requestId;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return -1;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ignored) {}
        }
    }

    /**
     * Get all technician requests, optionally filtered by status.
     */
    public List<TechnicianRequest> getRequestsByStatus(String status) {
        String sql = status != null && !status.isEmpty()
                ? "SELECT * FROM technician_requests WHERE status = ? ORDER BY submitted_date DESC"
                : "SELECT * FROM technician_requests ORDER BY submitted_date DESC";

        List<TechnicianRequest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (status != null && !status.isEmpty()) ps.setString(1, status);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRequest(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get a single request by ID, including its associated files.
     */
    public TechnicianRequest getRequestById(int requestId) {
        String sql = "SELECT * FROM technician_requests WHERE request_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TechnicianRequest request = mapRequest(rs);
                    request.setFiles(getFilesForRequest(conn, requestId));
                    return request;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private List<TechnicianRequestFile> getFilesForRequest(Connection conn, int requestId) throws SQLException {
        String sql = "SELECT * FROM technician_request_files WHERE request_id = ? ORDER BY file_type, file_id";
        List<TechnicianRequestFile> files = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TechnicianRequestFile f = new TechnicianRequestFile();
                    f.setFileId(rs.getInt("file_id"));
                    f.setRequestId(rs.getInt("request_id"));
                    f.setFileType(rs.getString("file_type"));
                    f.setFilePath(rs.getString("file_path"));
                    f.setOriginalFilename(rs.getString("original_filename"));
                    f.setUploadedAt(rs.getTimestamp("uploaded_at"));
                    files.add(f);
                }
            }
        }
        return files;
    }

    /**
     * Approve a request: create the user with role='technician', then mark request APPROVED.
     */
    public boolean approveRequest(int requestId, int adminUserId) {
        String getSQL    = "SELECT * FROM technician_requests WHERE request_id = ? AND status = 'PENDING'";
        String insertSQL = "INSERT INTO users (first_name, last_name, username, email, password, phone_number, city, role, profile_picture_path) "
                         + "VALUES (?, ?, ?, ?, ?, ?, ?, 'technician', ?)";
        String updateSQL = "UPDATE technician_requests SET status = 'APPROVED', reviewed_date = CURRENT_TIMESTAMP, reviewed_by = ? WHERE request_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            TechnicianRequest req;
            try (PreparedStatement ps = conn.prepareStatement(getSQL)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) { conn.rollback(); return false; }
                    req = mapRequest(rs);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSQL)) {
                ps.setString(1, req.getFirstName());
                ps.setString(2, req.getLastName());
                ps.setString(3, req.getUsername());
                ps.setString(4, req.getEmail());
                ps.setString(5, req.getPasswordHash());
                ps.setString(6, req.getPhone());
                ps.setString(7, req.getCity());
                ps.setString(8, req.getProfilePicturePath());
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSQL)) {
                ps.setInt(1, adminUserId);
                ps.setInt(2, requestId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ignored) {}
        }
    }

    /**
     * Reject a request with a reason.
     */
    public boolean rejectRequest(int requestId, String reason, int adminUserId) {
        String sql = "UPDATE technician_requests SET status = 'REJECTED', rejection_reason = ?, "
                   + "reviewed_date = CURRENT_TIMESTAMP, reviewed_by = ? WHERE request_id = ? AND status = 'PENDING'";
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

    public int getPendingCount() {
        String sql = "SELECT COUNT(*) FROM technician_requests WHERE status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ? "
                   + "UNION SELECT 1 FROM technician_requests WHERE username = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ? "
                   + "UNION SELECT 1 FROM technician_requests WHERE email = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private TechnicianRequest mapRequest(ResultSet rs) throws SQLException {
        TechnicianRequest r = new TechnicianRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setFirstName(rs.getString("first_name"));
        r.setLastName(rs.getString("last_name"));
        r.setUsername(rs.getString("username"));
        r.setEmail(rs.getString("email"));
        r.setPhone(rs.getString("phone"));
        r.setPasswordHash(rs.getString("password_hash"));
        r.setCity(rs.getString("city"));
        r.setProfilePicturePath(rs.getString("profile_picture_path"));
        r.setHasQualifications(rs.getBoolean("has_qualifications"));
        r.setHasExperience(rs.getBoolean("has_experience"));
        r.setExperienceCompany(rs.getString("experience_company"));
        r.setExperienceRole(rs.getString("experience_role"));
        int years = rs.getInt("experience_years");
        r.setExperienceYears(rs.wasNull() ? null : years);
        r.setEmpIdCardPath(rs.getString("emp_id_card_path"));
        r.setEmpIdCardName(rs.getString("emp_id_card_name"));
        r.setStatus(rs.getString("status"));
        r.setRejectionReason(rs.getString("rejection_reason"));
        r.setSubmittedDate(rs.getTimestamp("submitted_date"));
        r.setReviewedDate(rs.getTimestamp("reviewed_date"));
        r.setReviewedBy(rs.getInt("reviewed_by"));
        return r;
    }
}
