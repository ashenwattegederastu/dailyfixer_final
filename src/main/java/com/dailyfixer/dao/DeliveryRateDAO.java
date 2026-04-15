package com.dailyfixer.dao;

import com.dailyfixer.model.DeliveryRate;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DeliveryRateDAO {

    private static final String SELECT_ALL =
        "SELECT * FROM delivery_rates ORDER BY rate_id";
    private static final String SELECT_ACTIVE =
        "SELECT * FROM delivery_rates WHERE is_active = 1 ORDER BY rate_id";
    private static final String SELECT_BY_ID =
        "SELECT * FROM delivery_rates WHERE rate_id = ?";
    private static final String INSERT =
        "INSERT INTO delivery_rates (vehicle_type, cost_per_km, base_fee, distribution_weight, is_active, max_simultaneous_orders) VALUES (?, ?, ?, ?, ?, ?)";
    private static final String UPDATE =
        "UPDATE delivery_rates SET vehicle_type=?, cost_per_km=?, base_fee=?, distribution_weight=?, is_active=?, max_simultaneous_orders=? WHERE rate_id=?";
    private static final String DELETE =
        "DELETE FROM delivery_rates WHERE rate_id=?";
    private static final String SELECT_VEHICLE_TYPES =
        "SELECT vehicle_type FROM delivery_rates WHERE is_active = 1 ORDER BY vehicle_type";

    public List<DeliveryRate> getAllRates() {
        return query(SELECT_ALL);
    }

    public List<DeliveryRate> getActiveRates() {
        return query(SELECT_ACTIVE);
    }

    public DeliveryRate getRateById(int rateId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ID)) {
            stmt.setInt(1, rateId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("DeliveryRateDAO.getRateById: " + e.getMessage());
        }
        return null;
    }

    public boolean addRate(DeliveryRate rate) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT)) {
            stmt.setString(1, rate.getVehicleType());
            stmt.setBigDecimal(2, rate.getCostPerKm());
            stmt.setBigDecimal(3, rate.getBaseFee());
            stmt.setBigDecimal(4, rate.getDistributionWeight());
            stmt.setBoolean(5, rate.isActive());
            stmt.setInt(6, rate.getMaxSimultaneousOrders());
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("DeliveryRateDAO.addRate: " + e.getMessage());
            return false;
        }
    }

    public boolean updateRate(DeliveryRate rate) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE)) {
            stmt.setString(1, rate.getVehicleType());
            stmt.setBigDecimal(2, rate.getCostPerKm());
            stmt.setBigDecimal(3, rate.getBaseFee());
            stmt.setBigDecimal(4, rate.getDistributionWeight());
            stmt.setBoolean(5, rate.isActive());
            stmt.setInt(6, rate.getMaxSimultaneousOrders());
            stmt.setInt(7, rate.getRateId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("DeliveryRateDAO.updateRate: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteRate(int rateId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(DELETE)) {
            stmt.setInt(1, rateId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("DeliveryRateDAO.deleteRate: " + e.getMessage());
            return false;
        }
    }

    /** Returns list of active vehicle type names (for driver dropdown). */
    public List<String> getActiveVehicleTypes() {
        List<String> types = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_VEHICLE_TYPES);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) types.add(rs.getString("vehicle_type"));
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("DeliveryRateDAO.getActiveVehicleTypes: " + e.getMessage());
        }
        return types;
    }

    private List<DeliveryRate> query(String sql) {
        List<DeliveryRate> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("DeliveryRateDAO.query: " + e.getMessage());
        }
        return list;
    }

    private DeliveryRate map(ResultSet rs) throws SQLException {
        DeliveryRate r = new DeliveryRate();
        r.setRateId(rs.getInt("rate_id"));
        r.setVehicleType(rs.getString("vehicle_type"));
        r.setCostPerKm(rs.getBigDecimal("cost_per_km"));
        r.setBaseFee(rs.getBigDecimal("base_fee"));
        r.setDistributionWeight(rs.getBigDecimal("distribution_weight"));
        r.setActive(rs.getBoolean("is_active"));
        r.setMaxSimultaneousOrders(rs.getInt("max_simultaneous_orders"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        return r;
    }
}
