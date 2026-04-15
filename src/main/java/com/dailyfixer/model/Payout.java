package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Payout {
    private int payoutId;
    private String payeeType;   // STORE or DRIVER
    private int payeeId;        // store_id for STORE, user_id for DRIVER
    private BigDecimal amount;
    private String status;      // PENDING, PROCESSING, COMPLETED
    private Integer lockedByAdminId;
    private String receiptImagePath;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient fields populated by DAO joins
    private String payeeName;
    private String adminName;

    public int getPayoutId() { return payoutId; }
    public void setPayoutId(int payoutId) { this.payoutId = payoutId; }

    public String getPayeeType() { return payeeType; }
    public void setPayeeType(String payeeType) { this.payeeType = payeeType; }

    public int getPayeeId() { return payeeId; }
    public void setPayeeId(int payeeId) { this.payeeId = payeeId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getLockedByAdminId() { return lockedByAdminId; }
    public void setLockedByAdminId(Integer lockedByAdminId) { this.lockedByAdminId = lockedByAdminId; }

    public String getReceiptImagePath() { return receiptImagePath; }
    public void setReceiptImagePath(String receiptImagePath) { this.receiptImagePath = receiptImagePath; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getPayeeName() { return payeeName; }
    public void setPayeeName(String payeeName) { this.payeeName = payeeName; }

    public String getAdminName() { return adminName; }
    public void setAdminName(String adminName) { this.adminName = adminName; }
}
