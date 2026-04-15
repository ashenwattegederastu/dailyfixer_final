package com.dailyfixer.dao;

import com.dailyfixer.model.BankDetail;
import com.dailyfixer.util.DBConnection;

import java.sql.*;

public class BankDetailDAO {

    private static final String SELECT_BY_USER =
        "SELECT * FROM bank_details WHERE user_id = ?";

    private static final String UPSERT =
        "INSERT INTO bank_details (user_id, bank_name, branch, account_number, account_holder_name) " +
        "VALUES (?, ?, ?, ?, ?) " +
        "ON DUPLICATE KEY UPDATE bank_name = VALUES(bank_name), branch = VALUES(branch), " +
        "account_number = VALUES(account_number), account_holder_name = VALUES(account_holder_name)";

    public BankDetail getByUserId(int userId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_USER)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            System.err.println("BankDetailDAO.getByUserId: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean upsert(BankDetail bd) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPSERT)) {
            stmt.setInt(1, bd.getUserId());
            stmt.setString(2, bd.getBankName());
            stmt.setString(3, bd.getBranch());
            stmt.setString(4, bd.getAccountNumber());
            stmt.setString(5, bd.getAccountHolderName());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("BankDetailDAO.upsert: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    private BankDetail mapRow(ResultSet rs) throws SQLException {
        BankDetail bd = new BankDetail();
        bd.setBankDetailId(rs.getInt("bank_detail_id"));
        bd.setUserId(rs.getInt("user_id"));
        bd.setBankName(rs.getString("bank_name"));
        bd.setBranch(rs.getString("branch"));
        bd.setAccountNumber(rs.getString("account_number"));
        bd.setAccountHolderName(rs.getString("account_holder_name"));
        bd.setCreatedAt(rs.getTimestamp("created_at"));
        bd.setUpdatedAt(rs.getTimestamp("updated_at"));
        return bd;
    }
}
