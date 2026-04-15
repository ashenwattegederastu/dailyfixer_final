package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.util.ImageUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for deleting a guide.
 * URL: /guides/delete (POST only)
 */
@WebServlet("/guides/delete")
public class GuideDeleteServlet extends HttpServlet {

    private GuideDAO guideDAO = new GuideDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Check if user can delete (admin or creator)
        boolean isAdmin = "admin".equals(currentUser.getRole());
        boolean isCreator = guideDAO.isGuideCreator(guideId, currentUser.getUserId());

        if (!isAdmin && !isCreator) {
            response.sendRedirect(request.getContextPath() + "/guides/view?id=" + guideId);
            return;
        }

        String webAppPath = getServletContext().getRealPath("/");

        // Delete guide and get image paths to clean up
        List<String> imagePaths = guideDAO.deleteGuide(guideId);

        // Delete image files from disk
        for (String imagePath : imagePaths) {
            ImageUploadUtil.deleteImage(imagePath, webAppPath);
        }

        // Redirect based on role
        String role = currentUser.getRole();
        if ("admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/pages/guides/admin-list.jsp?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/pages/guides/my-guides.jsp?success=deleted");
        }
    }
}
