package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.dao.ClientNoShowPenaltyDAO;
import com.dailyfixer.dao.RescheduleRequestDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.Chat;
import com.dailyfixer.model.ClientNoShowPenalty;
import com.dailyfixer.model.RescheduleRequest;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
@WebServlet("/bookings/calendar")
public class BookingCalendarServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            BookingDAO bookingDAO = new BookingDAO();

            // Load all active statuses the technician needs to see
            List<Booking> bookings = new ArrayList<>();
            for (String status : new String[]{"ACCEPTED", "IN_PROGRESS", "TECHNICIAN_COMPLETED", "RESCHEDULE_PENDING"}) {
                bookings.addAll(bookingDAO.getBookingsByTechnicianAndStatus(currentUser.getUserId(), status));
            }

            // For RESCHEDULE_PENDING bookings, load the pending reschedule request so the JSP can show it
            RescheduleRequestDAO rescheduleDAO = new RescheduleRequestDAO();
            Map<Integer, RescheduleRequest> pendingReschedules = new HashMap<>();
            for (Booking b : bookings) {
                if ("RESCHEDULE_PENDING".equals(b.getStatus())) {
                    RescheduleRequest rr = rescheduleDAO.getPendingByBookingId(b.getBookingId());
                    if (rr != null) pendingReschedules.put(b.getBookingId(), rr);
                }
            }

            // Load pending client penalty reviews for this technician
            ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();
            List<ClientNoShowPenalty> pendingPenaltyReviews =
                    penaltyDAO.getPendingReviewForTechnician(currentUser.getUserId());

            // Build bookingId → chatId map (one chat per user-technician pair)
            ChatDAO chatDAO = new ChatDAO();
            Map<Integer, Integer> bookingChatIds = new HashMap<>();
            Map<Integer, Integer> pairChatCache = new HashMap<>(); // technicianId → chatId
            for (Booking b : bookings) {
                if (!pairChatCache.containsKey(b.getTechnicianId())) {
                    Chat chat = chatDAO.getChatByPair(b.getUserId(), b.getTechnicianId());
                    pairChatCache.put(b.getTechnicianId(), chat != null ? chat.getChatId() : 0);
                }
                bookingChatIds.put(b.getBookingId(), pairChatCache.get(b.getTechnicianId()));
            }

            request.setAttribute("bookings", bookings);
            request.setAttribute("pendingReschedules", pendingReschedules);
            request.setAttribute("pendingPenaltyReviews", pendingPenaltyReviews);
            request.setAttribute("bookingChatIds", bookingChatIds);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/booking-calendar.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading calendar: " + e.getMessage());
        }
    }
}
