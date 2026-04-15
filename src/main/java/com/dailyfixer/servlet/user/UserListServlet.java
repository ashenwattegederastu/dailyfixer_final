package com.dailyfixer.servlet.user;

import com.dailyfixer.model.User;
import com.dailyfixer.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/admin/users")
public class UserListServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM users ORDER BY user_id DESC")) {

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFirstName(rs.getString("first_name"));
                u.setLastName(rs.getString("last_name"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setPhoneNumber(rs.getString("phone_number"));
                u.setCity(rs.getString("city"));
                u.setRole(rs.getString("role"));
                u.setStatus(rs.getString("status"));
                users.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("users", users);
        RequestDispatcher rd = request.getRequestDispatcher("/pages/dashboards/admindash/userManagement.jsp");

//        RequestDispatcher rd = request.getRequestDispatcher(request.getContextPath() + "pages/dashboards/admindash/user_management.jsp");
        rd.forward(request, response);
    }
}
