package com.dailyfixer.model;

import java.sql.Timestamp;

/**
 * Proof package for doorstep-drop completion.
 */
public class DeliveryDropProof {

    private int proofId;
    private int assignmentId;
    private String orderId;
    private int driverId;
    private String photoPackagePath;
    private String photoDoorContextPath;
    private String note;
    private Timestamp createdAt;

    public int getProofId() {
        return proofId;
    }

    public void setProofId(int proofId) {
        this.proofId = proofId;
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public int getDriverId() {
        return driverId;
    }

    public void setDriverId(int driverId) {
        this.driverId = driverId;
    }

    public String getPhotoPackagePath() {
        return photoPackagePath;
    }

    public void setPhotoPackagePath(String photoPackagePath) {
        this.photoPackagePath = photoPackagePath;
    }

    public String getPhotoDoorContextPath() {
        return photoDoorContextPath;
    }

    public void setPhotoDoorContextPath(String photoDoorContextPath) {
        this.photoDoorContextPath = photoDoorContextPath;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
