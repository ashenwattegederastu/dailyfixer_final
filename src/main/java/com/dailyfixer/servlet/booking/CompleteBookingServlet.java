package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/bookings/complete")
public class CompleteBookingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");

            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }

            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String completionType = request.getParameter("completionType"); // "technician" or "user"

            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }

            // Technician marks job as started (ACCEPTED → IN_PROGRESS)
            if ("start".equals(completionType)) {
                if (booking.getTechnicianId() != currentUser.getUserId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                    return;
                }
                if (!"ACCEPTED".equals(booking.getStatus())) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Booking must be accepted to start");
                    return;
                }
                bookingDAO.updateBookingStatus(bookingId, "IN_PROGRESS");
                response.sendRedirect(request.getContextPath() + "/bookings/calendar?started=true");
            }
            // Technician marks as completed
            else if ("technician".equals(completionType)) {
                if (booking.getTechnicianId() != currentUser.getUserId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                    return;
                }

                if (!"ACCEPTED".equals(booking.getStatus()) && !"IN_PROGRESS".equals(booking.getStatus())) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                            "Booking must be accepted or in progress to mark as complete");
                    return;
                }

                bookingDAO.updateBookingStatus(bookingId, "TECHNICIAN_COMPLETED");
                response.sendRedirect(request.getContextPath() + "/bookings/calendar?completed=true");
            }
            // User confirms completion
            else if ("user".equals(completionType)) {
                if (booking.getUserId() != currentUser.getUserId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                    return;
                }

                if (!"TECHNICIAN_COMPLETED".equals(booking.getStatus())) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Technician must mark as complete first");
                    return;
                }

                bookingDAO.updateBookingStatus(bookingId, "FULLY_COMPLETED");
                response.sendRedirect(request.getContextPath() + "/user/bookings/completed?confirmed=true");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid completion type");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error completing booking: " + e.getMessage());
        }
    }
}
