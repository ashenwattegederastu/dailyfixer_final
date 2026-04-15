package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * POST /store/markPickedUp
 * Called by the store when the driver physically picks up the package.
 * Transitions assignment ACCEPTED → PICKED_UP and order → OUT_FOR_DELIVERY.
 */
@WebServlet(name = "MarkPickedUpServlet", urlPatterns = {"/store/markPickedUp"})
public class MarkPickedUpServlet extends HttpServlet {

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    private final StoreDAO storeDAO = new StoreDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }
        String role = user.getRole() != null ? user.getRole().trim().toLowerCase() : "";
        if (!"store".equals(role) && !"admin".equals(role)) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String assignmentIdStr = req.getParameter("assignmentId");
        if (assignmentIdStr == null || assignmentIdStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing assignmentId\"}");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);

            // Resolve store for this user
            Store store = storeDAO.getStoreByUsername(user.getUsername());
            if (store == null) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Store not found\"}");
                return;
            }

            boolean ok = assignmentDAO.markPickedUp(assignmentId, store.getStoreId());
            if (ok) {
                // Also get the assignment to update the order status
                // We look up the order ID via a lightweight query
                DeliveryAssignment da = assignmentDAO.getByAssignmentId(assignmentId);
                if (da != null && da.getOrderId() != null) {
                    orderDAO.updateStatus(da.getOrderId(), "OUT_FOR_DELIVERY");
                }
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Could not mark as picked up. Assignment may not belong to your store or driver hasn't accepted yet.\"}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid assignmentId\"}");
        }
    }
}
