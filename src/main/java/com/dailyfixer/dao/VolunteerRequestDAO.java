package com.dailyfixer.dao;

import com.dailyfixer.model.VolunteerProof;
import com.dailyfixer.model.VolunteerRequest;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VolunteerRequestDAO {

    /**
     * Submit a new volunteer request (insert into volunteer_requests +
     * volunteer_proofs).
     * Returns the generated request_id, or -1 on failure.
     */
    public int submitRequest(VolunteerRequest request) {
        String insertRequestSQL = "INSERT INTO volunteer_requests (full_name, username, email, phone, password_hash, city, "
                +
                "profile_picture_path, expertise, skill_level, bio, sample_guide_file_path) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertProofSQL = "INSERT INTO volunteer_proofs (request_id, proof_type, image_path, description, upload_order) "
                +
                "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psRequest = null;
        PreparedStatement psProof = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Step 1: Insert request
            psRequest = conn.prepareStatement(insertRequestSQL, Statement.RETURN_GENERATED_KEYS);
            psRequest.setString(1, request.getFullName());
            psRequest.setString(2, request.getUsername());
            psRequest.setString(3, request.getEmail());
            psRequest.setString(4, request.getPhone());
            psRequest.setString(5, request.getPasswordHash());
            psRequest.setString(6, request.getCity());
            psRequest.setString(7, request.getProfilePicturePath());
            psRequest.setString(8, request.getExpertise());
            psRequest.setString(9, request.getSkillLevel());
            psRequest.setString(10, request.getBio());
            psRequest.setString(11, request.getSampleGuideFilePath());
            psRequest.executeUpdate();

            rs = psRequest.getGeneratedKeys();
            int requestId = -1;
            if (rs.next()) {
                requestId = rs.getInt(1);
            } else {
                conn.rollback();
                return -1;
            }

            // Step 2: Insert proofs
            if (request.getProofs() != null && !request.getProofs().isEmpty()) {
                psProof = conn.prepareStatement(insertProofSQL);
                for (VolunteerProof proof : request.getProofs()) {
                    psProof.setInt(1, requestId);
                    psProof.setString(2, proof.getProofType());
                    psProof.setString(3, proof.getImagePath());
                    psProof.setString(4, proof.getDescription());
                    psProof.setInt(5, proof.getUploadOrder());
                    psProof.addBatch();
                }
                psProof.executeBatch();
            }

            conn.commit();
            return requestId;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null)
                    conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return -1;
        } finally {
            try {
                if (rs != null)
                    rs.close();
            } catch (Exception ignored) {
            }
            try {
                if (psRequest != null)
                    psRequest.close();
            } catch (Exception ignored) {
            }
            try {
                if (psProof != null)
                    psProof.close();
            } catch (Exception ignored) {
            }
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }

    /**
     * Get all volunteer requests, optionally filtered by status.
     */
    public List<VolunteerRequest> getRequestsByStatus(String status) {
        String sql;
        if (status != null && !status.isEmpty()) {
            sql = "SELECT * FROM volunteer_requests WHERE status = ? ORDER BY submitted_date DESC";
        } else {
            sql = "SELECT * FROM volunteer_requests ORDER BY submitted_date DESC";
        }

        List<VolunteerRequest> requests = new ArrayList<>();
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
     * Get a single volunteer request by ID, with proofs loaded.
     */
    public VolunteerRequest getRequestById(int requestId) {
        String sql = "SELECT * FROM volunteer_requests WHERE request_id = ?";
        String proofsSql = "SELECT * FROM volunteer_proofs WHERE request_id = ? ORDER BY upload_order";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                PreparedStatement psProofs = conn.prepareStatement(proofsSql)) {

            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    VolunteerRequest request = mapRequest(rs);

                    // Load proofs
                    psProofs.setInt(1, requestId);
                    try (ResultSet rsProofs = psProofs.executeQuery()) {
                        List<VolunteerProof> proofs = new ArrayList<>();
                        while (rsProofs.next()) {
                            VolunteerProof proof = new VolunteerProof();
                            proof.setProofId(rsProofs.getInt("proof_id"));
                            proof.setRequestId(rsProofs.getInt("request_id"));
                            proof.setProofType(rsProofs.getString("proof_type"));
                            proof.setImagePath(rsProofs.getString("image_path"));
                            proof.setDescription(rsProofs.getString("description"));
                            proof.setUploadOrder(rsProofs.getInt("upload_order"));
                            proofs.add(proof);
                        }
                        request.setProofs(proofs);
                    }

                    return request;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Approve a volunteer request.
     * Creates user + volunteer records, updates request status.
     */
    public boolean approveRequest(int requestId, int adminUserId) {
        String getRequestSQL = "SELECT * FROM volunteer_requests WHERE request_id = ? AND status = 'PENDING'";
        String insertUserSQL = "INSERT INTO users (first_name, last_name, username, email, password, phone_number, city, role) VALUES (?, '', ?, ?, ?, ?, ?, 'volunteer')";
        String insertVolunteerSQL = "INSERT INTO volunteers (user_id, expertise, skill_level, experience_years, bio, profile_picture_path, agreement) VALUES (?, ?, ?, ?, ?, ?, 1)";
        String updateRequestSQL = "UPDATE volunteer_requests SET status = 'APPROVED', reviewed_date = CURRENT_TIMESTAMP, reviewed_by = ? WHERE request_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Step 1: Get the pending request
            VolunteerRequest request;
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

            // Step 2: Insert into users
            int userId;
            try (PreparedStatement ps = conn.prepareStatement(insertUserSQL, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, request.getFullName());
                ps.setString(2, request.getUsername());
                ps.setString(3, request.getEmail());
                ps.setString(4, request.getPasswordHash());
                ps.setString(5, request.getPhone());
                ps.setString(6, request.getCity());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            // Step 3: Insert into volunteers
            try (PreparedStatement ps = conn.prepareStatement(insertVolunteerSQL)) {
                ps.setInt(1, userId);
                ps.setString(2, request.getExpertise());
                ps.setString(3, request.getSkillLevel());
                ps.setString(4, request.getExperienceYears());
                ps.setString(5, request.getBio());
                ps.setString(6, request.getProfilePicturePath());
                ps.executeUpdate();
            }

            // Step 4: Update request status
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
                if (conn != null)
                    conn.rollback();
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
            } catch (Exception ignored) {
            }
        }
    }

    /**
     * Reject a volunteer request with a reason.
     */
    public boolean rejectRequest(int requestId, String reason, int adminUserId) {
        String sql = "UPDATE volunteer_requests SET status = 'REJECTED', rejection_reason = ?, reviewed_date = CURRENT_TIMESTAMP, reviewed_by = ? WHERE request_id = ? AND status = 'PENDING'";

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
     * Check if username already exists in users or pending volunteer_requests.
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ? UNION SELECT 1 FROM volunteer_requests WHERE username = ? AND status = 'PENDING'";
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
     * Check if email already exists in users or pending volunteer_requests.
     */
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ? UNION SELECT 1 FROM volunteer_requests WHERE email = ? AND status = 'PENDING'";
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
     * Get count of pending requests (for admin dashboard badge).
     */
    public int getPendingCount() {
        String sql = "SELECT COUNT(*) FROM volunteer_requests WHERE status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next())
                return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private VolunteerRequest mapRequest(ResultSet rs) throws SQLException {
        VolunteerRequest r = new VolunteerRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setFullName(rs.getString("full_name"));
        r.setUsername(rs.getString("username"));
        r.setEmail(rs.getString("email"));
        r.setPhone(rs.getString("phone"));
        r.setPasswordHash(rs.getString("password_hash"));
        r.setCity(rs.getString("city"));
        r.setProfilePicturePath(rs.getString("profile_picture_path"));
        r.setExpertise(rs.getString("expertise"));
        r.setSkillLevel(rs.getString("skill_level"));
        r.setExperienceYears(rs.getString("experience_years"));
        r.setBio(rs.getString("bio"));
        r.setSampleGuide(rs.getString("sample_guide"));
        r.setSampleGuideFilePath(rs.getString("sample_guide_file_path"));
        r.setStatus(rs.getString("status"));
        r.setRejectionReason(rs.getString("rejection_reason"));
        r.setSubmittedDate(rs.getTimestamp("submitted_date"));
        r.setReviewedDate(rs.getTimestamp("reviewed_date"));
        r.setReviewedBy(rs.getInt("reviewed_by"));
        return r;
    }
}
