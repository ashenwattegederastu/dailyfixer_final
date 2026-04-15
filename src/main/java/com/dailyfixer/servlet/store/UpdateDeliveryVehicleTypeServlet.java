package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.DeliveryRateDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * POST /store/updateDeliveryVehicleType
 * Store can change required vehicle type only while assignment is still PENDING
 * and not accepted by any driver.
 */
@WebServlet(name = "UpdateDeliveryVehicleTypeServlet", urlPatterns = {"/store/updateDeliveryVehicleType"})
public class UpdateDeliveryVehicleTypeServlet extends HttpServlet {

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    private final StoreDAO storeDAO = new StoreDAO();
    private final DeliveryRateDAO deliveryRateDAO = new DeliveryRateDAO();

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
        String vehicleType = req.getParameter("vehicleType");

        if (assignmentIdStr == null || assignmentIdStr.isBlank() || vehicleType == null || vehicleType.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing assignmentId or vehicleType\"}");
            return;
        }

        List<String> activeVehicleTypes = deliveryRateDAO.getActiveVehicleTypes();
        boolean validType = activeVehicleTypes.stream().anyMatch(v -> v.equalsIgnoreCase(vehicleType));
        if (!validType) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Vehicle type is not active\"}");
            return;
        }

        Store store = storeDAO.getStoreByUsername(user.getUsername());
        if (store == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Store not found\"}");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            boolean updated = assignmentDAO.updateVehicleTypeIfPending(
                assignmentId,
                store.getStoreId(),
                vehicleType.trim()
            );

            if (updated) {
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Cannot update vehicle type. Assignment may already be accepted by a driver.\"}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid assignmentId\"}");
        }
    }
}
