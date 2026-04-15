package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideFlagDAO;
import com.dailyfixer.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet for flagging a guide.
 * POST /guides/flag - submit a flag (AJAX, returns JSON)
 */
@WebServlet("/guides/flag")
public class GuideFlagServlet extends HttpServlet {

    private GuideFlagDAO flagDAO = new GuideFlagDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Auth check
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\": \"Please login to flag guides.\"}");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\": \"Please login to flag guides.\"}");
            return;
        }

        // Parse parameters
        String guideIdParam = request.getParameter("guideId");
        String reason = request.getParameter("reason");
        String description = request.getParameter("description");

        if (guideIdParam == null || reason == null || reason.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Guide ID and reason are required.\"}");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(guideIdParam);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid guide ID.\"}");
            return;
        }

        int userId = currentUser.getUserId();

        // Check if user already flagged
        if (flagDAO.hasUserFlagged(guideId, userId)) {
            response.getWriter().write("{\"success\": false, \"message\": \"You have already flagged this guide.\"}");
            return;
        }

        // Sanitize description
        String safeDescription = description != null ? description.trim() : null;
        if (safeDescription != null && safeDescription.length() > 500) {
            safeDescription = safeDescription.substring(0, 500);
        }

        // Add the flag
        boolean success = flagDAO.addFlag(guideId, userId, reason, safeDescription);

        if (success) {
            int flagCount = flagDAO.getFlagCount(guideId);
            response.getWriter().write(String.format(
                    "{\"success\": true, \"message\": \"Guide has been flagged. Thank you for your report.\", \"flagCount\": %d}",
                    flagCount));
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Failed to submit flag. Please try again.\"}");
        }
    }
}
