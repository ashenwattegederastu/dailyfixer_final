package com.dailyfixer.servlet.diagnostic;

import com.dailyfixer.dao.CategoryDAO;
import com.dailyfixer.dao.DecisionNodeDAO;
import com.dailyfixer.dao.DecisionTreeDAO;
import com.dailyfixer.model.Category;
import com.dailyfixer.model.DecisionNode;
import com.dailyfixer.model.DecisionTree;
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
 * Servlet for handling decision tree operations.
 * URL: /api/diagnostic/trees
 */
@WebServlet(urlPatterns = { "/api/diagnostic/trees", "/api/diagnostic/trees/*" })
public class DiagnosticTreeServlet extends HttpServlet {

    private DecisionTreeDAO treeDAO;
    private DecisionNodeDAO nodeDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        treeDAO = new DecisionTreeDAO();
        nodeDAO = new DecisionNodeDAO();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String pathInfo = request.getPathInfo();
            String categoryParam = request.getParameter("category");
            String searchParam = request.getParameter("search");
            String includeNodes = request.getParameter("includeNodes");

            if (pathInfo != null && !pathInfo.equals("/")) {
                // Get single tree by ID
                int treeId = Integer.parseInt(pathInfo.substring(1));
                DecisionTree tree = treeDAO.getTreeById(treeId);

                if (tree == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Tree not found\"}");
                    return;
                }

                // Optionally include the full node structure
                if ("true".equals(includeNodes)) {
                    DecisionNode rootNode = nodeDAO.getTreeStructure(treeId);
                    out.print(treeToJsonWithNodes(tree, rootNode));
                } else {
                    out.print(treeToJson(tree));
                }
            } else if (searchParam != null && !searchParam.isEmpty()) {
                // Search trees
                List<DecisionTree> trees = treeDAO.searchTrees(searchParam);
                out.print(treesToJson(trees));
            } else if (categoryParam != null) {
                // Get trees by category
                int categoryId = Integer.parseInt(categoryParam);
                List<DecisionTree> trees = treeDAO.getTreesByCategory(categoryId);
                out.print(treesToJson(trees));
            } else {
                // Get all trees (admin view or check session)
                HttpSession session = request.getSession(false);
                if (session != null && isAdmin(session)) {
                    List<DecisionTree> trees = treeDAO.getAllTrees();
                    out.print(treesToJson(trees));
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\": \"Category parameter required\"}");
                }
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to fetch trees\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Login required\"}");
            return;
        }

        // For now, only admins can create trees
        if (!isAdmin(session)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"error\": \"Admin access required\"}");
            return;
        }

        try {
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String categoryIdParam = request.getParameter("categoryId");

            if (title == null || title.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Title is required\"}");
                return;
            }

            if (categoryIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Category is required\"}");
                return;
            }

            int categoryId = Integer.parseInt(categoryIdParam);

            // Verify category exists
            Category category = categoryDAO.getCategoryById(categoryId);
            if (category == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Invalid category\"}");
                return;
            }

            DecisionTree tree = new DecisionTree();
            tree.setTitle(title.trim());
            tree.setDescription(description != null ? description.trim() : "");
            tree.setCategoryId(categoryId);
            tree.setCreatorId(currentUser.getUserId());
            tree.setStatus("draft");

            int treeId = treeDAO.createTree(tree);
            if (treeId > 0) {
                out.print("{\"success\": true, \"treeId\": " + treeId + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"Failed to create tree\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid category ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to create tree\"}");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check if user is admin
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Unauthorized\"}");
            return;
        }

        try {
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || pathInfo.equals("/")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Tree ID is required\"}");
                return;
            }

            int treeId = Integer.parseInt(pathInfo.substring(1));

            // For PUT requests, we need to manually parse the request body
            // since getParameter() doesn't work for PUT in all servlet containers
            java.util.Map<String, String> params = parseRequestBody(request);

            String title = params.get("title");
            String description = params.get("description");
            String categoryIdParam = params.get("categoryId");
            String status = params.get("status");

            // Debug logging
            System.out.println("=== DiagnosticTreeServlet PUT ===");
            System.out.println("treeId: " + treeId);
            System.out.println("title: " + title);
            System.out.println("categoryIdParam: " + categoryIdParam);
            System.out.println("status: " + status);

            // If only status is being updated, use the simpler updateTreeStatus method
            if (status != null && title == null && categoryIdParam == null) {
                System.out.println("Using updateTreeStatus method");
                if (!status.equals("draft") && !status.equals("published")) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\": \"Invalid status value\"}");
                    return;
                }

                boolean updated = treeDAO.updateTreeStatus(treeId, status);
                System.out.println("updateTreeStatus result: " + updated);
                if (updated) {
                    out.print("{\"success\": true}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\": \"Failed to update status\"}");
                }
                return;
            }

            // Full update - need to get existing tree first
            DecisionTree existingTree = treeDAO.getTreeById(treeId);

            if (existingTree == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Tree not found\"}");
                return;
            }

            existingTree.setTreeId(treeId);
            if (title != null && !title.trim().isEmpty()) {
                existingTree.setTitle(title.trim());
            }
            if (description != null) {
                existingTree.setDescription(description.trim());
            }
            if (categoryIdParam != null) {
                existingTree.setCategoryId(Integer.parseInt(categoryIdParam));
            }
            if (status != null && (status.equals("draft") || status.equals("published"))) {
                existingTree.setStatus(status);
            }

            boolean updated = treeDAO.updateTree(existingTree);
            if (updated) {
                out.print("{\"success\": true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"Failed to update tree\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to update tree\"}");
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
            out.print("{\"error\": \"Unauthorized\"}");
            return;
        }

        try {
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || pathInfo.equals("/")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Tree ID is required\"}");
                return;
            }

            int treeId = Integer.parseInt(pathInfo.substring(1));
            boolean deleted = treeDAO.deleteTree(treeId);

            if (deleted) {
                out.print("{\"success\": true}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Tree not found\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid tree ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to delete tree\"}");
        }
    }

    private boolean isAdmin(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    private String treesToJson(List<DecisionTree> trees) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < trees.size(); i++) {
            if (i > 0)
                sb.append(",");
            sb.append(treeToJson(trees.get(i)));
        }
        sb.append("]");
        return sb.toString();
    }

    private String treeToJson(DecisionTree tree) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"treeId\":").append(tree.getTreeId()).append(",");
        sb.append("\"title\":\"").append(escapeJson(tree.getTitle())).append("\",");
        sb.append("\"description\":\"").append(escapeJson(tree.getDescription())).append("\",");
        sb.append("\"categoryId\":").append(tree.getCategoryId()).append(",");
        sb.append("\"categoryName\":\"").append(escapeJson(tree.getCategoryName())).append("\",");
        sb.append("\"mainCategoryName\":\"").append(escapeJson(tree.getMainCategoryName())).append("\",");
        sb.append("\"creatorId\":").append(tree.getCreatorId()).append(",");
        sb.append("\"creatorName\":\"").append(escapeJson(tree.getCreatorName())).append("\",");
        sb.append("\"creatorUsername\":\"").append(escapeJson(tree.getCreatorUsername())).append("\",");
        sb.append("\"status\":\"").append(tree.getStatus()).append("\",");
        sb.append("\"averageRating\":").append(String.format("%.1f", tree.getAverageRating())).append(",");
        sb.append("\"ratingCount\":").append(tree.getRatingCount()).append(",");
        sb.append("\"createdAt\":\"").append(tree.getCreatedAt()).append("\",");
        sb.append("\"updatedAt\":\"").append(tree.getUpdatedAt()).append("\"");
        sb.append("}");
        return sb.toString();
    }

    private String treeToJsonWithNodes(DecisionTree tree, DecisionNode rootNode) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"treeId\":").append(tree.getTreeId()).append(",");
        sb.append("\"title\":\"").append(escapeJson(tree.getTitle())).append("\",");
        sb.append("\"description\":\"").append(escapeJson(tree.getDescription())).append("\",");
        sb.append("\"categoryId\":").append(tree.getCategoryId()).append(",");
        sb.append("\"categoryName\":\"").append(escapeJson(tree.getCategoryName())).append("\",");
        sb.append("\"mainCategoryName\":\"").append(escapeJson(tree.getMainCategoryName())).append("\",");
        sb.append("\"creatorId\":").append(tree.getCreatorId()).append(",");
        sb.append("\"creatorName\":\"").append(escapeJson(tree.getCreatorName())).append("\",");
        sb.append("\"creatorUsername\":\"").append(escapeJson(tree.getCreatorUsername())).append("\",");
        sb.append("\"status\":\"").append(tree.getStatus()).append("\",");
        sb.append("\"averageRating\":").append(String.format("%.1f", tree.getAverageRating())).append(",");
        sb.append("\"ratingCount\":").append(tree.getRatingCount()).append(",");
        sb.append("\"rootNode\":").append(rootNode != null ? nodeToJson(rootNode) : "null");
        sb.append("}");
        return sb.toString();
    }

    private String nodeToJson(DecisionNode node) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"nodeId\":").append(node.getNodeId()).append(",");
        sb.append("\"treeId\":").append(node.getTreeId()).append(",");
        sb.append("\"parentId\":").append(node.getParentId() == null ? "null" : node.getParentId()).append(",");
        sb.append("\"nodeText\":\"").append(escapeJson(node.getNodeText())).append("\",");
        sb.append("\"optionLabel\":\"").append(escapeJson(node.getOptionLabel())).append("\",");
        sb.append("\"nodeType\":\"").append(node.getNodeType()).append("\",");
        sb.append("\"displayOrder\":").append(node.getDisplayOrder()).append(",");
        sb.append("\"isRoot\":").append(node.isRoot()).append(",");
        sb.append("\"children\":[");
        List<DecisionNode> children = node.getChildren();
        for (int i = 0; i < children.size(); i++) {
            if (i > 0)
                sb.append(",");
            sb.append(nodeToJson(children.get(i)));
        }
        sb.append("]");
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

    /**
     * Parse URL-encoded form data from request body.
     * Required for PUT requests since getParameter() doesn't work.
     */
    private java.util.Map<String, String> parseRequestBody(HttpServletRequest request) throws IOException {
        java.util.Map<String, String> params = new java.util.HashMap<>();

        java.io.BufferedReader reader = request.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        String body = sb.toString();

        if (body.isEmpty()) {
            return params;
        }

        // Parse URL-encoded body (e.g., "status=published&title=Test")
        String[] pairs = body.split("&");
        for (String pair : pairs) {
            int idx = pair.indexOf("=");
            if (idx > 0) {
                String key = java.net.URLDecoder.decode(pair.substring(0, idx), "UTF-8");
                String value = idx < pair.length() - 1
                        ? java.net.URLDecoder.decode(pair.substring(idx + 1), "UTF-8")
                        : "";
                params.put(key, value);
            }
        }

        return params;
    }
}
