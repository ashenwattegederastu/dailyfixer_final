package com.dailyfixer.dao;

import com.dailyfixer.model.Store;
import com.dailyfixer.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class StoreDAO {

    /**
     * Add a new store to the database.
     * Returns true if successful and sets the generated storeId in the Store object.
     */
    public boolean addStore(Store store) {
        String sql = "INSERT INTO stores (user_id, store_name, store_address, store_city, store_type, latitude, longitude) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, store.getUserId());
            ps.setString(2, store.getStoreName());
            ps.setString(3, store.getStoreAddress());
            ps.setString(4, store.getStoreCity());
            ps.setString(5, store.getStoreType());
            ps.setDouble(6, store.getLatitude());
            ps.setDouble(7, store.getLongitude());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        store.setStoreId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get a store by its ID, including latitude and longitude
     */
    public Store getStoreById(int storeId) {
        String sql = "SELECT * FROM stores WHERE store_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, storeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Store store = new Store();
                store.setStoreId(rs.getInt("store_id"));
                store.setUserId(rs.getInt("user_id"));
                store.setStoreName(rs.getString("store_name"));
                store.setStoreAddress(rs.getString("store_address"));
                store.setStoreCity(rs.getString("store_city"));
                store.setStoreType(rs.getString("store_type"));
                store.setLatitude(rs.getDouble("latitude"));
                store.setLongitude(rs.getDouble("longitude"));
                store.setCreatedAt(rs.getTimestamp("created_at"));
                return store;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Optional: update store's latitude/longitude
     */
    public boolean updateStoreCoordinates(int storeId, double latitude, double longitude) {
        String sql = "UPDATE stores SET latitude = ?, longitude = ? WHERE store_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, latitude);
            ps.setDouble(2, longitude);
            ps.setInt(3, storeId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update editable store fields (name, address, city, type).
     * Latitude/longitude are managed separately via updateStoreCoordinates().
     */
    public boolean updateStore(Store store) {
        String sql = "UPDATE stores SET store_name = ?, store_address = ?, store_city = ?, store_type = ? WHERE store_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, store.getStoreName());
            ps.setString(2, store.getStoreAddress());
            ps.setString(3, store.getStoreCity());
            ps.setString(4, store.getStoreType());
            ps.setInt(5, store.getStoreId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get a store by the owner's user_id
     */
    public Store getStoreByUserId(int userId) {
        String sql = "SELECT * FROM stores WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Store store = new Store();
                store.setStoreId(rs.getInt("store_id"));
                store.setUserId(rs.getInt("user_id"));
                store.setStoreName(rs.getString("store_name"));
                store.setStoreAddress(rs.getString("store_address"));
                store.setStoreCity(rs.getString("store_city"));
                store.setStoreType(rs.getString("store_type"));
                store.setLatitude(rs.getDouble("latitude"));
                store.setLongitude(rs.getDouble("longitude"));
                store.setCreatedAt(rs.getTimestamp("created_at"));
                return store;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get a store by the owner's username
     */
    public Store getStoreByUsername(String username) {
        String sql = "SELECT s.* FROM stores s " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "WHERE u.username = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Store store = new Store();
                store.setStoreId(rs.getInt("store_id"));
                store.setUserId(rs.getInt("user_id"));
                store.setStoreName(rs.getString("store_name"));
                store.setStoreAddress(rs.getString("store_address"));
                store.setStoreCity(rs.getString("store_city"));
                store.setStoreType(rs.getString("store_type"));
                store.setLatitude(rs.getDouble("latitude"));
                store.setLongitude(rs.getDouble("longitude"));
                store.setCreatedAt(rs.getTimestamp("created_at"));
                return store;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
