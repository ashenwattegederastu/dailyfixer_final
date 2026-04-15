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
 * Servlet for admin moderation actions on flagged guides.
 * POST /admin/moderate-guide
 * Actions: hide, dismiss, unhide
 */
@WebServlet("/admin/moderate-guide")
public class AdminModerateGuideServlet extends HttpServlet {

    private GuideFlagDAO flagDAO = new GuideFlagDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");

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

        String action = request.getParameter("action");
        String guideIdParam = request.getParameter("guideId");

        if (action == null || guideIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/flagged-guides");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(guideIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/flagged-guides");
            return;
        }

        int adminId = currentUser.getUserId();
        String redirectUrl = request.getContextPath() + "/admin/flagged-guides";

        switch (action) {
            case "hide":
                String reason = request.getParameter("reason");
                if (reason == null || reason.trim().isEmpty()) {
                    reason = "Flagged by community and hidden by admin";
                } else {
                    reason = reason.trim();
                    if (reason.length() > 500) {
                        reason = reason.substring(0, 500);
                    }
                }
                flagDAO.hideGuide(guideId, adminId, reason);
                redirectUrl += "?success=hidden";
                break;

            case "dismiss":
                flagDAO.dismissFlags(guideId, adminId);
                redirectUrl += "?success=dismissed";
                break;

            case "unhide":
                flagDAO.unhideGuide(guideId, adminId);
                redirectUrl += "?view=pending&success=unhidden";
                break;

            default:
                break;
        }

        response.sendRedirect(redirectUrl);
    }
}
