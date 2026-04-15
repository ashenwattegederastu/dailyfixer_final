package com.dailyfixer.servlet.service;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/technician/profile")
public class TechnicianProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        int userId = user.getUserId();

        // Get dynamic stats
        ServiceDAO serviceDAO = new ServiceDAO();
        BookingDAO bookingDAO = new BookingDAO();

        int activeListings = serviceDAO.countServicesByTechnician(userId);
        int completedBookings = bookingDAO.countCompletedBookingsByTechnician(userId);

        request.setAttribute("activeListings", activeListings);
        request.setAttribute("completedBookings", completedBookings);

        request.getRequestDispatcher("/pages/dashboards/techniciandash/technicianProfile.jsp")
                .forward(request, response);
    }
}
