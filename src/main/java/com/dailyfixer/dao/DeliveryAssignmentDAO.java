package com.dailyfixer.dao;

import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.util.DBConnection;
import com.dailyfixer.util.DeliveryFeeCalculator;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for delivery_assignments table.
 * Race-condition safety for acceptAssignment():
 *   UPDATE delivery_assignments
 *     SET status='ACCEPTED', driver_id=?, assigned_at=NOW()
 *   WHERE assignment_id=? AND status='PENDING'
 * MySQL InnoDB serialises concurrent UPDATEs on the same row via row-level locking.
 * The first writer gets rowsAffected=1 (SUCCESS); every subsequent writer gets 0
 * (ALREADY_TAKEN) because the WHERE status='PENDING' predicate no longer matches.
 * No explicit transaction or optimistic-lock version column is needed.
 */
public class DeliveryAssignmentDAO {

    /** Result of an acceptAssignment() call. */
    public enum AcceptResult { SUCCESS, ALREADY_TAKEN, LIMIT_REACHED, ERROR }

    // ── SQL constants ─────────────────────────────────────────────────────────

    /** Count this driver's currently active (non-completed) assignments. */
    private static final String COUNT_DRIVER_ACTIVE =
        "SELECT COUNT(*) FROM delivery_assignments " +
        "WHERE driver_id = ? AND status IN ('ACCEPTED','PICKED_UP')";

    /** Get the max simultaneous order limit for this driver's registered vehicle category. */
    private static final String GET_DRIVER_ORDER_LIMIT =
        "SELECT dr.max_simultaneous_orders " +
        "FROM delivery_rates dr " +
        "JOIN vehicles v ON v.vehicle_category = dr.vehicle_type " +
        "WHERE v.driver_id = ? AND dr.is_active = 1 " +
        "LIMIT 1";

    private static final String INSERT =
        "INSERT INTO delivery_assignments " +
        "(order_id, store_id, required_vehicle_type, delivery_fee_earned, " +
        " pickup_address, delivery_address, delivery_lat, delivery_lng, delivery_pin, status) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

    private static final String SELECT_BY_ORDER =
        "SELECT da.*, s.store_name, s.latitude AS store_lat, s.longitude AS store_lng " +
        "FROM delivery_assignments da " +
        "JOIN stores s ON da.store_id = s.store_id " +
        "WHERE da.order_id = ?";

    private static final String SELECT_BY_ID =
        "SELECT da.*, s.store_name, s.latitude AS store_lat, s.longitude AS store_lng " +
        "FROM delivery_assignments da " +
        "JOIN stores s ON da.store_id = s.store_id " +
        "WHERE da.assignment_id = ?";

    /**
     * Fetches all PENDING, unassigned assignments matching any of the given vehicle types.
     * The 10 km radius filter is applied in Java after fetching (store coords come via JOIN).
     */
    private static final String SELECT_PENDING_BASE =
        "SELECT da.*, " +
        "       s.store_name, s.latitude AS store_lat, s.longitude AS store_lng, " +
        "       s.store_address AS pickup_addr_join, " +
        "       o.first_name, o.last_name " +
        "FROM delivery_assignments da " +
        "JOIN stores s ON da.store_id = s.store_id " +
        "JOIN orders o ON da.order_id  = o.order_id " +
        "WHERE da.status = 'PENDING' AND da.driver_id IS NULL " +
        "AND da.required_vehicle_type IN ";   // caller appends (?,?,...) dynamically

    /** Atomic accept — the heart of the race-condition guard. */
    private static final String ACCEPT =
        "UPDATE delivery_assignments " +
        "SET status='ACCEPTED', driver_id=?, assigned_at=NOW() " +
        "WHERE assignment_id=? AND status='PENDING'";

    private static final String MARK_PICKED_UP =
        "UPDATE delivery_assignments " +
        "SET status='PICKED_UP', picked_up_at=NOW() " +
        "WHERE assignment_id=? AND store_id=? AND status='ACCEPTED'";

    private static final String MARK_DELIVERED =
        "UPDATE delivery_assignments " +
        "SET status='DELIVERED', completed_at=NOW(), completion_method='PIN' " +
        "WHERE assignment_id=? AND driver_id=? AND status='PICKED_UP' AND delivery_pin=?";

    private static final String MARK_DELIVERED_DOORSTEP =
        "UPDATE delivery_assignments " +
        "SET status='DELIVERED', completed_at=NOW(), completion_method='DOORSTEP_PHOTO' " +
        "WHERE assignment_id=? AND driver_id=? AND status='PICKED_UP'";

    private static final String CANCEL =
        "UPDATE delivery_assignments SET status='CANCELLED' " +
        "WHERE assignment_id=? AND status IN ('PENDING','ACCEPTED','PICKED_UP')";

    /** Returns an ACCEPTED assignment to PENDING so another driver can claim it. */
    private static final String RESET_TO_PENDING =
        "UPDATE delivery_assignments " +
        "SET status='PENDING', driver_id=NULL, assigned_at=NULL " +
        "WHERE assignment_id=? AND status='ACCEPTED'";

    /** Driver voluntarily releases an accepted assignment back to the pool. */
    private static final String DRIVER_RELEASE_ACCEPTED =
        "UPDATE delivery_assignments " +
        "SET status='PENDING', driver_id=NULL, assigned_at=NULL " +
        "WHERE assignment_id=? AND driver_id=? AND status='ACCEPTED'";

    /** Audit trail for no-penalty driver re-queues. */
    private static final String INSERT_REQUEUE_EVENT =
        "INSERT INTO delivery_requeue_events " +
        "(assignment_id, order_id, actor_driver_id, reason_code, reason_note) " +
        "VALUES (?, ?, ?, ?, ?)";

    /** Store can edit vehicle type only while order is still in pending pool. */
    private static final String UPDATE_VEHICLE_TYPE_PENDING =
        "UPDATE delivery_assignments " +
        "SET required_vehicle_type=? " +
        "WHERE assignment_id=? AND store_id=? AND status='PENDING' AND driver_id IS NULL";

    // Rule 3: driver accepted but didn't pick up within N hours
    private static final String SELECT_STALE_ACCEPTED =
        "SELECT da.assignment_id, da.driver_id, da.order_id " +
        "FROM delivery_assignments da " +
        "WHERE da.status = 'ACCEPTED' " +
        "  AND da.driver_id IS NOT NULL " +
        "  AND da.assigned_at IS NOT NULL " +
        "  AND TIMESTAMPDIFF(HOUR, da.assigned_at, NOW()) >= ?";

    // Rule 4: driver picked up but didn't deliver within N hours (uses picked_up_at)
    private static final String SELECT_STALE_PICKED_UP =
        "SELECT da.assignment_id, da.order_id, da.driver_id, " +
        "       s.store_name, " +
        "       u.email AS store_owner_email, " +
        "       du.email AS driver_email, " +
        "       o.email AS buyer_email, " +
        "       CONCAT(o.first_name, ' ', o.last_name) AS buyer_name, " +
        "       o.payhere_payment_id, o.total_amount, o.currency " +
        "FROM delivery_assignments da " +
        "JOIN stores s  ON da.store_id  = s.store_id " +
        "JOIN users  u  ON s.user_id    = u.user_id " +
        "JOIN users  du ON da.driver_id = du.user_id " +
        "JOIN orders o  ON da.order_id  = o.order_id " +
        "WHERE da.status = 'PICKED_UP' " +
        "  AND da.picked_up_at IS NOT NULL " +
        "  AND TIMESTAMPDIFF(HOUR, da.picked_up_at, NOW()) >= ?";

    // Rule 1: paid orders not dispatched by store within N hours
    private static final String SELECT_STALE_PAID =
        "SELECT o.order_id, " +
        "       s.store_name, " +
        "       u.email AS store_owner_email, " +
        "       o.email AS buyer_email, " +
        "       CONCAT(o.first_name, ' ', o.last_name) AS buyer_name, " +
        "       o.payhere_payment_id, o.total_amount, o.currency " +
        "FROM orders o " +
        "JOIN stores s ON o.store_id = s.store_id " +
        "JOIN users  u ON s.user_id  = u.user_id " +
        "WHERE o.status = 'PAID' " +
        "  AND TIMESTAMPDIFF(HOUR, o.updated_at, NOW()) >= ?";


    private static final String SELECT_BY_DRIVER =
        "SELECT da.*, s.store_name, s.latitude AS store_lat, s.longitude AS store_lng, " +
        "       o.first_name, o.last_name, o.phone AS buyer_phone " +
        "FROM delivery_assignments da " +
        "JOIN stores s ON da.store_id = s.store_id " +
        "JOIN orders o ON da.order_id = o.order_id " +
        "WHERE da.driver_id = ? AND da.status = ? " +
        "ORDER BY da.created_at DESC";

    private static final String SELECT_BY_STORE =
        "SELECT da.*, " +
        "       CONCAT(u.first_name,' ',u.last_name) AS driver_name_join, " +
        "       o.first_name, o.last_name " +
        "FROM delivery_assignments da " +
        "JOIN orders o ON da.order_id = o.order_id " +
        "LEFT JOIN users u ON da.driver_id = u.user_id " +
        "WHERE da.store_id = ? " +
        "ORDER BY da.created_at DESC";

    // ── Public methods ────────────────────────────────────────────────────────

    /**
     * Persists a new delivery assignment (status=PENDING, no driver yet).
     * Called by the store servlet when the store accepts an order.
     */
    public boolean createAssignment(DeliveryAssignment da) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, da.getOrderId());
            stmt.setInt(2, da.getStoreId());
            stmt.setString(3, da.getRequiredVehicleType());
            stmt.setBigDecimal(4, da.getDeliveryFeeEarned());
            stmt.setString(5, da.getPickupAddress());
            stmt.setString(6, da.getDeliveryAddress());
            if (da.getDeliveryLat() != null) stmt.setDouble(7, da.getDeliveryLat());
            else stmt.setNull(7, Types.DECIMAL);
            if (da.getDeliveryLng() != null) stmt.setDouble(8, da.getDeliveryLng());
            else stmt.setNull(8, Types.DECIMAL);
            stmt.setString(9, da.getDeliveryPin());

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) da.setAssignmentId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.createAssignment: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Returns the assignment for the given order, or null if none exists yet.
     */
    public DeliveryAssignment getByOrderId(String orderId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ORDER)) {

            stmt.setString(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    DeliveryAssignment da = mapRow(rs);
                    da.setStoreName(rs.getString("store_name"));
                    da.setStoreLat(rs.getDouble("store_lat"));
                    da.setStoreLng(rs.getDouble("store_lng"));
                    return da;
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getByOrderId: " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns the assignment for the given assignment ID, or null if not found.
     */
    public DeliveryAssignment getByAssignmentId(int assignmentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_ID)) {

            stmt.setInt(1, assignmentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    DeliveryAssignment da = mapRow(rs);
                    da.setStoreName(rs.getString("store_name"));
                    da.setStoreLat(rs.getDouble("store_lat"));
                    da.setStoreLng(rs.getDouble("store_lng"));
                    return da;
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getByAssignmentId: " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns PENDING assignments within radiusKm of (driverLat, driverLng)
     * whose required_vehicle_type is one of vehicleTypes.
     * The haversine distance check runs in Java after a DB fetch filtered only
     * by vehicle type and PENDING status, keeping the SQL simple and portable.
     */
    public List<DeliveryAssignment> getPendingNearby(double driverLat, double driverLng,
                                                      List<String> vehicleTypes,
                                                      double radiusKm) {
        List<DeliveryAssignment> result = new ArrayList<>();
        if (vehicleTypes == null || vehicleTypes.isEmpty()) return result;

        // Build: WHERE ... AND required_vehicle_type IN (?,?,...)
        StringBuilder inClause = new StringBuilder("(");
        for (int i = 0; i < vehicleTypes.size(); i++) {
            if (i > 0) inClause.append(",");
            inClause.append("?");
        }
        inClause.append(")");

        String sql = SELECT_PENDING_BASE + inClause;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            for (int i = 0; i < vehicleTypes.size(); i++) {
                stmt.setString(i + 1, vehicleTypes.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    double storeLat = rs.getDouble("store_lat");
                    double storeLng = rs.getDouble("store_lng");

                    // Apply 10 km radius filter
                    double dist = 0;
                    if (storeLat != 0 && storeLng != 0 && driverLat != 0 && driverLng != 0) {
                        dist = DeliveryFeeCalculator.haversineDistance(storeLat, storeLng, driverLat, driverLng);
                        if (dist > radiusKm) continue; // outside radius — skip
                    }

                    DeliveryAssignment da = mapRow(rs);
                    da.setStoreName(rs.getString("store_name"));
                    da.setStoreLat(storeLat);
                    da.setStoreLng(storeLng);
                    da.setDistanceKm(dist);
                    da.setCustomerName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    result.add(da);
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getPendingNearby: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Atomically claims a PENDING assignment for the given driver.
     * First checks whether the driver has reached the simultaneous order limit
     * for their vehicle category (from delivery_rates.max_simultaneous_orders).
     * Then uses a single UPDATE with WHERE status='PENDING' as the race guard.
     *
     * @return SUCCESS       – driver now owns this assignment
     *         ALREADY_TAKEN – another driver accepted first (rowsAffected=0)
     *         LIMIT_REACHED – driver already at max concurrent orders for their vehicle type
     *         ERROR         – unexpected exception
     */
    public AcceptResult acceptAssignment(int assignmentId, int driverId) {
        try (Connection conn = DBConnection.getConnection()) {

            // 1. Get this driver's limit from their vehicle category
            int limit = 1; // safe minimum if lookup fails
            try (PreparedStatement ps = conn.prepareStatement(GET_DRIVER_ORDER_LIMIT)) {
                ps.setInt(1, driverId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        limit = rs.getInt(1);
                    } else {
                        // No registered vehicle → cannot accept deliveries
                        return AcceptResult.ERROR;
                    }
                }
            }

            // 2. Count current active orders for this driver
            int activeCount;
            try (PreparedStatement ps = conn.prepareStatement(COUNT_DRIVER_ACTIVE)) {
                ps.setInt(1, driverId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    activeCount = rs.getInt(1);
                }
            }

            if (activeCount >= limit) {
                return AcceptResult.LIMIT_REACHED;
            }

            // 3. Atomic claim — existing race guard unchanged
            try (PreparedStatement ps = conn.prepareStatement(ACCEPT)) {
                ps.setInt(1, driverId);
                ps.setInt(2, assignmentId);
                int rows = ps.executeUpdate();
                return rows > 0 ? AcceptResult.SUCCESS : AcceptResult.ALREADY_TAKEN;
            }

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.acceptAssignment: " + e.getMessage());
            e.printStackTrace();
            return AcceptResult.ERROR;
        }
    }

    /**
     * Marks an ACCEPTED assignment as PICKED_UP.
     * Called by the store when the driver physically picks up the package.
     * Only succeeds if the assignment belongs to the given store and is in ACCEPTED status.
     */
    public boolean markPickedUp(int assignmentId, int storeId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(MARK_PICKED_UP)) {

            stmt.setInt(1, assignmentId);
            stmt.setInt(2, storeId);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.markPickedUp: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Marks a picked-up assignment as DELIVERED.
     * Only succeeds if the assignment belongs to driverId, is in PICKED_UP status,
     * and the delivery PIN matches.
     */
    public boolean markDelivered(int assignmentId, int driverId, String deliveryPin) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(MARK_DELIVERED)) {

            stmt.setInt(1, assignmentId);
            stmt.setInt(2, driverId);
            stmt.setString(3, deliveryPin);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.markDelivered: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Marks a picked-up assignment as DELIVERED using doorstep-photo proof.
     * PIN is not required for this exception path.
     */
    public boolean markDeliveredDoorstep(int assignmentId, int driverId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(MARK_DELIVERED_DOORSTEP)) {

            stmt.setInt(1, assignmentId);
            stmt.setInt(2, driverId);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.markDeliveredDoorstep: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cancels a PENDING or ACCEPTED assignment (e.g. store cancels order).
     */
    public boolean cancelAssignment(int assignmentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(CANCEL)) {

            stmt.setInt(1, assignmentId);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.cancelAssignment: " + e.getMessage());
            return false;
        }
    }

    /**
     * Resets a stale ACCEPTED assignment back to PENDING (driver_id cleared),
     * making it claimable by another driver. Used by Rule 3 of the timeout job.
     */
    public boolean resetAssignmentToPending(int assignmentId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(RESET_TO_PENDING)) {

            stmt.setInt(1, assignmentId);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.resetAssignmentToPending: " + e.getMessage());
            return false;
        }
    }

    /**
     * Driver voluntarily releases their ACCEPTED assignment back to PENDING.
     * This path intentionally does not create a driver incident.
     */
    public boolean releaseAcceptedByDriver(int assignmentId, int driverId,
                                           String reasonCode, String reasonNote) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String orderId = null;
            try (PreparedStatement get = conn.prepareStatement(
                    "SELECT order_id FROM delivery_assignments WHERE assignment_id=? AND driver_id=? AND status='ACCEPTED'")) {
                get.setInt(1, assignmentId);
                get.setInt(2, driverId);
                try (ResultSet rs = get.executeQuery()) {
                    if (rs.next()) {
                        orderId = rs.getString("order_id");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement release = conn.prepareStatement(DRIVER_RELEASE_ACCEPTED)) {
                release.setInt(1, assignmentId);
                release.setInt(2, driverId);
                if (release.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement audit = conn.prepareStatement(INSERT_REQUEUE_EVENT)) {
                audit.setInt(1, assignmentId);
                audit.setString(2, orderId);
                audit.setInt(3, driverId);
                audit.setString(4, reasonCode);
                if (reasonNote == null || reasonNote.isBlank()) {
                    audit.setNull(5, Types.VARCHAR);
                } else {
                    audit.setString(5, reasonNote);
                }
                audit.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.releaseAcceptedByDriver: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) { }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) { }
            }
        }
    }

    /**
     * Allows the owning store to change required vehicle type while still unclaimed.
     */
    public boolean updateVehicleTypeIfPending(int assignmentId, int storeId, String vehicleType) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_VEHICLE_TYPE_PENDING)) {

            stmt.setString(1, vehicleType);
            stmt.setInt(2, assignmentId);
            stmt.setInt(3, storeId);
            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.updateVehicleTypeIfPending: " + e.getMessage());
            return false;
        }
    }

    /**
     * Lightweight DTO for a stale ACCEPTED assignment (Rule 3).
     * Only the IDs are needed — no contact details, since we do not email on a re-queue.
     */
    public static class StaleAcceptedAssignment {
        public final int assignmentId;
        public final int driverId;
        public final String orderId;

        public StaleAcceptedAssignment(int assignmentId, int driverId, String orderId) {
            this.assignmentId = assignmentId;
            this.driverId     = driverId;
            this.orderId      = orderId;
        }
    }

    /**
     * Returns ACCEPTED assignments where the driver has not triggered a pickup
     * within {@code hoursOld} hours of accepting (Rule 3).
     */
    public List<StaleAcceptedAssignment> getStaleAcceptedAssignments(int hoursOld) {
        List<StaleAcceptedAssignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_STALE_ACCEPTED)) {

            stmt.setInt(1, hoursOld);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new StaleAcceptedAssignment(
                        rs.getInt("assignment_id"),
                        rs.getInt("driver_id"),
                        rs.getString("order_id")
                    ));
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getStaleAcceptedAssignments: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns PICKED_UP assignments where the driver has not completed delivery
     * within {@code hoursOld} hours of the recorded pickup time (Rule 4).
     * Reuses {@link StaleAssignment} since the same fields are needed for notifications.
     */
    public List<StaleAssignment> getStalePickedUpAssignments(int hoursOld) {
        List<StaleAssignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_STALE_PICKED_UP)) {

            stmt.setInt(1, hoursOld);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new StaleAssignment(
                        rs.getInt("assignment_id"),
                        rs.getString("order_id"),
                        rs.getInt("driver_id"),
                        rs.getString("driver_email"),
                        rs.getString("store_name"),
                        rs.getString("store_owner_email"),
                        rs.getString("buyer_email"),
                        rs.getString("buyer_name"),
                        rs.getString("payhere_payment_id"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("currency")
                    ));
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getStalePickedUpAssignments: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns orders that were paid but not dispatched by the store within
     * {@code hoursOld} hours (Rule 1). Reuses {@link OrphanedOrder} since
     * both represent an order-level result with the same contact fields.
     */
    public List<OrphanedOrder> getStalePaidOrders(int hoursOld) {
        List<OrphanedOrder> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_STALE_PAID)) {

            stmt.setInt(1, hoursOld);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new OrphanedOrder(
                        rs.getString("order_id"),
                        rs.getString("store_name"),
                        rs.getString("store_owner_email"),
                        rs.getString("buyer_email"),
                        rs.getString("buyer_name"),
                        rs.getString("payhere_payment_id"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("currency")
                    ));
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getStalePaidOrders: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns all assignments for a driver filtered by status.
     * Use "ACCEPTED" for active deliveries, "DELIVERED" for history.
     */
    public List<DeliveryAssignment> getByDriver(int driverId, String status) {
        List<DeliveryAssignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_DRIVER)) {

            stmt.setInt(1, driverId);
            stmt.setString(2, status);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DeliveryAssignment da = mapRow(rs);
                    da.setStoreName(rs.getString("store_name"));
                    da.setStoreLat(rs.getDouble("store_lat"));
                    da.setStoreLng(rs.getDouble("store_lng"));
                    String fn = rs.getString("first_name");
                    String ln = rs.getString("last_name");
                    if (fn != null) da.setCustomerName(fn + (ln != null ? " " + ln : ""));
                    da.setBuyerPhone(rs.getString("buyer_phone"));
                    list.add(da);
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getByDriver: " + e.getMessage());
        }
        return list;
    }

    /**
     * Returns all assignments for a store (all statuses), newest first.
     */
    public List<DeliveryAssignment> getByStore(int storeId) {
        List<DeliveryAssignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_BY_STORE)) {

            stmt.setInt(1, storeId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DeliveryAssignment da = mapRow(rs);
                    da.setCustomerName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    String driverName = rs.getString("driver_name_join");
                    da.setDriverName(driverName != null ? driverName : "Unassigned");
                    list.add(da);
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getByStore: " + e.getMessage());
        }
        return list;
    }

    // ── Timeout / sad-path query ──────────────────────────────────────────────

    /**
     * Holds everything the timeout job needs to process one stale assignment.
     * Loaded via a JOIN across delivery_assignments, stores, users, and orders.
     */
    public static class StaleAssignment {
        public final int    assignmentId;
        public final String orderId;
        public final int    driverId;
        public final String driverEmail;
        public final String storeName;
        public final String storeOwnerEmail;
        public final String buyerEmail;
        public final String buyerName;
        public final String payherePaymentId;
        public final java.math.BigDecimal totalAmount;
        public final String currency;

        public StaleAssignment(int assignmentId, String orderId, int driverId, String driverEmail,
                               String storeName, String storeOwnerEmail, String buyerEmail,
                               String buyerName, String payherePaymentId,
                               java.math.BigDecimal totalAmount, String currency) {
            this.assignmentId    = assignmentId;
            this.orderId         = orderId;
            this.driverId        = driverId;
            this.driverEmail     = driverEmail;
            this.storeName       = storeName;
            this.storeOwnerEmail = storeOwnerEmail;
            this.buyerEmail      = buyerEmail;
            this.buyerName       = buyerName;
            this.payherePaymentId = payherePaymentId;
            this.totalAmount     = totalAmount;
            this.currency        = currency;
        }
    }

    private static final String SELECT_STALE =
        "SELECT da.assignment_id, da.order_id, " +
        "       s.store_name, " +
        "       u.email AS store_owner_email, " +
        "       o.email AS buyer_email, " +
        "       CONCAT(o.first_name, ' ', o.last_name) AS buyer_name, " +
        "       o.payhere_payment_id, o.total_amount, o.currency " +
        "FROM delivery_assignments da " +
        "JOIN stores s  ON da.store_id  = s.store_id " +
        "JOIN users  u  ON s.user_id    = u.user_id " +
        "JOIN orders o  ON da.order_id  = o.order_id " +
        "WHERE da.status = 'PENDING' " +
        "  AND da.driver_id IS NULL " +
        "  AND TIMESTAMPDIFF(HOUR, da.created_at, NOW()) >= ?";

    /**
     * Holds everything the timeout job needs to refund an order whose
     * delivery_assignment row never existed (or was already cancelled/missing),
     * yet the order has been stuck in STORE_ACCEPTED for too long.
     */
    public static class OrphanedOrder {
        public final String orderId;
        public final String storeName;
        public final String storeOwnerEmail;
        public final String buyerEmail;
        public final String buyerName;
        public final String payherePaymentId;
        public final java.math.BigDecimal totalAmount;
        public final String currency;

        public OrphanedOrder(String orderId, String storeName,
                             String storeOwnerEmail, String buyerEmail,
                             String buyerName, String payherePaymentId,
                             java.math.BigDecimal totalAmount, String currency) {
            this.orderId          = orderId;
            this.storeName        = storeName;
            this.storeOwnerEmail  = storeOwnerEmail;
            this.buyerEmail       = buyerEmail;
            this.buyerName        = buyerName;
            this.payherePaymentId = payherePaymentId;
            this.totalAmount      = totalAmount;
            this.currency         = currency;
        }
    }

    /**
     * Finds orders that are stuck in STORE_ACCEPTED for longer than {@code hoursOld}
     * hours AND have no corresponding PENDING delivery_assignment row.
     * This catches cases where the assignment row was never created (e.g. silent
     * duplicate-key failure on a retry) so the normal stale-assignment query misses them.
     */
    private static final String SELECT_ORPHANED =
        "SELECT o.order_id, " +
        "       s.store_name, " +
        "       u.email  AS store_owner_email, " +
        "       o.email  AS buyer_email, " +
        "       CONCAT(o.first_name, ' ', o.last_name) AS buyer_name, " +
        "       o.payhere_payment_id, o.total_amount, o.currency " +
        "FROM orders o " +
        "JOIN stores s ON o.store_id  = s.store_id " +
        "JOIN users  u ON s.user_id   = u.user_id " +
        "WHERE o.status = 'STORE_ACCEPTED' " +
        "  AND TIMESTAMPDIFF(HOUR, o.updated_at, NOW()) >= ? " +
        "  AND NOT EXISTS ( " +
        "      SELECT 1 FROM delivery_assignments da " +
        "      WHERE da.order_id = o.order_id AND da.status = 'PENDING' " +
        "  )";

    public List<OrphanedOrder> getOrphanedStoreAcceptedOrders(int hoursOld) {
        List<OrphanedOrder> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ORPHANED)) {

            stmt.setInt(1, hoursOld);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new OrphanedOrder(
                        rs.getString("order_id"),
                        rs.getString("store_name"),
                        rs.getString("store_owner_email"),
                        rs.getString("buyer_email"),
                        rs.getString("buyer_name"),
                        rs.getString("payhere_payment_id"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("currency")
                    ));
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getOrphanedStoreAcceptedOrders: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Returns all PENDING, unassigned assignments older than {@code hoursOld} hours,
     * enriched with store-owner and buyer contact details for notification.
     */
    public List<StaleAssignment> getStaleAssignments(int hoursOld) {
        List<StaleAssignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_STALE)) {

            stmt.setInt(1, hoursOld);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new StaleAssignment(
                        rs.getInt("assignment_id"),
                        rs.getString("order_id"),
                        0,    // PENDING assignments have no driver yet
                        null, // no driver email
                        rs.getString("store_name"),
                        rs.getString("store_owner_email"),
                        rs.getString("buyer_email"),
                        rs.getString("buyer_name"),
                        rs.getString("payhere_payment_id"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("currency")
                    ));
                }
            }
        } catch (Exception e) {
            System.err.println("DeliveryAssignmentDAO.getStaleAssignments: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private DeliveryAssignment mapRow(ResultSet rs) throws SQLException {
        DeliveryAssignment da = new DeliveryAssignment();
        da.setAssignmentId(rs.getInt("assignment_id"));
        da.setOrderId(rs.getString("order_id"));
        da.setStoreId(rs.getInt("store_id"));

        int driverId = rs.getInt("driver_id");
        da.setDriverId(rs.wasNull() ? null : driverId);

        da.setRequiredVehicleType(rs.getString("required_vehicle_type"));
        da.setDeliveryFeeEarned(rs.getBigDecimal("delivery_fee_earned"));
        da.setPickupAddress(rs.getString("pickup_address"));
        da.setDeliveryAddress(rs.getString("delivery_address"));

        double lat = rs.getDouble("delivery_lat");
        da.setDeliveryLat(rs.wasNull() ? null : lat);
        double lng = rs.getDouble("delivery_lng");
        da.setDeliveryLng(rs.wasNull() ? null : lng);

        da.setStatus(rs.getString("status"));
        da.setCompletionMethod(rs.getString("completion_method"));
        da.setAssignedAt(rs.getTimestamp("assigned_at"));
        da.setCompletedAt(rs.getTimestamp("completed_at"));

        int payoutId = rs.getInt("driver_payout_id");
        da.setDriverPayoutId(rs.wasNull() ? null : payoutId);

        da.setDeliveryPin(rs.getString("delivery_pin"));
        da.setCreatedAt(rs.getTimestamp("created_at"));
        return da;
    }
}
