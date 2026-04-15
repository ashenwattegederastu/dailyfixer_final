package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class DeliveryRate {
    private int rateId;
    private String vehicleType;
    private BigDecimal costPerKm;
    private BigDecimal baseFee;
    private BigDecimal distributionWeight; // percentage, e.g. 50.00 = 50%
    private int maxSimultaneousOrders = 3; // max concurrent ACCEPTED+PICKED_UP orders
    private boolean active;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getRateId() { return rateId; }
    public void setRateId(int rateId) { this.rateId = rateId; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public BigDecimal getCostPerKm() { return costPerKm; }
    public void setCostPerKm(BigDecimal costPerKm) { this.costPerKm = costPerKm; }

    public BigDecimal getBaseFee() { return baseFee; }
    public void setBaseFee(BigDecimal baseFee) { this.baseFee = baseFee; }

    public BigDecimal getDistributionWeight() { return distributionWeight; }
    public void setDistributionWeight(BigDecimal distributionWeight) { this.distributionWeight = distributionWeight; }

    public int getMaxSimultaneousOrders() { return maxSimultaneousOrders; }
    public void setMaxSimultaneousOrders(int maxSimultaneousOrders) { this.maxSimultaneousOrders = maxSimultaneousOrders; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
