package com.dailyfixer.model;

import java.sql.Timestamp;
import java.util.List;

public class Guide {
    private int guideId;
    private String title;
    private String mainImagePath;
    private String mainCategory;
    private String subCategory;
    private String youtubeUrl;
    private int createdBy;
    private String createdRole;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int viewCount;
    private String status; // ACTIVE, HIDDEN, PENDING_REVIEW
    private String hideReason;
    private Timestamp hiddenAt;
    private int hiddenBy;
    private int flagCount; // Transient, loaded from query

    // Associated data (loaded separately)
    private List<String> requirements;
    private List<GuideStep> steps;
    private String creatorName; // For display purposes

    public Guide() {
    }

    public Guide(String title, String mainImagePath, String mainCategory, String subCategory,
            String youtubeUrl, int createdBy, String createdRole) {
        this.title = title;
        this.mainImagePath = mainImagePath;
        this.mainCategory = mainCategory;
        this.subCategory = subCategory;
        this.youtubeUrl = youtubeUrl;
        this.createdBy = createdBy;
        this.createdRole = createdRole;
    }

    // Getters and Setters
    public int getGuideId() {
        return guideId;
    }

    public void setGuideId(int guideId) {
        this.guideId = guideId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMainImagePath() {
        return mainImagePath;
    }

    public void setMainImagePath(String mainImagePath) {
        this.mainImagePath = mainImagePath;
    }

    public String getMainCategory() {
        return mainCategory;
    }

    public void setMainCategory(String mainCategory) {
        this.mainCategory = mainCategory;
    }

    public String getSubCategory() {
        return subCategory;
    }

    public void setSubCategory(String subCategory) {
        this.subCategory = subCategory;
    }

    public String getYoutubeUrl() {
        return youtubeUrl;
    }

    public void setYoutubeUrl(String youtubeUrl) {
        this.youtubeUrl = youtubeUrl;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatedRole() {
        return createdRole;
    }

    public void setCreatedRole(String createdRole) {
        this.createdRole = createdRole;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getViewCount() {
        return viewCount;
    }

    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }

    public List<String> getRequirements() {
        return requirements;
    }

    public void setRequirements(List<String> requirements) {
        this.requirements = requirements;
    }

    public List<GuideStep> getSteps() {
        return steps;
    }

    public void setSteps(List<GuideStep> steps) {
        this.steps = steps;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getHideReason() {
        return hideReason;
    }

    public void setHideReason(String hideReason) {
        this.hideReason = hideReason;
    }

    public Timestamp getHiddenAt() {
        return hiddenAt;
    }

    public void setHiddenAt(Timestamp hiddenAt) {
        this.hiddenAt = hiddenAt;
    }

    public int getHiddenBy() {
        return hiddenBy;
    }

    public void setHiddenBy(int hiddenBy) {
        this.hiddenBy = hiddenBy;
    }

    public int getFlagCount() {
        return flagCount;
    }

    public void setFlagCount(int flagCount) {
        this.flagCount = flagCount;
    }

    // Helper to get YouTube embed URL
    public String getYoutubeEmbedUrl() {
        if (youtubeUrl == null || youtubeUrl.isEmpty())
            return null;
        // Convert watch URL to embed URL
        if (youtubeUrl.contains("watch?v=")) {
            return youtubeUrl.replace("watch?v=", "embed/");
        } else if (youtubeUrl.contains("youtu.be/")) {
            return youtubeUrl.replace("youtu.be/", "www.youtube.com/embed/");
        }
        return youtubeUrl;
    }
}
