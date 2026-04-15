package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.util.ImageUploadUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 5, // 5 MB
        maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = Integer.parseInt(request.getParameter("userId"));
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String phoneNumber = request.getParameter("phoneNumber");
        String city = request.getParameter("city");
        String bio = request.getParameter("bio");

        UserDAO userDAO = new UserDAO();
        boolean updated = userDAO.updateUserInfo(userId, firstName, lastName, phoneNumber, city, bio);

        // Handle profile picture upload
        Part picturePart = request.getPart("profilePicture");
        if (picturePart != null && picturePart.getSize() > 0) {
            String webAppPath = getServletContext().getRealPath("/");
            String picturePath = ImageUploadUtil.saveProfilePicture(picturePart, userId, webAppPath);
            if (picturePath != null) {
                userDAO.updateProfilePicture(userId, picturePath);
            }
        }

        if (updated) {
            // Refresh session with updated user data
            User updatedUser = userDAO.getUserById(userId);
            request.getSession().setAttribute("currentUser", updatedUser);
            response.sendRedirect(request.getContextPath() + "/technician/profile");
        } else {
            response.getWriter().println("<script>alert('Update failed. Try again.');history.back();</script>");
        }
    }
}
