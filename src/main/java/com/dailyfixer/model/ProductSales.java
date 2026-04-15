package com.dailyfixer.model;

/**
 * Holds product name and quantity sold for sales charts.
 */
public class ProductSales {
    private int productId;
    private String productName;
    private int quantitySold;

    public ProductSales() {}

    public ProductSales(String productName, int quantitySold) {
        this.productName = productName;
        this.quantitySold = quantitySold;
    }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getQuantitySold() { return quantitySold; }
    public void setQuantitySold(int quantitySold) { this.quantitySold = quantitySold; }
}
