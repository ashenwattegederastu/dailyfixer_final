package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.dao.ClientNoShowPenaltyDAO;
import com.dailyfixer.model.ClientNoShowPenalty;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * POST /technician/client-penalty/review
 *
 * Technician reviews a client payment proof and either confirms or disputes it.
 *
 * Parameters:
 *   penaltyId – int, ID of the client_no_show_penalties row
 *   action    – "confirm" | "dispute"
 *
 * "confirm"  → status = CONFIRMED_PAID, client notified that penalty is resolved.
 * "dispute"  → status = ADMIN_REVIEW, admin notified for manual review.
 */
@WebServlet("/technician/client-penalty/review")
public class TechnicianClientPenaltyReviewServlet extends HttpServlet {

    private final ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();
    private final BookingNotificationDAO notifDAO   = new BookingNotificationDAO();
    private final BookingDAO             bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !"technician".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String penaltyIdStr = req.getParameter("penaltyId");
        String action       = req.getParameter("action");

        if (penaltyIdStr == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/technician/bookings/completed?penaltyError=missingParams");
            return;
        }

        int penaltyId;
        try {
            penaltyId = Integer.parseInt(penaltyIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/technician/bookings/completed?penaltyError=invalidId");
            return;
        }

        try {
            ClientNoShowPenalty penalty = penaltyDAO.getByPenaltyId(penaltyId);

            if (penalty == null || penalty.getTechnicianId() != user.getUserId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }

            if (!"PROOF_UPLOADED".equals(penalty.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/technician/bookings/completed?penaltyError=invalidStatus");
                return;
            }

            switch (action) {
                case "confirm":
                    penaltyDAO.technicianConfirmPaid(penaltyId);
                    // Mark the booking as fully completed
                    bookingDAO.updateBookingStatus(penalty.getBookingId(), "FULLY_COMPLETED");
                    // Notify client
                    notifDAO.createNotification(
                            penalty.getClientId(),
                            penalty.getBookingId(),
                            "Your payment proof for booking #" + penalty.getBookingId()
                            + " has been confirmed by the technician. The no-show penalty of Rs. 2,500 is resolved. Thank you.");
                    resp.sendRedirect(req.getContextPath() + "/technician/bookings/completed?penaltyConfirmed=true");
                    break;

                case "dispute":
                    penaltyDAO.technicianMarkNotPaid(penaltyId);
                    // Notify client
                    notifDAO.createNotification(
                            penalty.getClientId(),
                            penalty.getBookingId(),
                            "The technician has disputed your payment proof for booking #" + penalty.getBookingId()
                            + ". Your case has been escalated to admin for review. Please await further contact.");
                    resp.sendRedirect(req.getContextPath() + "/technician/bookings/completed?penaltyDisputed=true");
                    break;

                default:
                    resp.sendRedirect(req.getContextPath() + "/technician/bookings/completed?penaltyError=invalidAction");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/technician/bookings/completed?penaltyError=serverError");
        }
    }
}
