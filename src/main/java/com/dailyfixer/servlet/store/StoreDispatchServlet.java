package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.security.SecureRandom;

/**
 * POST /store/dispatch
 * Called when a store marks an order as "Ready to Deliver" and selects a vehicle type.
 * Creates a delivery_assignment record and updates order status to STORE_ACCEPTED.
 */
@WebServlet(name = "StoreDispatchServlet", urlPatterns = {"/store/dispatch"})
public class StoreDispatchServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final StoreDAO storeDAO = new StoreDAO();
    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        // Auth guard
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

        String orderId = req.getParameter("orderId");
        String vehicleType = req.getParameter("vehicleType");

        if (orderId == null || orderId.isBlank() || vehicleType == null || vehicleType.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing orderId or vehicleType\"}");
            return;
        }

        try {
            // Load order
            Order order = orderDAO.findOrderById(orderId);
            if (order == null) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Order not found\"}");
                return;
            }

            // Check order already dispatched
            String currentStatus = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "";
            if ("STORE_ACCEPTED".equals(currentStatus)) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Order already dispatched\"}");
                return;
            }

            // Load store for pickup address
            Integer storeId = order.getStoreId();
            Store store = storeId != null && storeId > 0 ? storeDAO.getStoreById(storeId) : null;

            // Build delivery assignment
            DeliveryAssignment assignment = new DeliveryAssignment();
            assignment.setOrderId(orderId);
            assignment.setStoreId(storeId != null ? storeId : 0);
            assignment.setRequiredVehicleType(vehicleType);
            assignment.setDeliveryFeeEarned(
                order.getDeliveryFee() != null ? order.getDeliveryFee() : BigDecimal.ZERO
            );

            // Pickup address = store address + city
            if (store != null) {
                String pickupAddr = store.getStoreAddress() != null ? store.getStoreAddress() : "";
                if (store.getStoreCity() != null && !store.getStoreCity().isBlank()) {
                    pickupAddr = pickupAddr.isBlank() ? store.getStoreCity()
                                                      : pickupAddr + ", " + store.getStoreCity();
                }
                assignment.setPickupAddress(pickupAddr);
            }

            // Delivery address = order address + city
            String addr = order.getAddress() != null ? order.getAddress() : "";
            String city = order.getCity() != null ? order.getCity() : "";
            String deliveryAddr = addr.isBlank() ? city : (city.isBlank() ? addr : addr + ", " + city);
            assignment.setDeliveryAddress(deliveryAddr);

            // Delivery coordinates from order
            assignment.setDeliveryLat(order.getDeliveryLatitude());
            assignment.setDeliveryLng(order.getDeliveryLongitude());

            // Generate 6-digit delivery PIN for buyer verification
            String pin = String.format("%06d", secureRandom.nextInt(1_000_000));
            assignment.setDeliveryPin(pin);

            // Persist assignment
            boolean created = assignmentDAO.createAssignment(assignment);
            if (!created) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Failed to create delivery assignment\"}");
                return;
            }

            // Update order status
            orderDAO.updateStatus(orderId, "STORE_ACCEPTED");

            resp.getWriter().write("{\"success\":true}");

        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown error";
            resp.getWriter().write("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }
}
