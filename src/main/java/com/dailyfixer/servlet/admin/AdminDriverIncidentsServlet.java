package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.DriverIncidentDAO;
import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.DriverIncident;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "AdminDriverIncidentsServlet", urlPatterns = {"/admin/driver-incidents", "/admin/suspend-driver", "/admin/review-incident"})
public class AdminDriverIncidentsServlet extends HttpServlet {

    private final DriverIncidentDAO incidentDAO = new DriverIncidentDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        List<DriverIncident> incidentsSummary = incidentDAO.getDriverIncidentSummary();
        req.setAttribute("incidentsSummary", incidentsSummary);
        List<DriverIncident> allIncidents = incidentDAO.getAllIncidents();
        req.setAttribute("allIncidents", allIncidents);
        req.getRequestDispatcher("/pages/dashboards/admindash/driverIncidents.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = req.getServletPath();
        if ("/admin/suspend-driver".equals(path)) {
            handleSuspendDriver(req, resp);
        } else if ("/admin/review-incident".equals(path)) {
            handleReviewIncident(req, resp);
        }
    }

    private void handleSuspendDriver(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        String driverIdStr = req.getParameter("driverId");
        String action = req.getParameter("action"); // "suspend" or "activate"

        if (driverIdStr == null || driverIdStr.trim().isEmpty() || action == null) {
            out.print("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        try {
            int driverId = Integer.parseInt(driverIdStr);
            String targetStatus = "suspend".equals(action) ? "suspended" : "active";

            boolean updated = userDAO.updateUserStatus(driverId, targetStatus);
            if (updated) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to update driver status.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Server error.\"}");
        } finally {
            out.close();
        }
    }

    private boolean isAdmin(User user) {
        return user != null && user.getRole() != null && "admin".equalsIgnoreCase(user.getRole().trim());
    }

    private void handleReviewIncident(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        String incidentIdStr = req.getParameter("incidentId");
        String notes = req.getParameter("notes");
        User admin = (User) req.getSession().getAttribute("currentUser");

        if (incidentIdStr == null || incidentIdStr.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Missing incidentId\"}");
            return;
        }

        try {
            int incidentId = Integer.parseInt(incidentIdStr);
            boolean updated = incidentDAO.markReviewed(incidentId, admin.getUserId(),
                    notes != null ? notes.trim() : null);
            if (updated) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Incident not found or already reviewed.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Server error.\"}");
        } finally {
            out.close();
        }
    }
}