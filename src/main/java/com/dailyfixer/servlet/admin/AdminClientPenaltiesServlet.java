package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.dao.ClientNoShowPenaltyDAO;
import com.dailyfixer.model.ClientNoShowPenalty;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Handles the admin Client Penalties panel.
 *
 * GET  /admin/client-penalties  → display all ADMIN_REVIEW penalties
 * POST /admin/client-penalty-action  → mark paid or suspend client for fraud
 */
@WebServlet(name = "AdminClientPenaltiesServlet",
            urlPatterns = {"/admin/client-penalties", "/admin/client-penalty-action"})
public class AdminClientPenaltiesServlet extends HttpServlet {

    private final ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();
    private final BookingNotificationDAO notifDAO   = new BookingNotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        List<ClientNoShowPenalty> pendingCases = null;
        try {
            pendingCases = penaltyDAO.getAllForAdminReview();
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("pendingCases", pendingCases);
        req.getRequestDispatcher(
                "/pages/dashboards/admindash/clientPenalties.jsp"
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
            String action       = req.getParameter("action");

            if (penaltyIdStr == null || action == null) {
                out.print("{\"success\":false,\"message\":\"Missing parameters\"}");
                return;
            }

            int penaltyId = Integer.parseInt(penaltyIdStr.trim());
            ClientNoShowPenalty penalty = penaltyDAO.getByPenaltyId(penaltyId);

            if (penalty == null) {
                out.print("{\"success\":false,\"message\":\"Penalty not found\"}");
                return;
            }

            if (!"ADMIN_REVIEW".equals(penalty.getStatus())) {
                out.print("{\"success\":false,\"message\":\"Penalty is not in ADMIN_REVIEW status\"}");
                return;
            }

            switch (action) {
                case "markPaid":
                    penaltyDAO.adminMarkPaid(penaltyId, user.getUserId());
                    // Notify both parties
                    notifDAO.createNotification(
                            penalty.getClientId(),
                            penalty.getBookingId(),
                            "Admin has confirmed your payment for booking #" + penalty.getBookingId()
                            + " no-show penalty. The case is now resolved.");
                    notifDAO.createNotification(
                            penalty.getTechnicianId(),
                            penalty.getBookingId(),
                            "Admin has resolved the client no-show penalty for booking #"
                            + penalty.getBookingId() + " as paid.");
                    out.print("{\"success\":true,\"action\":\"markPaid\"}");
                    break;

                case "suspendClient":
                    penaltyDAO.adminSuspendClientForFraud(penaltyId, user.getUserId());
                    notifDAO.createNotification(
                            penalty.getClientId(),
                            penalty.getBookingId(),
                            "Your account has been suspended due to fraudulent payment proof submission "
                            + "for booking #" + penalty.getBookingId()
                            + ". Please contact DailyFixer support to appeal.");
                    notifDAO.createNotification(
                            penalty.getTechnicianId(),
                            penalty.getBookingId(),
                            "The client for booking #" + penalty.getBookingId()
                            + " has been suspended by admin for submitting fraudulent payment proof.");
                    out.print("{\"success\":true,\"action\":\"suspendClient\"}");
                    break;

                default:
                    out.print("{\"success\":false,\"message\":\"Unknown action\"}");
            }

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
