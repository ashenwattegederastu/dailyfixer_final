package com.dailyfixer.model;

import java.sql.Timestamp;

public class BookingCancellation {
    private int cancellationId;
    private int bookingId;
    private int cancelledBy;
    private String cancellationReason;
    private Timestamp cancelledAt;

    // Extended field for display
    private String cancelledByName;

    // Getters and setters
    public int getCancellationId() { return cancellationId; }
    public void setCancellationId(int cancellationId) { this.cancellationId = cancellationId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getCancelledBy() { return cancelledBy; }
    public void setCancelledBy(int cancelledBy) { this.cancelledBy = cancelledBy; }

    public String getCancellationReason() { return cancellationReason; }
    public void setCancellationReason(String cancellationReason) { this.cancellationReason = cancellationReason; }

    public Timestamp getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(Timestamp cancelledAt) { this.cancelledAt = cancelledAt; }

    public String getCancelledByName() { return cancelledByName; }
    public void setCancelledByName(String cancelledByName) { this.cancelledByName = cancelledByName; }
}
