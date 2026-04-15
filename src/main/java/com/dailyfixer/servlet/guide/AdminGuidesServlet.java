package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.model.Guide;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for admin's guide management page.
 * URL: /guides/admin
 */
@WebServlet("/guides/admin")
public class AdminGuidesServlet extends HttpServlet {

    private GuideDAO guideDAO = new GuideDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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

        if (!"admin".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Check for filter
        String filter = request.getParameter("filter");
        List<Guide> guides;

        if ("mine".equals(filter)) {
            guides = guideDAO.getGuidesByCreator(currentUser.getUserId());
        } else {
            guides = guideDAO.getAllGuides();
        }

        request.setAttribute("guides", guides);
        request.setAttribute("filter", filter);

        request.getRequestDispatcher("/pages/guides/admin-list.jsp").forward(request, response);
    }
}
