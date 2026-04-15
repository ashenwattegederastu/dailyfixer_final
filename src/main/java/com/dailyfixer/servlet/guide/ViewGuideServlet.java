package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.model.Guide;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/ViewGuideServlet")
public class ViewGuideServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/ViewGuidesServlet");
            return;
        }
        int guideId = Integer.parseInt(idStr);
        Guide guide = new GuideDAO().getGuideById(guideId);

        if (guide == null) {
            response.sendRedirect(request.getContextPath() + "/ViewGuidesServlet");
            return;
        }

        request.setAttribute("guide", guide);
        RequestDispatcher rd = request.getRequestDispatcher("/pages/guides/view.jsp");
        rd.forward(request, response);
    }
}
