package com.dailyfixer.servlet.auth;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.util.HashUtil;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "RegisterUserServlet", urlPatterns = {"/registerUser"})
public class RegisterUserServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String phone = req.getParameter("phone");
        String city = req.getParameter("city");

        StringBuilder errors = new StringBuilder();
        if (firstName == null || firstName.trim().isEmpty()) errors.append("First name is required.<br>");
        if (lastName == null || lastName.trim().isEmpty()) errors.append("Last name is required.<br>");
        if (username == null || username.trim().isEmpty()) errors.append("Username is required.<br>");
        if (email == null || email.trim().isEmpty()) errors.append("Email is required.<br>");
        if (password == null || password.trim().isEmpty()) errors.append("Password is required.<br>");
        if (password != null && !password.equals(confirmPassword)) errors.append("Passwords do not match.<br>");

        try {
            if (username != null && userDAO.isUsernameTaken(username)) errors.append("Username already taken.<br>");
            if (email != null && userDAO.isEmailTaken(email)) errors.append("Email already registered.<br>");

            if (errors.length() > 0) {
                req.setAttribute("errorMsg", errors.toString());
                req.getRequestDispatcher("pages/authentication/register/registerUser.jsp").forward(req, resp);
                return;
            }

            User user = new User();
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setUsername(username);
            user.setEmail(email);
            user.setPassword(HashUtil.sha256(password));
            user.setPhoneNumber(phone);
            user.setCity(city);

            userDAO.saveUser(user);

            HttpSession session = req.getSession();
            session.setAttribute("successMsg", "Registration successful. Please log in.");
            resp.sendRedirect("pages/authentication/login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "Server error: " + e.getMessage());
            req.getRequestDispatcher("pages/authentication/register/registerUser.jsp").forward(req, resp);
        }
    }
}
