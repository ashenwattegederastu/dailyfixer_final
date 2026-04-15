package com.dailyfixer.servlet.driver;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Set;

/**
 * POST /driver/cancelAccepted
 * Driver can voluntarily release an ACCEPTED assignment back to the pending pool
 * before pickup. This path is explicitly no-penalty.
 */
@WebServlet(name = "CancelAcceptedDeliveryServlet", urlPatterns = {"/driver/cancelAccepted"})
public class CancelAcceptedDeliveryServlet extends HttpServlet {

    private static final Set<String> ALLOWED_REASONS = Set.of(
        "NOT_ENOUGH_SPACE",
        "EMERGENCY",
        "VEHICLE_ISSUE",
        "OTHER"
    );

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String assignmentIdStr = req.getParameter("assignmentId");
        String reasonCode = req.getParameter("reasonCode");
        String reasonNote = req.getParameter("reasonNote");

        if (assignmentIdStr == null || assignmentIdStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing assignmentId\"}");
            return;
        }

        if (reasonCode == null || reasonCode.isBlank() || !ALLOWED_REASONS.contains(reasonCode)) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid cancellation reason\"}");
            return;
        }

        if (reasonNote != null && reasonNote.length() > 400) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Reason note is too long\"}");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            boolean ok = assignmentDAO.releaseAcceptedByDriver(
                assignmentId,
                user.getUserId(),
                reasonCode,
                reasonNote
            );

            if (ok) {
                resp.getWriter().write("{\"success\":true,\"message\":\"Order returned to delivery pool\"}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Unable to cancel. Order may already be picked up or reassigned.\"}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid assignmentId\"}");
        }
    }
}
