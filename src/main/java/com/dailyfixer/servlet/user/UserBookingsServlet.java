package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingRatingDAO;
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
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/user/bookings/*")
public class UserBookingsServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || !"user".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user/bookings/active");
            return;
        }

        try {
            int userId = currentUser.getUserId();
            List<Booking> bookings;
            String targetJsp = "";

            switch (pathInfo) {
                case "/active":
                    bookings = bookingDAO.getBookingsByUserAndStatuses(userId,
                            "REQUESTED", "ACCEPTED", "IN_PROGRESS", "TECHNICIAN_COMPLETED",
                            "RESCHEDULE_PENDING", "NO_SHOW", "CLIENT_NO_SHOW");

                    // For recurring contracts, show only the next upcoming booking per contract.
                    // Non-recurring bookings are shown as-is.
                    Map<Integer, Booking> nextRecurring = new LinkedHashMap<>();
                    List<Booking> nonRecurring = new ArrayList<>();
                    for (Booking b : bookings) {
                        if (b.getRecurringContractId() == null) {
                            nonRecurring.add(b);
                        } else {
                            int cid = b.getRecurringContractId();
                            if (!nextRecurring.containsKey(cid) ||
                                b.getBookingDate().before(nextRecurring.get(cid).getBookingDate())) {
                                nextRecurring.put(cid, b);
                            }
                        }
                    }
                    List<Booking> displayed = new ArrayList<>(nonRecurring);
                    displayed.addAll(nextRecurring.values());
                    displayed.sort((a, z) -> z.getBookingDate().compareTo(a.getBookingDate()));

                    // For RESCHEDULE_PENDING bookings, load the pending reschedule request
                    RescheduleRequestDAO rescheduleDAO = new RescheduleRequestDAO();
                    Map<Integer, RescheduleRequest> pendingReschedules = new HashMap<>();
                    for (Booking b : displayed) {
                        if ("RESCHEDULE_PENDING".equals(b.getStatus())) {
                            RescheduleRequest rr = rescheduleDAO.getPendingByBookingId(b.getBookingId());
                            if (rr != null) pendingReschedules.put(b.getBookingId(), rr);
                        }
                    }

                    // Load client no-show penalty data keyed by bookingId
                    ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();
                    Map<Integer, ClientNoShowPenalty> clientPenalties = new HashMap<>();
                    for (Booking b : displayed) {
                        if ("CLIENT_NO_SHOW".equals(b.getStatus())) {
                            ClientNoShowPenalty penalty = penaltyDAO.getByBookingId(b.getBookingId());
                            if (penalty != null) clientPenalties.put(b.getBookingId(), penalty);
                        }
                    }

                    request.setAttribute("activeBookings", displayed);
                    request.setAttribute("pendingReschedules", pendingReschedules);
                    request.setAttribute("clientPenalties", clientPenalties);

                    // Build bookingId → chatId map for the Message button
                    ChatDAO chatDAO = new ChatDAO();
                    Map<Integer, Integer> bookingChatIds = new HashMap<>();
                    Map<Integer, Integer> pairChatCache = new HashMap<>(); // technicianId → chatId
                    for (Booking b : displayed) {
                        if (!pairChatCache.containsKey(b.getTechnicianId())) {
                            Chat chat = chatDAO.getChatByPair(b.getUserId(), b.getTechnicianId());
                            pairChatCache.put(b.getTechnicianId(), chat != null ? chat.getChatId() : 0);
                        }
                        bookingChatIds.put(b.getBookingId(), pairChatCache.get(b.getTechnicianId()));
                    }
                    request.setAttribute("bookingChatIds", bookingChatIds);

                    targetJsp = "/pages/dashboards/userdash/activeBookings.jsp";
                    break;
                case "/completed":
                    bookings = bookingDAO.getBookingsByUserAndStatuses(userId, "FULLY_COMPLETED");
                    request.setAttribute("completedBookings", bookings);

                    // Build set of booking IDs where user has already submitted a TECHNICIAN_RATING
                    BookingRatingDAO ratingDAO = new BookingRatingDAO();
                    Set<Integer> ratedBookingIds = new HashSet<>();
                    for (Booking b : bookings) {
                        if (ratingDAO.hasRated(b.getBookingId(), "TECHNICIAN_RATING")) {
                            ratedBookingIds.add(b.getBookingId());
                        }
                    }
                    request.setAttribute("ratedBookingIds", ratedBookingIds);
                    targetJsp = "/pages/dashboards/userdash/completedBookings.jsp";
                    break;
                case "/cancelled":
                    bookings = bookingDAO.getBookingsByUserAndStatuses(userId, "REJECTED", "CANCELLED", "AUTO_REJECTED");
                    request.setAttribute("cancelledBookings", bookings);
                    targetJsp = "/pages/dashboards/userdash/cancelledBookings.jsp";
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/user/bookings/active");
                    return;
            }

            request.getRequestDispatcher(targetJsp).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/pages/dashboards/userdash/userdashmain.jsp?error=fetch_failed");
        }
    }
}
