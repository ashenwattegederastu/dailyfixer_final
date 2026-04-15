package com.dailyfixer.dao;

import com.dailyfixer.model.DeliveryDropProof;
import com.dailyfixer.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * DAO for delivery_drop_proofs table.
 */
public class DeliveryDropProofDAO {

    private static final String INSERT =
        "INSERT INTO delivery_drop_proofs " +
        "(assignment_id, order_id, driver_id, photo_package_path, photo_door_context_path, note) " +
        "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ORDER =
        "SELECT * FROM delivery_drop_proofs WHERE order_id = ? LIMIT 1";

    public boolean create(DeliveryDropProof proof) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, proof.getAssignmentId());
            stmt.setString(2, proof.getOrderId());
            stmt.setInt(3, proof.getDriverId());
            stmt.setString(4, proof.getPhotoPackagePath());
            stmt.setString(5, proof.getPhotoDoorContextPath());
            stmt.setString(6, proof.getNote());

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        proof.setProofId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            System.err.println("DeliveryDropProofDAO.create: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public DeliveryDropProof getByOrderId(String orderId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ORDER)) {

            stmt.setString(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    DeliveryDropProof proof = new DeliveryDropProof();
                    proof.setProofId(rs.getInt("proof_id"));
                    proof.setAssignmentId(rs.getInt("assignment_id"));
                    proof.setOrderId(rs.getString("order_id"));
                    proof.setDriverId(rs.getInt("driver_id"));
                    proof.setPhotoPackagePath(rs.getString("photo_package_path"));
                    proof.setPhotoDoorContextPath(rs.getString("photo_door_context_path"));
                    proof.setNote(rs.getString("note"));
                    proof.setCreatedAt(rs.getTimestamp("created_at"));
                    return proof;
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryDropProofDAO.getByOrderId: " + e.getMessage());
        }
        return null;
    }
}
