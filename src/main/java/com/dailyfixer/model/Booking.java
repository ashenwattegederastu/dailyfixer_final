package com.dailyfixer.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.math.BigDecimal;

public class Booking {
    private int bookingId;
    private int userId;
    private int technicianId;
    private int serviceId;
    private Date bookingDate;
    private Time bookingTime;
    private String phoneNumber;
    private String problemDescription;
    private String locationAddress;
    private BigDecimal locationLatitude;
    private BigDecimal locationLongitude;
    private String status; // REQUESTED, ACCEPTED, REJECTED, CANCELLED, TECHNICIAN_COMPLETED, FULLY_COMPLETED
    private String rejectionReason;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Extended fields for display (not in database)
    private String userName;
    private String technicianName;
    private String serviceName;

    // Recurring booking fields
    private Integer recurringContractId;
    private Integer recurringSequence;

    // Getters and setters
    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }

    public Date getBookingDate() { return bookingDate; }
    public void setBookingDate(Date bookingDate) { this.bookingDate = bookingDate; }

    public Time getBookingTime() { return bookingTime; }
    public void setBookingTime(Time bookingTime) { this.bookingTime = bookingTime; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getProblemDescription() { return problemDescription; }
    public void setProblemDescription(String problemDescription) { this.problemDescription = problemDescription; }

    public String getLocationAddress() { return locationAddress; }
    public void setLocationAddress(String locationAddress) { this.locationAddress = locationAddress; }

    public BigDecimal getLocationLatitude() { return locationLatitude; }
    public void setLocationLatitude(BigDecimal locationLatitude) { this.locationLatitude = locationLatitude; }

    public BigDecimal getLocationLongitude() { return locationLongitude; }
    public void setLocationLongitude(BigDecimal locationLongitude) { this.locationLongitude = locationLongitude; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getTechnicianName() { return technicianName; }
    public void setTechnicianName(String technicianName) { this.technicianName = technicianName; }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public Integer getRecurringContractId() { return recurringContractId; }
    public void setRecurringContractId(Integer recurringContractId) { this.recurringContractId = recurringContractId; }

    public Integer getRecurringSequence() { return recurringSequence; }
    public void setRecurringSequence(Integer recurringSequence) { this.recurringSequence = recurringSequence; }
}
