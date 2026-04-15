package com.dailyfixer.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class TechnicianRequest {
    private int requestId;
    private String firstName;
    private String lastName;
    private String username;
    private String email;
    private String phone;
    private String passwordHash;
    private String city;
    private String profilePicturePath;

    private boolean hasQualifications;
    private boolean hasExperience;

    // Workplace experience
    private String experienceCompany;
    private String experienceRole;
    private Integer experienceYears;
    private String empIdCardPath;
    private String empIdCardName;

    private String status;
    private String rejectionReason;
    private Timestamp submittedDate;
    private Timestamp reviewedDate;
    private int reviewedBy;

    // Associated files (qualifications + work proofs)
    private List<TechnicianRequestFile> files = new ArrayList<>();

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getFullName() {
        return ((firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "")).trim();
    }

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

    public String getProfilePicturePath() { return profilePicturePath; }
    public void setProfilePicturePath(String profilePicturePath) { this.profilePicturePath = profilePicturePath; }

    public boolean isHasQualifications() { return hasQualifications; }
    public void setHasQualifications(boolean hasQualifications) { this.hasQualifications = hasQualifications; }

    public boolean isHasExperience() { return hasExperience; }
    public void setHasExperience(boolean hasExperience) { this.hasExperience = hasExperience; }

    public String getExperienceCompany() { return experienceCompany; }
    public void setExperienceCompany(String experienceCompany) { this.experienceCompany = experienceCompany; }

    public String getExperienceRole() { return experienceRole; }
    public void setExperienceRole(String experienceRole) { this.experienceRole = experienceRole; }

    public Integer getExperienceYears() { return experienceYears; }
    public void setExperienceYears(Integer experienceYears) { this.experienceYears = experienceYears; }

    public String getEmpIdCardPath() { return empIdCardPath; }
    public void setEmpIdCardPath(String empIdCardPath) { this.empIdCardPath = empIdCardPath; }

    public String getEmpIdCardName() { return empIdCardName; }
    public void setEmpIdCardName(String empIdCardName) { this.empIdCardName = empIdCardName; }

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

    public List<TechnicianRequestFile> getFiles() { return files; }
    public void setFiles(List<TechnicianRequestFile> files) { this.files = files; }

    public List<TechnicianRequestFile> getQualificationFiles() {
        List<TechnicianRequestFile> result = new ArrayList<>();
        for (TechnicianRequestFile f : files) {
            if ("QUALIFICATION".equals(f.getFileType())) result.add(f);
        }
        return result;
    }

    public List<TechnicianRequestFile> getWorkProofFiles() {
        List<TechnicianRequestFile> result = new ArrayList<>();
        for (TechnicianRequestFile f : files) {
            if ("WORK_PROOF".equals(f.getFileType())) result.add(f);
        }
        return result;
    }
}
