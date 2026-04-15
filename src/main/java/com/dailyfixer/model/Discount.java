package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Discount {
    private int discountId;
    private String discountName;
    private String discountType; // "PERCENTAGE" or "FIXED"
    private BigDecimal discountValue;
    private Timestamp startDate;
    private Timestamp endDate;
    private String storeUsername;
    private boolean isActive;

    public Discount() {}

    public Discount(String discountName, String discountType, BigDecimal discountValue, 
                   Timestamp startDate, Timestamp endDate, String storeUsername) {
        this.discountName = discountName;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.startDate = startDate;
        this.endDate = endDate;
        this.storeUsername = storeUsername;
        this.isActive = true;
    }

    // Getters and Setters
    public int getDiscountId() { return discountId; }
    public void setDiscountId(int discountId) { this.discountId = discountId; }

    public String getDiscountName() { return discountName; }
    public void setDiscountName(String discountName) { this.discountName = discountName; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }

    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }

    public String getStoreUsername() { return storeUsername; }
    public void setStoreUsername(String storeUsername) { this.storeUsername = storeUsername; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    // Helper method to calculate discounted price
    public double calculateDiscountedPrice(double originalPrice) {
        if (discountType == null || discountValue == null) {
            return originalPrice;
        }

        if ("PERCENTAGE".equalsIgnoreCase(discountType)) {
            double discountAmount = originalPrice * (discountValue.doubleValue() / 100.0);
            return Math.max(0, originalPrice - discountAmount);
        } else if ("FIXED".equalsIgnoreCase(discountType)) {
            return Math.max(0, originalPrice - discountValue.doubleValue());
        }

        return originalPrice;
    }

    // Helper method to check if discount is currently valid
    public boolean isValid() {
        if (!isActive) return false;
        
        long currentTime = System.currentTimeMillis();
        if (startDate != null && currentTime < startDate.getTime()) {
            return false;
        }
        if (endDate != null && currentTime > endDate.getTime()) {
            return false;
        }
        return true;
    }
}
