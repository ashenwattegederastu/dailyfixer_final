package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.model.Guide;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * AJAX typeahead endpoint for guide title suggestions.
 * URL: /guides/suggest?q=...
 * Returns a JSON array of up to 8 matching active guide titles.
 */
@WebServlet("/guides/suggest")
public class GuideSuggestServlet extends HttpServlet {

    private static final int MAX_SUGGESTIONS = 8;
    private static final int MIN_QUERY_LENGTH = 2;

    private GuideDAO guideDAO = new GuideDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String q = request.getParameter("q");

        if (q == null || q.trim().length() < MIN_QUERY_LENGTH) {
            response.getWriter().print("[]");
            return;
        }

        List<Guide> suggestions = guideDAO.suggestGuides(q, MAX_SUGGESTIONS);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < suggestions.size(); i++) {
            Guide g = suggestions.get(i);
            json.append("{");
            json.append("\"guideId\":").append(g.getGuideId()).append(",");
            json.append("\"title\":\"").append(escapeJson(g.getTitle())).append("\",");
            json.append("\"mainCategory\":\"").append(escapeJson(g.getMainCategory())).append("\"");
            json.append("}");
            if (i < suggestions.size() - 1) json.append(",");
        }
        json.append("]");

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
