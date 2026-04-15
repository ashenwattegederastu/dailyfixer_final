package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "SoftDeleteUserServlet", urlPatterns = {"/SoftDeleteUserServlet"})
public class SoftDeleteUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        int userId = user.getUserId();
        UserDAO userDAO = new UserDAO();
        boolean success = userDAO.softDeleteUser(userId);

        if (success) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp?deleted=true");
        } else {
            response.getWriter().println(
                "<script>alert('Account deletion failed. Please try again.');history.back();</script>"
            );
        }
    }
}
