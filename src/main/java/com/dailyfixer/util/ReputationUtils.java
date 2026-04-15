package com.dailyfixer.util;

import com.dailyfixer.model.VolunteerStats;

public class ReputationUtils {

    // Tier thresholds
    private static final double DIAGNOSTIC_CONTRIBUTOR_THRESHOLD = 31.0;

    /**
     * Check if a volunteer's reputation score qualifies for diagnostic tree access.
     * Requires "Diagnostic Contributor" tier (150+ reputation points).
     */
    public static boolean isDiagnosticContributor(double score) {
        return score >= DIAGNOSTIC_CONTRIBUTOR_THRESHOLD;
    }

    public static void calculateReputation(VolunteerStats stats) {
        if (stats == null)
            return;

        // Guide contribution: 8 points per guide published
        double guidePoints = stats.getTotalGuides() * 8.0;

        // Approval contribution: approval rating is already 0-100 (%)
        double approvalPoints = stats.getApprovalRating() * 0.7;

        double reputation = Math.round((guidePoints + approvalPoints) * 100.0) / 100.0;

        stats.setContributionScore(Math.round(guidePoints * 100.0) / 100.0);
        stats.setQualityScore(Math.round(approvalPoints * 100.0) / 100.0);
        stats.setEngagementScore(0);
        stats.setReputationScore(reputation);
    }

    public static String getBadgeForScore(double score) {
        if (score >= 150)
            return "Diagnostic Contributor";
        if (score >= 100)
            return "Expert Volunteer";
        if (score >= 50)
            return "Trusted Helper";
        if (score >= 10)
            return "Helper";
        return "New Volunteer";
    }

    public static String getNextTierName(double score) {
        if (score < 10)
            return "Helper";
        if (score < 50)
            return "Trusted Helper";
        if (score < 100)
            return "Expert Volunteer";
        if (score < 150)
            return "Diagnostic Contributor";
        return "Max Tier Reached";
    }

    public static int getNextTierScore(double score) {
        if (score < 10)
            return 10;
        if (score < 50)
            return 50;
        if (score < 100)
            return 100;
        if (score < 150)
            return 150;
        return 0; // Max tier
    }
}
