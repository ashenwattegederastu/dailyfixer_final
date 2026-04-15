package com.dailyfixer.model;

import java.sql.Timestamp;

public class GuideFlag {
    private int flagId;
    private int guideId;
    private int userId;
    private String reason; // INACCURATE, OUTDATED, INAPPROPRIATE, SPAM, OTHER
    private String description;
    private Timestamp createdAt;

    // For display
    private String username;
    private String userFirstName;

    public GuideFlag() {
    }

    public GuideFlag(int guideId, int userId, String reason, String description) {
        this.guideId = guideId;
        this.userId = userId;
        this.reason = reason;
        this.description = description;
    }

    public int getFlagId() {
        return flagId;
    }

    public void setFlagId(int flagId) {
        this.flagId = flagId;
    }

    public int getGuideId() {
        return guideId;
    }

    public void setGuideId(int guideId) {
        this.guideId = guideId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getUserFirstName() {
        return userFirstName;
    }

    public void setUserFirstName(String userFirstName) {
        this.userFirstName = userFirstName;
    }
}
