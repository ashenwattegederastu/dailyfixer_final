package com.dailyfixer.dao;

import com.dailyfixer.model.Vehicle;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleDAO {

    // ─────────────────────────────────────────────────────────────
    // Fetch THE vehicle for a specific driver (at most 1 now)
    // ─────────────────────────────────────────────────────────────
    public Vehicle getVehicleByDriver(int driverId) {
        String sql = "SELECT * FROM vehicles WHERE driver_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, driverId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVehicle(rs);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching vehicle for driver " + driverId, e);
        }
        return null;
    }

    // Legacy list wrapper — used by driverdashmain.jsp and deliveryrequests.jsp which need a List
    public List<Vehicle> getVehiclesByDriver(int driverId) {
        List<Vehicle> list = new ArrayList<>();
        Vehicle v = getVehicleByDriver(driverId);
        if (v != null) list.add(v);
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // Fetch a single vehicle by its PK id
    // ─────────────────────────────────────────────────────────────
    public Vehicle getVehicleById(int id) {
        String sql = "SELECT * FROM vehicles WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVehicle(rs);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching vehicle with ID " + id, e);
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────
    // Add a new vehicle (1 per driver enforced by DB unique key)
    // ─────────────────────────────────────────────────────────────
    public boolean addVehicle(Vehicle v) {
        String sql = "INSERT INTO vehicles " +
                "(driver_id, vehicle_type, brand, model, plate_number, vehicle_category, " +
                "img_front, img_left, img_right, img_back, " +
                "doc_registration, doc_insurance, doc_revenue) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, v.getDriverId());
            stmt.setString(2, v.getBrand());   // vehicle_type re-used as brand
            stmt.setString(3, v.getBrand());
            stmt.setString(4, v.getModel());
            stmt.setString(5, v.getPlateNumber());
            stmt.setString(6, v.getVehicleCategory());
            stmt.setString(7, v.getImgFront());
            stmt.setString(8, v.getImgLeft());
            stmt.setString(9, v.getImgRight());
            stmt.setString(10, v.getImgBack());
            stmt.setString(11, v.getDocRegistration());
            stmt.setString(12, v.getDocInsurance());   // may be null
            stmt.setString(13, v.getDocRevenue());
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error adding vehicle for driver " + v.getDriverId(), e);
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Update a vehicle — blobs are only updated when non-null
    // ─────────────────────────────────────────────────────────────
    public boolean updateVehicle(Vehicle v) {
        String sql = "UPDATE vehicles SET " +
                "vehicle_type=?, brand=?, model=?, plate_number=?, vehicle_category=?, " +
                "img_front=?, img_left=?, img_right=?, img_back=?, " +
                "doc_registration=?, doc_insurance=?, doc_revenue=? " +
                "WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, v.getBrand());
            stmt.setString(2, v.getBrand());
            stmt.setString(3, v.getModel());
            stmt.setString(4, v.getPlateNumber());
            stmt.setString(5, v.getVehicleCategory());
            stmt.setString(6, v.getImgFront());
            stmt.setString(7, v.getImgLeft());
            stmt.setString(8, v.getImgRight());
            stmt.setString(9, v.getImgBack());
            stmt.setString(10, v.getDocRegistration());
            stmt.setString(11, v.getDocInsurance());
            stmt.setString(12, v.getDocRevenue());
            stmt.setInt(13, v.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error updating vehicle with ID " + v.getId(), e);
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Delete a vehicle by id
    // ─────────────────────────────────────────────────────────────
    public boolean deleteVehicle(int id) {
        String sql = "DELETE FROM vehicles WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error deleting vehicle with ID " + id, e);
        }
    }

    // ─────────────────────────────────────────────────────────────
    // vehicle_makes lookup
    // ─────────────────────────────────────────────────────────────
    public List<String> getMakesByCategory(String category) {
        List<String> makes = new ArrayList<>();
        String sql = "SELECT make_name FROM vehicle_makes WHERE category = ? ORDER BY is_custom ASC, make_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, category);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    makes.add(rs.getString("make_name"));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching makes for category " + category, e);
        }
        return makes;
    }

    public void addCustomMake(String category, String makeName) {
        String sql = "INSERT IGNORE INTO vehicle_makes (category, make_name, is_custom) VALUES (?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, category);
            stmt.setString(2, makeName);
            stmt.executeUpdate();
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Error adding custom make " + makeName, e);
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Internal mapper
    // ─────────────────────────────────────────────────────────────
    private Vehicle mapResultSetToVehicle(ResultSet rs) throws SQLException {
        Vehicle v = new Vehicle();
        v.setId(rs.getInt("id"));
        v.setDriverId(rs.getInt("driver_id"));
        v.setBrand(rs.getString("brand"));
        v.setModel(rs.getString("model"));
        v.setPlateNumber(rs.getString("plate_number"));
        v.setVehicleCategory(rs.getString("vehicle_category"));
        v.setImgFront(rs.getString("img_front"));
        v.setImgLeft(rs.getString("img_left"));
        v.setImgRight(rs.getString("img_right"));
        v.setImgBack(rs.getString("img_back"));
        v.setDocRegistration(rs.getString("doc_registration"));
        v.setDocInsurance(rs.getString("doc_insurance"));
        v.setDocRevenue(rs.getString("doc_revenue"));
        return v;
    }
}
