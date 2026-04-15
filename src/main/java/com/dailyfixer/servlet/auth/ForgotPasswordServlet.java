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

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");

        try {
            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserByEmail(email);

            if (user != null) {
                String token = java.util.UUID.randomUUID().toString();
                Timestamp expiry = new Timestamp(System.currentTimeMillis() + (30 * 60 * 1000)); // 30 mins

                PasswordResetDAO prDAO = new PasswordResetDAO();
                prDAO.saveToken(user.getUserId(), token, expiry);

                // Build reset link using request context path dynamically
                String scheme = request.getScheme(); // http or https
                String serverName = request.getServerName(); // localhost or domain
                int serverPort = request.getServerPort(); // 8080 or other
                String contextPath = request.getContextPath(); // /DailyFixer or /dailyfixer_war_exploded
                
                String resetLink = scheme + "://" + serverName;
                if ((scheme.equals("http") && serverPort != 80) || (scheme.equals("https") && serverPort != 443)) {
                    resetLink += ":" + serverPort;
                }
                resetLink += contextPath + "/pages/authentication/forgot_password/reset_password.jsp?token=" + token;
                
                String htmlContent = "<h3>DailyFixer Password Reset</h3>" +
                        "<p>Click the link below to reset your password:</p>" +
                        "<a href='" + resetLink + "'>Reset My Password</a>";

                EmailUtil.sendEmail(email, "DailyFixer Password Reset", htmlContent);
            }

            request.setAttribute("message", "If an account exists for " + email + ", an email has been sent.");
            request.getRequestDispatcher("pages/authentication/forgot_password/forgot_password.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}