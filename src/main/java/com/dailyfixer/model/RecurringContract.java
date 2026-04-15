package com.dailyfixer.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class RecurringContract {
    private int contractId;
    private int userId;
    private int technicianId;
    private int serviceId;
    private Date startDate;
    private Date endDate;
    private int bookingDayOfMonth;
    private BigDecimal recurringFee;
    private String status; // PENDING, ACTIVE, CANCELLED, COMPLETED
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Display fields (not persisted)
    private String userName;
    private String technicianName;
    private String serviceName;

    public int getContractId() { return contractId; }
    public void setContractId(int contractId) { this.contractId = contractId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public int getBookingDayOfMonth() { return bookingDayOfMonth; }
    public void setBookingDayOfMonth(int bookingDayOfMonth) { this.bookingDayOfMonth = bookingDayOfMonth; }

    public BigDecimal getRecurringFee() { return recurringFee; }
    public void setRecurringFee(BigDecimal recurringFee) { this.recurringFee = recurringFee; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

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
}
