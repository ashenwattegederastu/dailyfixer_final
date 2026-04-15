package com.dailyfixer.servlet.diagnostic;

import com.dailyfixer.dao.VolunteerStatsDAO;
import com.dailyfixer.dao.DecisionNodeDAO;
import com.dailyfixer.dao.DecisionTreeDAO;
import com.dailyfixer.model.DecisionNode;
import com.dailyfixer.model.DecisionTree;
import com.dailyfixer.model.User;
import com.dailyfixer.model.VolunteerStats;
import com.dailyfixer.util.ReputationUtils;

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
 * Servlet for handling volunteer diagnostic node operations.
 * Only accessible to volunteers with "Diagnostic Contributor" tier (150+
 * reputation).
 * Volunteers can only access nodes in their own trees.
 * URL: /api/volunteer/diagnostic/nodes
 */
@WebServlet(urlPatterns = { "/api/volunteer/diagnostic/nodes", "/api/volunteer/diagnostic/nodes/*" })
public class VolunteerDiagnosticNodeServlet extends HttpServlet {

    private DecisionNodeDAO nodeDAO;
    private DecisionTreeDAO treeDAO;
    private VolunteerStatsDAO statsDAO;

    @Override
    public void init() throws ServletException {
        nodeDAO = new DecisionNodeDAO();
        treeDAO = new DecisionTreeDAO();
        statsDAO = new VolunteerStatsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Verify volunteer access
        User currentUser = getAuthorizedVolunteer(request, response, out);
        if (currentUser == null)
            return;

        try {
            String pathInfo = request.getPathInfo();
            String treeIdParam = request.getParameter("tree");

            if (pathInfo != null && !pathInfo.equals("/")) {
                // Get single node or its children
                String[] parts = pathInfo.split("/");
                int nodeId = Integer.parseInt(parts[1]);

                // Verify node's tree is owned by volunteer
                DecisionNode node = nodeDAO.getNodeById(nodeId);
                if (node == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Node not found\"}");
                    return;
                }

                if (!isTreeOwnedByUser(node.getTreeId(), currentUser.getUserId())) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"error\": \"Access denied - you can only access nodes in your own trees\"}");
                    return;
                }

                if (parts.length > 2 && "children".equals(parts[2])) {
                    List<DecisionNode> children = nodeDAO.getChildNodes(nodeId);
                    out.print(nodesToJson(children));
                } else {
                    out.print(nodeToJson(node));
                }
            } else if (treeIdParam != null) {
                int treeId = Integer.parseInt(treeIdParam);

                // Verify tree ownership
                if (!isTreeOwnedByUser(treeId, currentUser.getUserId())) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"error\": \"Access denied - you can only access your own trees\"}");
                    return;
                }

                if ("true".equals(request.getParameter("flat"))) {
                    List<DecisionNode> nodes = nodeDAO.getNodesByTree(treeId);
                    out.print(nodesToJson(nodes));
                } else {
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

        // Verify volunteer access
        User currentUser = getAuthorizedVolunteer(request, response, out);
        if (currentUser == null)
            return;

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

            // Verify tree ownership
            if (!isTreeOwnedByUser(treeId, currentUser.getUserId())) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"Access denied - you can only add nodes to your own trees\"}");
                return;
            }

            Integer parentId = null;
            if (parentIdParam != null && !parentIdParam.isEmpty()) {
                parentId = Integer.parseInt(parentIdParam);
                DecisionNode parent = nodeDAO.getNodeById(parentId);
                if (parent == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Parent node not found\"}");
                    return;
                }
            } else {
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

        // Verify volunteer access
        User currentUser = getAuthorizedVolunteer(request, response, out);
        if (currentUser == null)
            return;

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

            // Verify tree ownership
            if (!isTreeOwnedByUser(existingNode.getTreeId(), currentUser.getUserId())) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"Access denied - you can only edit nodes in your own trees\"}");
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

        // Verify volunteer access
        User currentUser = getAuthorizedVolunteer(request, response, out);
        if (currentUser == null)
            return;

        try {
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || pathInfo.equals("/")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Node ID is required\"}");
                return;
            }

            int nodeId = Integer.parseInt(pathInfo.substring(1));
            DecisionNode node = nodeDAO.getNodeById(nodeId);

            if (node == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Node not found\"}");
                return;
            }

            // Verify tree ownership
            if (!isTreeOwnedByUser(node.getTreeId(), currentUser.getUserId())) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"Access denied - you can only delete nodes in your own trees\"}");
                return;
            }

            boolean deleted = nodeDAO.deleteNode(nodeId);
            if (deleted) {
                out.print("{\"success\": true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"Failed to delete node\"}");
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

    /**
     * Check if a tree is owned by the given user.
     */
    private boolean isTreeOwnedByUser(int treeId, int userId) {
        try {
            DecisionTree tree = treeDAO.getTreeById(treeId);
            return tree != null && tree.getCreatorId() == userId;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Verify user is a volunteer with Diagnostic Contributor tier.
     */
    private User getAuthorizedVolunteer(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Login required\"}");
            return null;
        }

        if (!"volunteer".equalsIgnoreCase(currentUser.getRole())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"error\": \"Volunteer access required\"}");
            return null;
        }

        VolunteerStats stats = statsDAO.getStats(currentUser.getUserId());
        if (!ReputationUtils.isDiagnosticContributor(stats.getReputationScore())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"error\": \"Diagnostic Contributor tier required (150+ reputation)\", \"currentScore\": "
                    + stats.getReputationScore() + ", \"requiredScore\": 150}");
            return null;
        }

        return currentUser;
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
