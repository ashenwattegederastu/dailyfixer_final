package com.dailyfixer.model;

import java.sql.Timestamp;

public class PasswordResetToken {
    private int userId;
    private String token;
    private Timestamp expiry;
    private boolean used;

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public Timestamp getExpiry() { return expiry; }
    public void setExpiry(Timestamp expiry) { this.expiry = expiry; }
    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }
}
