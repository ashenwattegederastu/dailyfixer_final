package com.dailyfixer.model;

import java.sql.Timestamp;

/**
 * Model class for guide sub-categories.
 */
public class GuideSubCategory {
    private int subCategoryId;
    private int categoryId;
    private String name;
    private Timestamp createdAt;

    public GuideSubCategory() {
    }

    public GuideSubCategory(int subCategoryId, int categoryId, String name) {
        this.subCategoryId = subCategoryId;
        this.categoryId = categoryId;
        this.name = name;
    }

    public int getSubCategoryId() {
        return subCategoryId;
    }

    public void setSubCategoryId(int subCategoryId) {
        this.subCategoryId = subCategoryId;
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
