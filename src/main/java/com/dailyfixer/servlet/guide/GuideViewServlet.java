package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.dao.GuideRatingDAO;
import com.dailyfixer.dao.GuideCommentDAO;
import com.dailyfixer.dao.GuideFlagDAO;
import com.dailyfixer.model.Guide;
import com.dailyfixer.model.GuideComment;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for viewing a single guide with its details, ratings, and comments.
 * URL: /guides/view?id=123
 */
@WebServlet("/guides/view")
public class GuideViewServlet extends HttpServlet {

    private GuideDAO guideDAO = new GuideDAO();
    private GuideRatingDAO ratingDAO = new GuideRatingDAO();
    private GuideCommentDAO commentDAO = new GuideCommentDAO();
    private GuideFlagDAO flagDAO = new GuideFlagDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Get the guide
        Guide guide = guideDAO.getGuideById(guideId);
        if (guide == null) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Increment view count
        guideDAO.incrementViewCount(guideId);
        // Reload guide to get updated view count or manually update it
        guide.setViewCount(guide.getViewCount() + 1);

        // Get ratings
        int[] ratingCounts = ratingDAO.getRatingCounts(guideId);

        // Get comments
        List<GuideComment> comments = commentDAO.getCommentsByGuide(guideId);

        // Check if current user has rated
        HttpSession session = request.getSession(false);
        String userRating = null;
        boolean canEdit = false;
        boolean hasUserFlagged = false;
        int currentUserId = 0;
        boolean isAdmin = false;

        if (session != null) {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser != null) {
                currentUserId = currentUser.getUserId();
                isAdmin = "admin".equals(currentUser.getRole());
                userRating = ratingDAO.getUserRating(guideId, currentUserId);
                hasUserFlagged = flagDAO.hasUserFlagged(guideId, currentUserId);

                // Check if user can edit (admin or creator)
                canEdit = isAdmin || guide.getCreatedBy() == currentUserId;
            }
        }

        // If guide is hidden, only allow admin or creator to view
        if ("HIDDEN".equals(guide.getStatus()) || "PENDING_REVIEW".equals(guide.getStatus())) {
            if (!isAdmin && guide.getCreatedBy() != currentUserId) {
                response.sendRedirect(request.getContextPath() + "/guides");
                return;
            }
        }

        int flagCount = flagDAO.getFlagCount(guideId);

        request.setAttribute("guide", guide);
        request.setAttribute("upCount", ratingCounts[0]);
        request.setAttribute("downCount", ratingCounts[1]);
        request.setAttribute("userRating", userRating);
        request.setAttribute("comments", comments);
        request.setAttribute("canEdit", canEdit);
        request.setAttribute("currentUserId", currentUserId);
        request.setAttribute("hasUserFlagged", hasUserFlagged);
        request.setAttribute("flagCount", flagCount);
        request.setAttribute("isAdmin", isAdmin);

        request.getRequestDispatcher("/pages/guides/view.jsp").forward(request, response);
    }
}
