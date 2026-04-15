package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.dao.RecurringContractDAO;
import com.dailyfixer.dao.TechnicianDailyLimitDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/bookings/accept")
public class AcceptBookingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            
            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null || booking.getTechnicianId() != currentUser.getUserId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }

            // Enforce daily booking limit
            TechnicianDailyLimitDAO limitDAO = new TechnicianDailyLimitDAO();
            int maxPerDay = limitDAO.getMaxBookingsPerDay(currentUser.getUserId());
            int currentCount = bookingDAO.countActiveBookingsForDate(
                    currentUser.getUserId(), booking.getBookingDate());
            if (currentCount >= maxPerDay) {
                response.sendRedirect(request.getContextPath()
                        + "/bookings/requests?limitReached=true&date=" + booking.getBookingDate());
                return;
            }

            // Update booking status
            bookingDAO.updateBookingStatus(bookingId, "ACCEPTED");

            // If this is the first booking of a recurring contract, activate the
            // contract and auto-generate months 2-12 as ACCEPTED bookings.
            if (booking.getRecurringContractId() != null && Integer.valueOf(1).equals(booking.getRecurringSequence())) {
                RecurringContractDAO contractDAO = new RecurringContractDAO();
                contractDAO.updateContractStatus(booking.getRecurringContractId(), "ACTIVE");
                bookingDAO.createRecurringBookings(booking.getRecurringContractId(), booking);
            }

            // Create chat for this user-technician pair (once per pair, shared across all bookings)
            ChatDAO chatDAO = new ChatDAO();
            if (chatDAO.getChatByPair(booking.getUserId(), booking.getTechnicianId()) == null) {
                com.dailyfixer.model.Chat chat = new com.dailyfixer.model.Chat();
                chat.setUserId(booking.getUserId());
                chat.setTechnicianId(booking.getTechnicianId());
                chatDAO.createChat(chat);
            }

            // Notify the client
            BookingNotificationDAO notifDAO = new BookingNotificationDAO();
            notifDAO.createNotification(booking.getUserId(), bookingId,
                    "Your booking #" + bookingId + " for \"" + booking.getServiceName()
                            + "\" on " + booking.getBookingDate() + " has been accepted by the technician.");
            
            response.sendRedirect(request.getContextPath() + "/bookings/requests?accepted=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error accepting booking: " + e.getMessage());
        }
    }
}
