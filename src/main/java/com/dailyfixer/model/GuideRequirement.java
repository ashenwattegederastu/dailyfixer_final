package com.dailyfixer.model;

public class GuideRequirement {
    private int reqId;
    private int guideId;
    private String requirement;

    public GuideRequirement() {}

    public GuideRequirement(int guideId, String requirement) {
        this.guideId = guideId;
        this.requirement = requirement;
    }

    public int getReqId() { return reqId; }
    public void setReqId(int reqId) { this.reqId = reqId; }

    public int getGuideId() { return guideId; }
    public void setGuideId(int guideId) { this.guideId = guideId; }

    public String getRequirement() { return requirement; }
    public void setRequirement(String requirement) { this.requirement = requirement; }
}
