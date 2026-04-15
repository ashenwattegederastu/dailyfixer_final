package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideRatingDAO;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet for rating a guide (thumbs up/down).
 * URL: /guides/rate (POST only)
 */
@WebServlet("/guides/rate")
public class GuideRateServlet extends HttpServlet {

    private GuideRatingDAO ratingDAO = new GuideRatingDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Please login to rate guides.");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Please login to rate guides.");
            return;
        }

        String guideIdParam = request.getParameter("guideId");
        String rating = request.getParameter("rating");

        if (guideIdParam == null || rating == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing parameters.");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(guideIdParam);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid guide ID.");
            return;
        }

        // Validate rating value
        if (!"UP".equals(rating) && !"DOWN".equals(rating)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid rating value.");
            return;
        }

        int userId = currentUser.getUserId();

        // Check if user already has this rating (toggle off)
        String existingRating = ratingDAO.getUserRating(guideId, userId);

        if (rating.equals(existingRating)) {
            // Same rating - remove it (toggle off)
            ratingDAO.removeRating(guideId, userId);
        } else {
            // Different or no rating - add/update
            ratingDAO.addOrUpdateRating(guideId, userId, rating);
        }

        // Return updated counts
        int[] counts = ratingDAO.getRatingCounts(guideId);
        String newUserRating = ratingDAO.getUserRating(guideId, userId);

        response.setContentType("application/json");
        response.getWriter().write(String.format(
                "{\"upCount\": %d, \"downCount\": %d, \"userRating\": %s}",
                counts[0], counts[1],
                newUserRating == null ? "null" : "\"" + newUserRating + "\""));
    }
}
