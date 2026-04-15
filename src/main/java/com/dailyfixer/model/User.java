package com.dailyfixer.model;

public class User {
    private int userId;
    private String firstName;
    private String lastName;
    private String username;
    private String email;
    private String password;
    private String phoneNumber;
    private String city;
    private String bio;
    private String profilePicturePath;
    private String role = "user";
    private String status;
    private Double latitude;   // home base lat (drivers) — null if not set
    private Double longitude;  // home base lng (drivers) — null if not set
    private String nicNumber;
    private String nicFrontPath;
    private String nicBackPath;
    private String licenseFrontPath;
    private String licenseBackPath;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getProfilePicturePath() {
        return profilePicturePath;
    }

    public void setProfilePicturePath(String profilePicturePath) {
        this.profilePicturePath = profilePicturePath;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getNicNumber() { return nicNumber; }
    public void setNicNumber(String nicNumber) { this.nicNumber = nicNumber; }

    public String getNicFrontPath() { return nicFrontPath; }
    public void setNicFrontPath(String nicFrontPath) { this.nicFrontPath = nicFrontPath; }

    public String getNicBackPath() { return nicBackPath; }
    public void setNicBackPath(String nicBackPath) { this.nicBackPath = nicBackPath; }

    public String getLicenseFrontPath() { return licenseFrontPath; }
    public void setLicenseFrontPath(String licenseFrontPath) { this.licenseFrontPath = licenseFrontPath; }

    public String getLicenseBackPath() { return licenseBackPath; }
    public void setLicenseBackPath(String licenseBackPath) { this.licenseBackPath = licenseBackPath; }
}
