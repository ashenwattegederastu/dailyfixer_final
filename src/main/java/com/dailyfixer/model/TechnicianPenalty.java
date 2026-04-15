package com.dailyfixer.model;

import java.sql.Timestamp;

/**
 * Represents one entry in the technician_penalty_log table.
 * Each no-show that triggers a penalty produces one row here.
 *
 * Levels:
 *   1 – Warning (first no-show within a 90-day rolling window)
 *   2 – Listing suppressed for 7 days (second no-show)
 *   3 – Account suspended (third+ no-show; requires admin review to lift)
 */
public class TechnicianPenalty {

    private int penaltyId;
    private int technicianId;
    private int noShowId;
    private int penaltyLevel;
    private Timestamp issuedAt;
    private Timestamp expiresAt;   // null = indefinite
    private Integer liftedBy;      // admin userId; null if not yet lifted
    private Timestamp liftedAt;
    private String notes;
    /** Transient — populated by JOIN queries in the admin view, not stored in DB. */
    private String technicianName;

    public int getPenaltyId()              { return penaltyId; }
    public void setPenaltyId(int v)        { penaltyId = v; }

    public int getTechnicianId()           { return technicianId; }
    public void setTechnicianId(int v)     { technicianId = v; }

    public int getNoShowId()               { return noShowId; }
    public void setNoShowId(int v)         { noShowId = v; }

    public int getPenaltyLevel()           { return penaltyLevel; }
    public void setPenaltyLevel(int v)     { penaltyLevel = v; }

    public Timestamp getIssuedAt()         { return issuedAt; }
    public void setIssuedAt(Timestamp v)   { issuedAt = v; }

    public Timestamp getExpiresAt()        { return expiresAt; }
    public void setExpiresAt(Timestamp v)  { expiresAt = v; }

    public Integer getLiftedBy()           { return liftedBy; }
    public void setLiftedBy(Integer v)     { liftedBy = v; }

    public Timestamp getLiftedAt()         { return liftedAt; }
    public void setLiftedAt(Timestamp v)   { liftedAt = v; }

    public String getNotes()               { return notes; }
    public void setNotes(String v)         { notes = v; }

    public String getTechnicianName()          { return technicianName; }
    public void setTechnicianName(String v)    { technicianName = v; }
}
