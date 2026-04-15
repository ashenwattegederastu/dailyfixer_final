package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Represents one row in the client_no_show_penalties table.
 *
 * Status flow:
 *   PENDING → PROOF_UPLOADED → CONFIRMED_PAID (resolved)
 *                           ↘ ADMIN_REVIEW → RESOLVED | FRAUD_SUSPENDED
 *   (48-hr tech timeout also moves PROOF_UPLOADED → ADMIN_REVIEW)
 */
public class ClientNoShowPenalty {

    private int penaltyId;
    private int bookingId;
    private int clientId;
    private int technicianId;
    private BigDecimal amount;
    private String status;  // PENDING | PROOF_UPLOADED | CONFIRMED_PAID | ADMIN_REVIEW | RESOLVED | FRAUD_SUSPENDED
    private String proofPath;         // client's payment proof
    private String techProofPath;      // technician's arrival proof (required at time of marking)
    private Timestamp proofUploadedAt;
    private String techAction;   // CONFIRMED_PAID | MARKED_NOT_PAID | null
    private Timestamp techActionAt;
    private String adminAction;  // MARK_PAID | SUSPEND_CLIENT | null
    private Timestamp adminActionAt;
    private Integer adminId;
    private Timestamp createdAt;

    /** Transient — populated by JOIN queries, not stored in DB. */
    private String clientName;
    private String technicianName;
    private String serviceName;
    private String bookingDate;

    // ── Getters / Setters ────────────────────────────────────────────────────

    public int getPenaltyId()                   { return penaltyId; }
    public void setPenaltyId(int v)             { this.penaltyId = v; }

    public int getBookingId()                   { return bookingId; }
    public void setBookingId(int v)             { this.bookingId = v; }

    public int getClientId()                    { return clientId; }
    public void setClientId(int v)              { this.clientId = v; }

    public int getTechnicianId()                { return technicianId; }
    public void setTechnicianId(int v)          { this.technicianId = v; }

    public BigDecimal getAmount()               { return amount; }
    public void setAmount(BigDecimal v)         { this.amount = v; }

    public String getStatus()                   { return status; }
    public void setStatus(String v)             { this.status = v; }

    public String getProofPath()                { return proofPath; }
    public void setProofPath(String v)          { this.proofPath = v; }

    public String getTechProofPath()            { return techProofPath; }
    public void setTechProofPath(String v)      { this.techProofPath = v; }

    public Timestamp getProofUploadedAt()       { return proofUploadedAt; }
    public void setProofUploadedAt(Timestamp v) { this.proofUploadedAt = v; }

    public String getTechAction()               { return techAction; }
    public void setTechAction(String v)         { this.techAction = v; }

    public Timestamp getTechActionAt()          { return techActionAt; }
    public void setTechActionAt(Timestamp v)    { this.techActionAt = v; }

    public String getAdminAction()              { return adminAction; }
    public void setAdminAction(String v)        { this.adminAction = v; }

    public Timestamp getAdminActionAt()         { return adminActionAt; }
    public void setAdminActionAt(Timestamp v)   { this.adminActionAt = v; }

    public Integer getAdminId()                 { return adminId; }
    public void setAdminId(Integer v)           { this.adminId = v; }

    public Timestamp getCreatedAt()             { return createdAt; }
    public void setCreatedAt(Timestamp v)       { this.createdAt = v; }

    public String getClientName()               { return clientName; }
    public void setClientName(String v)         { this.clientName = v; }

    public String getTechnicianName()           { return technicianName; }
    public void setTechnicianName(String v)     { this.technicianName = v; }

    public String getServiceName()              { return serviceName; }
    public void setServiceName(String v)        { this.serviceName = v; }

    public String getBookingDate()              { return bookingDate; }
    public void setBookingDate(String v)        { this.bookingDate = v; }
}
