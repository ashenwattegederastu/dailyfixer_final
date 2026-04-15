package com.dailyfixer.dao;

import com.dailyfixer.model.BookingNoShow;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingNoShowDAO {

    public void recordNoShow(BookingNoShow ns) throws Exception {
        String sql = "INSERT IGNORE INTO booking_no_shows " +
                     "(booking_id, technician_id, scheduled_at, notes) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ns.getBookingId());
            ps.setInt(2, ns.getTechnicianId());
            ps.setTimestamp(3, ns.getScheduledAt());
            ps.setString(4, ns.getNotes());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) ns.setNoShowId(rs.getInt(1));
            }
        }
    }

    /**
     * Returns ACCEPTED bookings whose scheduled datetime + gracePeriodMinutes has passed,
     * meaning the technician still hasn't moved them to IN_PROGRESS.
     */
    public List<int[]> getNoShowCandidates(int gracePeriodMinutes) throws Exception {
        // Returns [booking_id, technician_id, user_id]
        String sql = "SELECT b.booking_id, b.technician_id, b.user_id " +
                     "FROM bookings b " +
                     "LEFT JOIN booking_no_shows ns ON b.booking_id = ns.booking_id " +
                     "WHERE b.status = 'ACCEPTED' " +
                     "  AND TIMESTAMP(b.booking_date, b.booking_time) < DATE_SUB(NOW(), INTERVAL ? MINUTE) " +
                     "  AND ns.no_show_id IS NULL";
        List<int[]> results = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, gracePeriodMinutes);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(new int[]{rs.getInt("booking_id"), rs.getInt("technician_id"), rs.getInt("user_id")});
                }
            }
        }
        return results;
    }

    /** Count no-shows for a technician (for internal reporting). */
    public int countNoShowsByTechnician(int technicianId) throws Exception {
        String sql = "SELECT COUNT(*) FROM booking_no_shows WHERE technician_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
