package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/toggleUserStatus")
public class ToggleUserStatusServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdParam = request.getParameter("userId");
        String currentStatus = request.getParameter("currentStatus");
        String search = request.getParameter("search");

        String newStatus = "active".equals(currentStatus) ? "suspended" : "active";

        try {
            int userId = Integer.parseInt(userIdParam);
            userDAO.updateUserStatus(userId, newStatus);
        } catch (Exception e) {
            e.printStackTrace();
        }

        String redirect = request.getContextPath() + "/admin/users";
        if (search != null && !search.trim().isEmpty()) {
            redirect += "?search=" + URLEncoder.encode(search.trim(), "UTF-8");
        }
        response.sendRedirect(redirect);
    }
}
