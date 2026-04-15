package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideCategoryDAO;
import com.dailyfixer.model.GuideCategory;
import com.dailyfixer.model.GuideSubCategory;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * REST-like servlet for category management.
 * URL: /guides/categories
 * 
 * GET - Returns all categories and sub-categories as JSON
 * POST - Creates a new category or sub-category (requires admin/volunteer role)
 */
@WebServlet("/guides/categories")
public class GuideCategoryServlet extends HttpServlet {

    private GuideCategoryDAO categoryDAO = new GuideCategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        List<GuideCategory> categories = categoryDAO.getAllCategories();

        // Build JSON response
        StringBuilder json = new StringBuilder();
        json.append("{\"categories\":[");

        for (int i = 0; i < categories.size(); i++) {
            GuideCategory cat = categories.get(i);
            List<GuideSubCategory> subs = categoryDAO.getSubCategoriesByCategoryId(cat.getCategoryId());

            json.append("{");
            json.append("\"categoryId\":").append(cat.getCategoryId()).append(",");
            json.append("\"name\":\"").append(escapeJson(cat.getName())).append("\",");
            json.append("\"subCategories\":[");

            for (int j = 0; j < subs.size(); j++) {
                GuideSubCategory sub = subs.get(j);
                json.append("{");
                json.append("\"subCategoryId\":").append(sub.getSubCategoryId()).append(",");
                json.append("\"name\":\"").append(escapeJson(sub.getName())).append("\"");
                json.append("}");
                if (j < subs.size() - 1)
                    json.append(",");
            }

            json.append("]}");
            if (i < categories.size() - 1)
                json.append(",");
        }

        json.append("]}");

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Check if user is logged in as admin or volunteer
        HttpSession session = request.getSession(false);
        if (session == null) {
            sendError(response, 401, "Unauthorized");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            sendError(response, 401, "Unauthorized");
            return;
        }

        String role = currentUser.getRole();
        if (!"admin".equals(role) && !"volunteer".equals(role)) {
            sendError(response, 403, "Forbidden");
            return;
        }

        // Read JSON body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String body = sb.toString();

        // Simple JSON parsing (type, name, categoryId)
        String type = extractJsonValue(body, "type");
        String name = extractJsonValue(body, "name");
        String categoryIdStr = extractJsonValue(body, "categoryId");

        if (name == null || name.trim().isEmpty()) {
            sendError(response, 400, "Name is required");
            return;
        }

        PrintWriter out = response.getWriter();

        if ("main".equals(type)) {
            // Create new main category
            int newId = categoryDAO.addCategory(name.trim());
            if (newId > 0) {
                out.print(
                        "{\"success\":true,\"categoryId\":" + newId + ",\"name\":\"" + escapeJson(name.trim()) + "\"}");
            } else {
                sendError(response, 500, "Failed to create category. It may already exist.");
                return;
            }
        } else if ("sub".equals(type)) {
            // Create new sub-category
            if (categoryIdStr == null || categoryIdStr.isEmpty()) {
                sendError(response, 400, "categoryId is required for sub-category");
                return;
            }

            int categoryId;
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException e) {
                sendError(response, 400, "Invalid categoryId");
                return;
            }

            int newId = categoryDAO.addSubCategory(categoryId, name.trim());
            if (newId > 0) {
                out.print("{\"success\":true,\"subCategoryId\":" + newId + ",\"categoryId\":" + categoryId
                        + ",\"name\":\"" + escapeJson(name.trim()) + "\"}");
            } else {
                sendError(response, 500, "Failed to create sub-category. It may already exist.");
                return;
            }
        } else {
            sendError(response, 400, "Invalid type. Use 'main' or 'sub'");
            return;
        }

        out.flush();
    }

    private void sendError(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        PrintWriter out = response.getWriter();
        out.print("{\"success\":false,\"error\":\"" + escapeJson(message) + "\"}");
        out.flush();
    }

    private String escapeJson(String str) {
        if (str == null)
            return "";
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    /**
     * Simple JSON value extraction (handles basic cases).
     */
    private String extractJsonValue(String json, String key) {
        String searchKey = "\"" + key + "\":";
        int keyIndex = json.indexOf(searchKey);
        if (keyIndex == -1)
            return null;

        int valueStart = keyIndex + searchKey.length();

        // Skip whitespace
        while (valueStart < json.length() && Character.isWhitespace(json.charAt(valueStart))) {
            valueStart++;
        }

        if (valueStart >= json.length())
            return null;

        char startChar = json.charAt(valueStart);

        if (startChar == '"') {
            // String value
            int valueEnd = json.indexOf('"', valueStart + 1);
            if (valueEnd == -1)
                return null;
            return json.substring(valueStart + 1, valueEnd);
        } else if (Character.isDigit(startChar) || startChar == '-') {
            // Numeric value
            int valueEnd = valueStart;
            while (valueEnd < json.length() &&
                    (Character.isDigit(json.charAt(valueEnd)) || json.charAt(valueEnd) == '.'
                            || json.charAt(valueEnd) == '-')) {
                valueEnd++;
            }
            return json.substring(valueStart, valueEnd);
        }

        return null;
    }
}
