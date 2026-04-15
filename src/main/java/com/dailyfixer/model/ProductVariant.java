package com.dailyfixer.model;

import java.math.BigDecimal;

public class ProductVariant {

    private int variantId;
    private int productId;
    private String color;
    private String size;
    private String power;
    private BigDecimal price;
    private int quantity;
    private String imagePath;

    public ProductVariant() {}

    public ProductVariant(int variantId, int productId, String color, String size, String power, BigDecimal price, int quantity) {
        this.variantId = variantId;
        this.productId = productId;
        this.color = color;
        this.size = size;
        this.power = power;
        this.price = price;
        this.quantity = quantity;
    }

    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public String getPower() { return power; }
    public void setPower(String power) { this.power = power; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
}
