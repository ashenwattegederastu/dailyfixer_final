<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page
            import="com.dailyfixer.model.User, com.dailyfixer.model.VolunteerStats, com.dailyfixer.dao.VolunteerStatsDAO, com.dailyfixer.util.ReputationUtils"
            %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null ||
                !"volunteer".equalsIgnoreCase(user.getRole())) { response.sendRedirect(request.getContextPath()
                + "/pages/authentication/login.jsp" ); return; } VolunteerStatsDAO statsDAO=new VolunteerStatsDAO(); VolunteerStats
                stats=statsDAO.getStats(user.getUserId()); double currentScore=stats.getReputationScore(); boolean
                hasAccess=ReputationUtils.isDiagnosticContributor(currentScore); double requiredScore=150.0; double
                progressPercent=Math.min(100, (currentScore / requiredScore) * 100); %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Diagnostic Trees | Volunteer Dashboard</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    <style>
                        .tree-card {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 1rem 1.5rem;
                            background: var(--card);
                            border: 1px solid var(--border);
                            border-radius: var(--radius-md);
                            margin-bottom: 0.75rem;
                            transition: all 0.2s ease;
                        }

                        .tree-card:hover {
                            box-shadow: var(--shadow-md);
                            transform: translateY(-2px);
                        }

                        .tree-info {
                            flex: 1;
                        }

                        .tree-title {
                            font-size: 1.1rem;
                            font-weight: 600;
                            color: var(--foreground);
                            margin-bottom: 0.25rem;
                        }

                        .tree-meta {
                            font-size: 0.85rem;
                            color: var(--muted-foreground);
                        }

                        .tree-meta span {
                            margin-right: 1rem;
                        }

                        .tree-status {
                            padding: 0.25rem 0.75rem;
                            border-radius: var(--radius-sm);
                            font-size: 0.75rem;
                            font-weight: 600;
                            text-transform: uppercase;
                        }

                        .tree-status.draft {
                            background: var(--muted);
                            color: var(--muted-foreground);
                        }

                        .tree-status.published {
                            background: oklch(0.6290 0.1902 156.4499 / 0.2);
                            color: oklch(0.6290 0.1902 156.4499);
                        }

                        .tree-actions {
                            display: flex;
                            gap: 0.5rem;
                            align-items: center;
                        }

                        .star-rating {
                            color: oklch(0.7336 0.1758 50.5517);
                            font-size: 0.9rem;
                        }

                        .page-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 2rem;
                        }

                        .page-header h1 {
                            font-size: 1.75rem;
                            color: var(--foreground);
                        }

                        .empty-state {
                            text-align: center;
                            padding: 4rem 2rem;
                            background: var(--card);
                            border: 2px dashed var(--border);
                            border-radius: var(--radius-lg);
                        }

                        .empty-state h3 {
                            font-size: 1.25rem;
                            margin-bottom: 0.5rem;
                        }

                        .empty-state p {
                            color: var(--muted-foreground);
                            margin-bottom: 1.5rem;
                        }

                        .filter-bar {
                            display: flex;
                            gap: 1rem;
                            margin-bottom: 1.5rem;
                            flex-wrap: wrap;
                        }

                        .filter-bar select,
                        .filter-bar input {
                            padding: 0.5rem 1rem;
                            border: 1px solid var(--border);
                            border-radius: var(--radius-md);
                            background: var(--input);
                            color: var(--foreground);
                            font-size: 0.9rem;
                        }

                        /* Access Denied Styling */
                        .access-denied {
                            text-align: center;
                            padding: 4rem 2rem;
                            background: var(--card);
                            border: 1px solid var(--border);
                            border-radius: var(--radius-lg);
                            max-width: 600px;
                            margin: 2rem auto;
                        }

                        .access-denied .icon {
                            font-size: 4rem;
                            margin-bottom: 1.5rem;
                        }

                        .access-denied h2 {
                            font-size: 1.5rem;
                            color: var(--foreground);
                            margin-bottom: 1rem;
                        }

                        .access-denied p {
                            color: var(--muted-foreground);
                            margin-bottom: 1.5rem;
                            line-height: 1.6;
                        }

                        .progress-container {
                            background: var(--muted);
                            border-radius: var(--radius-md);
                            padding: 1.5rem;
                            margin: 2rem 0;
                        }

                        .progress-header {
                            display: flex;
                            justify-content: space-between;
                            margin-bottom: 0.75rem;
                            font-size: 0.9rem;
                        }

                        .progress-header .current {
                            color: var(--primary);
                            font-weight: 600;
                        }

                        .progress-header .target {
                            color: var(--muted-foreground);
                        }

                        .progress-bar {
                            width: 100%;
                            height: 12px;
                            background: var(--border);
                            border-radius: 6px;
                            overflow: hidden;
                        }

                        .progress-fill {
                            height: 100%;
                            background: linear-gradient(90deg, var(--primary), oklch(0.6290 0.1902 156.4499));
                            border-radius: 6px;
                            transition: width 0.5s ease;
                        }

                        .requirements-list {
                            text-align: left;
                            list-style: none;
                            padding: 0;
                            margin: 1.5rem 0;
                        }

                        .requirements-list li {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                            padding: 0.75rem 0;
                            border-bottom: 1px solid var(--border);
                            color: var(--muted-foreground);
                        }

                        .requirements-list li:last-child {
                            border-bottom: none;
                        }

                        .requirements-list .check {
                            color: oklch(0.6290 0.1902 156.4499);
                        }

                        .requirements-list .pending {
                            color: var(--muted-foreground);
                        }
                    </style>
                </head>

                <body class="dashboard-layout">

                    <jsp:include page="/pages/dashboards/volunteerdash/sidebar.jsp" />

                    <main class="main-content">
                        <% if (hasAccess) { %>
                            <!-- Has Access - Show Tree List -->
                            <div class="page-header">
                                <h1>My Diagnostic Trees</h1>
                                <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/diagnostic-tree-builder.jsp"
                                    class="btn-primary">+ Create New Tree</a>
                            </div>

                            <div class="filter-bar">
                                <input type="text" id="searchInput" placeholder="Search trees..."
                                    onkeyup="filterTrees()">
                                <select id="statusFilter" onchange="filterTrees()">
                                    <option value="">All Status</option>
                                    <option value="draft">Draft</option>
                                    <option value="published">Published</option>
                                </select>
                                <select id="categoryFilter" onchange="filterTrees()">
                                    <option value="">All Categories</option>
                                </select>
                            </div>

                            <div id="treesContainer">
                                <div class="empty-state" id="loadingState">
                                    <p>Loading trees...</p>
                                </div>
                            </div>

                            <!-- Delete Confirmation Dialog -->
                            <dialog id="deleteDialog"
                                style="padding: 2rem; border-radius: var(--radius-lg); border: 1px solid var(--border);">
                                <h3 style="margin-bottom: 1rem;">Delete Tree?</h3>
                                <p style="margin-bottom: 1.5rem; color: var(--muted-foreground);">This will permanently
                                    delete the tree and all its nodes. This action cannot be undone.</p>
                                <div style="display: flex; gap: 1rem; justify-content: flex-end;">
                                    <button onclick="closeDeleteDialog()" class="btn-secondary">Cancel</button>
                                    <button onclick="confirmDelete()" class="btn-danger">Delete</button>
                                </div>
                            </dialog>
                            <% } else { %>
                                <!-- No Access - Show Progress -->
                                <div class="access-denied">
                                    <div class="icon">🔒</div>
                                    <h2>You Don't Have Access Yet</h2>
                                    <p>
                                        To access the Diagnostic Tree tools, you need to reach the
                                        <strong>Diagnostic Contributor</strong> tier by earning at least
                                        <strong>150 reputation points</strong>.
                                    </p>

                                    <div class="progress-container">
                                        <div class="progress-header">
                                            <span class="current">
                                                <%= Math.round(currentScore * 10.0) / 10.0 %> pts
                                            </span>
                                            <span class="target">
                                                <%= (int) requiredScore %> pts required
                                            </span>
                                        </div>
                                        <div class="progress-bar">
                                            <div class="progress-fill" style="width: <%= progressPercent %>%;"></div>
                                        </div>
                                        <p
                                            style="margin-top: 0.75rem; font-size: 0.85rem; color: var(--muted-foreground);">
                                            <strong>
                                                <%= Math.round((requiredScore - currentScore) * 10.0) / 10.0 %>
                                            </strong> more points needed
                                        </p>
                                    </div>

                                    <h4 style="margin-bottom: 1rem; color: var(--foreground);">How to Earn Reputation
                                    </h4>
                                    <ul class="requirements-list">
                                        <li>
                                            <span>📚</span>
                                            <span>Create high-quality guides on fixing problems</span>
                                        </li>
                                        <li>
                                            <span>👍</span>
                                            <span>Get likes and positive ratings on your guides</span>
                                        </li>
                                        <li>
                                            <span>👀</span>
                                            <span>Attract views to your helpful content</span>
                                        </li>
                                        <li>
                                            <span>⭐</span>
                                            <span>Maintain a high approval rating (likes vs dislikes)</span>
                                        </li>
                                    </ul>

                                    <a href="${pageContext.request.contextPath}/guides/create"
                                        class="btn-primary">Create a Guide to Earn Points</a>
                                </div>
                                <% } %>
                    </main>
                    <% if (hasAccess) { %>
                        <script>
                            const contextPath = '${pageContext.request.contextPath}';
                            let allTrees = [];
                            let treeToDelete = null;

                            document.addEventListener('DOMContentLoaded', function () {
                                loadCategories();
                                loadTrees();
                            });

                            function loadCategories() {
                                fetch(contextPath + '/api/diagnostic/categories')
                                    .then(response => response.json())
                                    .then(categories => {
                                        const select = document.getElementById('categoryFilter');
                                        categories.forEach(cat => {
                                            const option = document.createElement('option');
                                            option.value = cat.categoryId;
                                            option.textContent = cat.name;
                                            select.appendChild(option);
                                        });
                                    })
                                    .catch(err => console.error('Failed to load categories:', err));
                            }

                            function loadTrees() {
                                fetch(contextPath + '/api/volunteer/diagnostic/trees')
                                    .then(response => response.json())
                                    .then(trees => {
                                        allTrees = trees;
                                        renderTrees(trees);
                                    })
                                    .catch(function (err) {
                                        console.error('Failed to load trees:', err);
                                        document.getElementById('treesContainer').innerHTML = '<div class="empty-state"><h3>Error Loading Trees</h3><p>Please try refreshing the page.</p></div>';
                                    });
                            }

                            function renderTrees(trees) {
                                var container = document.getElementById('treesContainer');
                                var createTreeUrl = contextPath + '/pages/dashboards/volunteerdash/diagnostic-tree-builder.jsp';

                                if (trees.length === 0) {
                                    container.innerHTML = '<div class="empty-state"><h3>No Diagnostic Trees Yet</h3><p>Create your first diagnostic tree to help users troubleshoot problems.</p><a href="' + createTreeUrl + '" class="btn-primary">+ Create New Tree</a></div>';
                                    return;
                                }

                                var html = '';
                                trees.forEach(function (tree) {
                                    var stars = '★'.repeat(Math.round(tree.averageRating)) + '☆'.repeat(5 - Math.round(tree.averageRating));
                                    html += '<div class="tree-card" data-status="' + tree.status + '" data-category="' + tree.categoryId + '">' +
                                        '<div class="tree-info">' +
                                        '<div class="tree-title">' + escapeHtml(tree.title) + '</div>' +
                                        '<div class="tree-meta">' +
                                        '<span>📁 ' + escapeHtml(tree.mainCategoryName || '') + ' / ' + escapeHtml(tree.categoryName) + '</span>' +
                                        '<span class="star-rating">' + stars + ' (' + tree.ratingCount + ')</span>' +
                                        '</div>' +
                                        '</div>' +
                                        '<div class="tree-actions">' +
                                        '<span class="tree-status ' + tree.status + '">' + tree.status + '</span>' +
                                        '<a href="' + createTreeUrl + '?id=' + tree.treeId + '" class="action-btn btn-view">Edit</a>' +
                                        '<button onclick="showDeleteDialog(' + tree.treeId + ')" class="action-btn btn-dismiss">Delete</button>' +
                                        '</div>' +
                                        '</div>';
                                });
                                container.innerHTML = html;
                            }

                            function filterTrees() {
                                const search = document.getElementById('searchInput').value.toLowerCase();
                                const status = document.getElementById('statusFilter').value;
                                const category = document.getElementById('categoryFilter').value;

                                const filtered = allTrees.filter(tree => {
                                    const matchesSearch = tree.title.toLowerCase().includes(search) ||
                                        (tree.description && tree.description.toLowerCase().includes(search));
                                    const matchesStatus = !status || tree.status === status;
                                    const matchesCategory = !category || tree.categoryId == category;
                                    return matchesSearch && matchesStatus && matchesCategory;
                                });

                                renderTrees(filtered);
                            }

                            function showDeleteDialog(treeId) {
                                treeToDelete = treeId;
                                document.getElementById('deleteDialog').showModal();
                            }

                            function closeDeleteDialog() {
                                treeToDelete = null;
                                document.getElementById('deleteDialog').close();
                            }

                            function confirmDelete() {
                                if (!treeToDelete) return;

                                fetch(contextPath + '/api/volunteer/diagnostic/trees/' + treeToDelete, {
                                    method: 'DELETE'
                                })
                                    .then(response => response.json())
                                    .then(data => {
                                        if (data.success) {
                                            loadTrees();
                                        } else {
                                            alert('Failed to delete tree: ' + (data.error || 'Unknown error'));
                                        }
                                    })
                                    .catch(err => {
                                        alert('Failed to delete tree');
                                        console.error(err);
                                    })
                                    .finally(() => {
                                        closeDeleteDialog();
                                    });
                            }

                            function escapeHtml(text) {
                                if (!text) return '';
                                const div = document.createElement('div');
                                div.textContent = text;
                                return div.innerHTML;
                            }
                        </script>
                        <% } %>

                </body>

                </html>