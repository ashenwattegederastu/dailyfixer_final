package com.dailyfixer.dao;

import com.dailyfixer.model.TechnicianPenalty;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the 3-strike progressive no-show penalty system.
 *
 * Business rules (all enforced here, not in the job):
 *   Rolling window : 90 days
 *   1st no-show   → Level 1: Warning (notification only, no restriction)
 *   2nd no-show   → Level 2: Listing suppressed for 7 days
 *   3rd+ no-show  → Level 3: Account suspended (admin lift required)
 *
 * A higher-level penalty supersedes a lower one; once at level 3 the
 * technician stays suspended even if additional no-shows are recorded.
 */
public class TechnicianPenaltyDAO {

    /** Rolling window in days for counting no-shows. */
    private static final int WINDOW_DAYS = 90;

    /** How long a level-2 suppression lasts (in milliseconds). */
    private static final long SUPPRESS_DURATION_MS = 7L * 24 * 60 * 60 * 1000;

    // ─────────────────────────────────────────────────────────────────────────
    // Public API
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Evaluates whether this no-show warrants a penalty and, if so, inserts a
     * row into technician_penalty_log and updates the user row for level 3.
     *
     * @param noShowId    the just-inserted booking_no_shows.no_show_id
     * @param technicianId the technician's user_id
     * @return the penalty level issued (1, 2, or 3), or 0 if none was issued
     */
    public int issueIfNeeded(int noShowId, int technicianId) throws Exception {
        int recentCount = countRecentNoShows(technicianId);

        int requiredLevel;
        if      (recentCount >= 3) requiredLevel = 3;
        else if (recentCount == 2) requiredLevel = 2;
        else                       requiredLevel = 1;

        // Skip if already at this level or higher (no duplicate records)
        if (getHighestActivePenaltyLevel(technicianId) >= requiredLevel) return 0;

        TechnicianPenalty penalty = new TechnicianPenalty();
        penalty.setTechnicianId(technicianId);
        penalty.setNoShowId(noShowId);
        penalty.setPenaltyLevel(requiredLevel);

        switch (requiredLevel) {
            case 1:
                penalty.setNotes("Warning: 1st no-show recorded within the 90-day window.");
                break;
            case 2:
                penalty.setExpiresAt(new Timestamp(System.currentTimeMillis() + SUPPRESS_DURATION_MS));
                penalty.setNotes("Listing suppressed for 7 days: 2nd no-show within the 90-day window.");
                break;
            case 3:
                penalty.setNotes("Account suspended: 3 or more no-shows within the 90-day window. Admin review required.");
                suspendUser(technicianId);
                break;
        }

        insertPenalty(penalty);
        return requiredLevel;
    }

    /**
     * Returns a human-readable message to send to the technician as a
     * notification when a penalty is issued.
     */
    public String buildPenaltyMessage(int level) {
        switch (level) {
            case 1:
                return "Warning: A no-show has been recorded against your account. "
                     + "Two or more no-shows within 90 days will suppress your service listing. "
                     + "Please review the No-Show Policy.";
            case 2:
                return "Notice: Your service listing has been suppressed for 7 days due to "
                     + "a second no-show within 90 days. Clients will not be able to find your "
                     + "services during this period. Please review the No-Show Policy.";
            case 3:
                return "Your account has been suspended due to 3 or more no-shows within 90 days. "
                     + "Please contact DailyFixer support to have your account reviewed and reinstated.";
            default:
                return "A penalty has been applied to your account due to a no-show.";
        }
    }

    /**
     * Returns the highest penalty level with an active (not lifted, not expired)
     * record for the given technician. Returns 0 if no active penalties exist.
     */
    public int getHighestActivePenaltyLevel(int technicianId) throws Exception {
        String sql = "SELECT MAX(penalty_level) FROM technician_penalty_log "
                   + "WHERE technician_id = ? "
                   + "  AND lifted_at IS NULL "
                   + "  AND (expires_at IS NULL OR expires_at > NOW())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int val = rs.getInt(1);
                    return rs.wasNull() ? 0 : val;
                }
            }
        }
        return 0;
    }

    /**
     * Returns every currently active (not lifted, not expired) penalty across all technicians.
     * Includes the technician's full name via a JOIN on users.
     * Used by the admin penalty management page.
     */
    public List<TechnicianPenalty> getAllActivePenalties() throws Exception {
        String sql = "SELECT tpl.*, CONCAT(u.first_name, ' ', u.last_name) AS technician_name "
                   + "FROM technician_penalty_log tpl "
                   + "JOIN users u ON tpl.technician_id = u.user_id "
                   + "WHERE tpl.lifted_at IS NULL "
                   + "  AND (tpl.expires_at IS NULL OR tpl.expires_at > NOW()) "
                   + "ORDER BY tpl.penalty_level DESC, tpl.issued_at DESC";
        List<TechnicianPenalty> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TechnicianPenalty p = extract(rs);
                p.setTechnicianName(rs.getString("technician_name"));
                list.add(p);
            }
        }
        return list;
    }

    /**
     * Retrieves the full penalty history for a technician, newest first.
     * Used for the technician's own dashboard view.
     */
    public List<TechnicianPenalty> getPenaltyHistory(int technicianId) throws Exception {
        String sql = "SELECT * FROM technician_penalty_log "
                   + "WHERE technician_id = ? ORDER BY issued_at DESC";
        List<TechnicianPenalty> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extract(rs));
            }
        }
        return list;
    }

    /**
     * Admin operation: lifts a specific penalty. For level-3 penalties this
     * also reinstates the user account to 'active'.
     */
    public void liftPenalty(int penaltyId, int adminUserId) throws Exception {
        // Fetch first to check if it's level 3
        String fetchSql = "SELECT technician_id, penalty_level FROM technician_penalty_log WHERE penalty_id = ?";
        int technicianId = 0;
        int level = 0;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(fetchSql)) {
            ps.setInt(1, penaltyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    technicianId = rs.getInt("technician_id");
                    level = rs.getInt("penalty_level");
                }
            }
        }
        if (technicianId == 0) return; // not found

        String liftSql = "UPDATE technician_penalty_log "
                       + "SET lifted_by = ?, lifted_at = NOW() "
                       + "WHERE penalty_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(liftSql)) {
            ps.setInt(1, adminUserId);
            ps.setInt(2, penaltyId);
            ps.executeUpdate();
        }

        // If level 3, reinstate the account only if there are no other active level-3 penalties
        if (level == 3 && getHighestActivePenaltyLevel(technicianId) < 3) {
            reinstateUser(technicianId);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Private helpers
    // ─────────────────────────────────────────────────────────────────────────

    /** Counts no-shows for a technician within the rolling WINDOW_DAYS period. */
    private int countRecentNoShows(int technicianId) throws Exception {
        String sql = "SELECT COUNT(*) FROM booking_no_shows "
                   + "WHERE technician_id = ? "
                   + "  AND detected_at >= DATE_SUB(NOW(), INTERVAL ? DAY)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, WINDOW_DAYS);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private void insertPenalty(TechnicianPenalty p) throws Exception {
        String sql = "INSERT INTO technician_penalty_log "
                   + "(technician_id, no_show_id, penalty_level, expires_at, notes) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, p.getTechnicianId());
            ps.setInt(2, p.getNoShowId());
            ps.setInt(3, p.getPenaltyLevel());
            if (p.getExpiresAt() != null) ps.setTimestamp(4, p.getExpiresAt());
            else                          ps.setNull(4, Types.TIMESTAMP);
            ps.setString(5, p.getNotes());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) p.setPenaltyId(rs.getInt(1));
            }
        }
    }

    private void suspendUser(int technicianId) throws Exception {
        String sql = "UPDATE users SET status = 'suspended' WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.executeUpdate();
        }
    }

    private void reinstateUser(int technicianId) throws Exception {
        String sql = "UPDATE users SET status = 'active' WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.executeUpdate();
        }
    }

    private TechnicianPenalty extract(ResultSet rs) throws SQLException {
        TechnicianPenalty p = new TechnicianPenalty();
        p.setPenaltyId(rs.getInt("penalty_id"));
        p.setTechnicianId(rs.getInt("technician_id"));
        p.setNoShowId(rs.getInt("no_show_id"));
        p.setPenaltyLevel(rs.getInt("penalty_level"));
        p.setIssuedAt(rs.getTimestamp("issued_at"));
        p.setExpiresAt(rs.getTimestamp("expires_at"));
        int lb = rs.getInt("lifted_by");
        if (!rs.wasNull()) p.setLiftedBy(lb);
        p.setLiftedAt(rs.getTimestamp("lifted_at"));
        p.setNotes(rs.getString("notes"));
        return p;
    }
}
