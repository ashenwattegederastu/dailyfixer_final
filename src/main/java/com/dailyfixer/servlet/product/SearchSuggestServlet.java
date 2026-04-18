package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.ProductDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Returns JSON search suggestions (categories + product names) for the
 * autocomplete dropdown on the store landing page.
 *
 * GET /search-suggest?q=<term>
 * Response: { "suggestions": [ { "kind": "category"|"product", "label": "..." }, ... ] }
 */
@WebServlet("/search-suggest")
public class SearchSuggestServlet extends HttpServlet {

    private static final int MAX_CATEGORY_HITS = 3;
    private static final int MAX_PRODUCT_HITS  = 6;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent the browser / proxy from caching suggestion responses
        response.setHeader("Cache-Control", "no-store");
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String q = request.getParameter("q");
        if (q == null) q = "";
        q = q.trim();

        if (q.length() < 2) {
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"suggestions\":[]}");
            }
            return;
        }

        List<String[]> suggestions = new ArrayList<>(); // each entry: { kind, label }
        String lowerQ = q.toLowerCase();

        try {
            ProductDAO dao = new ProductDAO();

            // --- Category suggestions (filter in-memory; category list is small) ---
            List<String> categories = dao.getAllCategories();
            int catCount = 0;
            for (String cat : categories) {
                if (cat != null && cat.toLowerCase().contains(lowerQ)) {
                    suggestions.add(new String[]{"category", cat});
                    if (++catCount >= MAX_CATEGORY_HITS) break;
                }
            }

            // --- Product name suggestions ---
            List<String> names = dao.getProductNameSuggestions(q, MAX_PRODUCT_HITS);
            for (String name : names) {
                suggestions.add(new String[]{"product", name});
            }

        } catch (Exception e) {
            // Return empty on any error — never expose internal details
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"suggestions\":[]}");
            }
            return;
        }

        // --- Build JSON manually (no external libraries) ---
        StringBuilder sb = new StringBuilder("{\"suggestions\":[");
        boolean first = true;
        for (String[] s : suggestions) {
            if (!first) sb.append(",");
            first = false;
            sb.append("{\"kind\":").append(jsonStr(s[0]))
              .append(",\"label\":").append(jsonStr(s[1]))
              .append("}");
        }
        sb.append("]}");

        try (PrintWriter out = response.getWriter()) {
            out.print(sb.toString());
        }
    }

    private static String jsonStr(String s) {
        if (s == null) return "null";
        return "\""
                + s.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t")
                + "\"";
    }
}
