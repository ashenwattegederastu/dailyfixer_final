package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.AdminDashboardDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AdminMainDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminMainDashboardServlet extends HttpServlet {

    private AdminDashboardDAO dao;

    @Override
    public void init() throws ServletException {
        super.init();
        dao = new AdminDashboardDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;
        if (user == null || user.getRole() == null
                || !"admin".equalsIgnoreCase(user.getRole().trim())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        // ── KPI cards ──
        req.setAttribute("totalUsers",              dao.getTotalUsers());
        req.setAttribute("activeUsers",             dao.getActiveUsers());
        req.setAttribute("suspendedUsers",          dao.getSuspendedUsers());
        req.setAttribute("ordersLast24h",           dao.getOrdersLast24h());
        req.setAttribute("revenueLast24h",          dao.getRevenueLast24h());
        req.setAttribute("totalBookings",           dao.getTotalBookings());
        req.setAttribute("activeBookings",          dao.getActiveBookings());
        req.setAttribute("totalGuides",             dao.getTotalGuides());
        req.setAttribute("totalDiagnosticTrees",    dao.getTotalDiagnosticTrees());
        req.setAttribute("totalStores",             dao.getTotalRegisteredStores());
        req.setAttribute("totalProducts",           dao.getTotalProductsListed());

        // ── Action-needed badges ──
        req.setAttribute("pendingRefunds",          dao.getPendingRefunds());
        req.setAttribute("pendingVolunteers",       dao.getPendingVolunteerRequests());
        req.setAttribute("flaggedGuides",           dao.getFlaggedGuidesCount());

        // ── Chart data (maps are serialised to JSON in JSP) ──
        int days = 30;
        String daysParam = req.getParameter("days");
        if (daysParam != null) {
            try { days = Integer.parseInt(daysParam); } catch (NumberFormatException ignored) {}
            if (days < 1 || days > 365) days = 7;
        }
        req.setAttribute("days", days);

        req.setAttribute("ordersPerDay",   dao.getOrdersPerDay(days));
        req.setAttribute("revenuePerDay",  dao.getRevenuePerDay(days));
        req.setAttribute("newUsersPerDay", dao.getNewUsersPerDay(days));
        req.setAttribute("bookingsPerDay", dao.getBookingsPerDay(days));

        // ── Breakdown maps ──
        req.setAttribute("usersByRole",       dao.getUserCountsByRole());
        req.setAttribute("ordersByStatus",    dao.getOrderCountsByStatus());

        req.getRequestDispatcher("/pages/dashboards/admindash/admindashmain.jsp")
           .forward(req, resp);
    }
}
