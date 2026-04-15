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
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Handles a reschedule request submission from either a client or a technician.
 * POST /bookings/reschedule/request
 *
 * Rules:
 *  - Booking must be in ACCEPTED status.
 *  - Request must be submitted at least 12 hours before the scheduled datetime.
 *  - No duplicate PENDING request from the same user for the same booking.
 *  - On success, booking moves to RESCHEDULE_PENDING and the other party is notified.
 */
@WebServlet("/bookings/reschedule/request")
public class RequestRescheduleServlet extends HttpServlet {

    private static final int MIN_HOURS_BEFORE = 12;

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
            String newDateStr = request.getParameter("newDate");
            String newTimeStr = request.getParameter("newTime");
            String reason = request.getParameter("reason");

            if (newDateStr == null || newTimeStr == null ||
                    newDateStr.isBlank() || newTimeStr.isBlank()) {
                sendError(request, response, currentUser, "New date and time are required.");
                return;
            }

            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }

            // Only the booking's client or technician can request a reschedule
            boolean isClient = booking.getUserId() == currentUser.getUserId();
            boolean isTech = booking.getTechnicianId() == currentUser.getUserId();
            if (!isClient && !isTech) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }

            // Booking must be ACCEPTED
            if (!"ACCEPTED".equals(booking.getStatus())) {
                sendError(request, response, currentUser,
                        "Reschedule requests can only be made for accepted bookings.");
                return;
            }

            // Enforce 12-hour advance window
            LocalDateTime scheduledDateTime = LocalDateTime.of(
                    booking.getBookingDate().toLocalDate(),
                    booking.getBookingTime().toLocalTime());
            if (LocalDateTime.now().plusHours(MIN_HOURS_BEFORE).isAfter(scheduledDateTime)) {
                sendError(request, response, currentUser,
                        "Reschedule requests must be submitted at least " + MIN_HOURS_BEFORE
                                + " hours before the scheduled time.");
                return;
            }

            // Validate new date/time is in the future
            LocalDate newDate = LocalDate.parse(newDateStr);
            LocalTime newTime = LocalTime.parse(newTimeStr);
            if (LocalDateTime.of(newDate, newTime).isBefore(LocalDateTime.now())) {
                sendError(request, response, currentUser,
                        "The proposed new date and time must be in the future.");
                return;
            }

            RescheduleRequestDAO rescheduleDAO = new RescheduleRequestDAO();

            // Prevent duplicate pending request from the same user
            if (rescheduleDAO.hasPendingRequest(bookingId, currentUser.getUserId())) {
                sendError(request, response, currentUser,
                        "You already have a pending reschedule request for this booking.");
                return;
            }

            // Create the reschedule request
            RescheduleRequest req = new RescheduleRequest();
            req.setBookingId(bookingId);
            req.setRequestedBy(currentUser.getUserId());
            req.setNewDate(Date.valueOf(newDate));
            req.setNewTime(Time.valueOf(newTime));
            req.setReason((reason != null && !reason.isBlank()) ? reason.trim() : null);
            rescheduleDAO.createRequest(req);

            // Move booking to RESCHEDULE_PENDING
            bookingDAO.updateBookingStatus(bookingId, "RESCHEDULE_PENDING");

            // Notify the other party
            BookingNotificationDAO notifDAO = new BookingNotificationDAO();
            if (isClient) {
                // Notify technician
                String msg = "Client " + currentUser.getFirstName() + " " + currentUser.getLastName()
                        + " has requested to reschedule booking #" + bookingId
                        + " (" + booking.getServiceName() + ") to " + newDateStr + " at " + newTimeStr + ".";
                notifDAO.createNotification(booking.getTechnicianId(), bookingId, msg);
                response.sendRedirect(request.getContextPath() + "/user/bookings/active?rescheduleRequested=true");
            } else {
                // Notify client
                String msg = "Technician " + currentUser.getFirstName() + " " + currentUser.getLastName()
                        + " has requested to reschedule booking #" + bookingId
                        + " (" + booking.getServiceName() + ") to " + newDateStr + " at " + newTimeStr + ".";
                notifDAO.createNotification(booking.getUserId(), bookingId, msg);
                response.sendRedirect(request.getContextPath() + "/bookings/calendar?rescheduleRequested=true");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid booking ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error submitting reschedule request: " + e.getMessage());
        }
    }

    private void sendError(HttpServletRequest request, HttpServletResponse response,
                           User currentUser, String message) throws IOException {
        String role = currentUser.getRole() == null ? "" : currentUser.getRole().toLowerCase();
        String base = "technician".equals(role)
                ? request.getContextPath() + "/bookings/calendar"
                : request.getContextPath() + "/user/bookings/active";
        response.sendRedirect(base + "?error=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}
