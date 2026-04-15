package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/bookings/reject")
public class RejectBookingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String rejectionReason = request.getParameter("rejectionReason");
            
            if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Rejection reason is required");
                return;
            }
            
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null || booking.getTechnicianId() != currentUser.getUserId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }
            
            // Update booking status with rejection reason
            bookingDAO.updateBookingStatusWithRejection(bookingId, "REJECTED", rejectionReason);
            
            response.sendRedirect(request.getContextPath() + "/bookings/requests?rejected=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error rejecting booking: " + e.getMessage());
        }
    }
}
