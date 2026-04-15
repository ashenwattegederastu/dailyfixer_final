package com.dailyfixer.job;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.DeliveryAssignmentDAO.StaleAssignment;
import com.dailyfixer.dao.DeliveryAssignmentDAO.StaleAcceptedAssignment;
import com.dailyfixer.dao.DeliveryAssignmentDAO.OrphanedOrder;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.DriverIncidentDAO;
import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.util.EmailUtil;

import java.math.BigDecimal;
import java.util.List;

/**
 * Background job enforcing five time-limit rules on orders and deliveries.
 *
 *  Rule 1 – PAID, store never dispatched (24 h)      → REFUND_PENDING
 *  Rule 2A – PENDING assignment, no driver (48 h)    → CANCELLED + REFUND_PENDING
 *  Rule 2B – STORE_ACCEPTED, assignment row missing  → REFUND_PENDING   (orphan guard)
 *  Rule 3 – ACCEPTED, driver never picked up (3 h)   → reset to PENDING (re-queue)
 *  Rule 4 – PICKED_UP, driver never delivered (24 h) → CANCELLED + REFUND_PENDING
 *
 * Scheduled by AppStartupListener every 15 minutes.
 */
public class DeliveryTimeoutJob implements Runnable {

    // ── Time-limit constants ──────────────────────────────────────────────────

    /** Rule 1: store must dispatch within this many hours of payment. */
    private static final int PAID_TIMEOUT_HOURS = 24;

    /** Rule 2A/2B: a driver must claim the assignment within this many hours. */
    private static final int DISPATCH_TIMEOUT_HOURS = 48;

    /** Rule 3: accepted driver must trigger pickup within this many hours. */
    private static final int ACCEPT_PICKUP_TIMEOUT_HOURS = 3;

    /** Rule 4: driver must complete delivery within this many hours of pickup. */
    private static final int PICKUP_DELIVERY_TIMEOUT_HOURS = 24;

    // ── DAO instances ─────────────────────────────────────────────────────────

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final DriverIncidentDAO incidentDAO = new DriverIncidentDAO();
    private final UserDAO userDAO = new UserDAO();

    // ── Main loop ─────────────────────────────────────────────────────────────

    @Override
    public void run() {
        System.out.println("[DeliveryTimeoutJob] Running time-limit checks...");
        try {

            // ── Rule 1: PAID orders not dispatched within 24 h ────────────────
            List<OrphanedOrder> stalePaid = assignmentDAO.getStalePaidOrders(PAID_TIMEOUT_HOURS);
            System.out.println("[DeliveryTimeoutJob] Rule 1 – stale PAID orders: " + stalePaid.size());
            for (OrphanedOrder o : stalePaid) processStalePaidOrder(o);

            // ── Rule 2A: PENDING assignment, no driver within 48 h ────────────
            List<StaleAssignment> staleList = assignmentDAO.getStaleAssignments(DISPATCH_TIMEOUT_HOURS);
            System.out.println("[DeliveryTimeoutJob] Rule 2A – stale PENDING assignments: " + staleList.size());
            for (StaleAssignment s : staleList) processStaleAssignment(s);

            // ── Rule 2B: STORE_ACCEPTED but no assignment row at all ──────────
            List<OrphanedOrder> orphaned = assignmentDAO.getOrphanedStoreAcceptedOrders(DISPATCH_TIMEOUT_HOURS);
            System.out.println("[DeliveryTimeoutJob] Rule 2B – orphaned STORE_ACCEPTED orders: " + orphaned.size());
            for (OrphanedOrder o : orphaned) processOrphanedOrder(o);

            // ── Rule 3: ACCEPTED assignment, driver didn't pick up within 3 h ─
            List<StaleAcceptedAssignment> staleAccepted =
                    assignmentDAO.getStaleAcceptedAssignments(ACCEPT_PICKUP_TIMEOUT_HOURS);
            System.out.println("[DeliveryTimeoutJob] Rule 3 – stale ACCEPTED assignments: " + staleAccepted.size());
            for (StaleAcceptedAssignment a : staleAccepted) processStaleAccepted(a);

            // ── Rule 4: PICKED_UP assignment, driver didn't deliver within 24 h
            List<StaleAssignment> stalePickedUp =
                    assignmentDAO.getStalePickedUpAssignments(PICKUP_DELIVERY_TIMEOUT_HOURS);
            System.out.println("[DeliveryTimeoutJob] Rule 4 – stale PICKED_UP assignments: " + stalePickedUp.size());
            for (StaleAssignment s : stalePickedUp) processStalePickedUp(s);

        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Rule 1 handler ────────────────────────────────────────────────────────

    /**
     * Order was paid but the store never dispatched it within 24 h.
     * Mark REFUND_PENDING and notify buyer.
     */
    private void processStalePaidOrder(OrphanedOrder o) {
        System.out.println("[DeliveryTimeoutJob] Rule 1 – processing stale PAID order " + o.orderId);
        try {
            boolean marked = orderDAO.markRefundPending(o.orderId,
                    "Store did not dispatch the order within " + PAID_TIMEOUT_HOURS + " hours of payment.");
            if (!marked) {
                System.err.println("[DeliveryTimeoutJob] Rule 1 – could not mark " + o.orderId
                        + " REFUND_PENDING (already in terminal state?).");
                return;
            }
            orderDAO.restoreStockForOrder(o.orderId);

            // Notify store
            if (o.storeOwnerEmail != null && !o.storeOwnerEmail.isBlank()) {
                tryEmail(o.storeOwnerEmail,
                        "Action Required – Order " + o.orderId + " Cancelled",
                        storeNotDispatchedEmail(o));
            }
            // Notify buyer
            if (o.buyerEmail != null && !o.buyerEmail.isBlank()) {
                tryEmail(o.buyerEmail,
                        "Your Order " + o.orderId + " – Refund Initiated",
                        buyerStoreNotDispatchedEmail(o));
            }

            System.out.println("[DeliveryTimeoutJob] Rule 1 – done for order " + o.orderId);
        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Rule 1 – error for order " + o.orderId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Rule 2A handler ───────────────────────────────────────────────────────

    /**
     * Delivery assignment existed (PENDING) but no driver claimed it within 48 h.
     * Cancel the assignment and mark the order REFUND_PENDING.
     */
    private void processStaleAssignment(StaleAssignment s) {
        System.out.println("[DeliveryTimeoutJob] Rule 2A – processing stale assignment #" + s.assignmentId
                + " (order " + s.orderId + ")");
        try {
            boolean cancelled = assignmentDAO.cancelAssignment(s.assignmentId);
            if (!cancelled) {
                System.err.println("[DeliveryTimeoutJob] Rule 2A – could not cancel assignment #"
                        + s.assignmentId + " (already handled?).");
                return;
            }
            orderDAO.markRefundPending(s.orderId,
                    "No driver was assigned within " + DISPATCH_TIMEOUT_HOURS + " hours of dispatch.");
            orderDAO.restoreStockForOrder(s.orderId);

            if (s.storeOwnerEmail != null && !s.storeOwnerEmail.isBlank()) {
                tryEmail(s.storeOwnerEmail,
                        "Delivery Cancelled – Order " + s.orderId,
                        storeNoDriverEmail(s.orderId, s.storeName, s.buyerName, s.totalAmount, s.currency, DISPATCH_TIMEOUT_HOURS));
            }
            if (s.buyerEmail != null && !s.buyerEmail.isBlank()) {
                tryEmail(s.buyerEmail,
                        "Your Order " + s.orderId + " – Refund Initiated",
                        buyerNoDriverEmail(s.orderId, s.storeName, s.buyerName, s.totalAmount, s.currency, DISPATCH_TIMEOUT_HOURS));
            }

            System.out.println("[DeliveryTimeoutJob] Rule 2A – done for assignment #" + s.assignmentId);
        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Rule 2A – error for assignment #"
                    + s.assignmentId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Rule 2B handler ───────────────────────────────────────────────────────

    /**
     * Order stuck STORE_ACCEPTED with no PENDING assignment row (assignment creation failed).
     * Mark directly REFUND_PENDING.
     */
    private void processOrphanedOrder(OrphanedOrder o) {
        System.out.println("[DeliveryTimeoutJob] Rule 2B – processing orphaned order " + o.orderId);
        try {
            boolean marked = orderDAO.markRefundPending(o.orderId,
                    "No driver could be assigned within " + DISPATCH_TIMEOUT_HOURS + " hours of dispatch.");
            if (!marked) {
                System.err.println("[DeliveryTimeoutJob] Rule 2B – could not mark " + o.orderId
                        + " REFUND_PENDING (already in terminal state?).");
                return;
            }
            orderDAO.restoreStockForOrder(o.orderId);
            if (o.storeOwnerEmail != null && !o.storeOwnerEmail.isBlank()) {
                tryEmail(o.storeOwnerEmail,
                        "Delivery Cancelled – Order " + o.orderId,
                        storeNoDriverEmail(o.orderId, o.storeName, o.buyerName, o.totalAmount, o.currency, DISPATCH_TIMEOUT_HOURS));
            }
            if (o.buyerEmail != null && !o.buyerEmail.isBlank()) {
                tryEmail(o.buyerEmail,
                        "Your Order " + o.orderId + " – Refund Initiated",
                        buyerNoDriverEmail(o.orderId, o.storeName, o.buyerName, o.totalAmount, o.currency, DISPATCH_TIMEOUT_HOURS));
            }
            System.out.println("[DeliveryTimeoutJob] Rule 2B – done for order " + o.orderId);
        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Rule 2B – error for order " + o.orderId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Rule 3 handler ────────────────────────────────────────────────────────

    /**
     * Driver accepted the assignment but did not pick up the package within 3 h.
     * Reset the assignment to PENDING so another driver can claim it.
     * No refund — the order is still dispatching.
     */
    private void processStaleAccepted(StaleAcceptedAssignment a) {
        System.out.println("[DeliveryTimeoutJob] Rule 3 – re-queuing stale ACCEPTED assignment #"
                + a.assignmentId + " (order " + a.orderId + ", driver " + a.driverId + ")");
        try {
            boolean reset = assignmentDAO.resetAssignmentToPending(a.assignmentId);
            if (!reset) {
                System.err.println("[DeliveryTimeoutJob] Rule 3 – could not reset assignment #"
                        + a.assignmentId + " (status may have already changed).");
                return;
            }
            
            // Log missing pickup incident against driver
            incidentDAO.logIncident(a.driverId, a.assignmentId, a.orderId, 
                    "ACCEPT_NO_PICKUP", 
                    "Driver accepted but did not pick up within " + ACCEPT_PICKUP_TIMEOUT_HOURS + " hours.");
            
            System.out.println("[DeliveryTimeoutJob] Rule 3 – assignment #" + a.assignmentId
                    + " returned to PENDING (was held by driver " + a.driverId + ").");
        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Rule 3 – error for assignment #"
                    + a.assignmentId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Rule 4 handler ────────────────────────────────────────────────────────

    /**
     * Driver picked up the package but did not complete delivery within 24 h.
     * Cancel the assignment and mark the order REFUND_PENDING.
     */
    private void processStalePickedUp(StaleAssignment s) {
        System.out.println("[DeliveryTimeoutJob] Rule 4 – processing stale PICKED_UP assignment #"
                + s.assignmentId + " (order " + s.orderId + ")");
        try {
            boolean cancelled = assignmentDAO.cancelAssignment(s.assignmentId);
            if (!cancelled) {
                System.err.println("[DeliveryTimeoutJob] Rule 4 – could not cancel assignment #"
                        + s.assignmentId + " (already handled?).");
                return;
            }
            
            // Log delivery failure incident, auto-suspend driver, and notify them
            DeliveryAssignment da = assignmentDAO.getByAssignmentId(s.assignmentId);
            if (da != null && da.getDriverId() != null) {
                incidentDAO.logIncident(da.getDriverId(), s.assignmentId, s.orderId,
                        "PICKUP_NO_DELIVERY",
                        "Driver picked up package but failed to deliver within " + PICKUP_DELIVERY_TIMEOUT_HOURS + " hours.");
                userDAO.updateUserStatus(da.getDriverId(), "suspended");
                if (s.driverEmail != null && !s.driverEmail.isBlank()) {
                    tryEmail(s.driverEmail,
                            "Your Delivery Account Has Been Suspended",
                            driverSuspensionEmail(s));
                }
            }
            
            orderDAO.markRefundPending(s.orderId,
                    "Driver picked up the package but did not complete delivery within "
                            + PICKUP_DELIVERY_TIMEOUT_HOURS + " hours.");

            if (s.storeOwnerEmail != null && !s.storeOwnerEmail.isBlank()) {
                tryEmail(s.storeOwnerEmail,
                        "Delivery Failed – Order " + s.orderId,
                        storePickupExpiredEmail(s));
            }
            if (s.buyerEmail != null && !s.buyerEmail.isBlank()) {
                tryEmail(s.buyerEmail,
                        "Your Order " + s.orderId + " – Refund Initiated",
                        buyerPickupExpiredEmail(s));
            }

            System.out.println("[DeliveryTimeoutJob] Rule 4 – done for assignment #" + s.assignmentId);
        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Rule 4 – error for assignment #"
                    + s.assignmentId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Email helper ──────────────────────────────────────────────────────────

    private void tryEmail(String to, String subject, String body) {
        try {
            EmailUtil.sendEmail(to, subject, body);
        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Failed to send email to " + to + ": " + e.getMessage());
        }
    }

    // ── Email templates ───────────────────────────────────────────────────────

    // Rule 1 – store didn't dispatch
    private String storeNotDispatchedEmail(OrphanedOrder o) {
        String amount = fmt(o.totalAmount, o.currency);
        return wrap(
            "<h2 style='color:#dc3545;'>Order Automatically Cancelled</h2>"
          + "<p>Hi <strong>" + esc(o.storeName) + "</strong>,</p>"
          + "<p>Order <strong>" + esc(o.orderId) + "</strong> was not dispatched within "
          + "<strong>" + PAID_TIMEOUT_HOURS + " hours</strong> of payment. "
          + "It has been automatically cancelled and the customer will be refunded.</p>"
          + table(o.orderId, o.buyerName, amount)
          + "<p>If this was an oversight, please contact support as soon as possible.</p>"
        );
    }

    private String buyerStoreNotDispatchedEmail(OrphanedOrder o) {
        String amount = fmt(o.totalAmount, o.currency);
        return wrap(
            "<h2 style='color:#0d6efd;'>Refund Initiated – Order " + esc(o.orderId) + "</h2>"
          + "<p>Hi <strong>" + esc(o.buyerName) + "</strong>,</p>"
          + "<p>Unfortunately, the store <strong>" + esc(o.storeName) + "</strong> did not process "
          + "your order within <strong>" + PAID_TIMEOUT_HOURS + " hours</strong>. "
          + "Your order has been cancelled and a full refund of <strong>" + amount + "</strong> "
          + "has been initiated.</p>"
          + table(o.orderId, o.storeName, amount)
          + "<p>Refunds typically appear within 5–7 business days depending on your bank.</p>"
        );
    }

    // Rule 2A / 2B – no driver found
    private String storeNoDriverEmail(String orderId, String storeName, String buyerName,
                                      BigDecimal totalAmount, String currency, int hours) {
        String amount = fmt(totalAmount, currency);
        return wrap(
            "<h2 style='color:#dc3545;'>Delivery Cancelled – No Driver Found</h2>"
          + "<p>Hi <strong>" + esc(storeName) + "</strong>,</p>"
          + "<p>No delivery driver was available for order <strong>" + esc(orderId) + "</strong> "
          + "within <strong>" + hours + " hours</strong> of dispatch. "
          + "The assignment has been cancelled and the customer will be refunded.</p>"
          + table(orderId, buyerName, amount)
        );
    }

    private String buyerNoDriverEmail(String orderId, String storeName, String buyerName,
                                      BigDecimal totalAmount, String currency, int hours) {
        String amount = fmt(totalAmount, currency);
        return wrap(
            "<h2 style='color:#0d6efd;'>Refund Initiated – Order " + esc(orderId) + "</h2>"
          + "<p>Hi <strong>" + esc(buyerName) + "</strong>,</p>"
          + "<p>We were unable to find a delivery driver for your order from "
          + "<strong>" + esc(storeName) + "</strong> within <strong>" + hours + " hours</strong>. "
          + "A full refund of <strong>" + amount + "</strong> has been initiated.</p>"
          + table(orderId, storeName, amount)
          + "<p>Refunds typically appear within 5–7 business days depending on your bank.</p>"
        );
    }

    // Rule 4 – picked up but not delivered
    private String storePickupExpiredEmail(StaleAssignment s) {
        String amount = fmt(s.totalAmount, s.currency);
        return wrap(
            "<h2 style='color:#dc3545;'>Delivery Not Completed</h2>"
          + "<p>Hi <strong>" + esc(s.storeName) + "</strong>,</p>"
          + "<p>The driver picked up order <strong>" + esc(s.orderId) + "</strong> but did not "
          + "complete delivery within <strong>" + PICKUP_DELIVERY_TIMEOUT_HOURS + " hours</strong>. "
          + "The delivery has been cancelled and the customer will be refunded.</p>"
          + table(s.orderId, s.buyerName, amount)
          + "<p>Please contact support if you need assistance recovering the package.</p>"
        );
    }

    private String buyerPickupExpiredEmail(StaleAssignment s) {
        String amount = fmt(s.totalAmount, s.currency);
        return wrap(
            "<h2 style='color:#0d6efd;'>Refund Initiated – Order " + esc(s.orderId) + "</h2>"
          + "<p>Hi <strong>" + esc(s.buyerName) + "</strong>,</p>"
          + "<p>The driver who picked up your order from <strong>" + esc(s.storeName) + "</strong> "
          + "did not complete delivery within <strong>" + PICKUP_DELIVERY_TIMEOUT_HOURS + " hours</strong>. "
          + "Your order has been cancelled and a full refund of <strong>" + amount + "</strong> "
          + "has been initiated.</p>"
          + table(s.orderId, s.storeName, amount)
          + "<p>Refunds typically appear within 5–7 business days. We apologise for the inconvenience.</p>"
        );
    }

    // Rule 4 – driver suspension notice
    private String driverSuspensionEmail(StaleAssignment s) {
        return wrap(
            "<h2 style='color:#dc3545;'>Your Delivery Account Has Been Suspended</h2>"
          + "<p>Hi,</p>"
          + "<p>Your Daily Fixer driver account has been <strong>suspended</strong> because order "
          + "<strong>" + esc(s.orderId) + "</strong> was picked up but not delivered within "
          + "<strong>" + PICKUP_DELIVERY_TIMEOUT_HOURS + " hours</strong> of pickup.</p>"
          + "<p>The customer has been refunded and the incident has been logged. "
          + "An admin will review your account. "
          + "If you believe this is an error, please contact support.</p>"
          + "<p style='color:#6c757d;font-size:0.9em;'>Order ID: " + esc(s.orderId) + "</p>"
        );
    }

    // ── Email building helpers ────────────────────────────────────────────────

    private String wrap(String body) {
        return "<div style='font-family:Inter,sans-serif;max-width:600px;margin:0 auto;padding:24px;'>"
             + body
             + "<p style='color:#6c757d;font-size:0.9em;margin-top:30px;'>– The Daily Fixer Team</p>"
             + "</div>";
    }

    private String table(String orderId, String secondLabel, String amount) {
        return "<table style='width:100%;border-collapse:collapse;margin:20px 0;'>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;width:40%;'>Order ID</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + esc(orderId) + "</td></tr>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;'>Details</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + esc(secondLabel) + "</td></tr>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;'>Amount</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + amount + "</td></tr>"
             + "</table>";
    }

    private String fmt(BigDecimal amount, String currency) {
        if (amount == null) return "—";
        return (currency != null ? currency : "LKR") + " " + String.format("%,.2f", amount);
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
