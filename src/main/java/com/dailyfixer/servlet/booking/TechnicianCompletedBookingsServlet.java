package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingRatingDAO;
import com.dailyfixer.dao.ClientNoShowPenaltyDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.ClientNoShowPenalty;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/technician/bookings/completed")
public class TechnicianCompletedBookingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");

            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }

            BookingDAO bookingDAO = new BookingDAO();
            BookingRatingDAO ratingDAO = new BookingRatingDAO();
            ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();
            int techId = currentUser.getUserId();

            // Fetch TECHNICIAN_COMPLETED (awaiting user confirm), FULLY_COMPLETED, CLIENT_NO_SHOW, and NO_SHOW
            List<Booking> techCompleted   = bookingDAO.getBookingsByTechnicianAndStatus(techId, "TECHNICIAN_COMPLETED");
            List<Booking> fullyCompleted  = bookingDAO.getBookingsByTechnicianAndStatus(techId, "FULLY_COMPLETED");
            List<Booking> clientNoShows   = bookingDAO.getBookingsByTechnicianAndStatus(techId, "CLIENT_NO_SHOW");
            List<Booking> noShows         = bookingDAO.getBookingsByTechnicianAndStatus(techId, "NO_SHOW");

            List<Booking> allCompleted = new ArrayList<>();
            allCompleted.addAll(techCompleted);
            allCompleted.addAll(fullyCompleted);
            allCompleted.addAll(clientNoShows);
            allCompleted.addAll(noShows);

            // Build set of booking IDs where technician has already submitted a CLIENT_RATING
            Set<Integer> ratedBookingIds = new HashSet<>();
            for (Booking b : fullyCompleted) {
                if (ratingDAO.hasRated(b.getBookingId(), "CLIENT_RATING")) {
                    ratedBookingIds.add(b.getBookingId());
                }
            }

            // Build penalty map for CLIENT_NO_SHOW bookings (keyed by bookingId)
            Map<Integer, ClientNoShowPenalty> penaltyMap = new HashMap<>();
            for (Booking b : clientNoShows) {
                ClientNoShowPenalty cp = penaltyDAO.getByBookingId(b.getBookingId());
                if (cp != null) {
                    penaltyMap.put(b.getBookingId(), cp);
                }
            }

            request.setAttribute("completedBookings", allCompleted);
            request.setAttribute("ratedBookingIds", ratedBookingIds);
            request.setAttribute("clientNoShowPenalties", penaltyMap);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/completedBookings.jsp").forward(request,
                    response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error loading completed bookings: " + e.getMessage());
        }
    }
}
