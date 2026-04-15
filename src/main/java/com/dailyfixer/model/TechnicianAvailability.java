package com.dailyfixer.model;

import java.sql.Time;
import java.sql.Timestamp;

public class TechnicianAvailability {
    private int availabilityId;
    private int technicianId;
    private String availabilityMode; // WEEKDAYS, WEEKENDS, CUSTOM
    private boolean monday;
    private boolean tuesday;
    private boolean wednesday;
    private boolean thursday;
    private boolean friday;
    private boolean saturday;
    private boolean sunday;
    private Time startTime;
    private Time endTime;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Getters and setters
    public int getAvailabilityId() { return availabilityId; }
    public void setAvailabilityId(int availabilityId) { this.availabilityId = availabilityId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public String getAvailabilityMode() { return availabilityMode; }
    public void setAvailabilityMode(String availabilityMode) { this.availabilityMode = availabilityMode; }

    public boolean isMonday() { return monday; }
    public void setMonday(boolean monday) { this.monday = monday; }

    public boolean isTuesday() { return tuesday; }
    public void setTuesday(boolean tuesday) { this.tuesday = tuesday; }

    public boolean isWednesday() { return wednesday; }
    public void setWednesday(boolean wednesday) { this.wednesday = wednesday; }

    public boolean isThursday() { return thursday; }
    public void setThursday(boolean thursday) { this.thursday = thursday; }

    public boolean isFriday() { return friday; }
    public void setFriday(boolean friday) { this.friday = friday; }

    public boolean isSaturday() { return saturday; }
    public void setSaturday(boolean saturday) { this.saturday = saturday; }

    public boolean isSunday() { return sunday; }
    public void setSunday(boolean sunday) { this.sunday = sunday; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
