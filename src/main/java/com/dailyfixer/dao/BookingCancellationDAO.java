package com.dailyfixer.dao;

import com.dailyfixer.model.BookingCancellation;
import com.dailyfixer.util.DBConnection;

import java.sql.*;

public class BookingCancellationDAO {

    public void createCancellation(BookingCancellation cancellation) throws Exception {
        String sql = "INSERT INTO booking_cancellations (booking_id, cancelled_by, cancellation_reason) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, cancellation.getBookingId());
            ps.setInt(2, cancellation.getCancelledBy());
            ps.setString(3, cancellation.getCancellationReason());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    cancellation.setCancellationId(rs.getInt(1));
                }
            }
        }
    }

    public BookingCancellation getCancellationByBookingId(int bookingId) throws Exception {
        String sql = "SELECT bc.*, u.first_name, u.last_name " +
                     "FROM booking_cancellations bc " +
                     "JOIN users u ON bc.cancelled_by = u.user_id " +
                     "WHERE bc.booking_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BookingCancellation cancellation = new BookingCancellation();
                    cancellation.setCancellationId(rs.getInt("cancellation_id"));
                    cancellation.setBookingId(rs.getInt("booking_id"));
                    cancellation.setCancelledBy(rs.getInt("cancelled_by"));
                    cancellation.setCancellationReason(rs.getString("cancellation_reason"));
                    cancellation.setCancelledAt(rs.getTimestamp("cancelled_at"));
                    cancellation.setCancelledByName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    return cancellation;
                }
            }
        }
        return null;
    }
}
