package com.dailyfixer.model;

import java.sql.Timestamp;

public class BookingRating {
    private int ratingId;
    private int bookingId;
    private int ratedBy;       // user_id of person giving rating
    private int ratedUser;     // user_id of person receiving rating
    private String ratingType; // "TECHNICIAN_RATING" or "CLIENT_RATING"
    private int rating;        // 1-5
    private String review;
    private Timestamp createdAt;

    // Extended display fields (not persisted)
    private String raterName;
    private String ratedUserName;

    // Getters and Setters
    public int getRatingId() { return ratingId; }
    public void setRatingId(int ratingId) { this.ratingId = ratingId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getRatedBy() { return ratedBy; }
    public void setRatedBy(int ratedBy) { this.ratedBy = ratedBy; }

    public int getRatedUser() { return ratedUser; }
    public void setRatedUser(int ratedUser) { this.ratedUser = ratedUser; }

    public String getRatingType() { return ratingType; }
    public void setRatingType(String ratingType) { this.ratingType = ratingType; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getReview() { return review; }
    public void setReview(String review) { this.review = review; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getRaterName() { return raterName; }
    public void setRaterName(String raterName) { this.raterName = raterName; }

    public String getRatedUserName() { return ratedUserName; }
    public void setRatedUserName(String ratedUserName) { this.ratedUserName = ratedUserName; }
}
