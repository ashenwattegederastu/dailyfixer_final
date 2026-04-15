package com.dailyfixer.dao;

import com.dailyfixer.model.ClientNoShowPenalty;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the client_no_show_penalties table.
 *
 * Status flow:
 *   PENDING         – penalty created when technician marks CLIENT_NO_SHOW
 *   PROOF_UPLOADED  – client uploaded payment proof
 *   CONFIRMED_PAID  – technician confirmed receipt; resolved
 *   ADMIN_REVIEW    – technician marked not paid, OR 48-hr tech action timeout
 *   RESOLVED        – admin marked as paid
 *   FRAUD_SUSPENDED – admin suspended client for fraudulent proof upload
 */
public class ClientNoShowPenaltyDAO {

    /** Hours before a PROOF_UPLOADED penalty with no technician action is auto-escalated to admin. */
    public static final int TECH_ACTION_WINDOW_HOURS = 48;

    // ── Create ───────────────────────────────────────────────────────────────

    /**
     * Creates a new PENDING penalty record for a CLIENT_NO_SHOW booking.
     * Does nothing if a penalty already exists for this booking (idempotent).
     * @param techProofPath relative path to the technician's arrival proof photo
     */
    public ClientNoShowPenalty createPenalty(int bookingId, int clientId, int technicianId, String techProofPath) throws Exception {
        String sql = "INSERT IGNORE INTO client_no_show_penalties "
                   + "(booking_id, client_id, technician_id, tech_proof_path) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, bookingId);
            ps.setInt(2, clientId);
            ps.setInt(3, technicianId);
            ps.setString(4, techProofPath);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return getByBookingId(bookingId);
                }
            }
        }
        // Row already existed — return existing
        return getByBookingId(bookingId);
    }

    // ── Fetch ────────────────────────────────────────────────────────────────

    public ClientNoShowPenalty getByBookingId(int bookingId) throws Exception {
        String sql = BASE_SELECT + " WHERE p.booking_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public ClientNoShowPenalty getByPenaltyId(int penaltyId) throws Exception {
        String sql = BASE_SELECT + " WHERE p.penalty_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, penaltyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /** Returns all active penalties visible to a client (PENDING or PROOF_UPLOADED). */
    public List<ClientNoShowPenalty> getActiveForClient(int clientId) throws Exception {
        String sql = BASE_SELECT
                + " WHERE p.client_id = ? AND p.status IN ('PENDING','PROOF_UPLOADED')"
                + " ORDER BY p.created_at DESC";
        return fetchList(sql, clientId);
    }

    /** Returns all penalties for a given client (for history). */
    public List<ClientNoShowPenalty> getAllForClient(int clientId) throws Exception {
        String sql = BASE_SELECT + " WHERE p.client_id = ? ORDER BY p.created_at DESC";
        return fetchList(sql, clientId);
    }

    /** Returns PROOF_UPLOADED penalties where the technician must review. */
    public List<ClientNoShowPenalty> getPendingReviewForTechnician(int technicianId) throws Exception {
        String sql = BASE_SELECT
                + " WHERE p.technician_id = ? AND p.status = 'PROOF_UPLOADED'"
                + " ORDER BY p.proof_uploaded_at ASC";
        return fetchList(sql, technicianId);
    }

    /** Returns all penalties that need admin review (ADMIN_REVIEW status). */
    public List<ClientNoShowPenalty> getAllForAdminReview() throws Exception {
        String sql = BASE_SELECT + " WHERE p.status = 'ADMIN_REVIEW' ORDER BY p.created_at ASC";
        return fetchListNoParam(sql);
    }

    /** Returns PROOF_UPLOADED penalties whose proof_uploaded_at is older than the tech action window. */
    public List<ClientNoShowPenalty> getEscalationCandidates() throws Exception {
        String sql = BASE_SELECT
                + " WHERE p.status = 'PROOF_UPLOADED'"
                + "   AND p.proof_uploaded_at < DATE_SUB(NOW(), INTERVAL " + TECH_ACTION_WINDOW_HOURS + " HOUR)";
        return fetchListNoParam(sql);
    }

    // ── Client Action: Upload Proof ──────────────────────────────────────────

    public void uploadProof(int penaltyId, String proofPath) throws Exception {
        String sql = "UPDATE client_no_show_penalties "
                   + "SET status = 'PROOF_UPLOADED', proof_path = ?, proof_uploaded_at = NOW() "
                   + "WHERE penalty_id = ? AND status = 'PENDING'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, proofPath);
            ps.setInt(2, penaltyId);
            ps.executeUpdate();
        }
    }

    // ── Technician Actions ───────────────────────────────────────────────────

    public void technicianConfirmPaid(int penaltyId) throws Exception {
        String sql = "UPDATE client_no_show_penalties "
                   + "SET status = 'CONFIRMED_PAID', tech_action = 'CONFIRMED_PAID', tech_action_at = NOW() "
                   + "WHERE penalty_id = ? AND status = 'PROOF_UPLOADED'";
        execute(sql, penaltyId);
    }

    public void technicianMarkNotPaid(int penaltyId) throws Exception {
        String sql = "UPDATE client_no_show_penalties "
                   + "SET status = 'ADMIN_REVIEW', tech_action = 'MARKED_NOT_PAID', tech_action_at = NOW() "
                   + "WHERE penalty_id = ? AND status = 'PROOF_UPLOADED'";
        execute(sql, penaltyId);
    }

    // ── Escalation Job ───────────────────────────────────────────────────────

    /** Called by the background job — moves timed-out tech reviews to admin. */
    public int escalateOverdueTechReviews() throws Exception {
        String sql = "UPDATE client_no_show_penalties "
                   + "SET status = 'ADMIN_REVIEW' "
                   + "WHERE status = 'PROOF_UPLOADED' "
                   + "  AND proof_uploaded_at < DATE_SUB(NOW(), INTERVAL " + TECH_ACTION_WINDOW_HOURS + " HOUR)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            return ps.executeUpdate();
        }
    }

    // ── Admin Actions ────────────────────────────────────────────────────────

    public void adminMarkPaid(int penaltyId, int adminId) throws Exception {
        String sql = "UPDATE client_no_show_penalties "
                   + "SET status = 'RESOLVED', admin_action = 'MARK_PAID', "
                   + "    admin_action_at = NOW(), admin_id = ? "
                   + "WHERE penalty_id = ? AND status = 'ADMIN_REVIEW'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setInt(2, penaltyId);
            ps.executeUpdate();
        }
    }

    public void adminSuspendClientForFraud(int penaltyId, int adminId) throws Exception {
        // 1. Update penalty status
        String sql = "UPDATE client_no_show_penalties "
                   + "SET status = 'FRAUD_SUSPENDED', admin_action = 'SUSPEND_CLIENT', "
                   + "    admin_action_at = NOW(), admin_id = ? "
                   + "WHERE penalty_id = ? AND status = 'ADMIN_REVIEW'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setInt(2, penaltyId);
            ps.executeUpdate();
        }

        // 2. Suspend the client account
        ClientNoShowPenalty penalty = getByPenaltyId(penaltyId);
        if (penalty != null) {
            String suspendSql = "UPDATE users SET status = 'SUSPENDED' WHERE user_id = ?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(suspendSql)) {
                ps.setInt(1, penalty.getClientId());
                ps.executeUpdate();
            }
        }
    }

    // ── Counts (for badges/dashboards) ───────────────────────────────────────

    public int countPendingReviewForTechnician(int technicianId) throws Exception {
        String sql = "SELECT COUNT(*) FROM client_no_show_penalties "
                   + "WHERE technician_id = ? AND status = 'PROOF_UPLOADED'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countForAdminReview() throws Exception {
        String sql = "SELECT COUNT(*) FROM client_no_show_penalties WHERE status = 'ADMIN_REVIEW'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ── Private helpers ──────────────────────────────────────────────────────

    private static final String BASE_SELECT =
        "SELECT p.*, "
        + "CONCAT(c.first_name, ' ', c.last_name) AS client_name, "
        + "CONCAT(t.first_name, ' ', t.last_name) AS technician_name, "
        + "s.service_name AS service_name, "
        + "b.booking_date AS booking_date "
        + "FROM client_no_show_penalties p "
        + "JOIN users c ON c.user_id = p.client_id "
        + "JOIN users t ON t.user_id = p.technician_id "
        + "JOIN bookings b ON b.booking_id = p.booking_id "
        + "JOIN services s ON s.service_id = b.service_id";

    private List<ClientNoShowPenalty> fetchList(String sql, int param) throws Exception {
        List<ClientNoShowPenalty> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private List<ClientNoShowPenalty> fetchListNoParam(String sql) throws Exception {
        List<ClientNoShowPenalty> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private void execute(String sql, int param) throws Exception {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            ps.executeUpdate();
        }
    }

    private ClientNoShowPenalty mapRow(ResultSet rs) throws SQLException {
        ClientNoShowPenalty p = new ClientNoShowPenalty();
        p.setPenaltyId(rs.getInt("penalty_id"));
        p.setBookingId(rs.getInt("booking_id"));
        p.setClientId(rs.getInt("client_id"));
        p.setTechnicianId(rs.getInt("technician_id"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setStatus(rs.getString("status"));
        p.setTechProofPath(rs.getString("tech_proof_path"));
        p.setProofPath(rs.getString("proof_path"));
        p.setProofUploadedAt(rs.getTimestamp("proof_uploaded_at"));
        p.setTechAction(rs.getString("tech_action"));
        p.setTechActionAt(rs.getTimestamp("tech_action_at"));
        p.setAdminAction(rs.getString("admin_action"));
        p.setAdminActionAt(rs.getTimestamp("admin_action_at"));
        int adminId = rs.getInt("admin_id");
        p.setAdminId(rs.wasNull() ? null : adminId);
        p.setCreatedAt(rs.getTimestamp("created_at"));
        // Transient join columns
        p.setClientName(rs.getString("client_name"));
        p.setTechnicianName(rs.getString("technician_name"));
        p.setServiceName(rs.getString("service_name"));
        Object bd = rs.getObject("booking_date");
        p.setBookingDate(bd != null ? bd.toString() : null);
        return p;
    }
}
