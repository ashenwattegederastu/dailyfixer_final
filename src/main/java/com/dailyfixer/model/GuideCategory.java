package com.dailyfixer.model;

import java.sql.Timestamp;

/**
 * Model class for main guide categories.
 */
public class GuideCategory {
    private int categoryId;
    private String name;
    private Timestamp createdAt;

    public GuideCategory() {
    }

    public GuideCategory(int categoryId, String name) {
        this.categoryId = categoryId;
        this.name = name;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
