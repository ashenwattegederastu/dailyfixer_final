package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.model.Guide;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for listing guides with search and filter capabilities.
 * URL: /guides
 */
@WebServlet("/guides")
public class GuideListServlet extends HttpServlet {

    private GuideDAO guideDAO = new GuideDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get filter parameters
        String keyword = request.getParameter("keyword");
        String mainCategory = request.getParameter("mainCategory");
        String subCategory = request.getParameter("subCategory");

        List<Guide> guides;

        // If any filter is provided, use search; otherwise get all
        if ((keyword != null && !keyword.isEmpty()) ||
                (mainCategory != null && !mainCategory.isEmpty()) ||
                (subCategory != null && !subCategory.isEmpty())) {
            guides = guideDAO.searchGuides(keyword, mainCategory, subCategory);
        } else {
            guides = guideDAO.getAllGuides();
        }

        request.setAttribute("guides", guides);
        request.setAttribute("keyword", keyword);
        request.setAttribute("mainCategory", mainCategory);
        request.setAttribute("subCategory", subCategory);

        // Forward to the list JSP
        request.getRequestDispatcher("/pages/guides/list.jsp").forward(request, response);
    }
}
