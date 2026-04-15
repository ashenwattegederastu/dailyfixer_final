package com.dailyfixer.model;

import java.sql.Timestamp;

public class GuideRating {
    private int ratingId;
    private int guideId;
    private int userId;
    private String rating; // "UP" or "DOWN"
    private Timestamp createdAt;

    public GuideRating() {
    }

    public GuideRating(int guideId, int userId, String rating) {
        this.guideId = guideId;
        this.userId = userId;
        this.rating = rating;
    }

    // Getters and Setters
    public int getRatingId() {
        return ratingId;
    }

    public void setRatingId(int ratingId) {
        this.ratingId = ratingId;
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

    public String getRating() {
        return rating;
    }

    public void setRating(String rating) {
        this.rating = rating;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
