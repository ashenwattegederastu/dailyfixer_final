package com.dailyfixer.servlet.driver;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.DeliveryAssignmentDAO.AcceptResult;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * POST /driver/acceptDelivery
 * Atomically claims a PENDING delivery assignment for the logged-in driver.
 * Race condition safe: uses UPDATE WHERE status='PENDING' — only the first
 * driver to write gets rowsAffected=1 (SUCCESS); others get ALREADY_TAKEN.
 */
@WebServlet(name = "AcceptDeliveryServlet", urlPatterns = {"/driver/acceptDelivery"})
public class AcceptDeliveryServlet extends HttpServlet {

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

        if ("suspended".equalsIgnoreCase(user.getStatus())) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Your account is suspended.\"}");
            return;
        }

        String assignmentIdStr = req.getParameter("assignmentId");
        if (assignmentIdStr == null || assignmentIdStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing assignmentId\"}");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            AcceptResult result = assignmentDAO.acceptAssignment(assignmentId, user.getUserId());

            switch (result) {
                case SUCCESS:
                    resp.getWriter().write("{\"success\":true}");
                    break;
                case ALREADY_TAKEN:
                    resp.getWriter().write("{\"success\":false,\"message\":\"This delivery has already been taken by another driver.\"}");
                    break;
                case LIMIT_REACHED:
                    resp.getWriter().write("{\"success\":false,\"message\":\"You have reached your maximum simultaneous order limit for your vehicle type.\"}");
                    break;
                default:
                    resp.getWriter().write("{\"success\":false,\"message\":\"Database error. Please try again.\"}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid assignmentId\"}");
        }
    }
}
