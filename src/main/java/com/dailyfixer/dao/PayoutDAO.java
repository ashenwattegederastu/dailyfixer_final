package com.dailyfixer.dao;

import com.dailyfixer.model.BankDetail;
import com.dailyfixer.model.Payout;
import com.dailyfixer.model.PayoutLineItem;
import com.dailyfixer.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO for the payout system (payouts + payout_line_items tables).
 *
 * Balance philosophy – revenue is NEVER reset:
 *   Lifetime Revenue  = all completed source records (DELIVERED orders / deliveries)
 *   Pending Balance    = completed < 7 days ago (not yet mature)
 *   Available Balance  = completed >= 7 days ago MINUS already-paid-out amounts
 */
public class PayoutDAO {

    // ── Store balance queries ───────────────────────────────────────────────

    /** Lifetime revenue for a store: sum of payable_amount for all DELIVERED orders */
    private static final String STORE_LIFETIME =
        "SELECT COALESCE(SUM(so.payable_amount), 0) " +
        "FROM store_orders so " +
        "JOIN orders o ON so.order_id = o.order_id " +
        "WHERE so.store_id = ? AND UPPER(o.status) = 'DELIVERED'";

    /** Pending balance: DELIVERED but completed < 7 days ago */
    private static final String STORE_PENDING =
        "SELECT COALESCE(SUM(so.payable_amount), 0) " +
        "FROM store_orders so " +
        "JOIN orders o ON so.order_id = o.order_id " +
        "WHERE so.store_id = ? AND UPPER(o.status) = 'DELIVERED' " +
        "AND o.updated_at > DATE_SUB(NOW(), INTERVAL 7 DAY)";

    /** Mature total: DELIVERED and completed >= 7 days ago */
    private static final String STORE_MATURE =
        "SELECT COALESCE(SUM(so.payable_amount), 0) " +
        "FROM store_orders so " +
        "JOIN orders o ON so.order_id = o.order_id " +
        "WHERE so.store_id = ? AND UPPER(o.status) = 'DELIVERED' " +
        "AND o.updated_at <= DATE_SUB(NOW(), INTERVAL 7 DAY)";

    /** Total already paid out for a store (COMPLETED payouts) */
    private static final String STORE_PAID_OUT =
        "SELECT COALESCE(SUM(pli.amount), 0) " +
        "FROM payout_line_items pli " +
        "JOIN payouts p ON pli.payout_id = p.payout_id " +
        "WHERE p.payee_type = 'STORE' AND p.payee_id = ? " +
        "AND p.status = 'COMPLETED' AND pli.source_type = 'STORE_ORDER'";

    /** Total refunded amount for a store (REFUND_PENDING + REFUNDED orders) */
    private static final String STORE_REFUND_TOTAL =
        "SELECT COALESCE(SUM(o.total_amount), 0) " +
        "FROM orders o " +
        "JOIN store_orders so ON so.order_id = o.order_id " +
        "WHERE so.store_id = ? AND UPPER(o.status) IN ('REFUND_PENDING','REFUNDED')";

    /** Total commission deducted from a store across all DELIVERED orders */
    private static final String STORE_COMMISSION =
        "SELECT COALESCE(SUM(so.commission), 0) " +
        "FROM store_orders so " +
        "JOIN orders o ON so.order_id = o.order_id " +
        "WHERE so.store_id = ? AND UPPER(o.status) = 'DELIVERED'";

    // ── Driver balance queries ──────────────────────────────────────────────

    private static final String DRIVER_LIFETIME =
        "SELECT COALESCE(SUM(da.delivery_fee_earned), 0) " +
        "FROM delivery_assignments da " +
        "WHERE da.driver_id = ? AND UPPER(da.status) = 'DELIVERED'";

    private static final String DRIVER_PENDING =
        "SELECT COALESCE(SUM(da.delivery_fee_earned), 0) " +
        "FROM delivery_assignments da " +
        "WHERE da.driver_id = ? AND UPPER(da.status) = 'DELIVERED' " +
        "AND da.completed_at > DATE_SUB(NOW(), INTERVAL 7 DAY)";

    private static final String DRIVER_MATURE =
        "SELECT COALESCE(SUM(da.delivery_fee_earned), 0) " +
        "FROM delivery_assignments da " +
        "WHERE da.driver_id = ? AND UPPER(da.status) = 'DELIVERED' " +
        "AND da.completed_at <= DATE_SUB(NOW(), INTERVAL 7 DAY)";

    private static final String DRIVER_PAID_OUT =
        "SELECT COALESCE(SUM(pli.amount), 0) " +
        "FROM payout_line_items pli " +
        "JOIN payouts p ON pli.payout_id = p.payout_id " +
        "WHERE p.payee_type = 'DRIVER' AND p.payee_id = ? " +
        "AND p.status = 'COMPLETED' AND pli.source_type = 'DELIVERY'";

    // ── Mature unpaid source records (for batch generation) ─────────────────

    /** Mature store_orders not yet linked to any payout */
    private static final String UNPAID_MATURE_STORE_ORDERS =
        "SELECT so.store_order_id, so.store_id, so.payable_amount " +
        "FROM store_orders so " +
        "JOIN orders o ON so.order_id = o.order_id " +
        "WHERE UPPER(o.status) = 'DELIVERED' " +
        "AND o.updated_at <= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
        "AND so.store_order_id NOT IN (" +
        "    SELECT pli.source_id FROM payout_line_items pli WHERE pli.source_type = 'STORE_ORDER'" +
        ")";

    /** Mature delivery_assignments not yet linked to any payout */
    private static final String UNPAID_MATURE_DELIVERIES =
        "SELECT da.assignment_id, da.driver_id, da.delivery_fee_earned " +
        "FROM delivery_assignments da " +
        "WHERE UPPER(da.status) = 'DELIVERED' " +
        "AND da.completed_at <= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
        "AND da.assignment_id NOT IN (" +
        "    SELECT pli.source_id FROM payout_line_items pli WHERE pli.source_type = 'DELIVERY'" +
        ")";

    // ── Payout CRUD ─────────────────────────────────────────────────────────

    private static final String INSERT_PAYOUT =
        "INSERT INTO payouts (payee_type, payee_id, amount, status) VALUES (?, ?, ?, 'PENDING')";

    private static final String INSERT_LINE_ITEM =
        "INSERT INTO payout_line_items (payout_id, source_type, source_id, amount) VALUES (?, ?, ?, ?)";

    /** Optimistic lock: only succeeds if status is still PENDING */
    private static final String LOCK_PAYOUT =
        "UPDATE payouts SET status = 'PROCESSING', locked_by_admin_id = ?, updated_at = NOW() " +
        "WHERE payout_id = ? AND status = 'PENDING'";

    private static final String COMPLETE_PAYOUT =
        "UPDATE payouts SET status = 'COMPLETED', receipt_image_path = ?, updated_at = NOW() " +
        "WHERE payout_id = ? AND status = 'PROCESSING' AND locked_by_admin_id = ?";

    /** Unlock – admin decides not to proceed */
    private static final String UNLOCK_PAYOUT =
        "UPDATE payouts SET status = 'PENDING', locked_by_admin_id = NULL, updated_at = NOW() " +
        "WHERE payout_id = ? AND status = 'PROCESSING' AND locked_by_admin_id = ?";

    private static final String SELECT_ALL =
        "SELECT p.*, " +
        "  CASE WHEN p.payee_type = 'STORE' THEN s.store_name " +
        "       ELSE CONCAT(u.first_name, ' ', u.last_name) END AS payee_name, " +
        "  CONCAT(a.first_name, ' ', a.last_name) AS admin_name " +
        "FROM payouts p " +
        "LEFT JOIN stores s ON p.payee_type = 'STORE' AND p.payee_id = s.store_id " +
        "LEFT JOIN users u  ON p.payee_type = 'DRIVER' AND p.payee_id = u.user_id " +
        "LEFT JOIN users a  ON p.locked_by_admin_id = a.user_id " +
        "ORDER BY p.created_at DESC";

    private static final String SELECT_BY_STATUS =
        "SELECT p.*, " +
        "  CASE WHEN p.payee_type = 'STORE' THEN s.store_name " +
        "       ELSE CONCAT(u.first_name, ' ', u.last_name) END AS payee_name, " +
        "  CONCAT(a.first_name, ' ', a.last_name) AS admin_name " +
        "FROM payouts p " +
        "LEFT JOIN stores s ON p.payee_type = 'STORE' AND p.payee_id = s.store_id " +
        "LEFT JOIN users u  ON p.payee_type = 'DRIVER' AND p.payee_id = u.user_id " +
        "LEFT JOIN users a  ON p.locked_by_admin_id = a.user_id " +
        "WHERE p.status = ? ORDER BY p.created_at DESC";

    private static final String SELECT_BY_ID =
        "SELECT p.*, " +
        "  CASE WHEN p.payee_type = 'STORE' THEN s.store_name " +
        "       ELSE CONCAT(u.first_name, ' ', u.last_name) END AS payee_name, " +
        "  CONCAT(a.first_name, ' ', a.last_name) AS admin_name " +
        "FROM payouts p " +
        "LEFT JOIN stores s ON p.payee_type = 'STORE' AND p.payee_id = s.store_id " +
        "LEFT JOIN users u  ON p.payee_type = 'DRIVER' AND p.payee_id = u.user_id " +
        "LEFT JOIN users a  ON p.locked_by_admin_id = a.user_id " +
        "WHERE p.payout_id = ?";

    private static final String SELECT_BY_PAYEE =
        "SELECT p.*, " +
        "  CASE WHEN p.payee_type = 'STORE' THEN s.store_name " +
        "       ELSE CONCAT(u.first_name, ' ', u.last_name) END AS payee_name, " +
        "  CONCAT(a.first_name, ' ', a.last_name) AS admin_name " +
        "FROM payouts p " +
        "LEFT JOIN stores s ON p.payee_type = 'STORE' AND p.payee_id = s.store_id " +
        "LEFT JOIN users u  ON p.payee_type = 'DRIVER' AND p.payee_id = u.user_id " +
        "LEFT JOIN users a  ON p.locked_by_admin_id = a.user_id " +
        "WHERE p.payee_type = ? AND p.payee_id = ? ORDER BY p.created_at DESC";

    private static final String SELECT_LINE_ITEMS =
        "SELECT * FROM payout_line_items WHERE payout_id = ?";

    // =====================================================================
    // Balance calculations
    // =====================================================================

    /**
     * Returns {lifetime, pending, available, refunded} for a store.
     */
    public BigDecimal[] getStoreBalances(int storeId) {
        BigDecimal lifetime   = querySingle(STORE_LIFETIME, storeId);
        BigDecimal pending    = querySingle(STORE_PENDING, storeId);
        BigDecimal mature     = querySingle(STORE_MATURE, storeId);
        BigDecimal paidOut    = querySingle(STORE_PAID_OUT, storeId);
        BigDecimal refunded   = querySingle(STORE_REFUND_TOTAL, storeId);
        BigDecimal commission = querySingle(STORE_COMMISSION, storeId);
        BigDecimal available  = mature.subtract(paidOut);
        if (available.compareTo(BigDecimal.ZERO) < 0) available = BigDecimal.ZERO;
        return new BigDecimal[]{ lifetime, pending, available, refunded, commission };
    }

    /**
     * Returns {lifetime, pending, available} for a driver.
     */
    public BigDecimal[] getDriverBalances(int driverId) {
        BigDecimal lifetime  = querySingle(DRIVER_LIFETIME, driverId);
        BigDecimal pending   = querySingle(DRIVER_PENDING, driverId);
        BigDecimal mature    = querySingle(DRIVER_MATURE, driverId);
        BigDecimal paidOut   = querySingle(DRIVER_PAID_OUT, driverId);
        BigDecimal available = mature.subtract(paidOut);
        if (available.compareTo(BigDecimal.ZERO) < 0) available = BigDecimal.ZERO;
        return new BigDecimal[]{ lifetime, pending, available };
    }

    // =====================================================================
    // Batch generation
    // =====================================================================

    /**
     * Scans for mature, unpaid source records and creates PENDING payouts.
     * Returns the number of new payout records created.
     */
    public int generatePayouts() {
        int created = 0;
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // --- Store payouts ---
            // Group unpaid store_orders by store_id
            Map<Integer, List<int[]>> storeMap = new HashMap<>(); // storeId -> [(storeOrderId, amount_cents)]
            Map<Integer, BigDecimal> storeTotals = new HashMap<>();
            try (PreparedStatement stmt = conn.prepareStatement(UNPAID_MATURE_STORE_ORDERS);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int soId = rs.getInt("store_order_id");
                    int sId  = rs.getInt("store_id");
                    BigDecimal amt = rs.getBigDecimal("payable_amount");
                    storeMap.computeIfAbsent(sId, k -> new ArrayList<>())
                            .add(new int[]{ soId });
                    storeTotals.merge(sId, amt, BigDecimal::add);
                    // stash amount for line items
                    storeMap.get(sId).get(storeMap.get(sId).size() - 1);
                }
            }

            // Re-query to also capture amounts per line item
            Map<Integer, List<Object[]>> storeLineItems = new HashMap<>();
            try (PreparedStatement stmt = conn.prepareStatement(UNPAID_MATURE_STORE_ORDERS);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int soId = rs.getInt("store_order_id");
                    int sId  = rs.getInt("store_id");
                    BigDecimal amt = rs.getBigDecimal("payable_amount");
                    storeLineItems.computeIfAbsent(sId, k -> new ArrayList<>())
                                  .add(new Object[]{ soId, amt });
                }
            }

            for (Map.Entry<Integer, BigDecimal> entry : storeTotals.entrySet()) {
                int storeId = entry.getKey();
                BigDecimal total = entry.getValue();
                if (total.compareTo(BigDecimal.ZERO) <= 0) continue;

                int payoutId = insertPayout(conn, "STORE", storeId, total);
                if (payoutId > 0) {
                    for (Object[] li : storeLineItems.get(storeId)) {
                        insertLineItem(conn, payoutId, "STORE_ORDER", (int) li[0], (BigDecimal) li[1]);
                    }
                    created++;
                }
            }

            // --- Driver payouts ---
            Map<Integer, List<Object[]>> driverLineItems = new HashMap<>();
            Map<Integer, BigDecimal> driverTotals = new HashMap<>();
            try (PreparedStatement stmt = conn.prepareStatement(UNPAID_MATURE_DELIVERIES);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int aId = rs.getInt("assignment_id");
                    int dId = rs.getInt("driver_id");
                    BigDecimal amt = rs.getBigDecimal("delivery_fee_earned");
                    driverLineItems.computeIfAbsent(dId, k -> new ArrayList<>())
                                   .add(new Object[]{ aId, amt });
                    driverTotals.merge(dId, amt, BigDecimal::add);
                }
            }

            for (Map.Entry<Integer, BigDecimal> entry : driverTotals.entrySet()) {
                int driverId = entry.getKey();
                BigDecimal total = entry.getValue();
                if (total.compareTo(BigDecimal.ZERO) <= 0) continue;

                int payoutId = insertPayout(conn, "DRIVER", driverId, total);
                if (payoutId > 0) {
                    for (Object[] li : driverLineItems.get(driverId)) {
                        insertLineItem(conn, payoutId, "DELIVERY", (int) li[0], (BigDecimal) li[1]);
                    }
                    created++;
                }
            }

            conn.commit();
        } catch (Exception e) {
            System.err.println("PayoutDAO.generatePayouts: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {}
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
        }
        return created;
    }

    // =====================================================================
    // Concurrency-controlled operations
    // =====================================================================

    /**
     * Atomically locks a PENDING payout for an admin.
     * @return true if lock acquired, false if another admin took it (409 scenario)
     */
    public boolean lockPayout(int payoutId, int adminId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(LOCK_PAYOUT)) {
            stmt.setInt(1, adminId);
            stmt.setInt(2, payoutId);
            return stmt.executeUpdate() == 1;
        } catch (Exception e) {
            System.err.println("PayoutDAO.lockPayout: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Completes a PROCESSING payout (sets receipt, marks COMPLETED).
     * Only the admin who locked it can complete it.
     */
    public boolean completePayout(int payoutId, int adminId, String receiptPath) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(COMPLETE_PAYOUT)) {
            stmt.setString(1, receiptPath);
            stmt.setInt(2, payoutId);
            stmt.setInt(3, adminId);
            return stmt.executeUpdate() == 1;
        } catch (Exception e) {
            System.err.println("PayoutDAO.completePayout: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Releases a PROCESSING payout back to PENDING (admin decides not to proceed).
     */
    public boolean unlockPayout(int payoutId, int adminId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UNLOCK_PAYOUT)) {
            stmt.setInt(1, payoutId);
            stmt.setInt(2, adminId);
            return stmt.executeUpdate() == 1;
        } catch (Exception e) {
            System.err.println("PayoutDAO.unlockPayout: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // =====================================================================
    // Read operations
    // =====================================================================

    public List<Payout> getAllPayouts() {
        return queryPayouts(SELECT_ALL);
    }

    public List<Payout> getPayoutsByStatus(String status) {
        return queryPayoutsWithParam(SELECT_BY_STATUS, status);
    }

    public Payout getPayoutById(int payoutId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ID)) {
            stmt.setInt(1, payoutId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapPayout(rs);
            }
        } catch (Exception e) {
            System.err.println("PayoutDAO.getPayoutById: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public List<Payout> getPayoutsByPayee(String payeeType, int payeeId) {
        List<Payout> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_PAYEE)) {
            stmt.setString(1, payeeType);
            stmt.setInt(2, payeeId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(mapPayout(rs));
            }
        } catch (Exception e) {
            System.err.println("PayoutDAO.getPayoutsByPayee: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<PayoutLineItem> getLineItems(int payoutId) {
        List<PayoutLineItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_LINE_ITEMS)) {
            stmt.setInt(1, payoutId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    PayoutLineItem li = new PayoutLineItem();
                    li.setLineItemId(rs.getInt("line_item_id"));
                    li.setPayoutId(rs.getInt("payout_id"));
                    li.setSourceType(rs.getString("source_type"));
                    li.setSourceId(rs.getInt("source_id"));
                    li.setAmount(rs.getBigDecimal("amount"));
                    list.add(li);
                }
            }
        } catch (Exception e) {
            System.err.println("PayoutDAO.getLineItems: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get the bank detail for a payout's payee.
     * For STORE payees, we look up the user_id from the stores table.
     * For DRIVER payees, the payee_id IS the user_id.
     */
    public BankDetail getBankDetailForPayout(Payout p) {
        int userId;
        if ("STORE".equals(p.getPayeeType())) {
            // Look up user_id from stores table
            userId = getStoreUserId(p.getPayeeId());
            if (userId <= 0) return null;
        } else {
            userId = p.getPayeeId();
        }
        return new BankDetailDAO().getByUserId(userId);
    }

    // =====================================================================
    // Private helpers
    // =====================================================================

    private int getStoreUserId(int storeId) {
        String sql = "SELECT user_id FROM stores WHERE store_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, storeId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt("user_id");
            }
        } catch (Exception e) {
            System.err.println("PayoutDAO.getStoreUserId: " + e.getMessage());
        }
        return -1;
    }

    private BigDecimal querySingle(String sql, int paramId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, paramId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (Exception e) {
            System.err.println("PayoutDAO.querySingle: " + e.getMessage());
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    private int insertPayout(Connection conn, String payeeType, int payeeId, BigDecimal amount) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(INSERT_PAYOUT, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, payeeType);
            stmt.setInt(2, payeeId);
            stmt.setBigDecimal(3, amount);
            stmt.executeUpdate();
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    private void insertLineItem(Connection conn, int payoutId, String sourceType, int sourceId, BigDecimal amount) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(INSERT_LINE_ITEM)) {
            stmt.setInt(1, payoutId);
            stmt.setString(2, sourceType);
            stmt.setInt(3, sourceId);
            stmt.setBigDecimal(4, amount);
            stmt.executeUpdate();
        }
    }

    private List<Payout> queryPayouts(String sql) {
        List<Payout> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) list.add(mapPayout(rs));
        } catch (Exception e) {
            System.err.println("PayoutDAO.queryPayouts: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    private List<Payout> queryPayoutsWithParam(String sql, String param) {
        List<Payout> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, param);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(mapPayout(rs));
            }
        } catch (Exception e) {
            System.err.println("PayoutDAO.queryPayoutsWithParam: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    private Payout mapPayout(ResultSet rs) throws SQLException {
        Payout p = new Payout();
        p.setPayoutId(rs.getInt("payout_id"));
        p.setPayeeType(rs.getString("payee_type"));
        p.setPayeeId(rs.getInt("payee_id"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setStatus(rs.getString("status"));
        int adminId = rs.getInt("locked_by_admin_id");
        p.setLockedByAdminId(rs.wasNull() ? null : adminId);
        p.setReceiptImagePath(rs.getString("receipt_image_path"));
        p.setNotes(rs.getString("notes"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        // Transient join fields (may not exist in every query)
        try { p.setPayeeName(rs.getString("payee_name")); } catch (SQLException ignored) {}
        try { p.setAdminName(rs.getString("admin_name")); } catch (SQLException ignored) {}
        return p;
    }
}
