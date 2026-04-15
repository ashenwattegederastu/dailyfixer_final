package com.dailyfixer.servlet.diagnostic;

import com.dailyfixer.dao.CategoryDAO;
import com.dailyfixer.model.Category;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Servlet for handling diagnostic category operations.
 * URL: /api/diagnostic/categories
 */
@WebServlet(urlPatterns = { "/api/diagnostic/categories", "/api/diagnostic/categories/*" })
public class DiagnosticCategoryServlet extends HttpServlet {

    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String parentIdParam = request.getParameter("parent");

            if (parentIdParam != null) {
                // Get sub-categories for a parent
                int parentId = Integer.parseInt(parentIdParam);
                List<Category> subCategories = categoryDAO.getSubCategories(parentId);
                out.print(categoriesToJson(subCategories));
            } else {
                // Get all main categories
                List<Category> mainCategories = categoryDAO.getAllMainCategories();
                out.print(categoriesToJson(mainCategories));
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid parent ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to fetch categories\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check if user is admin
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Unauthorized - Admin access required\"}");
            return;
        }

        try {
            String name = request.getParameter("name");
            String parentIdParam = request.getParameter("parentId");

            if (name == null || name.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Category name is required\"}");
                return;
            }

            Integer parentId = null;
            if (parentIdParam != null && !parentIdParam.isEmpty()) {
                parentId = Integer.parseInt(parentIdParam);
            }

            // Check if category already exists
            if (categoryDAO.categoryExists(name.trim(), parentId)) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print("{\"error\": \"Category already exists\"}");
                return;
            }

            Category category = new Category();
            category.setName(name.trim());
            category.setParentId(parentId);

            int categoryId = categoryDAO.createCategory(category);
            if (categoryId > 0) {
                out.print("{\"success\": true, \"categoryId\": " + categoryId + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"Failed to create category\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid parent ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to create category\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check if user is admin
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Unauthorized - Admin access required\"}");
            return;
        }

        try {
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || pathInfo.equals("/")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Category ID is required\"}");
                return;
            }

            int categoryId = Integer.parseInt(pathInfo.substring(1));
            boolean deleted = categoryDAO.deleteCategory(categoryId);

            if (deleted) {
                out.print("{\"success\": true}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Category not found\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid category ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to delete category\"}");
        }
    }

    private boolean isAdmin(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    private String categoriesToJson(List<Category> categories) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < categories.size(); i++) {
            if (i > 0)
                sb.append(",");
            sb.append(categoryToJson(categories.get(i)));
        }
        sb.append("]");
        return sb.toString();
    }

    private String categoryToJson(Category category) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"categoryId\":").append(category.getCategoryId()).append(",");
        sb.append("\"name\":\"").append(escapeJson(category.getName())).append("\",");
        sb.append("\"parentId\":").append(category.getParentId() == null ? "null" : category.getParentId()).append(",");
        sb.append("\"isMainCategory\":").append(category.isMainCategory());
        sb.append("}");
        return sb.toString();
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
}
