package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingCancellationDAO;
import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.BookingCancellation;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/bookings/cancel")
public class CancelBookingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String cancellationReason = request.getParameter("cancellationReason");
            
            if (cancellationReason == null || cancellationReason.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cancellation reason is required");
                return;
            }
            
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }
            
            // Check if user has permission to cancel
            if (booking.getUserId() != currentUser.getUserId() && booking.getTechnicianId() != currentUser.getUserId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }
            
            // Create cancellation record
            BookingCancellation cancellation = new BookingCancellation();
            cancellation.setBookingId(bookingId);
            cancellation.setCancelledBy(currentUser.getUserId());
            cancellation.setCancellationReason(cancellationReason);
            
            BookingCancellationDAO cancellationDAO = new BookingCancellationDAO();
            cancellationDAO.createCancellation(cancellation);
            
            // Update booking status
            bookingDAO.updateBookingStatus(bookingId, "CANCELLED");
            
            // Redirect based on user role
            String redirectUrl = "technician".equalsIgnoreCase(currentUser.getRole()) 
                ? "/bookings/calendar?cancelled=true" 
                : "/pages/dashboards/userdash/userdashmain.jsp?cancelled=true";
            
            response.sendRedirect(request.getContextPath() + redirectUrl);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error cancelling booking: " + e.getMessage());
        }
    }
}
