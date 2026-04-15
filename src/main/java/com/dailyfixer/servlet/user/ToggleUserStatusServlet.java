package com.dailyfixer.servlet.user;

import com.dailyfixer.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/admin/toggleUserStatus")
public class ToggleUserStatusServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String currentStatus = request.getParameter("currentStatus");

        String newStatus = "active".equals(currentStatus) ? "suspended" : "active";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("UPDATE users SET status=? WHERE user_id=?")) {

            ps.setString(1, newStatus);
            ps.setString(2, userId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
