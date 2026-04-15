package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/user/dashboard")
public class UserDashboardServlet extends HttpServlet {

    private BookingDAO bookingDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        this.bookingDAO = new BookingDAO();
        this.orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("currentUser");

        try {
            // Bookings
            List<Booking> allBookings = bookingDAO.getBookingsByUserId(user.getUserId());
            int totalBookings = allBookings.size();
            long activeBookings = allBookings.stream()
                .filter(b -> b.getStatus() != null && (b.getStatus().equals("REQUESTED") || b.getStatus().equals("ACCEPTED") || b.getStatus().equals("TECHNICIAN_COMPLETED")))
                .count();
            long completedBookings = allBookings.stream()
                .filter(b -> b.getStatus() != null && b.getStatus().equals("FULLY_COMPLETED"))
                .count();

            // Orders
            List<Order> allOrders = orderDAO.getOrdersByBuyerId(user.getUserId());
            int totalPurchases = allOrders.size();
            long pendingDeliveries = allOrders.stream()
                .filter(o -> o.getStatus() != null && (o.getStatus().equals("PAID") || o.getStatus().equals("PENDING") || o.getStatus().equals("PROCESSING") || o.getStatus().equals("OUT_FOR_DELIVERY")))
                .count();
            BigDecimal totalSpent = allOrders.stream()
                .map(Order::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Recent activity lists (max 5)
            List<Booking> recentBookings = allBookings.stream().limit(5).collect(Collectors.toList());
            List<Order> recentOrders = allOrders.stream().limit(5).collect(Collectors.toList());

            // Set attributes
            request.setAttribute("totalBookings", totalBookings);
            request.setAttribute("activeBookings", activeBookings);
            request.setAttribute("completedBookings", completedBookings);
            request.setAttribute("totalPurchases", totalPurchases);
            request.setAttribute("pendingDeliveries", pendingDeliveries);
            request.setAttribute("totalSpent", totalSpent);
            
            request.setAttribute("recentBookings", recentBookings);
            request.setAttribute("recentOrders", recentOrders);

            request.getRequestDispatcher("/pages/dashboards/userdash/userdashmain.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading dashboard data.");
        }
    }
}
