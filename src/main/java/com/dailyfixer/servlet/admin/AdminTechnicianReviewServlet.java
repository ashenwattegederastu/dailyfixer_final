package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.TechnicianRequestDAO;
import com.dailyfixer.model.TechnicianRequest;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminTechnicianReviewServlet", urlPatterns = {"/admin/technician-requests"})
public class AdminTechnicianReviewServlet extends HttpServlet {

    private TechnicianRequestDAO requestDAO = new TechnicianRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp"); return; }
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp"); return;
        }

        String idParam = req.getParameter("id");

        if (idParam != null && !idParam.isEmpty()) {
            // Detail view
            try {
                int requestId = Integer.parseInt(idParam);
                TechnicianRequest techRequest = requestDAO.getRequestById(requestId);
                if (techRequest == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/technician-requests?error=notfound"); return;
                }
                req.setAttribute("techRequest", techRequest);
                req.getRequestDispatcher("/pages/dashboards/admindash/technicianRequestDetail.jsp").forward(req, resp);
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/admin/technician-requests");
            }
        } else {
            // List view
            String statusFilter = req.getParameter("status");
            List<TechnicianRequest> requests = requestDAO.getRequestsByStatus(statusFilter);
            req.setAttribute("techRequests", requests);
            req.setAttribute("pendingCount", requestDAO.getPendingCount());
            req.getRequestDispatcher("/pages/dashboards/admindash/technicianRequests.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp"); return; }
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp"); return;
        }

        String action = req.getParameter("action");
        String requestIdStr = req.getParameter("requestId");

        if (action == null || requestIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/technician-requests?error=invalid"); return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);

            if ("approve".equals(action)) {
                boolean success = requestDAO.approveRequest(requestId, user.getUserId());
                resp.sendRedirect(req.getContextPath() + "/admin/technician-requests?"
                        + (success ? "success=approved" : "error=approveFailed"));
            } else if ("reject".equals(action)) {
                String reason = req.getParameter("rejectionReason");
                boolean success = requestDAO.rejectRequest(requestId, reason != null ? reason.trim() : "", user.getUserId());
                resp.sendRedirect(req.getContextPath() + "/admin/technician-requests?"
                        + (success ? "success=rejected" : "error=rejectFailed"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/technician-requests?error=invalid");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/technician-requests?error=invalid");
        }
    }
}
