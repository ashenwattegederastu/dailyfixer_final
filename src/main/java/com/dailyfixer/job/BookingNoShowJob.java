package com.dailyfixer.job;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingNoShowDAO;
import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.dao.TechnicianPenaltyDAO;
import com.dailyfixer.model.BookingNoShow;

import java.sql.Timestamp;
import java.util.List;

/**
 * Background job that enforces three time-based rules on technician bookings:
 *
 *  Rule 1 – No-Show Detection:
 *      ACCEPTED bookings whose scheduled time + 30 minutes has passed without the
 *      technician starting (moving to IN_PROGRESS) are marked NO_SHOW.
 *      An incident is logged and the client is notified.
 *
 *  Rule 2 – Auto-Reject Stale Requests:
 *      REQUESTED bookings older than 24 hours with no technician response are
 *      automatically moved to AUTO_REJECTED and the client is notified.
 *
 * Registered in AppStartupListener — runs every 10 minutes.
 */
public class BookingNoShowJob implements Runnable {

    /** Minutes after scheduled time before a booking is marked as a no-show. */
    private static final int NO_SHOW_GRACE_MINUTES = 30;

    /** Hours after creation before an unanswered REQUESTED booking is auto-rejected. */
    private static final int AUTO_REJECT_HOURS = 24;

    private final BookingNoShowDAO noShowDAO = new BookingNoShowDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingNotificationDAO notifDAO = new BookingNotificationDAO();
    private final TechnicianPenaltyDAO penaltyDAO = new TechnicianPenaltyDAO();

    @Override
    public void run() {
        System.out.println("[BookingNoShowJob] Running booking time-limit checks...");
        try {
            runNoShowCheck();
        } catch (Exception e) {
            System.err.println("[BookingNoShowJob] Error during no-show check: " + e.getMessage());
            e.printStackTrace();
        }
        try {
            runAutoRejectCheck();
        } catch (Exception e) {
            System.err.println("[BookingNoShowJob] Error during auto-reject check: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Rule 1: No-Show Detection ─────────────────────────────────────────────

    private void runNoShowCheck() throws Exception {
        List<int[]> candidates = noShowDAO.getNoShowCandidates(NO_SHOW_GRACE_MINUTES);
        System.out.println("[BookingNoShowJob] Rule 1 – no-show candidates: " + candidates.size());

        for (int[] row : candidates) {
            int bookingId = row[0];
            int technicianId = row[1];
            int userId = row[2];

            try {
                // Mark booking as NO_SHOW
                bookingDAO.updateBookingStatus(bookingId, "NO_SHOW");

                // Log the incident
                BookingNoShow ns = new BookingNoShow();
                ns.setBookingId(bookingId);
                ns.setTechnicianId(technicianId);
                ns.setScheduledAt(new Timestamp(System.currentTimeMillis())); // approximate; exact value in DB query
                ns.setNotes("Auto-detected: technician did not start within "
                        + NO_SHOW_GRACE_MINUTES + " minutes of scheduled time.");
                noShowDAO.recordNoShow(ns);

                // Apply progressive penalty
                if (ns.getNoShowId() > 0) {
                    try {
                        int penaltyLevel = penaltyDAO.issueIfNeeded(ns.getNoShowId(), technicianId);
                        if (penaltyLevel > 0) {
                            notifDAO.createNotification(technicianId, bookingId,
                                    penaltyDAO.buildPenaltyMessage(penaltyLevel));
                        }
                    } catch (Exception pe) {
                        System.err.println("[BookingNoShowJob] Penalty error for technician #"
                                + technicianId + ": " + pe.getMessage());
                    }
                }

                // Notify the client
                notifDAO.createNotification(userId, bookingId,
                        "Your technician did not show up for booking #" + bookingId
                                + ". The booking has been marked as a no-show. "
                                + "You may reschedule or cancel from your Active Bookings page.");

                System.out.println("[BookingNoShowJob] Rule 1 – marked NO_SHOW for booking #" + bookingId);
            } catch (Exception e) {
                System.err.println("[BookingNoShowJob] Rule 1 – error for booking #" + bookingId
                        + ": " + e.getMessage());
            }
        }
    }

    // ── Rule 2: Auto-Reject Stale Requests ───────────────────────────────────

    private void runAutoRejectCheck() throws Exception {
        List<int[]> candidates = bookingDAO.getAutoRejectCandidates(AUTO_REJECT_HOURS, NO_SHOW_GRACE_MINUTES);
        System.out.println("[BookingNoShowJob] Rule 2 – auto-reject candidates: " + candidates.size());

        for (int[] row : candidates) {
            int bookingId = row[0];
            int userId = row[1];

            try {
                bookingDAO.updateBookingStatus(bookingId, "AUTO_REJECTED");

                notifDAO.createNotification(userId, bookingId,
                        "Booking #" + bookingId + " was automatically rejected because the technician "
                                + "did not respond within " + AUTO_REJECT_HOURS + " hours. "
                                + "Please try booking a different technician.");

                System.out.println("[BookingNoShowJob] Rule 2 – auto-rejected booking #" + bookingId);
            } catch (Exception e) {
                System.err.println("[BookingNoShowJob] Rule 2 – error for booking #" + bookingId
                        + ": " + e.getMessage());
            }
        }
    }
}
