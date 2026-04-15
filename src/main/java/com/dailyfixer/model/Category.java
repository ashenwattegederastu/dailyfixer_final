package com.dailyfixer.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Represents a diagnostic category (main or sub-category).
 * If parentId is null, this is a main category.
 */
public class Category {
    private int categoryId;
    private String name;
    private Integer parentId;
    private Timestamp createdAt;
    private List<Category> children;

    public Category() {
        this.children = new ArrayList<>();
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

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<Category> getChildren() {
        return children;
    }

    public void setChildren(List<Category> children) {
        this.children = children;
    }

    public void addChild(Category child) {
        this.children.add(child);
    }

    public boolean isMainCategory() {
        return parentId == null;
    }
}
