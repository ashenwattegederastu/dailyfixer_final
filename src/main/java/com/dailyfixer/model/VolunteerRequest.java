package com.dailyfixer.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class VolunteerRequest {
    private int requestId;
    private String fullName;
    private String username;
    private String email;
    private String phone;
    private String passwordHash;
    private String city;
    private String profilePicturePath;
    private String expertise;
    private String skillLevel;
    private String experienceYears;
    private String bio;
    private String sampleGuide;
    private String sampleGuideFilePath;
    private String status;
    private String rejectionReason;
    private Timestamp submittedDate;
    private Timestamp reviewedDate;
    private int reviewedBy;
    private List<VolunteerProof> proofs = new ArrayList<>();

    // Getters and Setters
    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getProfilePicturePath() {
        return profilePicturePath;
    }

    public void setProfilePicturePath(String profilePicturePath) {
        this.profilePicturePath = profilePicturePath;
    }

    public String getExpertise() {
        return expertise;
    }

    public void setExpertise(String expertise) {
        this.expertise = expertise;
    }

    public String getSkillLevel() {
        return skillLevel;
    }

    public void setSkillLevel(String skillLevel) {
        this.skillLevel = skillLevel;
    }

    public String getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(String experienceYears) {
        this.experienceYears = experienceYears;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getSampleGuide() {
        return sampleGuide;
    }

    public void setSampleGuide(String sampleGuide) {
        this.sampleGuide = sampleGuide;
    }

    public String getSampleGuideFilePath() {
        return sampleGuideFilePath;
    }

    public void setSampleGuideFilePath(String sampleGuideFilePath) {
        this.sampleGuideFilePath = sampleGuideFilePath;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public Timestamp getSubmittedDate() {
        return submittedDate;
    }

    public void setSubmittedDate(Timestamp submittedDate) {
        this.submittedDate = submittedDate;
    }

    public Timestamp getReviewedDate() {
        return reviewedDate;
    }

    public void setReviewedDate(Timestamp reviewedDate) {
        this.reviewedDate = reviewedDate;
    }

    public int getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(int reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public List<VolunteerProof> getProofs() {
        return proofs;
    }

    public void setProofs(List<VolunteerProof> proofs) {
        this.proofs = proofs;
    }
}
