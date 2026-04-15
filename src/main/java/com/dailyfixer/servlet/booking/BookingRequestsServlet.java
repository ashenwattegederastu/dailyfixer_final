package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingRatingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/bookings/requests")
public class BookingRequestsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");

            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }

            BookingDAO bookingDAO = new BookingDAO();
            BookingRatingDAO ratingDAO = new BookingRatingDAO();

            List<Booking> requests = bookingDAO.getBookingsByTechnicianAndStatus(currentUser.getUserId(), "REQUESTED");

            // Build a map of userId -> avgClientRating so the technician can see it before accepting
            Map<Integer, Double> userAvgRatings = new HashMap<>();
            for (Booking b : requests) {
                int uid = b.getUserId();
                if (!userAvgRatings.containsKey(uid)) {
                    userAvgRatings.put(uid, ratingDAO.getAverageRatingForUser(uid));
                }
            }

            request.setAttribute("bookingRequests", requests);
            request.setAttribute("userAvgRatings", userAvgRatings);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/booking-requests.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading booking requests: " + e.getMessage());
        }
    }
}
