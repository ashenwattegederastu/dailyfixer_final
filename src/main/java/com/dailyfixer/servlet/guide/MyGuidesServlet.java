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
 * Servlet for volunteer's "My Guides" page.
 * URL: /guides/my
 */
@WebServlet("/guides/my")
public class MyGuidesServlet extends HttpServlet {

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

        String role = currentUser.getRole();
        if (!"admin".equals(role) && !"volunteer".equals(role) && !"technician".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        List<Guide> guides = guideDAO.getGuidesByCreator(currentUser.getUserId());
        request.setAttribute("guides", guides);

        request.getRequestDispatcher("/pages/guides/my-guides.jsp").forward(request, response);
    }
}
