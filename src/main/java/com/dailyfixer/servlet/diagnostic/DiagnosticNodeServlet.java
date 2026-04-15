package com.dailyfixer.servlet.diagnostic;

import com.dailyfixer.dao.DecisionNodeDAO;
import com.dailyfixer.dao.DecisionTreeDAO;
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
 * Servlet for handling decision node operations.
 * URL: /api/diagnostic/nodes
 */
@WebServlet(urlPatterns = { "/api/diagnostic/nodes", "/api/diagnostic/nodes/*" })
public class DiagnosticNodeServlet extends HttpServlet {

    private DecisionNodeDAO nodeDAO;
    private DecisionTreeDAO treeDAO;

    @Override
    public void init() throws ServletException {
        nodeDAO = new DecisionNodeDAO();
        treeDAO = new DecisionTreeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String pathInfo = request.getPathInfo();
            String treeIdParam = request.getParameter("tree");

            if (pathInfo != null && !pathInfo.equals("/")) {
                // Get single node or its children
                String[] parts = pathInfo.split("/");
                int nodeId = Integer.parseInt(parts[1]);

                if (parts.length > 2 && "children".equals(parts[2])) {
                    // Get children of a node
                    List<DecisionNode> children = nodeDAO.getChildNodes(nodeId);
                    out.print(nodesToJson(children));
                } else {
                    // Get single node
                    DecisionNode node = nodeDAO.getNodeById(nodeId);
                    if (node == null) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.print("{\"error\": \"Node not found\"}");
                        return;
                    }
                    out.print(nodeToJson(node));
                }
            } else if (treeIdParam != null) {
                // Get all nodes for a tree (as hierarchical structure)
                int treeId = Integer.parseInt(treeIdParam);

                if ("true".equals(request.getParameter("flat"))) {
                    // Return flat list
                    List<DecisionNode> nodes = nodeDAO.getNodesByTree(treeId);
                    out.print(nodesToJson(nodes));
                } else {
                    // Return hierarchical structure
                    DecisionNode rootNode = nodeDAO.getTreeStructure(treeId);
                    out.print(rootNode != null ? nodeToJsonRecursive(rootNode) : "null");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Tree ID or Node ID is required\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to fetch nodes\"}");
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
            out.print("{\"error\": \"Unauthorized\"}");
            return;
        }

        try {
            String treeIdParam = request.getParameter("treeId");
            String parentIdParam = request.getParameter("parentId");
            String nodeText = request.getParameter("nodeText");
            String optionLabel = request.getParameter("optionLabel");
            String nodeType = request.getParameter("nodeType");

            if (treeIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Tree ID is required\"}");
                return;
            }

            if (nodeText == null || nodeText.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Node text is required\"}");
                return;
            }

            int treeId = Integer.parseInt(treeIdParam);

            // Verify tree exists
            DecisionTree tree = treeDAO.getTreeById(treeId);
            if (tree == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Tree not found\"}");
                return;
            }

            Integer parentId = null;
            if (parentIdParam != null && !parentIdParam.isEmpty()) {
                parentId = Integer.parseInt(parentIdParam);
                // Verify parent exists
                DecisionNode parent = nodeDAO.getNodeById(parentId);
                if (parent == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Parent node not found\"}");
                    return;
                }
            } else {
                // Check if tree already has a root node
                if (nodeDAO.hasRootNode(treeId)) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    out.print("{\"error\": \"Tree already has a root node\"}");
                    return;
                }
            }

            DecisionNode node = new DecisionNode();
            node.setTreeId(treeId);
            node.setParentId(parentId);
            node.setNodeText(nodeText.trim());
            node.setOptionLabel(optionLabel != null ? optionLabel.trim() : "");
            node.setNodeType(nodeType != null && nodeType.equals("RESULT") ? "RESULT" : "QUESTION");

            // Set display order
            if (parentId != null) {
                node.setDisplayOrder(nodeDAO.getNextDisplayOrder(parentId));
            } else {
                node.setDisplayOrder(0);
            }

            int nodeId = nodeDAO.createNode(node);
            if (nodeId > 0) {
                node.setNodeId(nodeId);
                out.print("{\"success\": true, \"nodeId\": " + nodeId + ", \"node\": " + nodeToJson(node) + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"Failed to create node\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to create node\"}");
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
                out.print("{\"error\": \"Node ID is required\"}");
                return;
            }

            int nodeId = Integer.parseInt(pathInfo.substring(1));
            DecisionNode existingNode = nodeDAO.getNodeById(nodeId);

            if (existingNode == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Node not found\"}");
                return;
            }

            String nodeText = request.getParameter("nodeText");
            String optionLabel = request.getParameter("optionLabel");
            String nodeType = request.getParameter("nodeType");
            String displayOrderParam = request.getParameter("displayOrder");

            if (nodeText != null && !nodeText.trim().isEmpty()) {
                existingNode.setNodeText(nodeText.trim());
            }
            if (optionLabel != null) {
                existingNode.setOptionLabel(optionLabel.trim());
            }
            if (nodeType != null && (nodeType.equals("QUESTION") || nodeType.equals("RESULT"))) {
                existingNode.setNodeType(nodeType);
            }
            if (displayOrderParam != null) {
                existingNode.setDisplayOrder(Integer.parseInt(displayOrderParam));
            }

            boolean updated = nodeDAO.updateNode(existingNode);
            if (updated) {
                out.print("{\"success\": true, \"node\": " + nodeToJson(existingNode) + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"Failed to update node\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to update node\"}");
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
                out.print("{\"error\": \"Node ID is required\"}");
                return;
            }

            int nodeId = Integer.parseInt(pathInfo.substring(1));

            // Check if this is the root node
            DecisionNode node = nodeDAO.getNodeById(nodeId);
            if (node != null && node.isRoot()) {
                // Deleting root will delete all nodes - warn or prevent
                // For now, we allow it but the tree will have no nodes
            }

            boolean deleted = nodeDAO.deleteNode(nodeId);

            if (deleted) {
                out.print("{\"success\": true}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Node not found\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid node ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to delete node\"}");
        }
    }

    private boolean isAdmin(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    private String nodesToJson(List<DecisionNode> nodes) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < nodes.size(); i++) {
            if (i > 0)
                sb.append(",");
            sb.append(nodeToJson(nodes.get(i)));
        }
        sb.append("]");
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
        sb.append("\"isQuestion\":").append(node.isQuestion()).append(",");
        sb.append("\"isResult\":").append(node.isResult());
        sb.append("}");
        return sb.toString();
    }

    private String nodeToJsonRecursive(DecisionNode node) {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"nodeId\":").append(node.getNodeId()).append(",");
        sb.append("\"treeId\":").append(node.getTreeId()).append(",");
        sb.append("\"parentId\":").append(node.getParentId() == null ? "null" : node.getParentId()).append(",");
        sb.append("\"nodeText\":\"").append(escapeJson(node.getNodeText())).append("\",");
        sb.append("\"optionLabel\":\"").append(escapeJson(node.getOptionLabel())).append("\",");
        sb.append("\"nodeType\":\"").append(node.getNodeType()).append("\",");
        sb.append("\"displayOrder\":").append(node.getDisplayOrder()).append(",");
        sb.append("\"isRoot\":").append(node.isRoot()).append(",");
        sb.append("\"isQuestion\":").append(node.isQuestion()).append(",");
        sb.append("\"isResult\":").append(node.isResult()).append(",");
        sb.append("\"children\":[");
        List<DecisionNode> children = node.getChildren();
        for (int i = 0; i < children.size(); i++) {
            if (i > 0)
                sb.append(",");
            sb.append(nodeToJsonRecursive(children.get(i)));
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
}
