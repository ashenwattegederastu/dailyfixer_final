package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.dao.GuideFlagDAO;
import com.dailyfixer.model.Guide;
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
 * Servlet for admin to view flagged guides and pending review guides.
 * GET /admin/flagged-guides - shows flagged guides that exceed threshold
 * GET /admin/flagged-guides?view=pending - shows edited guides pending review
 */
@WebServlet("/admin/flagged-guides")
public class AdminFlaggedGuidesServlet extends HttpServlet {

    private GuideDAO guideDAO = new GuideDAO();
    private GuideFlagDAO flagDAO = new GuideFlagDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Admin auth check
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String view = request.getParameter("view");

        if ("pending".equals(view)) {
            // Show guides that were edited by creators and need re-review
            List<Guide> pendingGuides = guideDAO.getPendingReviewGuides();
            request.setAttribute("guides", pendingGuides);
            request.setAttribute("viewMode", "pending");
        } else {
            // Show flagged guides that exceed the threshold
            List<Guide> flaggedGuides = guideDAO.getFlaggedGuides(flagDAO.getFlagThreshold());
            request.setAttribute("guides", flaggedGuides);
            request.setAttribute("viewMode", "flagged");
        }

        request.setAttribute("threshold", flagDAO.getFlagThreshold());
        request.getRequestDispatcher("/pages/guides/admin-flagged.jsp").forward(request, response);
    }
}
