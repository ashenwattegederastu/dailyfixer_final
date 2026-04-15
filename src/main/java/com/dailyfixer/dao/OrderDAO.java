package com.dailyfixer.dao;

import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.ProductSales;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Order entity.
 * Handles all database operations for orders.
 */
public class OrderDAO {

    // SQL Statements
    private static final String INSERT_ORDER = "INSERT INTO orders (order_id, customer_name, first_name, last_name, email, phone, address, city, "
            +
            "total_amount, delivery_fee, currency, status, store_username, store_id, product_name, buyer_id, delivery_latitude, delivery_longitude, doorstep_drop_consent) "
            +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_ORDER_BY_ID = "SELECT * FROM orders WHERE order_id = ?";

    private static final String UPDATE_ORDER_STATUS = "UPDATE orders SET status = ?, payhere_payment_id = ? WHERE order_id = ?";

    private static final String UPDATE_STATUS_ONLY = "UPDATE orders SET status = ? WHERE order_id = ?";

    /**
     * Only transitions PENDING → PAID so duplicate PayHere notifies / Success page cannot
     * both apply inventory deduction (MySQL matched-row counts would otherwise allow a second reduction).
     */
    private static final String CLAIM_ORDER_PAID_FROM_PENDING_WITH_PAYMENT =
            "UPDATE orders SET status = 'PAID', payhere_payment_id = ? WHERE order_id = ? "
                    + "AND UPPER(TRIM(COALESCE(status,''))) = 'PENDING'";

    private static final String CLAIM_ORDER_PAID_FROM_PENDING_NO_PAYMENT =
            "UPDATE orders SET status = 'PAID' WHERE order_id = ? "
                    + "AND UPPER(TRIM(COALESCE(status,''))) = 'PENDING'";

    private static final String MARK_REFUNDED =
        "UPDATE orders " +
        "SET status = 'REFUNDED', refund_number = ?, refunded_at = NOW(), updated_at = NOW() " +
        "WHERE order_id = ? AND status = 'REFUND_PENDING'";

    private static final String MARK_REFUND_PENDING =
        "UPDATE orders " +
        "SET status = 'REFUND_PENDING', refund_reason = ?, updated_at = NOW() " +
        "WHERE order_id = ? " +
        "  AND status NOT IN ('REFUND_PENDING', 'REFUNDED', 'CANCELLED')";

    private static final String SELECT_ORDERS_BY_STATUS = "SELECT * FROM orders WHERE UPPER(TRIM(status)) = UPPER(TRIM(?)) ORDER BY created_at DESC";

    private static final String SELECT_ORDERS_BY_STORE = "SELECT * FROM orders WHERE UPPER(TRIM(status)) = UPPER(TRIM(?)) AND (store_id = ? OR store_username = ?) ORDER BY created_at DESC";

    private static final String SELECT_ALL_ORDERS_BY_STORE = "SELECT * FROM orders WHERE (store_id = ? OR store_username = ?) AND UPPER(TRIM(status)) IN ('PAID','PENDING','PROCESSING','STORE_ACCEPTED','OUT_FOR_DELIVERY','DELIVERED') ORDER BY created_at DESC";

    private static final String SELECT_REFUND_ORDERS_BY_STORE = "SELECT * FROM orders WHERE (store_id = ? OR store_username = ?) AND UPPER(TRIM(status)) IN ('REFUND_PENDING','REFUNDED') ORDER BY created_at DESC";

    private static final String SELECT_ORDERS_BY_BUYER = "SELECT * FROM orders WHERE buyer_id = ? ORDER BY created_at DESC";

    // Order Items SQL
    private static final String INSERT_ORDER_ITEM = "INSERT INTO order_items (order_id, store_id, product_id, variant_id, "
            +
            "product_name, quantity, unit_price, total_price, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_ORDER_ITEMS_BY_ORDER_ID = "SELECT * FROM order_items WHERE order_id = ? ORDER BY id";

    private static final String SELECT_ORDER_ITEMS_BY_STORE_AND_STATUS = "SELECT oi.* FROM order_items oi " +
            "JOIN orders o ON oi.order_id = o.order_id " +
            "WHERE oi.store_id = ? AND UPPER(TRIM(o.status)) = UPPER(TRIM(?)) " +
            "ORDER BY o.created_at DESC, oi.id";

    private static final String SELECT_PRODUCT_SALES_BY_STORE_ID = "SELECT oi.product_name, SUM(oi.quantity) AS total_qty FROM order_items oi "
            +
            "JOIN orders o ON oi.order_id = o.order_id " +
            "WHERE oi.store_id = ? AND UPPER(TRIM(o.status)) IN ('PAID','PENDING','PROCESSING','STORE_ACCEPTED','OUT_FOR_DELIVERY','DELIVERED') "
            +
            "GROUP BY oi.product_id, oi.product_name ORDER BY total_qty DESC";

    private static final String SELECT_PRODUCT_SALES_BY_STORE_USERNAME = "SELECT oi.product_id, oi.product_name, SUM(oi.quantity) AS total_qty FROM order_items oi "
            +
            "JOIN orders o ON oi.order_id = o.order_id " +
            "WHERE o.store_username = ? AND UPPER(TRIM(o.status)) IN ('PAID','PENDING','PROCESSING','STORE_ACCEPTED','OUT_FOR_DELIVERY','DELIVERED') "
            +
            "GROUP BY oi.product_id, oi.product_name ORDER BY total_qty DESC";

    /**
     * Get database connection.
     * Protected to allow overriding in tests (e.g., to use H2).
     */
    protected Connection getConnection() throws SQLException, ClassNotFoundException {
        return DBConnection.getConnection();
    }

    /**
     * Create a new order in the database.
     *
     * @param order The order to create
     * @return true if successful, false otherwise
     */
    public boolean createOrder(Order order) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(INSERT_ORDER);

            // Build customer_name from first + last for backward compatibility
            String customerName = order.getFirstName();
            if (order.getLastName() != null && !order.getLastName().isEmpty()) {
                customerName += " " + order.getLastName();
            }

            stmt.setString(1, order.getOrderId());
            stmt.setString(2, customerName); // customer_name (legacy)
            stmt.setString(3, order.getFirstName()); // first_name
            stmt.setString(4, order.getLastName()); // last_name
            stmt.setString(5, order.getEmail());
            stmt.setString(6, order.getPhone());
            stmt.setString(7, order.getAddress());
            stmt.setString(8, order.getCity());
            stmt.setBigDecimal(9, order.getAmount()); // total_amount
            java.math.BigDecimal deliveryFee = order.getDeliveryFee() != null ? order.getDeliveryFee() : java.math.BigDecimal.ZERO;
            stmt.setBigDecimal(10, deliveryFee); // delivery_fee
            stmt.setString(11, order.getCurrency());
            stmt.setString(12, order.getStatus());
            stmt.setString(13, order.getStoreUsername());
            if (order.getStoreId() != null) {
                stmt.setInt(14, order.getStoreId()); // store_id
            } else {
                stmt.setNull(14, Types.INTEGER);
            }
            stmt.setString(15, order.getProductName());
            if (order.getBuyerId() != null) {
                stmt.setInt(16, order.getBuyerId());
            } else {
                stmt.setNull(16, Types.INTEGER);
            }
            if (order.getDeliveryLatitude() != null) {
                stmt.setDouble(17, order.getDeliveryLatitude());
            } else {
                stmt.setNull(17, Types.DECIMAL);
            }
            if (order.getDeliveryLongitude() != null) {
                stmt.setDouble(18, order.getDeliveryLongitude());
            } else {
                stmt.setNull(18, Types.DECIMAL);
            }
            stmt.setBoolean(19, order.isDoorstepDropConsent());

            int rowsAffected = stmt.executeUpdate();
            System.out.println("Order created: " + order.getOrderId() + " | Rows affected: " + rowsAffected);
            return rowsAffected > 0;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error creating order: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(stmt, conn);
        }
    }

    /**
     * Find an order by its ID.
     *
     * @param orderId The order ID to search for
     * @return Order object if found, null otherwise
     */
    public Order findOrderById(String orderId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_ORDER_BY_ID);
            stmt.setString(1, orderId);

            rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToOrder(rs);
            }
            return null;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error finding order: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }

    /**
     * Update order status and optionally PayHere payment ID.
     *
     * @param orderId          The order ID
     * @param status           New status (PENDING, PAID, CANCELLED, FAILED)
     * @param payherePaymentId PayHere payment ID (optional)
     * @return true if successful, false otherwise
     */
    public boolean updateOrderStatus(String orderId, String status, String payherePaymentId) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(UPDATE_ORDER_STATUS);

            stmt.setString(1, status);
            stmt.setString(2, payherePaymentId);
            stmt.setString(3, orderId);

            int rowsAffected = stmt.executeUpdate();
            System.out.println("Order status updated: " + orderId + " -> " + status + " | Rows: " + rowsAffected);
            return rowsAffected > 0;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error updating order status: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(stmt, conn);
        }
    }

    /**
     * Update only the order status.
     *
     * @param orderId The order ID
     * @param status  New status
     * @return true if successful, false otherwise
     */
    public boolean updateStatus(String orderId, String status) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(UPDATE_STATUS_ONLY);

            stmt.setString(1, status);
            stmt.setString(2, orderId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error updating status: " + e.getMessage());
            return false;
        } finally {
            closeResources(stmt, conn);
        }
    }

    /**
     * Atomically sets an order to PAID only if it is still PENDING.
     * Call this before {@link #reduceStockForOrder(String)} so only one concurrent
     * caller (PayHere notify, success page, duplicate webhook) can deduct inventory.
     *
     * @param payherePaymentId optional; when null or blank, {@code payhere_payment_id} is not changed
     * @return true if exactly one row was updated (this path should reduce stock)
     */
    public boolean claimOrderPaidFromPending(String orderId, String payherePaymentId) {
        if (orderId == null || orderId.isBlank()) {
            return false;
        }
        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = getConnection();
            boolean setPayment = payherePaymentId != null && !payherePaymentId.isBlank();
            if (setPayment) {
                stmt = conn.prepareStatement(CLAIM_ORDER_PAID_FROM_PENDING_WITH_PAYMENT);
                stmt.setString(1, payherePaymentId);
                stmt.setString(2, orderId);
            } else {
                stmt = conn.prepareStatement(CLAIM_ORDER_PAID_FROM_PENDING_NO_PAYMENT);
                stmt.setString(1, orderId);
            }
            int n = stmt.executeUpdate();
            if (n > 0) {
                System.out.println("claimOrderPaidFromPending: claimed PAID for order " + orderId + " (rows=" + n + ")");
            }
            return n > 0;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("claimOrderPaidFromPending: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(stmt, conn);
        }
    }

    /**
     * Get all orders by status.
     *
     * @param status The order status (e.g., "PAID", "PENDING")
     * @return List of orders with the specified status
     */
    public java.util.List<Order> getOrdersByStatus(String status) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Order> orders = new java.util.ArrayList<>();

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_ORDERS_BY_STATUS);
            stmt.setString(1, status);

            rs = stmt.executeQuery();

            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
            return orders;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting orders by status: " + e.getMessage());
            e.printStackTrace();
            return orders;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }

    /**
     * Get orders by status and store username.
     *
     * @param status        The order status (e.g., "PAID", "PENDING")
     * @param storeUsername The store username
     * @return List of orders for the store with the specified status
     */
    public java.util.List<Order> getOrdersByStatusAndStore(String status, String storeUsername) {
        return getOrdersByStatusAndStore(status, storeUsername, 0);
    }

    /**
     * Get orders by status and store (using store_id or store_username).
     */
    public java.util.List<Order> getOrdersByStatusAndStore(String status, String storeUsername, int storeId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Order> orders = new java.util.ArrayList<>();

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_ORDERS_BY_STORE);
            stmt.setString(1, status);
            stmt.setInt(2, storeId);
            stmt.setString(3, storeUsername);

            rs = stmt.executeQuery();

            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
            return orders;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting orders by status and store: " + e.getMessage());
            e.printStackTrace();
            return orders;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }

    /**
     * Get all orders for a store (PAID, PENDING, PROCESSING, STORE_ACCEPTED,
     * OUT_FOR_DELIVERY, DELIVERED) for charts and trends.
     */
    public java.util.List<Order> getAllOrdersByStore(String storeUsername) {
        return getAllOrdersByStore(storeUsername, 0);
    }

    /**
     * Get all orders for a store using store_id or store_username.
     */
    public java.util.List<Order> getAllOrdersByStore(String storeUsername, int storeId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Order> orders = new java.util.ArrayList<>();
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_ALL_ORDERS_BY_STORE);
            stmt.setInt(1, storeId);
            stmt.setString(2, storeUsername);
            rs = stmt.executeQuery();
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting all orders by store: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
        }
        return orders;
    }

    /**
     * Get orders in REFUND_PENDING or REFUNDED status for a store.
     */
    public java.util.List<Order> getRefundOrdersByStore(String storeUsername, int storeId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Order> orders = new java.util.ArrayList<>();
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_REFUND_ORDERS_BY_STORE);
            stmt.setInt(1, storeId);
            stmt.setString(2, storeUsername);
            rs = stmt.executeQuery();
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting refund orders by store: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
        }
        return orders;
    }

    /**
     * Get all orders for a specific buyer (user).
     *
     * @param buyerId The user ID of the buyer
     * @return List of orders placed by the buyer
     */
    public java.util.List<Order> getOrdersByBuyerId(int buyerId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<Order> orders = new java.util.ArrayList<>();
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_ORDERS_BY_BUYER);
            stmt.setInt(1, buyerId);
            rs = stmt.executeQuery();
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting orders by buyer ID: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
        }
        return orders;
    }

    /**
     * Get top selling products by quantity for a store (from PAID, PENDING,
     * PROCESSING, STORE_ACCEPTED, OUT_FOR_DELIVERY, DELIVERED orders).
     */
    public java.util.List<ProductSales> getProductSalesByStore(int storeId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<ProductSales> list = new java.util.ArrayList<>();
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_PRODUCT_SALES_BY_STORE_ID);
            stmt.setInt(1, storeId);
            rs = stmt.executeQuery();
            while (rs.next() && list.size() < 10) {
                ProductSales ps = new ProductSales();
                ps.setProductName(rs.getString("product_name") != null ? rs.getString("product_name") : "");
                ps.setQuantitySold(rs.getInt("total_qty"));
                list.add(ps);
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting product sales by store: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
        }
        return list;
    }

    /**
     * Get top selling products by quantity for a store by store username.
     * Uses orders.store_username so it works even when StoreDAO returns null.
     * Includes PAID, PENDING, PROCESSING, STORE_ACCEPTED, OUT_FOR_DELIVERY, DELIVERED.
     */
    public java.util.List<ProductSales> getProductSalesByStore(String storeUsername) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        java.util.List<ProductSales> list = new java.util.ArrayList<>();
        if (storeUsername == null || storeUsername.trim().isEmpty())
            return list;
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_PRODUCT_SALES_BY_STORE_USERNAME);
            stmt.setString(1, storeUsername.trim());
            rs = stmt.executeQuery();
            while (rs.next() && list.size() < 10) {
                ProductSales ps = new ProductSales();
                ps.setProductId(rs.getInt("product_id"));
                ps.setProductName(rs.getString("product_name") != null ? rs.getString("product_name") : "");
                ps.setQuantitySold(rs.getInt("total_qty"));
                list.add(ps);
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting product sales by store username: " + e.getMessage());
        } finally {
            closeResources(rs, stmt, conn);
        }
        return list;
    }

    /**
     * Map ResultSet to Order object.
     */
    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getString("order_id"));

        // Read first_name and last_name directly from dedicated columns
        String firstName = rs.getString("first_name");
        String lastName = rs.getString("last_name");
        if (firstName != null) {
            order.setFirstName(firstName);
            order.setLastName(lastName != null ? lastName : "");
        } else {
            // Fallback: split customer_name for rows created before the migration
            String customerName = rs.getString("customer_name");
            if (customerName != null && !customerName.isEmpty()) {
                String[] nameParts = customerName.trim().split("\\s+", 2);
                order.setFirstName(nameParts[0]);
                order.setLastName(nameParts.length > 1 ? nameParts[1] : "");
            } else {
                order.setFirstName("");
                order.setLastName("");
            }
        }

        order.setEmail(rs.getString("email"));
        order.setPhone(rs.getString("phone"));
        order.setAddress(rs.getString("address"));
        order.setCity(rs.getString("city"));
        String productName = rs.getString("product_name");
        order.setProductName(productName != null ? productName : "");
        order.setAmount(rs.getBigDecimal("total_amount"));
        order.setDeliveryFee(rs.getBigDecimal("delivery_fee"));
        order.setCurrency(rs.getString("currency"));
        order.setStatus(rs.getString("status"));
        order.setPayherePaymentId(rs.getString("payhere_payment_id"));
        order.setStoreUsername(rs.getString("store_username"));
        int storeId = rs.getInt("store_id");
        order.setStoreId(rs.wasNull() ? null : storeId);
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));
        int buyerId = rs.getInt("buyer_id");
        order.setBuyerId(rs.wasNull() ? null : buyerId);
        double dlat = rs.getDouble("delivery_latitude");
        if (!rs.wasNull()) order.setDeliveryLatitude(dlat);
        double dlng = rs.getDouble("delivery_longitude");
        if (!rs.wasNull()) order.setDeliveryLongitude(dlng);
        order.setRefundReason(rs.getString("refund_reason"));
        order.setRefundNumber(rs.getString("refund_number"));
        order.setRefundedAt(rs.getTimestamp("refunded_at"));
        order.setDoorstepDropConsent(rs.getBoolean("doorstep_drop_consent"));
        return order;
    }

    /**
     * Create an order item in the database.
     *
     * @param orderItem The order item to create
     * @return true if successful, false otherwise
     */
    public boolean createOrderItem(OrderItem orderItem) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(INSERT_ORDER_ITEM);

            stmt.setString(1, orderItem.getOrderId());
            stmt.setInt(2, orderItem.getStoreId());
            stmt.setInt(3, orderItem.getProductId());
            if (orderItem.getVariantId() != null) {
                stmt.setInt(4, orderItem.getVariantId());
            } else {
                stmt.setNull(4, Types.INTEGER);
            }
            stmt.setString(5, orderItem.getProductName());
            stmt.setInt(6, orderItem.getQuantity());
            stmt.setBigDecimal(7, orderItem.getUnitPrice());
            stmt.setBigDecimal(8, orderItem.getTotalPrice());
            stmt.setString(9, orderItem.getStatus() != null ? orderItem.getStatus() : "PENDING");

            int rowsAffected = stmt.executeUpdate();
            System.out.println(
                    "Order item created for order: " + orderItem.getOrderId() + " | Rows affected: " + rowsAffected);
            return rowsAffected > 0;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error creating order item: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(stmt, conn);
        }
    }

    /**
     * Get all order items for a specific order.
     *
     * @param orderId The order ID
     * @return List of order items
     */
    public List<OrderItem> getOrderItemsByOrderId(String orderId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<OrderItem> orderItems = new ArrayList<>();

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_ORDER_ITEMS_BY_ORDER_ID);
            stmt.setString(1, orderId);

            rs = stmt.executeQuery();

            while (rs.next()) {
                orderItems.add(mapResultSetToOrderItem(rs));
            }
            return orderItems;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting order items by order ID: " + e.getMessage());
            e.printStackTrace();
            return orderItems;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }

    /**
     * Get order items by store ID and order status.
     *
     * @param storeId The store ID
     * @param status  The order status
     * @return List of order items grouped by order
     */
    public List<OrderItem> getOrderItemsByStoreAndStatus(int storeId, String status) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<OrderItem> orderItems = new ArrayList<>();

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(SELECT_ORDER_ITEMS_BY_STORE_AND_STATUS);
            stmt.setInt(1, storeId);
            stmt.setString(2, status);

            rs = stmt.executeQuery();

            while (rs.next()) {
                orderItems.add(mapResultSetToOrderItem(rs));
            }
            return orderItems;

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting order items by store and status: " + e.getMessage());
            e.printStackTrace();
            return orderItems;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }

    /**
     * Map ResultSet to OrderItem object.
     */
    private OrderItem mapResultSetToOrderItem(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setId(rs.getInt("id"));
        item.setOrderId(rs.getString("order_id"));
        item.setStoreId(rs.getInt("store_id"));
        item.setProductId(rs.getInt("product_id"));
        int variantId = rs.getInt("variant_id");
        item.setVariantId(rs.wasNull() ? null : variantId);
        item.setProductName(rs.getString("product_name"));
        item.setQuantity(rs.getInt("quantity"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        item.setTotalPrice(rs.getBigDecimal("total_price"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    /**
     * Marks a REFUND_PENDING order as REFUNDED and records the refund reference number.
     *
     * @param orderId      The order ID
     * @param refundNumber The refund reference/transaction number from PayHere or bank
     * @return true if updated, false if order was not in REFUND_PENDING state
     */
    public boolean markRefunded(String orderId, String refundNumber) {
        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(MARK_REFUNDED);
            stmt.setString(1, refundNumber);
            stmt.setString(2, orderId);
            boolean updated = stmt.executeUpdate() > 0;
            if (updated) {
                new StoreOrderDAO().clearCommission(orderId);
            }
            return updated;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("OrderDAO.markRefunded: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(stmt, conn);
        }
    }

    /**
     * Marks an order as REFUND_PENDING and records the reason.
     * Idempotent — skips orders already in REFUND_PENDING, REFUNDED, or CANCELLED state.
     *
     * @param orderId The order ID
     * @param reason  Human-readable reason (stored in refund_reason column)
     * @return true if the row was updated, false if already in a terminal state or not found
     */
    public boolean markRefundPending(String orderId, String reason) {
        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(MARK_REFUND_PENDING);
            stmt.setString(1, reason);
            stmt.setString(2, orderId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("OrderDAO.markRefundPending: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(stmt, conn);
        }
    }

    /**
     * Close database resources safely (with ResultSet).
     */
    private void closeResources(ResultSet rs, PreparedStatement stmt, Connection conn) {
        try {
            if (rs != null)
                rs.close();
        } catch (SQLException e) {
            System.err.println("Error closing result set: " + e.getMessage());
        }
        closeResources(stmt, conn);
    }

    /**
     * Reduce stock for all items in an order.
     * This should be called when payment is successful (status = PAID).
     * 
     * @param orderId The order ID
     * @return true if stock reduction was successful for all items, false otherwise
     */
    public boolean reduceStockForOrder(String orderId) {
        try {
            // Get all order items
            List<OrderItem> orderItems = getOrderItemsByOrderId(orderId);

            if (orderItems == null || orderItems.isEmpty()) {
                System.out.println("No order items found for order: " + orderId);
                return false;
            }

            // Merge duplicate lines for the same product/variant (defensive — checkout should not duplicate)
            Map<String, Integer> qtyByKey = new LinkedHashMap<>();
            for (OrderItem item : orderItems) {
                Integer vid = item.getVariantId();
                if (vid != null && vid == 0) {
                    vid = null;
                }
                String key = item.getProductId() + ":" + (vid == null ? "P" : "V" + vid);
                qtyByKey.merge(key, item.getQuantity(), Integer::sum);
            }

            com.dailyfixer.dao.ProductDAO productDAO = new com.dailyfixer.dao.ProductDAO();
            com.dailyfixer.dao.ProductVariantDAO variantDAO = new com.dailyfixer.dao.ProductVariantDAO();

            boolean allSuccessful = true;

            for (Map.Entry<String, Integer> e : qtyByKey.entrySet()) {
                try {
                    String key = e.getKey();
                    int qty = e.getValue();
                    boolean isVariant = key.contains(":V");
                    if (isVariant) {
                        int variantId = Integer.parseInt(key.substring(key.indexOf(":V") + 2));
                        boolean success = variantDAO.reduceVariantQuantity(variantId, qty);
                        if (!success) {
                            System.err.println("Failed to reduce stock for variant ID: " + variantId);
                            allSuccessful = false;
                        }
                    } else {
                        int productId = Integer.parseInt(key.substring(0, key.indexOf(':')));
                        boolean success = productDAO.reduceProductQuantity(productId, qty);
                        if (!success) {
                            System.err.println("Failed to reduce stock for product ID: " + productId);
                            allSuccessful = false;
                        }
                    }
                } catch (Exception ex) {
                    System.err.println("Error reducing stock for order item: " + ex.getMessage());
                    ex.printStackTrace();
                    allSuccessful = false;
                }
            }

            if (allSuccessful) {
                System.out.println("Successfully reduced stock for all items in order: " + orderId);
            } else {
                System.err.println("Some stock reductions failed for order: " + orderId);
            }

            return allSuccessful;

        } catch (Exception e) {
            System.err.println("Error reducing stock for order: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Restores stock quantities for all items in an order.
     * Should be called whenever a PAID order is cancelled or refunded.
     */
    public boolean restoreStockForOrder(String orderId) {
        try {
            List<OrderItem> orderItems = getOrderItemsByOrderId(orderId);

            if (orderItems == null || orderItems.isEmpty()) {
                System.out.println("No order items found for order to restore: " + orderId);
                return false;
            }

            com.dailyfixer.dao.ProductDAO productDAO = new com.dailyfixer.dao.ProductDAO();
            com.dailyfixer.dao.ProductVariantDAO variantDAO = new com.dailyfixer.dao.ProductVariantDAO();

            boolean allSuccessful = true;

            for (OrderItem item : orderItems) {
                try {
                    if (item.getVariantId() != null) {
                        boolean success = variantDAO.restoreVariantQuantity(item.getVariantId(), item.getQuantity());
                        if (!success) {
                            System.err.println("Failed to restore stock for variant ID: " + item.getVariantId());
                            allSuccessful = false;
                        }
                    } else {
                        boolean success = productDAO.restoreProductQuantity(item.getProductId(), item.getQuantity());
                        if (!success) {
                            System.err.println("Failed to restore stock for product ID: " + item.getProductId());
                            allSuccessful = false;
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error restoring stock for order item: " + e.getMessage());
                    e.printStackTrace();
                    allSuccessful = false;
                }
            }

            if (allSuccessful) {
                System.out.println("Successfully restored stock for all items in order: " + orderId);
            } else {
                System.err.println("Some stock restorations failed for order: " + orderId);
            }

            return allSuccessful;

        } catch (Exception e) {
            System.err.println("Error restoring stock for order: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Close database resources safely.
     */
    private void closeResources(PreparedStatement stmt, Connection conn) {
        try {
            if (stmt != null)
                stmt.close();
        } catch (SQLException e) {
            System.err.println("Error closing statement: " + e.getMessage());
        }
        try {
            if (conn != null)
                conn.close();
        } catch (SQLException e) {
            System.err.println("Error closing connection: " + e.getMessage());
        }
    }
}
