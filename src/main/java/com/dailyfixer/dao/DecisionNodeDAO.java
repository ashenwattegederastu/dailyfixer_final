package com.dailyfixer.dao;

import com.dailyfixer.model.DecisionNode;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for decision tree nodes.
 */
public class DecisionNodeDAO {

    /**
     * Get all nodes for a tree as a flat list.
     */
    public List<DecisionNode> getNodesByTree(int treeId) throws Exception {
        List<DecisionNode> nodes = new ArrayList<>();
        String sql = "SELECT * FROM diagnostic_nodes WHERE tree_id = ? ORDER BY display_order";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    nodes.add(mapResultSetToNode(rs));
                }
            }
        }
        return nodes;
    }

    /**
     * Get all nodes for a tree as a hierarchical structure.
     * Returns the root node with children recursively populated.
     */
    public DecisionNode getTreeStructure(int treeId) throws Exception {
        List<DecisionNode> allNodes = getNodesByTree(treeId);
        if (allNodes.isEmpty()) {
            return null;
        }

        // Build a map for quick lookup
        Map<Integer, DecisionNode> nodeMap = new HashMap<>();
        DecisionNode root = null;

        for (DecisionNode node : allNodes) {
            nodeMap.put(node.getNodeId(), node);
            if (node.isRoot()) {
                root = node;
            }
        }

        // Build the tree structure
        for (DecisionNode node : allNodes) {
            if (node.getParentId() != null) {
                DecisionNode parent = nodeMap.get(node.getParentId());
                if (parent != null) {
                    parent.addChild(node);
                }
            }
        }

        return root;
    }

    /**
     * Get a node by its ID.
     */
    public DecisionNode getNodeById(int nodeId) throws Exception {
        String sql = "SELECT * FROM diagnostic_nodes WHERE node_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, nodeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToNode(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get children of a node.
     */
    public List<DecisionNode> getChildNodes(int parentId) throws Exception {
        List<DecisionNode> nodes = new ArrayList<>();
        String sql = "SELECT * FROM diagnostic_nodes WHERE parent_id = ? ORDER BY display_order";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    nodes.add(mapResultSetToNode(rs));
                }
            }
        }
        return nodes;
    }

    /**
     * Get the root node of a tree.
     */
    public DecisionNode getRootNode(int treeId) throws Exception {
        String sql = "SELECT * FROM diagnostic_nodes WHERE tree_id = ? AND parent_id IS NULL";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToNode(rs);
                }
            }
        }
        return null;
    }

    /**
     * Create a new node.
     * Returns the generated node ID, or -1 on failure.
     */
    public int createNode(DecisionNode node) throws Exception {
        String sql = "INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order) "
                +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, node.getTreeId());
            if (node.getParentId() != null) {
                ps.setInt(2, node.getParentId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, node.getNodeText());
            ps.setString(4, node.getOptionLabel());
            ps.setString(5, node.getNodeType());
            ps.setInt(6, node.getDisplayOrder());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Update a node.
     */
    public boolean updateNode(DecisionNode node) throws Exception {
        String sql = "UPDATE diagnostic_nodes SET node_text = ?, option_label = ?, node_type = ?, display_order = ? " +
                "WHERE node_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, node.getNodeText());
            ps.setString(2, node.getOptionLabel());
            ps.setString(3, node.getNodeType());
            ps.setInt(4, node.getDisplayOrder());
            ps.setInt(5, node.getNodeId());

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete a node.
     * Note: This will cascade delete all child nodes.
     */
    public boolean deleteNode(int nodeId) throws Exception {
        String sql = "DELETE FROM diagnostic_nodes WHERE node_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, nodeId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete all nodes for a tree.
     */
    public boolean deleteAllNodesForTree(int treeId) throws Exception {
        String sql = "DELETE FROM diagnostic_nodes WHERE tree_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get the next display order for children of a parent.
     */
    public int getNextDisplayOrder(int parentId) throws Exception {
        String sql = "SELECT COALESCE(MAX(display_order), 0) + 1 FROM diagnostic_nodes WHERE parent_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 1;
    }

    /**
     * Count nodes in a tree.
     */
    public int countNodesInTree(int treeId) throws Exception {
        String sql = "SELECT COUNT(*) FROM diagnostic_nodes WHERE tree_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, treeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Check if a tree has a root node.
     */
    public boolean hasRootNode(int treeId) throws Exception {
        return getRootNode(treeId) != null;
    }

    private DecisionNode mapResultSetToNode(ResultSet rs) throws SQLException {
        DecisionNode node = new DecisionNode();
        node.setNodeId(rs.getInt("node_id"));
        node.setTreeId(rs.getInt("tree_id"));
        int parentId = rs.getInt("parent_id");
        node.setParentId(rs.wasNull() ? null : parentId);
        node.setNodeText(rs.getString("node_text"));
        node.setOptionLabel(rs.getString("option_label"));
        node.setNodeType(rs.getString("node_type"));
        node.setDisplayOrder(rs.getInt("display_order"));
        node.setCreatedAt(rs.getTimestamp("created_at"));
        return node;
    }
}
