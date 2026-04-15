package com.dailyfixer.model;

public class UserDriver {
    private int driverId;
    private User user; // reference to common user
    private String realPic;
    private String serviceArea;
    private String licensePic;

    // Getters and setters
    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getRealPic() { return realPic; }
    public void setRealPic(String realPic) { this.realPic = realPic; }

    public String getServiceArea() { return serviceArea; }
    public void setServiceArea(String serviceArea) { this.serviceArea = serviceArea; }

    public String getLicensePic() { return licensePic; }
    public void setLicensePic(String licensePic) { this.licensePic = licensePic; }
}
