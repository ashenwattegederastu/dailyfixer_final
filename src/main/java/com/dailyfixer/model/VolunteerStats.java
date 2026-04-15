package com.dailyfixer.model;

public class VolunteerStats {
    private int totalGuides;
    private int totalViews;
    private int totalLikes;
    private int totalDislikes;
    private double approvalRating;

    public VolunteerStats() {
    }

    public int getTotalGuides() {
        return totalGuides;
    }

    public void setTotalGuides(int totalGuides) {
        this.totalGuides = totalGuides;
    }

    public int getTotalViews() {
        return totalViews;
    }

    public void setTotalViews(int totalViews) {
        this.totalViews = totalViews;
    }

    public int getTotalLikes() {
        return totalLikes;
    }

    public void setTotalLikes(int totalLikes) {
        this.totalLikes = totalLikes;
    }

    public int getTotalDislikes() {
        return totalDislikes;
    }

    public void setTotalDislikes(int totalDislikes) {
        this.totalDislikes = totalDislikes;
    }

    public double getApprovalRating() {
        return approvalRating;
    }

    private double reputationScore;
    private double qualityScore;
    private double engagementScore;
    private double contributionScore;

    public void setApprovalRating(double approvalRating) {
        this.approvalRating = approvalRating;
    }

    public double getReputationScore() {
        return reputationScore;
    }

    public void setReputationScore(double reputationScore) {
        this.reputationScore = reputationScore;
    }

    public double getQualityScore() {
        return qualityScore;
    }

    public void setQualityScore(double qualityScore) {
        this.qualityScore = qualityScore;
    }

    public double getEngagementScore() {
        return engagementScore;
    }

    public void setEngagementScore(double engagementScore) {
        this.engagementScore = engagementScore;
    }

    public double getContributionScore() {
        return contributionScore;
    }

    public void setContributionScore(double contributionScore) {
        this.contributionScore = contributionScore;
    }
}
