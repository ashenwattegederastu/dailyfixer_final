package com.dailyfixer.dao;

import com.dailyfixer.model.DriverIncident;
import com.dailyfixer.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DriverIncidentDAO {

    /**
     * Logs an incident for a driver in the driver_incidents table.
     */
    public boolean logIncident(int driverId, int assignmentId, String orderId, String incidentType, String description) {
        String sql = "INSERT INTO driver_incidents (driver_id, assignment_id, order_id, incident_type, description) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.setInt(2, assignmentId);
            ps.setString(3, orderId);
            ps.setString(4, incidentType);
            ps.setString(5, description);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns a summary list of all drivers who have incidents, aggregated.
     */
    public List<DriverIncident> getDriverIncidentSummary() {
        List<DriverIncident> summaries = new ArrayList<>();
        String sql = "SELECT di.driver_id, u.first_name, u.last_name, u.email, u.status AS driver_status, " +
                     "COUNT(di.incident_id) as total_incidents, " +
                     "SUM(CASE WHEN di.incident_type = 'PICKUP_NO_DELIVERY' THEN 1 ELSE 0 END) as pickup_miss_count, " +
                     "SUM(CASE WHEN di.incident_type = 'ACCEPT_NO_PICKUP' THEN 1 ELSE 0 END) as accept_miss_count, " +
                     "MAX(di.created_at) as last_incident " +
                     "FROM driver_incidents di " +
                     "JOIN users u ON u.user_id = di.driver_id " +
                     "GROUP BY di.driver_id, u.first_name, u.last_name, u.email, u.status " +
                     "ORDER BY total_incidents DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DriverIncident summary = new DriverIncident();
                summary.setDriverId(rs.getInt("driver_id"));
                String fName = rs.getString("first_name");
                String lName = rs.getString("last_name");
                summary.setDriverName((fName != null ? fName : "") + (lName != null ? " " + lName : ""));
                summary.setDriverEmail(rs.getString("email"));
                summary.setDriverStatus(rs.getString("driver_status"));
                summary.setTotalIncidents(rs.getInt("total_incidents"));
                summary.setPickupMissCount(rs.getInt("pickup_miss_count"));
                summary.setAcceptMissCount(rs.getInt("accept_miss_count"));
                summary.setLastIncident(rs.getTimestamp("last_incident"));
                
                summaries.add(summary);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return summaries;
    }

    /**
     * Gets all specific incidents for a single driver.
     */
    public List<DriverIncident> getIncidentsByDriverId(int driverId) {
        List<DriverIncident> incidents = new ArrayList<>();
        String sql = "SELECT * FROM driver_incidents WHERE driver_id = ? ORDER BY created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    incidents.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return incidents;
    }

    /**
     * Gets all incidents related to orders dispatched by a given store owner.
     * Used by the store dashboard to show delivery incidents on their orders.
     */
    public List<DriverIncident> getIncidentsByStoreOwnerUserId(int storeOwnerUserId) {
        List<DriverIncident> incidents = new ArrayList<>();
        String sql = "SELECT di.*, u.first_name, u.last_name, u.email AS driver_email " +
                     "FROM driver_incidents di " +
                     "JOIN delivery_assignments da ON di.assignment_id = da.assignment_id " +
                     "JOIN stores s ON da.store_id = s.store_id " +
                     "JOIN users u ON di.driver_id = u.user_id " +
                     "WHERE s.user_id = ? " +
                     "ORDER BY di.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, storeOwnerUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DriverIncident incident = mapRow(rs);
                    String fName = rs.getString("first_name");
                    String lName = rs.getString("last_name");
                    incident.setDriverName((fName != null ? fName : "") + (lName != null ? " " + lName : ""));
                    incident.setDriverEmail(rs.getString("driver_email"));
                    incidents.add(incident);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return incidents;
    }

    /**
     * Marks an incident as reviewed by an admin.
     */
    public boolean markReviewed(int incidentId, int adminId, String notes) {
        String sql = "UPDATE driver_incidents SET reviewed = 1, reviewed_by = ?, reviewed_at = NOW(), review_notes = ? WHERE incident_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setString(2, notes);
            ps.setInt(3, incidentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Gets all individual incidents (for admin review view).
     */
    public List<DriverIncident> getAllIncidents() {
        List<DriverIncident> incidents = new ArrayList<>();
        String sql = "SELECT di.*, u.first_name, u.last_name, u.email AS driver_email " +
                     "FROM driver_incidents di " +
                     "JOIN users u ON di.driver_id = u.user_id " +
                     "ORDER BY di.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DriverIncident incident = mapRow(rs);
                String fName = rs.getString("first_name");
                String lName = rs.getString("last_name");
                incident.setDriverName((fName != null ? fName : "") + (lName != null ? " " + lName : ""));
                incident.setDriverEmail(rs.getString("driver_email"));
                incidents.add(incident);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return incidents;
    }

    private DriverIncident mapRow(ResultSet rs) throws Exception {
        DriverIncident incident = new DriverIncident();
        incident.setIncidentId(rs.getInt("incident_id"));
        incident.setDriverId(rs.getInt("driver_id"));
        incident.setAssignmentId(rs.getInt("assignment_id"));
        incident.setOrderId(rs.getString("order_id"));
        incident.setIncidentType(rs.getString("incident_type"));
        incident.setDescription(rs.getString("description"));
        incident.setReviewed(rs.getBoolean("reviewed"));
        incident.setReviewedBy(rs.getInt("reviewed_by"));
        incident.setReviewedAt(rs.getTimestamp("reviewed_at"));
        incident.setReviewNotes(rs.getString("review_notes"));
        incident.setCreatedAt(rs.getTimestamp("created_at"));
        return incident;
    }
}
