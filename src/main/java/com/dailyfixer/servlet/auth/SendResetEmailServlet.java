package com.dailyfixer.servlet.auth;

import com.dailyfixer.dao.PasswordResetDAO;
import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Timestamp;
import java.security.SecureRandom;
import java.math.BigInteger;

@WebServlet("/SendResetEmailServlet")
public class SendResetEmailServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();

    // Generate a secure random token
    private String generateToken() {
        SecureRandom random = new SecureRandom();
        return new BigInteger(130, random).toString(32); // 32-character random string
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        try {
            User user = userDAO.getUserByEmail(email);

            if (user != null) {
                // Generate token
                String token = generateToken();
                Timestamp expiry = new Timestamp(System.currentTimeMillis() + 30 * 60 * 1000); // 30 mins

                // Save token
                resetDAO.saveToken(user.getUserId(), token, expiry);

                // Build reset link dynamically
                String resetLink = request.getScheme() + "://" +
                        request.getServerName() + ":" +
                        request.getServerPort() +
                        request.getContextPath() +
                        "/pages/authentication/forgot_password/reset_password.jsp?token=" + token;

                // Email content (HTML)
                String htmlMessage = "<html><body>"
                        + "<p>Hi " + user.getUsername() + ",</p>"
                        + "<p>We received a request to reset your DailyFixer password.</p>"
                        + "<p><a href='" + resetLink + "' "
                        + "style='padding:10px 20px; background-color:#4CAF50; color:white; text-decoration:none; border-radius:5px;'>"
                        + "Reset Password</a></p>"
                        + "<p>This link will expire in 30 minutes.</p>"
                        + "<p>If you did not request this, ignore this email.</p>"
                        + "<p>Thanks,<br>DailyFixer Team</p>"
                        + "</body></html>";

                // Send email
                EmailUtil.sendEmail(email, "DailyFixer Password Reset", htmlMessage);
            }

            // Security: always show the same message
            request.setAttribute("message", "If the email exists, a password reset link has been sent.");
            request.getRequestDispatcher("pages/authentication/forgot_password/forgot_password.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Server error: " + e.getMessage());
            request.getRequestDispatcher("pages/authentication/forgot_password/forgot_password.jsp").forward(request, response);
        }
    }
}
