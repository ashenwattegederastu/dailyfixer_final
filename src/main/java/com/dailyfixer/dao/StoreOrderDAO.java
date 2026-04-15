package com.dailyfixer.dao;

import com.dailyfixer.model.StoreOrder;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for StoreOrder entity.
 * Handles per-store order breakdowns in the store_orders table.
 */
public class StoreOrderDAO {

    private static final String INSERT_STORE_ORDER = "INSERT INTO store_orders (order_id, store_id, store_total, delivery_fee, commission, payable_amount, status) "
            +
            "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ORDER_ID = "SELECT * FROM store_orders WHERE order_id = ? ORDER BY store_order_id";

    private static final String SELECT_BY_STORE_ID = "SELECT * FROM store_orders WHERE store_id = ? ORDER BY created_at DESC";

    private static final String UPDATE_COMMISSION =
            "UPDATE store_orders " +
            "SET commission = ROUND(store_total * 0.10, 2), " +
            "    payable_amount = ROUND(store_total * 0.90, 2) " +
            "WHERE order_id = ?";

    private static final String CLEAR_COMMISSION =
            "UPDATE store_orders " +
            "SET commission = 0.00, " +
            "    payable_amount = store_total " +
            "WHERE order_id = ?";

    private static final String TOTAL_COMMISSION_COLLECTED =
            "SELECT COALESCE(SUM(so.commission), 0) " +
            "FROM store_orders so " +
            "JOIN orders o ON so.order_id = o.order_id " +
            "WHERE UPPER(o.status) = 'DELIVERED'";

    /**
     * Create a store order entry.
     *
     * @param storeOrder The store order to create
     * @return true if successful
     */
    public boolean createStoreOrder(StoreOrder storeOrder) {
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(INSERT_STORE_ORDER)) {

            stmt.setString(1, storeOrder.getOrderId());
            stmt.setInt(2, storeOrder.getStoreId());
            stmt.setBigDecimal(3, storeOrder.getStoreTotal());
            java.math.BigDecimal dFee = storeOrder.getDeliveryFee() != null ? storeOrder.getDeliveryFee() : java.math.BigDecimal.ZERO;
            stmt.setBigDecimal(4, dFee);
            stmt.setBigDecimal(5, storeOrder.getCommission());
            stmt.setBigDecimal(6, storeOrder.getPayableAmount());
            stmt.setString(7, storeOrder.getStatus() != null ? storeOrder.getStatus() : "PENDING");

            int rowsAffected = stmt.executeUpdate();
            System.out.println("Store order created for order: " + storeOrder.getOrderId()
                    + ", store: " + storeOrder.getStoreId() + " | Rows affected: " + rowsAffected);
            return rowsAffected > 0;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error creating store order: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all store orders for a given order ID.
     *
     * @param orderId The order ID
     * @return List of store orders
     */
    public List<StoreOrder> getStoreOrdersByOrderId(String orderId) {
        List<StoreOrder> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ORDER_ID)) {

            stmt.setString(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToStoreOrder(rs));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting store orders by order ID: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Applies 10% commission on a store_order row when an order is DELIVERED.
     * Sets commission = store_total * 0.10 and payable_amount = store_total * 0.90.
     */
    public boolean updateCommission(String orderId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_COMMISSION)) {
            stmt.setString(1, orderId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("StoreOrderDAO.updateCommission: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Clears commission on a store_order row when an order is REFUNDED.
     * Resets commission = 0.00 and payable_amount = store_total.
     */
    public boolean clearCommission(String orderId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(CLEAR_COMMISSION)) {
            stmt.setString(1, orderId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("StoreOrderDAO.clearCommission: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns the total commission collected across all stores for all DELIVERED orders.
     */
    public java.math.BigDecimal getTotalCommissionCollected() {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(TOTAL_COMMISSION_COLLECTED);
             java.sql.ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getBigDecimal(1);
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("StoreOrderDAO.getTotalCommissionCollected: " + e.getMessage());
            e.printStackTrace();
        }
        return java.math.BigDecimal.ZERO;
    }

    /**
     * Get all store orders for a given store.
     *
     * @param storeId The store ID
     * @return List of store orders
     */
    public List<StoreOrder> getStoreOrdersByStoreId(int storeId) {
        List<StoreOrder> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(SELECT_BY_STORE_ID)) {

            stmt.setInt(1, storeId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToStoreOrder(rs));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting store orders by store ID: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Map ResultSet to StoreOrder object.
     */
    private StoreOrder mapResultSetToStoreOrder(ResultSet rs) throws SQLException {
        StoreOrder so = new StoreOrder();
        so.setStoreOrderId(rs.getInt("store_order_id"));
        so.setOrderId(rs.getString("order_id"));
        so.setStoreId(rs.getInt("store_id"));
        so.setStoreTotal(rs.getBigDecimal("store_total"));
        so.setDeliveryFee(rs.getBigDecimal("delivery_fee"));
        so.setCommission(rs.getBigDecimal("commission"));
        so.setPayableAmount(rs.getBigDecimal("payable_amount"));
        so.setStatus(rs.getString("status"));
        so.setCreatedAt(rs.getTimestamp("created_at"));
        return so;
    }
}
