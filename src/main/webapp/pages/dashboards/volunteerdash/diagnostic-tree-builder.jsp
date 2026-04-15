<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>
            <% User user=(User) session.getAttribute("currentUser"); if (user==null ||
                !"volunteer".equalsIgnoreCase(user.getRole())) { response.sendRedirect(request.getContextPath()
                + "/pages/authentication/login.jsp" ); return; } String treeId=request.getParameter("id"); boolean isEditMode=treeId !=null
                && !treeId.isEmpty(); %>


                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        <%= isEditMode ? "Edit" : "Create" %> Diagnostic Tree | Volunteer Dashboard
                    </title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    <style>
                        /* Tree Builder Styles */
                        .builder-container {
                            display: flex;
                            flex-direction: column;
                            gap: 1.5rem;
                        }

                        .builder-step {
                            background: var(--card);
                            border: 1px solid var(--border);
                            border-radius: var(--radius-lg);
                            padding: 1.5rem;
                        }

                        .builder-step h2 {
                            font-size: 1.25rem;
                            margin-bottom: 1rem;
                            color: var(--primary);
                        }

                        /* Tree Visualization */
                        .tree-canvas {
                            min-height: 400px;
                            background: var(--muted);
                            border-radius: var(--radius-md);
                            padding: 2rem;
                            overflow-x: auto;
                        }

                        .tree-container {
                            display: flex;
                            flex-direction: row;
                            gap: 2rem;
                            min-width: max-content;
                        }

                        .node-wrapper {
                            display: flex;
                            flex-direction: column;
                            align-items: flex-start;
                        }

                        .node-with-children {
                            display: flex;
                            flex-direction: row;
                            align-items: flex-start;
                            gap: 1.5rem;
                        }

                        .node-card {
                            min-width: 220px;
                            max-width: 280px;
                            padding: 1rem;
                            border-radius: var(--radius-md);
                            border: 2px solid var(--border);
                            background: var(--card);
                            cursor: pointer;
                            transition: all 0.2s ease;
                            position: relative;
                        }

                        .node-card:hover {
                            box-shadow: var(--shadow-md);
                            border-color: var(--primary);
                        }

                        .node-card.question {
                            background: #e0e0e0;
                        }

                        .node-card.result {
                            background: #ffb3b3;
                        }

                        .dark .node-card.question {
                            background: oklch(0.35 0.02 270);
                        }

                        .dark .node-card.result {
                            background: oklch(0.4 0.1 20);
                        }

                        .node-label {
                            font-size: 0.75rem;
                            font-weight: 600;
                            text-transform: uppercase;
                            color: var(--muted-foreground);
                            margin-bottom: 0.25rem;
                        }

                        .node-text {
                            font-size: 0.9rem;
                            font-weight: 500;
                            color: var(--foreground);
                            margin-bottom: 0.5rem;
                            word-wrap: break-word;
                        }

                        .node-option {
                            font-size: 0.8rem;
                            padding: 0.25rem 0.5rem;
                            background: var(--primary);
                            color: var(--primary-foreground);
                            border-radius: var(--radius-sm);
                            display: inline-block;
                            margin-bottom: 0.5rem;
                        }

                        .node-actions {
                            display: flex;
                            gap: 0.5rem;
                            margin-top: 0.5rem;
                        }

                        .node-actions button {
                            font-size: 0.75rem;
                            padding: 0.25rem 0.5rem;
                            border: none;
                            border-radius: var(--radius-sm);
                            cursor: pointer;
                            transition: all 0.2s ease;
                        }

                        .node-actions .add-btn {
                            background: oklch(0.6290 0.1902 156.4499);
                            color: white;
                        }

                        .node-actions .edit-btn {
                            background: var(--primary);
                            color: var(--primary-foreground);
                        }

                        .node-actions .delete-btn {
                            background: var(--destructive);
                            color: var(--destructive-foreground);
                        }

                        .children-container {
                            display: flex;
                            flex-direction: column;
                            gap: 1rem;
                            padding-left: 1rem;
                            border-left: 2px solid var(--border);
                            margin-left: 1rem;
                        }

                        .child-wrapper {
                            position: relative;
                        }

                        .child-wrapper::before {
                            content: '';
                            position: absolute;
                            left: -1rem;
                            top: 50%;
                            width: 1rem;
                            height: 2px;
                            background: var(--border);
                        }

                        /* Form Styles */
                        .form-row {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                            gap: 1rem;
                            margin-bottom: 1rem;
                        }

                        .form-group {
                            margin-bottom: 1rem;
                        }

                        .form-group label {
                            display: block;
                            font-weight: 600;
                            margin-bottom: 0.5rem;
                            color: var(--foreground);
                        }

                        .form-group input,
                        .form-group select,
                        .form-group textarea {
                            width: 100%;
                            padding: 0.75rem;
                            border: 1px solid var(--border);
                            border-radius: var(--radius-md);
                            background: var(--input);
                            color: var(--foreground);
                            font-size: 0.9rem;
                        }

                        .form-group textarea {
                            min-height: 80px;
                            resize: vertical;
                        }

                        .other-category-input {
                            margin-top: 0.5rem;
                            display: none;
                        }

                        .other-category-input.visible {
                            display: block;
                        }

                        .button-group {
                            display: flex;
                            gap: 1rem;
                            margin-top: 1.5rem;
                        }

                        .empty-tree {
                            text-align: center;
                            padding: 3rem;
                            color: var(--muted-foreground);
                        }

                        .empty-tree button {
                            margin-top: 1rem;
                        }

                        /* Dialog Styles */
                        dialog {
                            padding: 1.5rem;
                            border-radius: var(--radius-lg);
                            border: 1px solid var(--border);
                            background: var(--card);
                            color: var(--foreground);
                            max-width: 500px;
                            width: 90%;
                        }

                        dialog::backdrop {
                            background: rgba(0, 0, 0, 0.5);
                        }

                        dialog h3 {
                            margin-bottom: 1rem;
                            color: var(--foreground);
                        }

                        .dialog-actions {
                            display: flex;
                            gap: 1rem;
                            justify-content: flex-end;
                            margin-top: 1.5rem;
                        }

                        /* Page Header */
                        .page-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 1.5rem;
                        }

                        .page-header h1 {
                            font-size: 1.75rem;
                            color: var(--foreground);
                        }

                        .header-actions {
                            display: flex;
                            gap: 0.75rem;
                        }

                        .status-badge {
                            padding: 0.5rem 1rem;
                            border-radius: var(--radius-md);
                            font-size: 0.85rem;
                            font-weight: 600;
                        }

                        .status-badge.draft {
                            background: var(--muted);
                            color: var(--muted-foreground);
                        }

                        .status-badge.published {
                            background: oklch(0.6290 0.1902 156.4499 / 0.2);
                            color: oklch(0.6290 0.1902 156.4499);
                        }
                    </style>
                </head>

                <body class="dashboard-layout">

                    <jsp:include page="/pages/dashboards/volunteerdash/sidebar.jsp" />

                    <main class="main-content">
                        <div class="page-header">
                            <h1 id="pageTitle">
                                <%= isEditMode ? "Edit Diagnostic Tree" : "Create Diagnostic Tree" %>
                            </h1>
                            <div class="header-actions" id="headerActions" style="display: none;">
                                <span id="statusBadge" class="status-badge draft">Draft</span>
                                <button onclick="togglePublish()" id="publishBtn" class="btn-primary">Publish</button>
                            </div>
                        </div>

                        <div class="builder-container">
                            <!-- Step 1: Tree Metadata -->
                            <div class="builder-step" id="metadataStep">
                                <h2>Step 1: Tree Information</h2>
                                <form id="metadataForm">
                                    <div class="form-group">
                                        <label for="treeTitle">Tree Title / Problem Description *</label>
                                        <input type="text" id="treeTitle" name="title"
                                            placeholder="e.g., Faucet is Leaking" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="treeDescription">Description (Optional)</label>
                                        <textarea id="treeDescription" name="description"
                                            placeholder="Brief description of what this diagnostic tree covers..."></textarea>
                                    </div>

                                    <div class="form-row">
                                        <div class="form-group">
                                            <label for="mainCategory">Main Category *</label>
                                            <select id="mainCategory" name="mainCategory" required
                                                onchange="loadSubCategories()">
                                                <option value="">Select Main Category</option>
                                            </select>
                                        </div>

                                        <div class="form-group">
                                            <label for="subCategory">Sub Category *</label>
                                            <select id="subCategory" name="subCategory" required
                                                onchange="handleSubCategoryChange()">
                                                <option value="">Select Sub Category first</option>
                                            </select>
                                            <input type="text" id="otherCategoryInput" class="other-category-input"
                                                placeholder="Enter new category name">
                                        </div>
                                    </div>

                                    <div class="button-group" id="metadataButtons">
                                        <button type="submit" class="btn-primary" id="saveMetaBtn">
                                            <%= isEditMode ? "Update & Continue" : "Save & Continue" %>
                                        </button>
                                        <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/diagnostic-trees.jsp"
                                            class="btn-secondary">Cancel</a>
                                    </div>
                                </form>
                            </div>

                            <!-- Step 2: Tree Builder (Hidden until metadata is saved) -->
                            <div class="builder-step" id="builderStep" style="display: none;">
                                <h2>Step 2: Build Decision Tree</h2>
                                <p style="color: var(--muted-foreground); margin-bottom: 1rem;">Click on a node to edit
                                    or add children. Question nodes are gray, Result nodes are pink.</p>

                                <div class="tree-canvas" id="treeCanvas">
                                    <div class="empty-tree" id="emptyTreeState">
                                        <p>No nodes yet. Start by adding the root question.</p>
                                        <button onclick="showAddNodeDialog(null)" class="btn-primary">+ Add Root
                                            Question</button>
                                    </div>
                                    <div class="tree-container" id="treeContainer" style="display: none;"></div>
                                </div>
                            </div>
                        </div>
                    </main>

                    <!-- Add/Edit Node Dialog -->
                    <dialog id="nodeDialog">
                        <h3 id="nodeDialogTitle">Add Node</h3>
                        <form id="nodeForm">
                            <input type="hidden" id="nodeId" value="">
                            <input type="hidden" id="parentNodeId" value="">

                            <div class="form-group" id="optionLabelGroup">
                                <label for="optionLabel">Option Label (Button Text) *</label>
                                <input type="text" id="optionLabel" placeholder="e.g., Yes, No, Sometimes">
                                <small style="color: var(--muted-foreground);">This text appears on the button that
                                    leads to this node</small>
                            </div>

                            <div class="form-group">
                                <label for="nodeText">Question/Result Text *</label>
                                <textarea id="nodeText"
                                    placeholder="e.g., Is the water coming from the spout or the base?"
                                    required></textarea>
                            </div>

                            <div class="form-group">
                                <label for="nodeType">Node Type *</label>
                                <select id="nodeType" required>
                                    <option value="QUESTION">Question (Has follow-up options)</option>
                                    <option value="RESULT">Result (End point - solution or diagnosis)</option>
                                </select>
                            </div>

                            <div class="dialog-actions">
                                <button type="button" onclick="closeNodeDialog()" class="btn-secondary">Cancel</button>
                                <button type="submit" class="btn-primary">Save Node</button>
                            </div>
                        </form>
                    </dialog>

                    <!-- Delete Node Confirmation -->
                    <dialog id="deleteNodeDialog">
                        <h3>Delete Node?</h3>
                        <p style="color: var(--muted-foreground); margin-bottom: 1rem;">This will delete this node and
                            all its children. This action cannot be undone.</p>
                        <div class="dialog-actions">
                            <button onclick="closeDeleteNodeDialog()" class="btn-secondary">Cancel</button>
                            <button onclick="confirmDeleteNode()" class="btn-danger">Delete</button>
                        </div>
                    </dialog>
                    <script>
                        const contextPath = '${pageContext.request.contextPath}';
                        let currentTreeId = <%= treeId != null ? treeId : "null" %>;
                        let currentTree = null;
                        let treeNodes = null;
                        let nodeToDelete = null;

                        document.addEventListener('DOMContentLoaded', function () {
                            loadCategories();

                            if (currentTreeId) {
                                loadTreeData();
                            }

                            // Form submission handlers
                            document.getElementById('metadataForm').addEventListener('submit', saveMetadata);
                            document.getElementById('nodeForm').addEventListener('submit', saveNode);
                        });

                        // ==================== Category Loading ====================
                        function loadCategories() {
                            fetch(contextPath + '/api/diagnostic/categories')
                                .then(response => response.json())
                                .then(categories => {
                                    const select = document.getElementById('mainCategory');
                                    categories.forEach(cat => {
                                        const option = document.createElement('option');
                                        option.value = cat.categoryId;
                                        option.textContent = cat.name;
                                        select.appendChild(option);
                                    });
                                })
                                .catch(err => console.error('Failed to load categories:', err));
                        }

                        function loadSubCategories() {
                            const mainCatId = document.getElementById('mainCategory').value;
                            const subSelect = document.getElementById('subCategory');
                            subSelect.innerHTML = '<option value="">Select Sub Category</option>';
                            document.getElementById('otherCategoryInput').classList.remove('visible');

                            if (!mainCatId) return;

                            fetch(contextPath + '/api/diagnostic/categories?parent=' + mainCatId)
                                .then(response => response.json())
                                .then(categories => {
                                    categories.forEach(cat => {
                                        const option = document.createElement('option');
                                        option.value = cat.categoryId;
                                        option.textContent = cat.name;
                                        subSelect.appendChild(option);
                                    });
                                    // Add "Other" option
                                    const otherOption = document.createElement('option');
                                    otherOption.value = 'other';
                                    otherOption.textContent = '+ Add New Category...';
                                    subSelect.appendChild(otherOption);
                                })
                                .catch(err => console.error('Failed to load sub-categories:', err));
                        }

                        function handleSubCategoryChange() {
                            const value = document.getElementById('subCategory').value;
                            const otherInput = document.getElementById('otherCategoryInput');
                            if (value === 'other') {
                                otherInput.classList.add('visible');
                                otherInput.focus();
                            } else {
                                otherInput.classList.remove('visible');
                            }
                        }

                        // ==================== Tree Data Loading ====================
                        function loadTreeData() {
                            fetch(contextPath + '/api/volunteer/diagnostic/trees/' + currentTreeId + '?includeNodes=true')
                                .then(response => {
                                    if (response.status === 403) {
                                        alert('You do not have access to this tree.');
                                        window.location.href = contextPath + '/pages/dashboards/volunteerdash/diagnostic-trees.jsp';
                                        return null;
                                    }
                                    return response.json();
                                })
                                .then(tree => {
                                    if (!tree) return;
                                    currentTree = tree;
                                    populateMetadata(tree);

                                    // Show builder step
                                    document.getElementById('builderStep').style.display = 'block';
                                    document.getElementById('headerActions').style.display = 'flex';
                                    updateStatusBadge(tree.status);

                                    if (tree.rootNode) {
                                        treeNodes = tree.rootNode;
                                        renderTree();
                                    }
                                })
                                .catch(err => {
                                    console.error('Failed to load tree:', err);
                                    alert('Failed to load tree data');
                                });
                        }

                        function populateMetadata(tree) {
                            document.getElementById('treeTitle').value = tree.title || '';
                            document.getElementById('treeDescription').value = tree.description || '';

                            // Set category (need to wait for categories to load)
                            setTimeout(() => {
                                if (tree.mainCategoryName) {
                                    const mainSelect = document.getElementById('mainCategory');
                                    for (let option of mainSelect.options) {
                                        if (option.textContent === tree.mainCategoryName) {
                                            mainSelect.value = option.value;
                                            loadSubCategories();
                                            setTimeout(() => {
                                                document.getElementById('subCategory').value = tree.categoryId;
                                            }, 300);
                                            break;
                                        }
                                    }
                                }
                            }, 500);
                        }

                        function updateStatusBadge(status) {
                            const badge = document.getElementById('statusBadge');
                            const btn = document.getElementById('publishBtn');
                            badge.className = 'status-badge ' + status;
                            badge.textContent = status.charAt(0).toUpperCase() + status.slice(1);
                            btn.textContent = status === 'published' ? 'Unpublish' : 'Publish';
                        }

                        // ==================== Metadata Form ====================
                        function saveMetadata(e) {
                            e.preventDefault();

                            const title = document.getElementById('treeTitle').value.trim();
                            const description = document.getElementById('treeDescription').value.trim();
                            let categoryId = document.getElementById('subCategory').value;
                            const mainCategoryId = document.getElementById('mainCategory').value;

                            if (!title || !categoryId || !mainCategoryId) {
                                alert('Please fill in all required fields');
                                return;
                            }

                            // Handle "other" category
                            if (categoryId === 'other') {
                                const newCategoryName = document.getElementById('otherCategoryInput').value.trim();
                                if (!newCategoryName) {
                                    alert('Please enter the new category name');
                                    return;
                                }

                                // Create new category first
                                const formData = new FormData();
                                formData.append('name', newCategoryName);
                                formData.append('parentId', mainCategoryId);

                                fetch(contextPath + '/api/diagnostic/categories', {
                                    method: 'POST',
                                    body: new URLSearchParams(formData)
                                })
                                    .then(response => response.json())
                                    .then(data => {
                                        if (data.categoryId) {
                                            saveTreeWithCategory(title, description, data.categoryId);
                                        } else {
                                            alert('Failed to create category: ' + (data.error || 'Unknown error'));
                                        }
                                    })
                                    .catch(err => {
                                        alert('Failed to create category');
                                        console.error(err);
                                    });
                            } else {
                                saveTreeWithCategory(title, description, categoryId);
                            }
                        }

                        function saveTreeWithCategory(title, description, categoryId) {
                            const formData = new FormData();
                            formData.append('title', title);
                            formData.append('description', description);
                            formData.append('categoryId', categoryId);

                            const method = currentTreeId ? 'PUT' : 'POST';
                            const url = currentTreeId
                                ? contextPath + '/api/volunteer/diagnostic/trees/' + currentTreeId
                                : contextPath + '/api/volunteer/diagnostic/trees';

                            fetch(url, {
                                method: method,
                                body: new URLSearchParams(formData)
                            })
                                .then(response => response.json())
                                .then(data => {
                                    if (data.success || data.treeId) {
                                        if (!currentTreeId) {
                                            currentTreeId = data.treeId;
                                            // Update URL without reload
                                            window.history.pushState({}, '', window.location.pathname + '?id=' + currentTreeId);
                                            document.getElementById('pageTitle').textContent = 'Edit Diagnostic Tree';
                                        }
                                        document.getElementById('builderStep').style.display = 'block';
                                        document.getElementById('headerActions').style.display = 'flex';
                                    } else {
                                        alert('Failed to save tree: ' + (data.error || 'Unknown error'));
                                    }
                                })
                                .catch(err => {
                                    alert('Failed to save tree');
                                    console.error(err);
                                });
                        }

                        // ==================== Tree Rendering ====================
                        function renderTree() {
                            const container = document.getElementById('treeContainer');
                            const emptyState = document.getElementById('emptyTreeState');

                            if (!treeNodes) {
                                container.style.display = 'none';
                                emptyState.style.display = 'block';
                                return;
                            }

                            container.style.display = 'flex';
                            emptyState.style.display = 'none';
                            container.innerHTML = renderNode(treeNodes);
                        }

                        function renderNode(node) {
                            const nodeClass = node.nodeType === 'RESULT' ? 'result' : 'question';
                            const hasChildren = node.children && node.children.length > 0;

                            let html = '<div class="node-wrapper">' +
                                '<div class="node-with-children">' +
                                '<div class="node-card ' + nodeClass + '" data-node-id="' + node.nodeId + '">';

                            if (node.optionLabel) {
                                html += '<div class="node-option">' + escapeHtml(node.optionLabel) + '</div>';
                            }

                            html += '<div class="node-label">' + node.nodeType + '</div>' +
                                '<div class="node-text">' + escapeHtml(node.nodeText) + '</div>' +
                                '<div class="node-actions">';

                            if (node.nodeType === 'QUESTION') {
                                html += '<button class="add-btn" onclick="showAddNodeDialog(' + node.nodeId + ')">+ Add</button>';
                            }

                            html += '<button class="edit-btn" onclick="showEditNodeDialog(' + node.nodeId + ')">Edit</button>';

                            if (!node.isRoot) {
                                html += '<button class="delete-btn" onclick="showDeleteNodeDialog(' + node.nodeId + ')">Delete</button>';
                            }

                            html += '</div></div>';

                            if (hasChildren) {
                                html += '<div class="children-container">';
                                node.children.forEach(function (child) {
                                    html += '<div class="child-wrapper">' + renderNode(child) + '</div>';
                                });
                                html += '</div>';
                            }

                            html += '</div></div>';
                            return html;
                        }

                        // ==================== Node Dialog ====================
                        function showAddNodeDialog(parentId) {
                            document.getElementById('nodeDialogTitle').textContent = parentId ? 'Add Child Node' : 'Add Root Question';
                            document.getElementById('nodeId').value = '';
                            document.getElementById('parentNodeId').value = parentId || '';
                            document.getElementById('optionLabel').value = '';
                            document.getElementById('nodeText').value = '';
                            document.getElementById('nodeType').value = 'QUESTION';

                            // Hide option label for root node
                            document.getElementById('optionLabelGroup').style.display = parentId ? 'block' : 'none';

                            document.getElementById('nodeDialog').showModal();
                        }

                        function showEditNodeDialog(nodeId) {
                            const node = findNodeById(treeNodes, nodeId);
                            if (!node) return;

                            document.getElementById('nodeDialogTitle').textContent = 'Edit Node';
                            document.getElementById('nodeId').value = node.nodeId;
                            document.getElementById('parentNodeId').value = node.parentId || '';
                            document.getElementById('optionLabel').value = node.optionLabel || '';
                            document.getElementById('nodeText').value = node.nodeText || '';
                            document.getElementById('nodeType').value = node.nodeType;

                            // Hide option label for root node
                            document.getElementById('optionLabelGroup').style.display = node.isRoot ? 'none' : 'block';

                            document.getElementById('nodeDialog').showModal();
                        }

                        function closeNodeDialog() {
                            document.getElementById('nodeDialog').close();
                        }

                        function saveNode(e) {
                            e.preventDefault();

                            const nodeId = document.getElementById('nodeId').value;
                            const parentId = document.getElementById('parentNodeId').value;
                            const optionLabel = document.getElementById('optionLabel').value.trim();
                            const nodeText = document.getElementById('nodeText').value.trim();
                            const nodeType = document.getElementById('nodeType').value;

                            if (!nodeText) {
                                alert('Node text is required');
                                return;
                            }

                            // Validate option label for non-root nodes
                            if (parentId && !optionLabel) {
                                alert('Option label is required for child nodes');
                                return;
                            }

                            const formData = new FormData();
                            formData.append('treeId', currentTreeId);
                            formData.append('nodeText', nodeText);
                            formData.append('optionLabel', optionLabel);
                            formData.append('nodeType', nodeType);
                            if (parentId) formData.append('parentId', parentId);

                            const method = nodeId ? 'PUT' : 'POST';
                            const url = nodeId
                                ? contextPath + '/api/volunteer/diagnostic/nodes/' + nodeId
                                : contextPath + '/api/volunteer/diagnostic/nodes';

                            fetch(url, {
                                method: method,
                                body: new URLSearchParams(formData)
                            })
                                .then(response => response.json())
                                .then(data => {
                                    if (data.success || data.nodeId) {
                                        closeNodeDialog();
                                        // Reload tree structure
                                        loadTreeData();
                                    } else {
                                        alert('Failed to save node: ' + (data.error || 'Unknown error'));
                                    }
                                })
                                .catch(err => {
                                    alert('Failed to save node');
                                    console.error(err);
                                });
                        }

                        // ==================== Delete Node ====================
                        function showDeleteNodeDialog(nodeId) {
                            nodeToDelete = nodeId;
                            document.getElementById('deleteNodeDialog').showModal();
                        }

                        function closeDeleteNodeDialog() {
                            nodeToDelete = null;
                            document.getElementById('deleteNodeDialog').close();
                        }

                        function confirmDeleteNode() {
                            if (!nodeToDelete) return;

                            fetch(contextPath + '/api/volunteer/diagnostic/nodes/' + nodeToDelete, {
                                method: 'DELETE'
                            })
                                .then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        loadTreeData();
                                    } else {
                                        alert('Failed to delete node: ' + (data.error || 'Unknown error'));
                                    }
                                })
                                .catch(err => {
                                    alert('Failed to delete node');
                                    console.error(err);
                                })
                                .finally(() => {
                                    closeDeleteNodeDialog();
                                });
                        }

                        // ==================== Publish/Unpublish ====================
                        function togglePublish() {
                            if (!currentTreeId) {
                                console.error('togglePublish: currentTreeId is not set');
                                alert('Error: Tree ID not set. Please save the tree first.');
                                return;
                            }

                            var newStatus = currentTree && currentTree.status === 'published' ? 'draft' : 'published';

                            var formData = new FormData();
                            formData.append('status', newStatus);

                            var url = contextPath + '/api/volunteer/diagnostic/trees/' + currentTreeId;

                            fetch(url, {
                                method: 'PUT',
                                body: new URLSearchParams(formData)
                            })
                                .then(function (response) {
                                    return response.json();
                                })
                                .then(function (data) {
                                    if (data.success) {
                                        currentTree.status = newStatus;
                                        updateStatusBadge(newStatus);
                                    } else {
                                        alert('Failed to update status: ' + (data.error || 'Unknown error'));
                                    }
                                })
                                .catch(function (err) {
                                    alert('Failed to update status');
                                    console.error('Error:', err);
                                });
                        }

                        // ==================== Utility Functions ====================
                        function findNodeById(node, id) {
                            if (!node) return null;
                            if (node.nodeId === id) return node;
                            if (node.children) {
                                for (const child of node.children) {
                                    const found = findNodeById(child, id);
                                    if (found) return found;
                                }
                            }
                            return null;
                        }

                        function escapeHtml(text) {
                            if (!text) return '';
                            const div = document.createElement('div');
                            div.textContent = text;
                            return div.innerHTML;
                        }
                    </script>

                </body>

                </html>