package com.dailyfixer.servlet.driver;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.StoreOrderDAO;
import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * POST /driver/markDelivered
 * Marks a PICKED_UP delivery assignment as DELIVERED.
 * The driver_id guard ensures a driver can only mark their own assignments.
 */
@WebServlet(name = "MarkDeliveredServlet", urlPatterns = {"/driver/markDelivered"})
public class MarkDeliveredServlet extends HttpServlet {

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final StoreOrderDAO storeOrderDAO = new StoreOrderDAO();

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
        String deliveryPin = req.getParameter("deliveryPin");
        if (assignmentIdStr == null || assignmentIdStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing assignmentId\"}");
            return;
        }
        if (deliveryPin == null || deliveryPin.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing delivery PIN\"}");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            boolean ok = assignmentDAO.markDelivered(assignmentId, user.getUserId(), deliveryPin.trim());

            if (ok) {
                // Also update the order status to DELIVERED and apply commission
                DeliveryAssignment da = assignmentDAO.getByAssignmentId(assignmentId);
                if (da != null) {
                    orderDAO.updateStatus(da.getOrderId(), "DELIVERED");
                    storeOrderDAO.updateCommission(da.getOrderId());
                }
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Incorrect PIN or delivery cannot be completed. Please verify the PIN with the customer.\"}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid assignmentId\"}");
        }
    }
}
