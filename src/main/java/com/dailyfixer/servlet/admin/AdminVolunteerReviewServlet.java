package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.VolunteerRequestDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.model.VolunteerRequest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminVolunteerReviewServlet", urlPatterns = { "/admin/volunteer-requests" })
public class AdminVolunteerReviewServlet extends HttpServlet {

    private VolunteerRequestDAO requestDAO = new VolunteerRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Check admin role
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String idParam = req.getParameter("id");

        if (idParam != null && !idParam.isEmpty()) {
            // Detail view
            try {
                int requestId = Integer.parseInt(idParam);
                VolunteerRequest volunteerRequest = requestDAO.getRequestById(requestId);
                if (volunteerRequest == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?error=notfound");
                    return;
                }
                req.setAttribute("volunteerRequest", volunteerRequest);
                req.getRequestDispatcher("/pages/dashboards/admindash/volunteerRequestDetail.jsp").forward(req, resp);
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests");
            }
        } else {
            // List view
            String statusFilter = req.getParameter("status");
            List<VolunteerRequest> requests;
            if (statusFilter != null && !statusFilter.isEmpty()) {
                requests = requestDAO.getRequestsByStatus(statusFilter);
            } else {
                requests = requestDAO.getRequestsByStatus(null);
            }
            req.setAttribute("volunteerRequests", requests);
            req.setAttribute("pendingCount", requestDAO.getPendingCount());
            req.getRequestDispatcher("/pages/dashboards/admindash/volunteerRequests.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Check admin role
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        String requestIdStr = req.getParameter("requestId");

        if (action == null || requestIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?error=invalid");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);

            if ("approve".equals(action)) {
                boolean success = requestDAO.approveRequest(requestId, user.getUserId());
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?success=approved");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?error=approveFailed");
                }
            } else if ("reject".equals(action)) {
                String reason = req.getParameter("rejectionReason");
                boolean success = requestDAO.rejectRequest(requestId, reason != null ? reason.trim() : "",
                        user.getUserId());
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?success=rejected");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?error=rejectFailed");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?error=invalid");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/volunteer-requests?error=invalid");
        }
    }
}
