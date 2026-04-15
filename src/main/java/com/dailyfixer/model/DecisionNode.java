package com.dailyfixer.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Represents a node in a decision tree.
 * Can be either a QUESTION or RESULT type.
 */
public class DecisionNode {
    private int nodeId;
    private int treeId;
    private Integer parentId;
    private String nodeText;
    private String optionLabel;
    private String nodeType;
    private int displayOrder;
    private Timestamp createdAt;
    private List<DecisionNode> children;

    public DecisionNode() {
        this.nodeType = "QUESTION";
        this.displayOrder = 0;
        this.children = new ArrayList<>();
    }

    public int getNodeId() {
        return nodeId;
    }

    public void setNodeId(int nodeId) {
        this.nodeId = nodeId;
    }

    public int getTreeId() {
        return treeId;
    }

    public void setTreeId(int treeId) {
        this.treeId = treeId;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public String getNodeText() {
        return nodeText;
    }

    public void setNodeText(String nodeText) {
        this.nodeText = nodeText;
    }

    public String getOptionLabel() {
        return optionLabel;
    }

    public void setOptionLabel(String optionLabel) {
        this.optionLabel = optionLabel;
    }

    public String getNodeType() {
        return nodeType;
    }

    public void setNodeType(String nodeType) {
        this.nodeType = nodeType;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<DecisionNode> getChildren() {
        return children;
    }

    public void setChildren(List<DecisionNode> children) {
        this.children = children;
    }

    public void addChild(DecisionNode child) {
        this.children.add(child);
    }

    public boolean isQuestion() {
        return "QUESTION".equals(nodeType);
    }

    public boolean isResult() {
        return "RESULT".equals(nodeType);
    }

    public boolean isRoot() {
        return parentId == null;
    }

    public boolean hasChildren() {
        return children != null && !children.isEmpty();
    }
}
