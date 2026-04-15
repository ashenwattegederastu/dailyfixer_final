package com.dailyfixer.dao;

import com.dailyfixer.model.Order;
import com.dailyfixer.model.ProductSales;
import com.dailyfixer.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AdminDashboardDAO {

    // ── Platform-wide overview stats (for admin main dashboard) ──

    public int getTotalUsers() {
        return countQuery("SELECT COUNT(*) FROM users");
    }

    public int getActiveUsers() {
        return countQuery("SELECT COUNT(*) FROM users WHERE status = 'active'");
    }

    public int getSuspendedUsers() {
        return countQuery("SELECT COUNT(*) FROM users WHERE status = 'suspended'");
    }

    public int getTotalBookings() {
        return countQuery("SELECT COUNT(*) FROM bookings");
    }

    public int getActiveBookings() {
        return countQuery("SELECT COUNT(*) FROM bookings WHERE status IN ('REQUESTED','ACCEPTED')");
    }

    public int getOrdersLast24h() {
        return countQuery("SELECT COUNT(*) FROM orders WHERE created_at >= NOW() - INTERVAL 1 DAY");
    }

    public double getRevenueLast24h() {
        return sumQuery("SELECT COALESCE(SUM(total_amount),0) FROM orders WHERE created_at >= NOW() - INTERVAL 1 DAY AND status IN ('PAID','PROCESSING','OUT_FOR_DELIVERY','DELIVERED')");
    }

    public int getPendingRefunds() {
        return countQuery("SELECT COUNT(*) FROM orders WHERE UPPER(TRIM(status)) = 'REFUND_PENDING'");
    }

    public int getPendingVolunteerRequests() {
        return countQuery("SELECT COUNT(*) FROM volunteer_requests WHERE status = 'PENDING'");
    }

    public int getFlaggedGuidesCount() {
        return countQuery("SELECT COUNT(DISTINCT guide_id) FROM guide_flags");
    }

    public int getTotalGuides() {
        return countQuery("SELECT COUNT(*) FROM guides");
    }

    public int getTotalDiagnosticTrees() {
        return countQuery("SELECT COUNT(*) FROM diagnostic_trees");
    }

    /** Returns a map of role -> count, e.g. {user=80, technician=15, ...} */
    public Map<String, Integer> getUserCountsByRole() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT role, COUNT(*) AS cnt FROM users GROUP BY role ORDER BY cnt DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("role"), rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Returns a map of status -> count for orders */
    public Map<String, Integer> getOrderCountsByStatus() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS cnt FROM orders GROUP BY status ORDER BY cnt DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Orders per day for the last N days – returns date-label -> count (ordered oldest→newest) */
    public Map<String, Integer> getOrdersPerDay(int days) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT DATE(created_at) AS d, COUNT(*) AS cnt FROM orders " +
                     "WHERE created_at >= CURDATE() - INTERVAL ? DAY " +
                     "GROUP BY d ORDER BY d";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("d"), rs.getInt("cnt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Revenue per day for the last N days (all paid/fulfilled orders) */
    public Map<String, Double> getRevenuePerDay(int days) {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT DATE(created_at) AS d, COALESCE(SUM(total_amount),0) AS rev FROM orders " +
                     "WHERE created_at >= CURDATE() - INTERVAL ? DAY AND status IN ('PAID','PROCESSING','OUT_FOR_DELIVERY','DELIVERED') " +
                     "GROUP BY d ORDER BY d";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("d"), rs.getDouble("rev"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** New user registrations per day for the last N days */
    public Map<String, Integer> getNewUsersPerDay(int days) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT DATE(created_at) AS d, COUNT(*) AS cnt FROM users " +
                     "WHERE created_at >= CURDATE() - INTERVAL ? DAY " +
                     "GROUP BY d ORDER BY d";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("d"), rs.getInt("cnt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Bookings per day for the last N days */
    public Map<String, Integer> getBookingsPerDay(int days) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT DATE(created_at) AS d, COUNT(*) AS cnt FROM bookings " +
                     "WHERE created_at >= CURDATE() - INTERVAL ? DAY " +
                     "GROUP BY d ORDER BY d";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("d"), rs.getInt("cnt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    // ── helper utilities ──

    private int countQuery(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private double sumQuery(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // ── Store-level stats (used by AdminStoreDashboardServlet) ──

    public int getTotalRegisteredStores() {
        String sql = "SELECT COUNT(*) FROM stores";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalProductsListed() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalSalesToday() {
        String sql = "SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURDATE() AND status IN ('PAID','PROCESSING','OUT_FOR_DELIVERY','DELIVERED')";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getTotalRevenueToday() {
        String sql = "SELECT SUM(total_amount) FROM orders WHERE DATE(created_at) = CURDATE() AND status IN ('PAID','PROCESSING','OUT_FOR_DELIVERY','DELIVERED')";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public double getTotalRevenueMonth() {
        String sql = "SELECT SUM(total_amount) FROM orders WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE()) AND status IN ('PAID','PROCESSING','OUT_FOR_DELIVERY','DELIVERED')";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public List<ProductSales> getBestSellingItems(int limit) {
        List<ProductSales> list = new ArrayList<>();
        String sql = "SELECT p.name, SUM(oi.quantity) as total_sold " +
                "FROM order_items oi " +
                "JOIN products p ON oi.product_id = p.product_id " +
                "JOIN orders o ON oi.order_id = o.order_id " +
                "WHERE o.status IN ('PAID','PROCESSING','OUT_FOR_DELIVERY','DELIVERED') " +
                "GROUP BY p.product_id, p.name " +
                "ORDER BY total_sold DESC " +
                "LIMIT ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductSales psales = new ProductSales();
                    psales.setProductName(rs.getString("name"));
                    psales.setQuantitySold(rs.getInt("total_sold"));
                    list.add(psales);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getLatestTransactions(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY created_at DESC LIMIT ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> searchTransactions(String query) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE order_id LIKE ? OR customer_name LIKE ? OR email LIKE ? ORDER BY created_at DESC";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getString("order_id"));

        // Split customer_name into first_name and last_name
        String customerName = rs.getString("customer_name");
        if (customerName != null && !customerName.isEmpty()) {
            String[] nameParts = customerName.trim().split("\\s+", 2);
            if (nameParts.length > 0) {
                order.setFirstName(nameParts[0]);
                order.setLastName(nameParts.length > 1 ? nameParts[1] : "");
            } else {
                order.setFirstName(customerName);
                order.setLastName("");
            }
        } else {
            order.setFirstName("");
            order.setLastName("");
        }

        order.setEmail(rs.getString("email"));
        order.setAmount(rs.getBigDecimal("total_amount"));
        order.setStatus(rs.getString("status"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setCurrency(rs.getString("currency")); // Added currency
        return order;
    }
}
