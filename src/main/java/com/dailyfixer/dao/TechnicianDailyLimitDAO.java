package com.dailyfixer.dao;

import com.dailyfixer.model.TechnicianDailyLimit;
import com.dailyfixer.util.DBConnection;

import java.sql.*;

public class TechnicianDailyLimitDAO {

    private static final int DEFAULT_LIMIT = 5;

    /**
     * Returns the max bookings per day for a technician.
     * Falls back to DEFAULT_LIMIT (5) if no row exists.
     */
    public int getMaxBookingsPerDay(int technicianId) throws Exception {
        String sql = "SELECT max_bookings_per_day FROM technician_daily_limits WHERE technician_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return DEFAULT_LIMIT;
    }

    public void setLimit(int technicianId, int maxPerDay) throws Exception {
        String sql = "INSERT INTO technician_daily_limits (technician_id, max_bookings_per_day) VALUES (?, ?) " +
                     "ON DUPLICATE KEY UPDATE max_bookings_per_day = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, maxPerDay);
            ps.setInt(3, maxPerDay);
            ps.executeUpdate();
        }
    }

    public TechnicianDailyLimit getLimitRow(int technicianId) throws Exception {
        String sql = "SELECT * FROM technician_daily_limits WHERE technician_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TechnicianDailyLimit limit = new TechnicianDailyLimit();
                    limit.setLimitId(rs.getInt("limit_id"));
                    limit.setTechnicianId(rs.getInt("technician_id"));
                    limit.setMaxBookingsPerDay(rs.getInt("max_bookings_per_day"));
                    limit.setCreatedAt(rs.getTimestamp("created_at"));
                    limit.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return limit;
                }
            }
        }
        return null;
    }
}
