package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.TechnicianPenaltyDAO;
import com.dailyfixer.model.TechnicianPenalty;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "AdminTechnicianPenaltiesServlet",
            urlPatterns = {"/admin/technician-penalties", "/admin/lift-technician-penalty"})
public class AdminTechnicianPenaltiesServlet extends HttpServlet {

    private final TechnicianPenaltyDAO penaltyDAO = new TechnicianPenaltyDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        List<TechnicianPenalty> activePenalties = null;
        try {
            activePenalties = penaltyDAO.getAllActivePenalties();
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("activePenalties", activePenalties);
        req.getRequestDispatcher(
                "/pages/dashboards/admindash/technicianPenalties.jsp"
        ).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        try {
            String penaltyIdStr = req.getParameter("penaltyId");
            if (penaltyIdStr == null || penaltyIdStr.trim().isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Missing penaltyId\"}");
                return;
            }
            int penaltyId = Integer.parseInt(penaltyIdStr.trim());
            penaltyDAO.liftPenalty(penaltyId, user.getUserId());
            out.print("{\"success\":true}");
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"Invalid penaltyId\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Server error: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            out.close();
        }
    }

    private boolean isAdmin(User user) {
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }
}
