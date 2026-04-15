package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.DriverRequestDAO;
import com.dailyfixer.model.DriverRequest;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminDriverReviewServlet", urlPatterns = {"/admin/driver-requests"})
public class AdminDriverReviewServlet extends HttpServlet {

    private DriverRequestDAO requestDAO = new DriverRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
                DriverRequest driverRequest = requestDAO.getRequestById(requestId);
                if (driverRequest == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?error=notfound");
                    return;
                }
                req.setAttribute("driverRequest", driverRequest);
                req.getRequestDispatcher("/pages/dashboards/admindash/driverRequestDetail.jsp").forward(req, resp);
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/admin/driver-requests");
            }
        } else {
            // List view
            String statusFilter = req.getParameter("status");
            List<DriverRequest> requests;
            if (statusFilter != null && !statusFilter.isEmpty()) {
                requests = requestDAO.getRequestsByStatus(statusFilter);
            } else {
                requests = requestDAO.getRequestsByStatus(null);
            }
            req.setAttribute("driverRequests", requests);
            req.setAttribute("pendingCount", requestDAO.getPendingCount());
            req.getRequestDispatcher("/pages/dashboards/admindash/driverRequests.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
            resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?error=invalid");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);

            if ("approve".equals(action)) {
                boolean success = requestDAO.approveRequest(requestId, user.getUserId());
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?success=approved");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?error=approveFailed");
                }
            } else if ("reject".equals(action)) {
                String reason = req.getParameter("rejectionReason");
                boolean success = requestDAO.rejectRequest(requestId, reason != null ? reason.trim() : "", user.getUserId());
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?success=rejected");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?error=rejectFailed");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?error=invalid");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/driver-requests?error=invalid");
        }
    }
}
