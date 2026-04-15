package com.dailyfixer.model;

import java.sql.Timestamp;

/**
 * Represents a user rating for a decision tree.
 * Rating is a value from 1 to 5 stars.
 */
public class TreeRating {
    private int ratingId;
    private int treeId;
    private int userId;
    private int rating;
    private String feedback;
    private Timestamp createdAt;

    // Display field
    private String username;

    public TreeRating() {
    }

    public int getRatingId() {
        return ratingId;
    }

    public void setRatingId(int ratingId) {
        this.ratingId = ratingId;
    }

    public int getTreeId() {
        return treeId;
    }

    public void setTreeId(int treeId) {
        this.treeId = treeId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        if (rating < 1)
            rating = 1;
        if (rating > 5)
            rating = 5;
        this.rating = rating;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
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
}
