package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingRatingDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.BookingRating;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/bookings/rate")
public class SubmitBookingRatingServlet extends HttpServlet {

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
            String ratingType = request.getParameter("ratingType"); // TECHNICIAN_RATING or CLIENT_RATING
            int ratingValue = Integer.parseInt(request.getParameter("rating"));
            String review = request.getParameter("review");
            String redirectUrl = request.getParameter("redirectUrl");

            // Validate rating value
            if (ratingValue < 1 || ratingValue > 5) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Rating must be between 1 and 5");
                return;
            }

            // Validate ratingType
            if (!"TECHNICIAN_RATING".equals(ratingType) && !"CLIENT_RATING".equals(ratingType)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid rating type");
                return;
            }

            BookingDAO bookingDAO = new BookingDAO();
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }

            // Booking must be FULLY_COMPLETED
            if (!"FULLY_COMPLETED".equals(booking.getStatus())) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Booking must be fully completed to rate");
                return;
            }

            // Determine who is rated_by and rated_user based on rating type
            int ratedBy, ratedUser;
            if ("TECHNICIAN_RATING".equals(ratingType)) {
                // User rates the technician — only the booking's user can submit this
                if (booking.getUserId() != currentUser.getUserId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only the booking client can rate the technician");
                    return;
                }
                ratedBy = booking.getUserId();
                ratedUser = booking.getTechnicianId();
            } else {
                // Technician rates the client — only the booking's technician can submit this
                if (booking.getTechnicianId() != currentUser.getUserId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only the booking technician can rate the client");
                    return;
                }
                ratedBy = booking.getTechnicianId();
                ratedUser = booking.getUserId();
            }

            BookingRatingDAO ratingDAO = new BookingRatingDAO();

            // Prevent double-rating
            if (ratingDAO.hasRated(bookingId, ratingType)) {
                // Already rated — redirect with a flag
                String base = (redirectUrl != null && !redirectUrl.isEmpty()) ? redirectUrl
                        : request.getContextPath() + "/";
                response.sendRedirect(base + (base.contains("?") ? "&" : "?") + "alreadyRated=true");
                return;
            }

            BookingRating bookingRating = new BookingRating();
            bookingRating.setBookingId(bookingId);
            bookingRating.setRatedBy(ratedBy);
            bookingRating.setRatedUser(ratedUser);
            bookingRating.setRatingType(ratingType);
            bookingRating.setRating(ratingValue);
            bookingRating.setReview((review != null && !review.trim().isEmpty()) ? review.trim() : null);

            ratingDAO.submitRating(bookingRating);

            // Redirect back
            String base = (redirectUrl != null && !redirectUrl.isEmpty()) ? redirectUrl
                    : request.getContextPath() + "/";
            response.sendRedirect(base + (base.contains("?") ? "&" : "?") + "rated=true");

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error submitting rating: " + e.getMessage());
        }
    }
}
