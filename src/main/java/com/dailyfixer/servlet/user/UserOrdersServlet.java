package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.DeliveryDropProofDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.model.DeliveryDropProof;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.OrderItem;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.User;
import com.dailyfixer.model.Store;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * UserOrdersServlet - Handles fetching orders for the logged-in user.
 * Redirects to myPurchases.jsp with the user's orders.
 *
 * URL: /user/orders
 * Method: GET
 */
@WebServlet("/user/orders")
public class UserOrdersServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private DeliveryAssignmentDAO assignmentDAO;
    private DeliveryDropProofDAO dropProofDAO;
    private StoreDAO storeDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
        assignmentDAO = new DeliveryAssignmentDAO();
        dropProofDAO = new DeliveryDropProofDAO();
        storeDAO = new StoreDAO();
        userDAO = new UserDAO();
        System.out.println("UserOrdersServlet initialized");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Check if user is logged in
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        // Check if the user has the correct role
        String role = currentUser.getRole();
        if (role == null || !"user".equalsIgnoreCase(role.trim())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        try {
            // Get orders for the logged-in user
            List<Order> orders = orderDAO.getOrdersByBuyerId(currentUser.getUserId());
            System.out.println("Found " + orders.size() + " orders for user ID: " + currentUser.getUserId());

            // Get order items for each order
            Map<String, List<OrderItem>> orderItemsMap = new HashMap<>();
            Map<Integer, Product> productsMap = new HashMap<>();

            for (Order order : orders) {
                List<OrderItem> items = orderDAO.getOrderItemsByOrderId(order.getOrderId());
                orderItemsMap.put(order.getOrderId(), items);

                // Fetch product details for each item to get images
                for (OrderItem item : items) {
                    if (!productsMap.containsKey(item.getProductId())) {
                        try {
                            Product product = productDAO.getProductById(item.getProductId());
                            if (product != null) {
                                productsMap.put(item.getProductId(), product);
                            }
                        } catch (Exception e) {
                            System.err
                                    .println("Could not fetch product " + item.getProductId() + ": " + e.getMessage());
                        }
                    }
                }
            }

            // One "Write Review" per product (duplicate order_item rows would duplicate buttons)
            Map<String, List<OrderItem>> orderItemsForReviewMap = new HashMap<>();
            for (Map.Entry<String, List<OrderItem>> entry : orderItemsMap.entrySet()) {
                List<OrderItem> raw = entry.getValue();
                if (raw == null || raw.isEmpty()) {
                    orderItemsForReviewMap.put(entry.getKey(), new ArrayList<>());
                    continue;
                }
                Set<Integer> seenProductIds = new HashSet<>();
                List<OrderItem> deduped = new ArrayList<>();
                for (OrderItem oi : raw) {
                    if (seenProductIds.add(oi.getProductId())) {
                        deduped.add(oi);
                    }
                }
                orderItemsForReviewMap.put(entry.getKey(), deduped);
            }

            // Build a map of orderId → delivery PIN for active delivery orders
            Map<String, String> deliveryPinMap = new HashMap<>();
            Map<String, Map<String, String>> storeDetailsMap = new HashMap<>();
            Map<String, Map<String, String>> driverDetailsMap = new HashMap<>();
            Map<String, Map<String, String>> deliveryProofMap = new HashMap<>();
            
            for (Order order : orders) {
                String status = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "";
                if ("STORE_ACCEPTED".equals(status) || "OUT_FOR_DELIVERY".equals(status)) {
                    DeliveryAssignment da = assignmentDAO.getByOrderId(order.getOrderId());
                    if (da != null && da.getDeliveryPin() != null) {
                        deliveryPinMap.put(order.getOrderId(), da.getDeliveryPin());
                    }
                }

                DeliveryAssignment assignment = assignmentDAO.getByOrderId(order.getOrderId());
                if (assignment != null) {
                    if (assignment.getDriverId() != null) {
                        User driver = userDAO.getUserById(assignment.getDriverId());
                        if (driver != null) {
                            Map<String, String> driverDetails = new HashMap<>();
                            String driverName = (driver.getFirstName() != null ? driver.getFirstName() : "")
                                    + (driver.getLastName() != null && !driver.getLastName().isBlank()
                                    ? " " + driver.getLastName() : "");
                            driverDetails.put("name", driverName.isBlank() ? "Delivery Driver" : driverName.trim());
                            driverDetails.put("phone", driver.getPhoneNumber() != null ? driver.getPhoneNumber() : "No phone");
                            driverDetails.put("picture", driver.getProfilePicturePath() != null ? driver.getProfilePicturePath() : "");
                            driverDetails.put("completionMethod", assignment.getCompletionMethod() != null ? assignment.getCompletionMethod() : "");
                            driverDetailsMap.put(order.getOrderId(), driverDetails);
                        }
                    }

                    DeliveryDropProof proof = dropProofDAO.getByOrderId(order.getOrderId());
                    if (proof != null) {
                        Map<String, String> proofDetails = new HashMap<>();
                        proofDetails.put("photoPackage", proof.getPhotoPackagePath() != null ? proof.getPhotoPackagePath() : "");
                        proofDetails.put("photoDoor", proof.getPhotoDoorContextPath() != null ? proof.getPhotoDoorContextPath() : "");
                        proofDetails.put("note", proof.getNote() != null ? proof.getNote() : "");
                        deliveryProofMap.put(order.getOrderId(), proofDetails);
                    }
                }

                // Fetch store details for the order
                if (order.getStoreUsername() != null && !order.getStoreUsername().isEmpty()) {
                    Store store = storeDAO.getStoreByUsername(order.getStoreUsername());
                    if (store != null) {
                        User storeOwner = userDAO.getUserById(store.getUserId());
                        if (storeOwner != null) {
                            Map<String, String> details = new HashMap<>();
                            details.put("storeName", store.getStoreName() != null ? store.getStoreName() : "Unknown Store");
                            details.put("email", storeOwner.getEmail() != null ? storeOwner.getEmail() : "No email");
                            details.put("phone", storeOwner.getPhoneNumber() != null ? storeOwner.getPhoneNumber() : "No phone");
                            details.put("address", (store.getStoreAddress() != null ? store.getStoreAddress() : "") + 
                                       (store.getStoreCity() != null ? ", " + store.getStoreCity() : ""));
                            storeDetailsMap.put(order.getOrderId(), details);
                        }
                    }
                }
            }

            // Set attributes for the JSP
            request.setAttribute("orders", orders);
            request.setAttribute("orderItemsMap", orderItemsMap);
            request.setAttribute("orderItemsForReviewMap", orderItemsForReviewMap);
            request.setAttribute("productsMap", productsMap);
            request.setAttribute("deliveryPinMap", deliveryPinMap);
            request.setAttribute("storeDetailsMap", storeDetailsMap);
            request.setAttribute("driverDetailsMap", driverDetailsMap);
            request.setAttribute("deliveryProofMap", deliveryProofMap);

            // Forward to myPurchases.jsp
            request.getRequestDispatcher("/pages/dashboards/userdash/myPurchases.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error fetching user orders: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Failed to load orders");
            request.setAttribute("orderItemsForReviewMap", new HashMap<String, List<OrderItem>>());
            request.getRequestDispatcher("/pages/dashboards/userdash/myPurchases.jsp").forward(request, response);
        }
    }
}
