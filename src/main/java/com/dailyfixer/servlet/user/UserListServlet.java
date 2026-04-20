package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/users")
public class UserListServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String search = request.getParameter("search");
        List<User> users;

        try {
            if (search != null && !search.trim().isEmpty()) {
                users = userDAO.searchUsers(search.trim());
            } else {
                users = userDAO.getAllUsers();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching users");
            return;
        }

        request.setAttribute("users", users);
        request.setAttribute("searchTerm", search != null ? search : "");
        request.getRequestDispatcher("/pages/dashboards/admindash/userManagement.jsp")
               .forward(request, response);
    }
}
