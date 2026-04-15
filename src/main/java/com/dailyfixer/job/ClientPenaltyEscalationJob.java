package com.dailyfixer.job;

import com.dailyfixer.dao.ClientNoShowPenaltyDAO;

/**
 * Background job that auto-escalates stale client no-show penalty reviews.
 *
 * Rule:
 *   If a client uploaded payment proof (status = PROOF_UPLOADED) and the
 *   assigned technician takes no action within 48 hours, the penalty is
 *   automatically escalated to admin (status → ADMIN_REVIEW).
 *
 * Registered in AppStartupListener — runs every 30 minutes.
 */
public class ClientPenaltyEscalationJob implements Runnable {

    private final ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();

    @Override
    public void run() {
        System.out.println("[ClientPenaltyEscalationJob] Checking for overdue technician reviews...");
        try {
            int escalated = penaltyDAO.escalateOverdueTechReviews();
            if (escalated > 0) {
                System.out.println("[ClientPenaltyEscalationJob] Escalated " + escalated
                        + " penalty case(s) to admin review.");
            }
        } catch (Exception e) {
            System.err.println("[ClientPenaltyEscalationJob] Error during escalation check: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
