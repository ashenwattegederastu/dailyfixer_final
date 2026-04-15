package com.dailyfixer.model;

public class VolunteerProof {
    private int proofId;
    private int requestId;
    private String proofType;
    private String imagePath;
    private String description;
    private int uploadOrder;

    // Getters and Setters
    public int getProofId() {
        return proofId;
    }

    public void setProofId(int proofId) {
        this.proofId = proofId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public String getProofType() {
        return proofType;
    }

    public void setProofType(String proofType) {
        this.proofType = proofType;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getUploadOrder() {
        return uploadOrder;
    }

    public void setUploadOrder(int uploadOrder) {
        this.uploadOrder = uploadOrder;
    }
}
