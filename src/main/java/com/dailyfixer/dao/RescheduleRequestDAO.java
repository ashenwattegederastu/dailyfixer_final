package com.dailyfixer.dao;

import com.dailyfixer.model.RescheduleRequest;
import com.dailyfixer.util.DBConnection;

import java.sql.*;

public class RescheduleRequestDAO {

    public void createRequest(RescheduleRequest req) throws Exception {
        String sql = "INSERT INTO booking_reschedule_requests " +
                     "(booking_id, requested_by, new_date, new_time, reason) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, req.getBookingId());
            ps.setInt(2, req.getRequestedBy());
            ps.setDate(3, req.getNewDate());
            ps.setTime(4, req.getNewTime());
            ps.setString(5, req.getReason());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) req.setRescheduleId(rs.getInt(1));
            }
        }
    }

    /** Returns the single PENDING reschedule request for a booking, or null. */
    public RescheduleRequest getPendingByBookingId(int bookingId) throws Exception {
        String sql = "SELECT rr.*, CONCAT(u.first_name, ' ', u.last_name) AS requester_name " +
                     "FROM booking_reschedule_requests rr " +
                     "JOIN users u ON rr.requested_by = u.user_id " +
                     "WHERE rr.booking_id = ? AND rr.status = 'PENDING' " +
                     "ORDER BY rr.created_at DESC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return extract(rs);
            }
        }
        return null;
    }

    /** Accept a pending reschedule request. */
    public void acceptRequest(int rescheduleId) throws Exception {
        String sql = "UPDATE booking_reschedule_requests " +
                     "SET status = 'ACCEPTED', responded_at = NOW() WHERE reschedule_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, rescheduleId);
            ps.executeUpdate();
        }
    }

    /** Reject a pending reschedule request. */
    public void rejectRequest(int rescheduleId) throws Exception {
        String sql = "UPDATE booking_reschedule_requests " +
                     "SET status = 'REJECTED', responded_at = NOW() WHERE reschedule_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, rescheduleId);
            ps.executeUpdate();
        }
    }

    /** Check if requestedBy already has a PENDING request for this booking (prevent duplicates). */
    public boolean hasPendingRequest(int bookingId, int requestedBy) throws Exception {
        String sql = "SELECT COUNT(*) FROM booking_reschedule_requests " +
                     "WHERE booking_id = ? AND requested_by = ? AND status = 'PENDING'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setInt(2, requestedBy);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public RescheduleRequest getById(int rescheduleId) throws Exception {
        String sql = "SELECT rr.*, CONCAT(u.first_name, ' ', u.last_name) AS requester_name " +
                     "FROM booking_reschedule_requests rr " +
                     "JOIN users u ON rr.requested_by = u.user_id " +
                     "WHERE rr.reschedule_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, rescheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return extract(rs);
            }
        }
        return null;
    }

    private RescheduleRequest extract(ResultSet rs) throws SQLException {
        RescheduleRequest req = new RescheduleRequest();
        req.setRescheduleId(rs.getInt("reschedule_id"));
        req.setBookingId(rs.getInt("booking_id"));
        req.setRequestedBy(rs.getInt("requested_by"));
        req.setNewDate(rs.getDate("new_date"));
        req.setNewTime(rs.getTime("new_time"));
        req.setReason(rs.getString("reason"));
        req.setStatus(rs.getString("status"));
        req.setRespondedAt(rs.getTimestamp("responded_at"));
        req.setCreatedAt(rs.getTimestamp("created_at"));
        try { req.setRequesterName(rs.getString("requester_name")); } catch (SQLException ignored) {}
        return req;
    }
}
