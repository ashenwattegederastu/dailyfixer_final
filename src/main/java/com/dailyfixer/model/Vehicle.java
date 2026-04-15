package com.dailyfixer.model;

public class Vehicle {
    private int id;
    private int driverId;
    private String vehicleCategory; // admin-defined category from delivery_rates (e.g. "Bike", "Three-wheel", "Lorry")
    private String brand;           // make/brand (e.g. "Honda", "Bajaj")
    private String model;           // model name (e.g. "CB125", "Pulsar")
    private String plateNumber;

    // 4 vehicle angle photos (stored as relative file paths)
    private String imgFront;
    private String imgLeft;
    private String imgRight;
    private String imgBack;

    // 3 documents (insurance is optional; stored as relative file paths)
    private String docRegistration;
    private String docInsurance;
    private String docRevenue;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }

    public String getVehicleCategory() { return vehicleCategory; }
    public void setVehicleCategory(String vehicleCategory) { this.vehicleCategory = vehicleCategory; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getPlateNumber() { return plateNumber; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }

    public String getImgFront() { return imgFront; }
    public void setImgFront(String imgFront) { this.imgFront = imgFront; }

    public String getImgLeft() { return imgLeft; }
    public void setImgLeft(String imgLeft) { this.imgLeft = imgLeft; }

    public String getImgRight() { return imgRight; }
    public void setImgRight(String imgRight) { this.imgRight = imgRight; }

    public String getImgBack() { return imgBack; }
    public void setImgBack(String imgBack) { this.imgBack = imgBack; }

    public String getDocRegistration() { return docRegistration; }
    public void setDocRegistration(String docRegistration) { this.docRegistration = docRegistration; }

    public String getDocInsurance() { return docInsurance; }
    public void setDocInsurance(String docInsurance) { this.docInsurance = docInsurance; }

    public String getDocRevenue() { return docRevenue; }
    public void setDocRevenue(String docRevenue) { this.docRevenue = docRevenue; }

    public boolean hasInsurance() { return docInsurance != null && !docInsurance.isEmpty(); }
    public boolean hasRegistration() { return docRegistration != null && !docRegistration.isEmpty(); }
    public boolean hasRevenue() { return docRevenue != null && !docRevenue.isEmpty(); }

    // Legacy: getVehicleType() returns brand for backward compat with dashboard pages
    public String getVehicleType() { return brand; }
}
