package com.dailyfixer.dao;

import com.dailyfixer.model.BookingNotification;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingNotificationDAO {

    public void createNotification(int userId, int bookingId, String message) throws Exception {
        String sql = "INSERT INTO booking_notifications (user_id, booking_id, message) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, bookingId);
            ps.setString(3, message);
            ps.executeUpdate();
        }
    }

    public List<BookingNotification> getUnreadByUserId(int userId) throws Exception {
        String sql = "SELECT * FROM booking_notifications WHERE user_id = ? AND is_read = 0 " +
                     "ORDER BY created_at DESC LIMIT 20";
        List<BookingNotification> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extract(rs));
            }
        }
        return list;
    }

    public List<BookingNotification> getAllByUserId(int userId) throws Exception {
        String sql = "SELECT * FROM booking_notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50";
        List<BookingNotification> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extract(rs));
            }
        }
        return list;
    }

    public int countUnread(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM booking_notifications WHERE user_id = ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public void markAllReadForUser(int userId) throws Exception {
        String sql = "UPDATE booking_notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    private BookingNotification extract(ResultSet rs) throws SQLException {
        BookingNotification n = new BookingNotification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setUserId(rs.getInt("user_id"));
        n.setBookingId(rs.getInt("booking_id"));
        n.setMessage(rs.getString("message"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
