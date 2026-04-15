package com.dailyfixer.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class RescheduleRequest {
    private int rescheduleId;
    private int bookingId;
    private int requestedBy;
    private Date newDate;
    private Time newTime;
    private String reason;
    private String status; // PENDING, ACCEPTED, REJECTED
    private Timestamp respondedAt;
    private Timestamp createdAt;

    // Display fields (not persisted)
    private String requesterName;

    public int getRescheduleId() { return rescheduleId; }
    public void setRescheduleId(int rescheduleId) { this.rescheduleId = rescheduleId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getRequestedBy() { return requestedBy; }
    public void setRequestedBy(int requestedBy) { this.requestedBy = requestedBy; }

    public Date getNewDate() { return newDate; }
    public void setNewDate(Date newDate) { this.newDate = newDate; }

    public Time getNewTime() { return newTime; }
    public void setNewTime(Time newTime) { this.newTime = newTime; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getRespondedAt() { return respondedAt; }
    public void setRespondedAt(Timestamp respondedAt) { this.respondedAt = respondedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }
}
