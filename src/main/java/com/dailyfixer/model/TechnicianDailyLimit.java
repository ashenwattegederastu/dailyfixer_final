package com.dailyfixer.model;

import java.sql.Timestamp;

public class TechnicianDailyLimit {
    private int limitId;
    private int technicianId;
    private int maxBookingsPerDay;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public int getLimitId() { return limitId; }
    public void setLimitId(int limitId) { this.limitId = limitId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public int getMaxBookingsPerDay() { return maxBookingsPerDay; }
    public void setMaxBookingsPerDay(int maxBookingsPerDay) { this.maxBookingsPerDay = maxBookingsPerDay; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
