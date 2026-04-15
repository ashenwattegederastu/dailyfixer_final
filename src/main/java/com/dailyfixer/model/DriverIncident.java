package com.dailyfixer.model;

import java.sql.Timestamp;

/**
 * Represents a driver accountability incident logged when
 * a delivery timeout rule fires (Rule 3 or Rule 4 in DeliveryTimeoutJob).
 */
public class DriverIncident {

    // ── DB columns ──────────────────────────────────────────────────────────
    private int incidentId;
    private int driverId;
    private int assignmentId;
    private String orderId;
    private String incidentType;   // PICKUP_NO_DELIVERY | ACCEPT_NO_PICKUP
    private String description;
    private boolean reviewed;
    private int reviewedBy;
    private Timestamp reviewedAt;
    private String reviewNotes;
    private Timestamp createdAt;

    // ── Transient fields (populated by DAO joins) ────────────────────────────
    private String driverName;
    private String driverEmail;
    private String driverStatus;
    private int totalIncidents;    // aggregate count for summary views
    private int pickupMissCount;
    private int acceptMissCount;
    private Timestamp lastIncident;

    // ── Getters & Setters ────────────────────────────────────────────────────

    public int getIncidentId() { return incidentId; }
    public void setIncidentId(int incidentId) { this.incidentId = incidentId; }

    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getIncidentType() { return incidentType; }
    public void setIncidentType(String incidentType) { this.incidentType = incidentType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isReviewed() { return reviewed; }
    public void setReviewed(boolean reviewed) { this.reviewed = reviewed; }

    public int getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(int reviewedBy) { this.reviewedBy = reviewedBy; }

    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }

    public String getReviewNotes() { return reviewNotes; }
    public void setReviewNotes(String reviewNotes) { this.reviewNotes = reviewNotes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getDriverEmail() { return driverEmail; }
    public void setDriverEmail(String driverEmail) { this.driverEmail = driverEmail; }

    public String getDriverStatus() { return driverStatus; }
    public void setDriverStatus(String driverStatus) { this.driverStatus = driverStatus; }

    public int getTotalIncidents() { return totalIncidents; }
    public void setTotalIncidents(int totalIncidents) { this.totalIncidents = totalIncidents; }

    public int getPickupMissCount() { return pickupMissCount; }
    public void setPickupMissCount(int pickupMissCount) { this.pickupMissCount = pickupMissCount; }

    public int getAcceptMissCount() { return acceptMissCount; }
    public void setAcceptMissCount(int acceptMissCount) { this.acceptMissCount = acceptMissCount; }

    public Timestamp getLastIncident() { return lastIncident; }
    public void setLastIncident(Timestamp lastIncident) { this.lastIncident = lastIncident; }
}
