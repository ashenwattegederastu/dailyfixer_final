package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * StoreOrder model class representing a per-store breakdown of an order.
 * Maps to the store_orders table.
 */
public class StoreOrder {
    private int storeOrderId;
    private String orderId;
    private int storeId;
    private BigDecimal storeTotal;
    private BigDecimal deliveryFee;
    private BigDecimal commission;
    private BigDecimal payableAmount;
    private String status;
    private Timestamp createdAt;

    // Constructors
    public StoreOrder() {
        this.status = "PENDING";
        this.commission = BigDecimal.ZERO;
    }

    public StoreOrder(String orderId, int storeId, BigDecimal storeTotal, BigDecimal commission,
            BigDecimal payableAmount) {
        this();
        this.orderId = orderId;
        this.storeId = storeId;
        this.storeTotal = storeTotal;
        this.commission = commission;
        this.payableAmount = payableAmount;
    }

    // Getters and Setters
    public int getStoreOrderId() {
        return storeOrderId;
    }

    public void setStoreOrderId(int storeOrderId) {
        this.storeOrderId = storeOrderId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public int getStoreId() {
        return storeId;
    }

    public void setStoreId(int storeId) {
        this.storeId = storeId;
    }

    public BigDecimal getStoreTotal() {
        return storeTotal;
    }

    public void setStoreTotal(BigDecimal storeTotal) {
        this.storeTotal = storeTotal;
    }

    public BigDecimal getDeliveryFee() {
        return deliveryFee;
    }

    public void setDeliveryFee(BigDecimal deliveryFee) {
        this.deliveryFee = deliveryFee;
    }

    public BigDecimal getCommission() {
        return commission;
    }

    public void setCommission(BigDecimal commission) {
        this.commission = commission;
    }

    public BigDecimal getPayableAmount() {
        return payableAmount;
    }

    public void setPayableAmount(BigDecimal payableAmount) {
        this.payableAmount = payableAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
