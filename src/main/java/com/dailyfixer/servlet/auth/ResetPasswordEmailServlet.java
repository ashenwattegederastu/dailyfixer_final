package com.dailyfixer.servlet.auth;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.dao.PasswordResetDAO;
import com.dailyfixer.model.PasswordResetToken;
import com.dailyfixer.util.HashUtil;
import java.sql.Timestamp;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/ResetEmailPasswordEmailServlet")
public class ResetPasswordEmailServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate inputs
        if (token == null || token.isEmpty()) {
            request.setAttribute("error", "Invalid reset link. Please request a new password reset.");
            request.getRequestDispatcher("pages/authentication/forgot_password/reset_password.jsp").forward(request, response);
            return;
        }

        if (newPassword == null || newPassword.isEmpty() || confirmPassword == null || confirmPassword.isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("pages/authentication/forgot_password/reset_password.jsp?token=" + token).forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("pages/authentication/forgot_password/reset_password.jsp?token=" + token).forward(request, response);
            return;
        }

        try {
            PasswordResetDAO prDAO = new PasswordResetDAO();
            PasswordResetToken prt = prDAO.getToken(token);

            if (prt == null) {
                request.setAttribute("error", "Invalid reset link. Please request a new password reset.");
                request.getRequestDispatcher("pages/authentication/forgot_password/reset_password.jsp?token=" + token).forward(request, response);
                return;
            }

            if (prt.isUsed()) {
                request.setAttribute("error", "This reset link has already been used. Please request a new password reset.");
                request.getRequestDispatcher("pages/authentication/forgot_password/reset_password.jsp?token=" + token).forward(request, response);
                return;
            }

            if (prt.getExpiry().before(new Timestamp(System.currentTimeMillis()))) {
                request.setAttribute("error", "This reset link has expired. Please request a new password reset.");
                request.getRequestDispatcher("pages/authentication/forgot_password/reset_password.jsp?token=" + token).forward(request, response);
                return;
            }

            // Token is valid, reset the password
            UserDAO userDAO = new UserDAO();
            userDAO.resetPasswordByUserId(prt.getUserId(), newPassword);
            prDAO.markTokenAsUsed(token);

            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp?msg=PasswordUpdated");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while resetting your password. Please try again.");
            request.getRequestDispatcher("pages/authentication/forgot_password/reset_password.jsp?token=" + (token != null ? token : "")).forward(request, response);
        }
    }
}
