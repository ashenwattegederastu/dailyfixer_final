package com.dailyfixer.model;

import java.sql.Timestamp;

public class BookingNoShow {
    private int noShowId;
    private int bookingId;
    private int technicianId;
    private Timestamp scheduledAt;
    private Timestamp detectedAt;
    private String notes;

    public int getNoShowId() { return noShowId; }
    public void setNoShowId(int noShowId) { this.noShowId = noShowId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public Timestamp getScheduledAt() { return scheduledAt; }
    public void setScheduledAt(Timestamp scheduledAt) { this.scheduledAt = scheduledAt; }

    public Timestamp getDetectedAt() { return detectedAt; }
    public void setDetectedAt(Timestamp detectedAt) { this.detectedAt = detectedAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
