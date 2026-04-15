package com.dailyfixer.model;

public class Service {
    private int serviceId;
    private int technicianId;
    private String serviceName;
    private String description;
    private String category;
    private String pricingType;
    private double fixedRate;
    private double hourlyRate;
    private double inspectionCharge;
    private double transportCharge;
    private String availableDates;
    private byte[] serviceImage;
    private String imageType;
    private boolean recurringEnabled;
    private double recurringFee;

    // Getters and setters
    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getPricingType() { return pricingType; }
    public void setPricingType(String pricingType) { this.pricingType = pricingType; }

    public double getFixedRate() { return fixedRate; }
    public void setFixedRate(double fixedRate) { this.fixedRate = fixedRate; }

    public double getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(double hourlyRate) { this.hourlyRate = hourlyRate; }

    public double getInspectionCharge() { return inspectionCharge; }
    public void setInspectionCharge(double inspectionCharge) { this.inspectionCharge = inspectionCharge; }

    public double getTransportCharge() { return transportCharge; }
    public void setTransportCharge(double transportCharge) { this.transportCharge = transportCharge; }

    public String getAvailableDates() { return availableDates; }
    public void setAvailableDates(String availableDates) { this.availableDates = availableDates; }

    public byte[] getServiceImage() { return serviceImage; }
    public void setServiceImage(byte[] serviceImage) { this.serviceImage = serviceImage; }

    public String getImageType() { return imageType; }
    public void setImageType(String imageType) { this.imageType = imageType; }

    public boolean isRecurringEnabled() { return recurringEnabled; }
    public void setRecurringEnabled(boolean recurringEnabled) { this.recurringEnabled = recurringEnabled; }

    public double getRecurringFee() { return recurringFee; }
    public void setRecurringFee(double recurringFee) { this.recurringFee = recurringFee; }
}
