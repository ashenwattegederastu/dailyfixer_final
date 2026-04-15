package com.dailyfixer.model;

import java.sql.Timestamp;

public class DriverRequest {
    private int requestId;
    private String fullName;
    private String username;
    private String email;
    private String phone;
    private String passwordHash;
    private String city;
    private String nicNumber;
    private String nicFrontPath;
    private String nicBackPath;
    private String profilePicturePath;
    private String licenseFrontPath;
    private String licenseBackPath;
    private boolean policyAccepted;
    private String status;
    private String rejectionReason;
    private Timestamp submittedDate;
    private Timestamp reviewedDate;
    private int reviewedBy;

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getNicNumber() { return nicNumber; }
    public void setNicNumber(String nicNumber) { this.nicNumber = nicNumber; }

    public String getNicFrontPath() { return nicFrontPath; }
    public void setNicFrontPath(String nicFrontPath) { this.nicFrontPath = nicFrontPath; }

    public String getNicBackPath() { return nicBackPath; }
    public void setNicBackPath(String nicBackPath) { this.nicBackPath = nicBackPath; }

    public String getProfilePicturePath() { return profilePicturePath; }
    public void setProfilePicturePath(String profilePicturePath) { this.profilePicturePath = profilePicturePath; }

    public String getLicenseFrontPath() { return licenseFrontPath; }
    public void setLicenseFrontPath(String licenseFrontPath) { this.licenseFrontPath = licenseFrontPath; }

    public String getLicenseBackPath() { return licenseBackPath; }
    public void setLicenseBackPath(String licenseBackPath) { this.licenseBackPath = licenseBackPath; }

    public boolean isPolicyAccepted() { return policyAccepted; }
    public void setPolicyAccepted(boolean policyAccepted) { this.policyAccepted = policyAccepted; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public Timestamp getSubmittedDate() { return submittedDate; }
    public void setSubmittedDate(Timestamp submittedDate) { this.submittedDate = submittedDate; }

    public Timestamp getReviewedDate() { return reviewedDate; }
    public void setReviewedDate(Timestamp reviewedDate) { this.reviewedDate = reviewedDate; }

    public int getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(int reviewedBy) { this.reviewedBy = reviewedBy; }
}
