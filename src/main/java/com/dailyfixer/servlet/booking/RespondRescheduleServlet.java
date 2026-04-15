package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.dao.RescheduleRequestDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.RescheduleRequest;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles the recipient's response (accept or reject) to a reschedule request.
 * POST /bookings/reschedule/respond
 *
 * Params: bookingId, rescheduleId, action ("accept" | "reject"), keepBooking ("true" | "false")
 *
 * Accept flow:  booking date/time updated → booking status → ACCEPTED
 * Reject flow:  reschedule row → REJECTED → booking status → ACCEPTED (unchanged)
 *               If the requester was the technician and the client responds with
 *               keepBooking=false, the booking is cancelled instead.
 */
@WebServlet("/bookings/reschedule/respond")
public class RespondRescheduleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int rescheduleId = Integer.parseInt(request.getParameter("rescheduleId"));
            String action = request.getParameter("action"); // "accept" or "reject"
            boolean keepBooking = !"false".equals(request.getParameter("keepBooking"));

            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }

            // Only the booking parties can respond
            boolean isClient = booking.getUserId() == currentUser.getUserId();
            boolean isTech = booking.getTechnicianId() == currentUser.getUserId();
            if (!isClient && !isTech) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }

            // Booking must still be in RESCHEDULE_PENDING
            if (!"RESCHEDULE_PENDING".equals(booking.getStatus())) {
                response.sendRedirect(buildRedirect(request, currentUser, "?error=reschedule_already_resolved"));
                return;
            }

            RescheduleRequestDAO rescheduleDAO = new RescheduleRequestDAO();
            RescheduleRequest req = rescheduleDAO.getById(rescheduleId);

            if (req == null || req.getBookingId() != bookingId) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Reschedule request not found");
                return;
            }

            // The responder must NOT be the original requester
            if (req.getRequestedBy() == currentUser.getUserId()) {
                response.sendRedirect(buildRedirect(request, currentUser, "?error=cannot_respond_own_request"));
                return;
            }

            BookingNotificationDAO notifDAO = new BookingNotificationDAO();

            if ("accept".equals(action)) {
                // Update the booking's date and time, restore ACCEPTED status
                rescheduleDAO.acceptRequest(rescheduleId);
                bookingDAO.updateBookingDateTime(bookingId, req.getNewDate(), req.getNewTime());
                bookingDAO.updateBookingStatus(bookingId, "ACCEPTED");

                // Notify the original requester
                String msg = "Your reschedule request for booking #" + bookingId
                        + " (" + booking.getServiceName() + ") was accepted. New time: "
                        + req.getNewDate() + " at " + req.getNewTime() + ".";
                notifDAO.createNotification(req.getRequestedBy(), bookingId, msg);

                response.sendRedirect(buildRedirect(request, currentUser, "?rescheduleAccepted=true"));

            } else if ("reject".equals(action)) {
                rescheduleDAO.rejectRequest(rescheduleId);

                if (!keepBooking && isClient) {
                    // Client chose to cancel after reschedule was rejected by them
                    // (edge case: technician requested, client rejected, then client doesn't want to keep)
                    bookingDAO.updateBookingStatus(bookingId, "CANCELLED");

                    com.dailyfixer.dao.BookingCancellationDAO cancelDAO =
                            new com.dailyfixer.dao.BookingCancellationDAO();
                    com.dailyfixer.model.BookingCancellation cancellation =
                            new com.dailyfixer.model.BookingCancellation();
                    cancellation.setBookingId(bookingId);
                    cancellation.setCancelledBy(currentUser.getUserId());
                    cancellation.setCancellationReason("Client cancelled after rejecting technician's reschedule request.");
                    cancelDAO.createCancellation(cancellation);

                    // Notify technician
                    String msg = "Client cancelled booking #" + bookingId + " (" + booking.getServiceName()
                            + ") after rejecting the reschedule request.";
                    notifDAO.createNotification(booking.getTechnicianId(), bookingId, msg);

                    response.sendRedirect(request.getContextPath() + "/user/bookings/active?rescheduleCancelled=true");
                } else {
                    // Restore booking to ACCEPTED with original date/time
                    bookingDAO.updateBookingStatus(bookingId, "ACCEPTED");

                    // Notify the original requester
                    String msg = "Your reschedule request for booking #" + bookingId
                            + " (" + booking.getServiceName() + ") was rejected. The original schedule is kept.";
                    notifDAO.createNotification(req.getRequestedBy(), bookingId, msg);

                    response.sendRedirect(buildRedirect(request, currentUser, "?rescheduleRejected=true"));
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error responding to reschedule: " + e.getMessage());
        }
    }

    private String buildRedirect(HttpServletRequest request, User currentUser, String queryString) {
        String role = currentUser.getRole() == null ? "" : currentUser.getRole().toLowerCase();
        String base = "technician".equals(role)
                ? request.getContextPath() + "/bookings/calendar"
                : request.getContextPath() + "/user/bookings/active";
        return base + queryString;
    }
}
