package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Order model class representing a customer order.
 */
public class Order {

    private String orderId;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String address;
    private String city;
    private String productName;
    private BigDecimal amount;
    private String currency;
    private String status;
    private String payherePaymentId;
    private String storeUsername; // Store username to filter orders by store
    private Integer storeId; // Store ID (FK to stores table)
    private Integer buyerId; // User ID of the buyer (null for guest checkout)
    private BigDecimal deliveryFee;
    private Double deliveryLatitude;
    private Double deliveryLongitude;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String refundReason;
    private String refundNumber;
    private Timestamp refundedAt;
    private boolean doorstepDropConsent;

    // Default constructor
    public Order() {
        this.currency = "LKR";
        this.status = "PENDING";
    }

    // Constructor with essential fields
    public Order(String orderId, String firstName, String lastName, String email,
            String phone, String address, String city, String productName, BigDecimal amount) {
        this();
        this.orderId = orderId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.city = city;
        this.productName = productName;
        this.amount = amount;
    }

    // ==================== Getters and Setters ====================

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPayherePaymentId() {
        return payherePaymentId;
    }

    public void setPayherePaymentId(String payherePaymentId) {
        this.payherePaymentId = payherePaymentId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getRefundReason() { return refundReason; }
    public void setRefundReason(String refundReason) { this.refundReason = refundReason; }

    public String getRefundNumber() { return refundNumber; }
    public void setRefundNumber(String refundNumber) { this.refundNumber = refundNumber; }

    public Timestamp getRefundedAt() { return refundedAt; }
    public void setRefundedAt(Timestamp refundedAt) { this.refundedAt = refundedAt; }

    public boolean isDoorstepDropConsent() {
        return doorstepDropConsent;
    }

    public void setDoorstepDropConsent(boolean doorstepDropConsent) {
        this.doorstepDropConsent = doorstepDropConsent;
    }

    public String getStoreUsername() {
        return storeUsername;
    }

    public void setStoreUsername(String storeUsername) {
        this.storeUsername = storeUsername;
    }

    public Integer getStoreId() {
        return storeId;
    }

    public void setStoreId(Integer storeId) {
        this.storeId = storeId;
    }

    public Integer getBuyerId() {
        return buyerId;
    }

    public void setBuyerId(Integer buyerId) {
        this.buyerId = buyerId;
    }

    public BigDecimal getDeliveryFee() {
        return deliveryFee;
    }

    public void setDeliveryFee(BigDecimal deliveryFee) {
        this.deliveryFee = deliveryFee;
    }

    public Double getDeliveryLatitude() {
        return deliveryLatitude;
    }

    public void setDeliveryLatitude(Double deliveryLatitude) {
        this.deliveryLatitude = deliveryLatitude;
    }

    public Double getDeliveryLongitude() {
        return deliveryLongitude;
    }

    public void setDeliveryLongitude(Double deliveryLongitude) {
        this.deliveryLongitude = deliveryLongitude;
    }

    // Get full customer name
    public String getFullName() {
        return firstName + " " + lastName;
    }

    // Get formatted amount (2 decimal places)
    public String getFormattedAmount() {
        return String.format("%.2f", amount);
    }

    @Override
    public String toString() {
        return "Order{" +
                "orderId='" + orderId + '\'' +
                ", customer='" + getFullName() + '\'' +
                ", amount=" + amount +
                ", status='" + status + '\'' +
                '}';
    }
}
