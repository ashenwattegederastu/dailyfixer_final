package com.dailyfixer.servlet.auth;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.util.HashUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/ResetPasswordServlet"})
public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        // --- Validation checks ---
        if (currentPassword == null || newPassword == null || confirmPassword == null ||
                currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            req.setAttribute("errorMsg", "All fields are required.");
            req.getRequestDispatcher("/pages/authentication/resetPassword.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("errorMsg", "New passwords do not match.");
            req.getRequestDispatcher("/pages/authentication/resetPassword.jsp").forward(req, resp);
            return;
        }

        try {
            // Hash the provided current password
            String hashedCurrent = HashUtil.sha256(currentPassword);

            // Fetch latest com.dailyfixer.user from DB to verify password accurately
            User dbUser = userDAO.getUserById(currentUser.getUserId());
            if (dbUser == null || !dbUser.getPassword().equals(hashedCurrent)) {
                req.setAttribute("errorMsg", "Current password is incorrect.");
                req.getRequestDispatcher("/pages/authentication/resetPassword.jsp").forward(req, resp);
                return;
            }

            // Hash and update new password
            String hashedNew = HashUtil.sha256(newPassword);
            boolean updated = userDAO.updatePassword(currentUser.getUserId(), hashedNew);

            if (updated) {
                // Update session to reflect new password
                currentUser.setPassword(hashedNew);
                session.setAttribute("currentUser", currentUser);
                req.setAttribute("successMsg", "Password updated successfully!");
            } else {
                req.setAttribute("errorMsg", "Failed to update password. Try again later.");
            }

            req.getRequestDispatcher("/pages/authentication/resetPassword.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "Server error: " + e.getMessage());
            req.getRequestDispatcher("/pages/authentication/resetPassword.jsp").forward(req, resp);
        }
    }
}
