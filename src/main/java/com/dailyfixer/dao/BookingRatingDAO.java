package com.dailyfixer.dao;

import com.dailyfixer.model.BookingRating;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingRatingDAO {

    /**
     * Submit a booking rating. Ignores duplicate submissions (unique key on booking_id + rating_type).
     */
    public boolean submitRating(BookingRating r) throws Exception {
        String sql = "INSERT IGNORE INTO booking_ratings " +
                     "(booking_id, rated_by, rated_user, rating_type, rating, review) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, r.getBookingId());
            ps.setInt(2, r.getRatedBy());
            ps.setInt(3, r.getRatedUser());
            ps.setString(4, r.getRatingType());
            ps.setInt(5, r.getRating());
            ps.setString(6, r.getReview());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) r.setRatingId(rs.getInt(1));
                }
                return true;
            }
            return false; // duplicate, already rated
        }
    }

    /**
     * Check if a rating already exists for this booking + type.
     */
    public boolean hasRated(int bookingId, String ratingType) throws Exception {
        String sql = "SELECT COUNT(*) FROM booking_ratings WHERE booking_id = ? AND rating_type = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setString(2, ratingType);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    /**
     * Average technician rating across all their completed bookings.
     */
    public double getAverageRatingForTechnician(int technicianId) throws Exception {
        String sql = "SELECT AVG(rating) FROM booking_ratings " +
                     "WHERE rating_type = 'TECHNICIAN_RATING' AND rated_user = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                double avg = rs.getDouble(1);
                return rs.wasNull() ? 0.0 : avg;
            }
        }
        return 0.0;
    }

    /**
     * Total number of ratings a technician has received.
     */
    public int getRatingCountForTechnician(int technicianId) throws Exception {
        String sql = "SELECT COUNT(*) FROM booking_ratings " +
                     "WHERE rating_type = 'TECHNICIAN_RATING' AND rated_user = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /**
     * Average client rating across all their completed bookings.
     */
    public double getAverageRatingForUser(int userId) throws Exception {
        String sql = "SELECT AVG(rating) FROM booking_ratings " +
                     "WHERE rating_type = 'CLIENT_RATING' AND rated_user = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                double avg = rs.getDouble(1);
                return rs.wasNull() ? 0.0 : avg;
            }
        }
        return 0.0;
    }

    /**
     * All written reviews (non-null/blank review text) left for a technician,
     * ordered newest first. Used for the "View Reviews" modal.
     */
    public List<BookingRating> getTechnicianReviews(int technicianId) throws Exception {
        List<BookingRating> reviews = new ArrayList<>();
        String sql = "SELECT br.*, " +
                     "CONCAT(u.first_name, ' ', u.last_name) AS rater_name " +
                     "FROM booking_ratings br " +
                     "JOIN users u ON br.rated_by = u.user_id " +
                     "WHERE br.rating_type = 'TECHNICIAN_RATING' " +
                     "AND br.rated_user = ? " +
                     "AND br.review IS NOT NULL AND TRIM(br.review) <> '' " +
                     "ORDER BY br.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BookingRating br = new BookingRating();
                br.setRatingId(rs.getInt("rating_id"));
                br.setBookingId(rs.getInt("booking_id"));
                br.setRatedBy(rs.getInt("rated_by"));
                br.setRatedUser(rs.getInt("rated_user"));
                br.setRatingType(rs.getString("rating_type"));
                br.setRating(rs.getInt("rating"));
                br.setReview(rs.getString("review"));
                br.setCreatedAt(rs.getTimestamp("created_at"));
                br.setRaterName(rs.getString("rater_name"));
                reviews.add(br);
            }
        }
        return reviews;
    }
}
