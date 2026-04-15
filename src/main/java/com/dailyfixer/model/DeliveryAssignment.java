package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Represents a single delivery leg for one store's order.
 * Lifecycle: PENDING → ACCEPTED → DELIVERED | CANCELLED
 */
public class DeliveryAssignment {

    // ── DB columns ──────────────────────────────────────────────────────────
    private int assignmentId;
    private String orderId;
    private int storeId;
    private Integer driverId;           // null until accepted
    private String requiredVehicleType;
    private BigDecimal deliveryFeeEarned;
    private String pickupAddress;       // store address
    private String deliveryAddress;     // customer address
    private Double deliveryLat;
    private Double deliveryLng;
    private String deliveryPin;         // 6-digit PIN for delivery confirmation
    private String status;              // PENDING | ACCEPTED | DELIVERED | CANCELLED
    private String completionMethod;    // PIN | DOORSTEP_PHOTO
    private Timestamp assignedAt;
    private Timestamp completedAt;
    private Integer driverPayoutId;     // null until paid out
    private Timestamp createdAt;

    // ── Transient fields (populated by DAO joins, not DB columns) ───────────
    private String storeName;
    private double storeLat;
    private double storeLng;
    private double distanceKm;          // haversine(store → driver home), set by DAO
    private String customerName;        // first_name + last_name from orders
    private String buyerPhone;          // phone from orders for delivery contact
    private String driverName;          // for admin / store views

    // ── Getters & Setters ────────────────────────────────────────────────────

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }

    public Integer getDriverId() { return driverId; }
    public void setDriverId(Integer driverId) { this.driverId = driverId; }

    public String getRequiredVehicleType() { return requiredVehicleType; }
    public void setRequiredVehicleType(String requiredVehicleType) { this.requiredVehicleType = requiredVehicleType; }

    public BigDecimal getDeliveryFeeEarned() { return deliveryFeeEarned; }
    public void setDeliveryFeeEarned(BigDecimal deliveryFeeEarned) { this.deliveryFeeEarned = deliveryFeeEarned; }

    public String getPickupAddress() { return pickupAddress; }
    public void setPickupAddress(String pickupAddress) { this.pickupAddress = pickupAddress; }

    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public Double getDeliveryLat() { return deliveryLat; }
    public void setDeliveryLat(Double deliveryLat) { this.deliveryLat = deliveryLat; }

    public Double getDeliveryLng() { return deliveryLng; }
    public void setDeliveryLng(Double deliveryLng) { this.deliveryLng = deliveryLng; }

    public String getDeliveryPin() { return deliveryPin; }
    public void setDeliveryPin(String deliveryPin) { this.deliveryPin = deliveryPin; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCompletionMethod() { return completionMethod; }
    public void setCompletionMethod(String completionMethod) { this.completionMethod = completionMethod; }

    public Timestamp getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }

    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }

    public Integer getDriverPayoutId() { return driverPayoutId; }
    public void setDriverPayoutId(Integer driverPayoutId) { this.driverPayoutId = driverPayoutId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // Transient
    public String getStoreName() { return storeName; }
    public void setStoreName(String storeName) { this.storeName = storeName; }

    public double getStoreLat() { return storeLat; }
    public void setStoreLat(double storeLat) { this.storeLat = storeLat; }

    public double getStoreLng() { return storeLng; }
    public void setStoreLng(double storeLng) { this.storeLng = storeLng; }

    public double getDistanceKm() { return distanceKm; }
    public void setDistanceKm(double distanceKm) { this.distanceKm = distanceKm; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getBuyerPhone() { return buyerPhone; }
    public void setBuyerPhone(String buyerPhone) { this.buyerPhone = buyerPhone; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }
}
