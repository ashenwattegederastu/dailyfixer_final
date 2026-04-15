package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.model.BookingNotification;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/user/notifications")
public class UserNotificationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || !"user".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        try {
            BookingNotificationDAO dao = new BookingNotificationDAO();
            // Fetch all first so JSP can distinguish unread vs read
            List<BookingNotification> notifications = dao.getAllByUserId(currentUser.getUserId());
            int unreadCount = (int) notifications.stream().filter(n -> !n.isRead()).count();

            // Mark all as read now that the user is viewing the page
            dao.markAllReadForUser(currentUser.getUserId());

            request.setAttribute("notifications", notifications);
            request.setAttribute("unreadCount", unreadCount);
            request.getRequestDispatcher(
                    "/pages/dashboards/userdash/notifications.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error loading notifications: " + e.getMessage());
        }
    }
}
