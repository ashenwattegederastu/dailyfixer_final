package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.model.BookingNotification;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * GET  /bookings/notifications        – returns unread notifications as JSON
 * POST /bookings/notifications/markread – marks all unread as read for the current user
 */
@WebServlet(urlPatterns = {"/bookings/notifications", "/bookings/notifications/markread"})
public class BookingNotificationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getUser(request, response);
        if (currentUser == null) return;

        try {
            BookingNotificationDAO dao = new BookingNotificationDAO();
            List<BookingNotification> notifications = dao.getUnreadByUserId(currentUser.getUserId());
            int unreadCount = notifications.size();

            // Build simple JSON array
            response.setContentType("application/json;charset=UTF-8");
            StringBuilder json = new StringBuilder();
            json.append("{\"unread\":").append(unreadCount).append(",\"notifications\":[");
            for (int i = 0; i < notifications.size(); i++) {
                BookingNotification n = notifications.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(n.getNotificationId()).append(",");
                json.append("\"bookingId\":").append(n.getBookingId()).append(",");
                json.append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",");
                json.append("\"createdAt\":\"").append(n.getCreatedAt()).append("\"");
                json.append("}");
            }
            json.append("]}");
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching notifications");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getUser(request, response);
        if (currentUser == null) return;

        try {
            BookingNotificationDAO dao = new BookingNotificationDAO();
            dao.markAllReadForUser(currentUser.getUserId());
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"ok\":true}");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error marking notifications read");
        }
    }

    private User getUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return null;
        }
        User u = (User) session.getAttribute("currentUser");
        if (u == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return null;
        }
        return u;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
