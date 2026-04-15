package com.dailyfixer.dao;

import com.dailyfixer.model.TechnicianAvailability;
import com.dailyfixer.util.DBConnection;

import java.sql.*;

public class TechnicianAvailabilityDAO {

    public void saveOrUpdateAvailability(TechnicianAvailability availability) throws Exception {
        // Check if availability exists
        TechnicianAvailability existing = getAvailabilityByTechnicianId(availability.getTechnicianId());
        
        if (existing != null) {
            updateAvailability(availability);
        } else {
            insertAvailability(availability);
        }
    }

    private void insertAvailability(TechnicianAvailability availability) throws Exception {
        String sql = "INSERT INTO technician_availability (technician_id, availability_mode, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_time, end_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, availability.getTechnicianId());
            ps.setString(2, availability.getAvailabilityMode());
            ps.setBoolean(3, availability.isMonday());
            ps.setBoolean(4, availability.isTuesday());
            ps.setBoolean(5, availability.isWednesday());
            ps.setBoolean(6, availability.isThursday());
            ps.setBoolean(7, availability.isFriday());
            ps.setBoolean(8, availability.isSaturday());
            ps.setBoolean(9, availability.isSunday());
            ps.setTime(10, availability.getStartTime());
            ps.setTime(11, availability.getEndTime());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    availability.setAvailabilityId(rs.getInt(1));
                }
            }
        }
    }

    private void updateAvailability(TechnicianAvailability availability) throws Exception {
        String sql = "UPDATE technician_availability SET availability_mode = ?, monday = ?, tuesday = ?, wednesday = ?, thursday = ?, friday = ?, saturday = ?, sunday = ?, start_time = ?, end_time = ? WHERE technician_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, availability.getAvailabilityMode());
            ps.setBoolean(2, availability.isMonday());
            ps.setBoolean(3, availability.isTuesday());
            ps.setBoolean(4, availability.isWednesday());
            ps.setBoolean(5, availability.isThursday());
            ps.setBoolean(6, availability.isFriday());
            ps.setBoolean(7, availability.isSaturday());
            ps.setBoolean(8, availability.isSunday());
            ps.setTime(9, availability.getStartTime());
            ps.setTime(10, availability.getEndTime());
            ps.setInt(11, availability.getTechnicianId());
            ps.executeUpdate();
        }
    }

    public TechnicianAvailability getAvailabilityByTechnicianId(int technicianId) throws Exception {
        String sql = "SELECT * FROM technician_availability WHERE technician_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractAvailabilityFromResultSet(rs);
                }
            }
        }
        return null;
    }

    private TechnicianAvailability extractAvailabilityFromResultSet(ResultSet rs) throws SQLException {
        TechnicianAvailability availability = new TechnicianAvailability();
        availability.setAvailabilityId(rs.getInt("availability_id"));
        availability.setTechnicianId(rs.getInt("technician_id"));
        availability.setAvailabilityMode(rs.getString("availability_mode"));
        availability.setMonday(rs.getBoolean("monday"));
        availability.setTuesday(rs.getBoolean("tuesday"));
        availability.setWednesday(rs.getBoolean("wednesday"));
        availability.setThursday(rs.getBoolean("thursday"));
        availability.setFriday(rs.getBoolean("friday"));
        availability.setSaturday(rs.getBoolean("saturday"));
        availability.setSunday(rs.getBoolean("sunday"));
        availability.setStartTime(rs.getTime("start_time"));
        availability.setEndTime(rs.getTime("end_time"));
        availability.setCreatedAt(rs.getTimestamp("created_at"));
        availability.setUpdatedAt(rs.getTimestamp("updated_at"));
        return availability;
    }
}
