package com.dailyfixer.model;

public class GuideStepImage {
    private int imageId;
    private int stepId;
    private String imagePath;

    public GuideStepImage() {
    }

    public GuideStepImage(int stepId, String imagePath) {
        this.stepId = stepId;
        this.imagePath = imagePath;
    }

    // Getters and Setters
    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getStepId() {
        return stepId;
    }

    public void setStepId(int stepId) {
        this.stepId = stepId;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
}
