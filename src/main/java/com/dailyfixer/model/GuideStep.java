package com.dailyfixer.model;

import java.util.List;

public class GuideStep {
    private int stepId;
    private int guideId;
    private int stepOrder;
    private String stepTitle;
    private String stepBody;
    private List<String> imagePaths; // Multiple images per step

    public GuideStep() {
    }

    public GuideStep(int guideId, int stepOrder, String stepTitle, String stepBody) {
        this.guideId = guideId;
        this.stepOrder = stepOrder;
        this.stepTitle = stepTitle;
        this.stepBody = stepBody;
    }

    // Getters and Setters
    public int getStepId() {
        return stepId;
    }

    public void setStepId(int stepId) {
        this.stepId = stepId;
    }

    public int getGuideId() {
        return guideId;
    }

    public void setGuideId(int guideId) {
        this.guideId = guideId;
    }

    public int getStepOrder() {
        return stepOrder;
    }

    public void setStepOrder(int stepOrder) {
        this.stepOrder = stepOrder;
    }

    public String getStepTitle() {
        return stepTitle;
    }

    public void setStepTitle(String stepTitle) {
        this.stepTitle = stepTitle;
    }

    public String getStepBody() {
        return stepBody;
    }

    public void setStepBody(String stepBody) {
        this.stepBody = stepBody;
    }

    public List<String> getImagePaths() {
        return imagePaths;
    }

    public void setImagePaths(List<String> imagePaths) {
        this.imagePaths = imagePaths;
    }
}
