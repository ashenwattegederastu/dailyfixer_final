package com.dailyfixer.model;

public class CartItem {
    private int productId;
    private String name;
    private double price;
    private int quantity;
    private String imagePath;
    private Integer variantId;
    private String variantColor;
    private String variantSize;
    private String variantPower;
    private double originalPrice; // Base price before discount
    private double discountAmount; // Discount amount applied
    private String discountName; // Name of the discount applied
    private String discountType; // "PERCENTAGE" or "FIXED"
    private int storeId; // Store that owns this product
    private String storeUsername; // Store username for order association

    public CartItem(int productId, String name, double price, int quantity, String imagePath) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.originalPrice = price;
        this.quantity = quantity;
        this.imagePath = imagePath;
        this.discountAmount = 0;
    }

    public CartItem(int productId, String name, double price, int quantity, String imagePath,
                    Integer variantId, String variantColor, String variantSize, String variantPower) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.originalPrice = price;
        this.quantity = quantity;
        this.imagePath = imagePath;
        this.variantId = variantId;
        this.variantColor = variantColor;
        this.variantSize = variantSize;
        this.variantPower = variantPower;
        this.discountAmount = 0;
    }

    public CartItem(int productId, String name, double price, double originalPrice, int quantity, String imagePath,
                    Integer variantId, String variantColor, String variantSize, String variantPower,
                    double discountAmount, String discountName, String discountType) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.originalPrice = originalPrice;
        this.quantity = quantity;
        this.imagePath = imagePath;
        this.variantId = variantId;
        this.variantColor = variantColor;
        this.variantSize = variantSize;
        this.variantPower = variantPower;
        this.discountAmount = discountAmount;
        this.discountName = discountName;
        this.discountType = discountType;
    }

    public int getProductId() { return productId; }
    public String getName() { return name; }
    public double getPrice() { return price; }
    public int getQuantity() { return quantity; }
    public String getImagePath() { return imagePath; }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
    /** @deprecated Use {@link #getImagePath()} instead. */
    @Deprecated
    public String getImageBase64() { return imagePath; }
    public Integer getVariantId() { return variantId; }
    public String getVariantColor() { return variantColor; }
    public String getVariantSize() { return variantSize; }
    public String getVariantPower() { return variantPower; }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public void setPrice(double price) {
        this.price = price;
    }
    
    public void setVariantId(Integer variantId) { this.variantId = variantId; }
    public void setVariantColor(String variantColor) { this.variantColor = variantColor; }
    public void setVariantSize(String variantSize) { this.variantSize = variantSize; }
    public void setVariantPower(String variantPower) { this.variantPower = variantPower; }
    
    public double getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(double originalPrice) { this.originalPrice = originalPrice; }
    
    public double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(double discountAmount) { this.discountAmount = discountAmount; }
    
    public String getDiscountName() { return discountName; }
    public void setDiscountName(String discountName) { this.discountName = discountName; }
    
    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public int getStoreId() { return storeId; }
    public void setStoreId(int storeId) { this.storeId = storeId; }

    public String getStoreUsername() { return storeUsername; }
    public void setStoreUsername(String storeUsername) { this.storeUsername = storeUsername; }

    // Helper method to calculate total discount for this item
    public double getTotalDiscount() {
        return discountAmount * quantity;
    }
}

