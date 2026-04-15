package com.dailyfixer.model;

import java.sql.Timestamp;

public class GuideComment {
    private int commentId;
    private int guideId;
    private int userId;
    private String comment;
    private Timestamp createdAt;

    // For display purposes
    private String reply;
    private Timestamp replyAt;

    // For display purposes
    private String username;
    private String userFirstName;
    private String guideTitle;

    public GuideComment() {
    }

    public GuideComment(int guideId, int userId, String comment) {
        this.guideId = guideId;
        this.userId = userId;
        this.comment = comment;
    }

    // Getters and Setters
    public int getCommentId() {
        return commentId;
    }

    public void setCommentId(int commentId) {
        this.commentId = commentId;
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

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
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

    public String getGuideTitle() {
        return guideTitle;
    }

    public void setGuideTitle(String guideTitle) {
        this.guideTitle = guideTitle;
    }

    public String getReply() {
        return reply;
    }

    public void setReply(String reply) {
        this.reply = reply;
    }

    public Timestamp getReplyAt() {
        return replyAt;
    }

    public void setReplyAt(Timestamp replyAt) {
        this.replyAt = replyAt;
    }
}
