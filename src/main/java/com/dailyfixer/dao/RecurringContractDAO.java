package com.dailyfixer.dao;

import com.dailyfixer.model.RecurringContract;
import com.dailyfixer.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RecurringContractDAO {

    public int createContract(RecurringContract contract) throws Exception {
        String sql = "INSERT INTO recurring_contracts (user_id, technician_id, service_id, start_date, end_date, " +
                "booking_day_of_month, recurring_fee, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contract.getUserId());
            ps.setInt(2, contract.getTechnicianId());
            ps.setInt(3, contract.getServiceId());
            ps.setDate(4, contract.getStartDate());
            ps.setDate(5, contract.getEndDate());
            ps.setInt(6, contract.getBookingDayOfMonth());
            ps.setBigDecimal(7, contract.getRecurringFee());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    contract.setContractId(id);
                    return id;
                }
            }
        }
        return -1;
    }

    public RecurringContract getContractById(int contractId) throws Exception {
        String sql = "SELECT rc.*, " +
                "u1.first_name as user_first, u1.last_name as user_last, " +
                "u2.first_name as tech_first, u2.last_name as tech_last, " +
                "s.service_name " +
                "FROM recurring_contracts rc " +
                "JOIN users u1 ON rc.user_id = u1.user_id " +
                "JOIN users u2 ON rc.technician_id = u2.user_id " +
                "JOIN services s ON rc.service_id = s.service_id " +
                "WHERE rc.contract_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return extract(rs);
            }
        }
        return null;
    }

    public List<RecurringContract> getContractsByUserId(int userId) throws Exception {
        List<RecurringContract> list = new ArrayList<>();
        String sql = "SELECT rc.*, " +
                "u1.first_name as user_first, u1.last_name as user_last, " +
                "u2.first_name as tech_first, u2.last_name as tech_last, " +
                "s.service_name " +
                "FROM recurring_contracts rc " +
                "JOIN users u1 ON rc.user_id = u1.user_id " +
                "JOIN users u2 ON rc.technician_id = u2.user_id " +
                "JOIN services s ON rc.service_id = s.service_id " +
                "WHERE rc.user_id = ? ORDER BY rc.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extract(rs));
            }
        }
        return list;
    }

    public List<RecurringContract> getContractsByTechnicianId(int technicianId) throws Exception {
        List<RecurringContract> list = new ArrayList<>();
        String sql = "SELECT rc.*, " +
                "u1.first_name as user_first, u1.last_name as user_last, " +
                "u2.first_name as tech_first, u2.last_name as tech_last, " +
                "s.service_name " +
                "FROM recurring_contracts rc " +
                "JOIN users u1 ON rc.user_id = u1.user_id " +
                "JOIN users u2 ON rc.technician_id = u2.user_id " +
                "JOIN services s ON rc.service_id = s.service_id " +
                "WHERE rc.technician_id = ? ORDER BY rc.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(extract(rs));
            }
        }
        return list;
    }

    public void updateContractStatus(int contractId, String status) throws Exception {
        String sql = "UPDATE recurring_contracts SET status = ? WHERE contract_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, contractId);
            ps.executeUpdate();
        }
    }

    /**
     * Returns an existing PENDING or ACTIVE contract for a user+service combination,
     * to prevent duplicate active contracts.
     */
    public RecurringContract getActiveContractForUserAndService(int userId, int serviceId) throws Exception {
        String sql = "SELECT rc.*, " +
                "u1.first_name as user_first, u1.last_name as user_last, " +
                "u2.first_name as tech_first, u2.last_name as tech_last, " +
                "s.service_name " +
                "FROM recurring_contracts rc " +
                "JOIN users u1 ON rc.user_id = u1.user_id " +
                "JOIN users u2 ON rc.technician_id = u2.user_id " +
                "JOIN services s ON rc.service_id = s.service_id " +
                "WHERE rc.user_id = ? AND rc.service_id = ? AND rc.status IN ('PENDING','ACTIVE') LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return extract(rs);
            }
        }
        return null;
    }

    private RecurringContract extract(ResultSet rs) throws SQLException {
        RecurringContract c = new RecurringContract();
        c.setContractId(rs.getInt("contract_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setTechnicianId(rs.getInt("technician_id"));
        c.setServiceId(rs.getInt("service_id"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setBookingDayOfMonth(rs.getInt("booking_day_of_month"));
        c.setRecurringFee(rs.getBigDecimal("recurring_fee"));
        c.setStatus(rs.getString("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        c.setUserName(rs.getString("user_first") + " " + rs.getString("user_last"));
        c.setTechnicianName(rs.getString("tech_first") + " " + rs.getString("tech_last"));
        c.setServiceName(rs.getString("service_name"));
        return c;
    }
}
