<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>

        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Diagnostic Tool | Daily Fixer</title>
            <link
                href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
            <style>
                .diagnostic-container {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 2rem;
                }

                .page-title {
                    text-align: center;
                    margin-bottom: 2rem;
                }

                .page-title h1 {
                    font-size: 2.5rem;
                    color: var(--foreground);
                    margin-bottom: 0.5rem;
                }

                .page-title p {
                    color: var(--muted-foreground);
                    font-size: 1.1rem;
                }

                /* Search Bar */
                .search-section {
                    max-width: 600px;
                    margin: 0 auto 3rem auto;
                }

                .search-box {
                    display: flex;
                    gap: 0.75rem;
                }

                .search-box input {
                    flex: 1;
                    padding: 1rem 1.5rem;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-lg);
                    font-size: 1rem;
                    background: var(--input);
                    color: var(--foreground);
                    transition: border-color 0.2s ease;
                }

                .search-box input:focus {
                    outline: none;
                    border-color: var(--primary);
                }

                .search-box button {
                    padding: 1rem 2rem;
                    background: var(--primary);
                    color: var(--primary-foreground);
                    border: none;
                    border-radius: var(--radius-lg);
                    font-weight: 1900;
                    cursor: pointer;
                    transition: all 0.2s ease;
                }

                .search-box button:hover {
                    transform: translateY(-2px);
                    box-shadow: var(--shadow-md);
                }

                /* Category Grid */
                .section-title {
                    font-size: 1.5rem;
                    font-weight: 600;
                    color: var(--foreground);
                    margin-bottom: 1.5rem;
                }

                .categories-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                    gap: 1.5rem;
                    margin-bottom: 3rem;
                }

                .category-card {
                    background: var(--card);
                    border: 1px solid var(--border);
                    border-radius: var(--radius-lg);
                    padding: 2rem;
                    text-align: center;
                    cursor: pointer;
                    transition: all 0.3s ease;
                    text-decoration: none;
                    color: inherit;
                }

                .category-card:hover {
                    transform: translateY(-5px);
                    box-shadow: var(--shadow-lg);
                    border-color: var(--primary);
                }

                .category-icon {
                    font-size: 3rem;
                    margin-bottom: 1rem;
                }

                .category-name {
                    font-size: 1.25rem;
                    font-weight: 600;
                    color: var(--foreground);
                    margin-bottom: 0.5rem;
                }

                .category-count {
                    font-size: 0.9rem;
                    color: var(--muted-foreground);
                }

                /* Sub-categories View */
                .subcategories-container {
                    display: none;
                }

                .breadcrumb {
                    display: flex;
                    align-items: center;
                    gap: 0.5rem;
                    margin-bottom: 1.5rem;
                    font-size: 0.95rem;
                }

                .breadcrumb a {
                    color: var(--primary);
                    text-decoration: none;
                }

                .breadcrumb a:hover {
                    text-decoration: underline;
                }

                .breadcrumb span {
                    color: var(--muted-foreground);
                }

                .back-btn {
                    display: inline-flex;
                    align-items: center;
                    gap: 0.5rem;
                    padding: 0.5rem 1rem;
                    background: var(--secondary);
                    color: var(--secondary-foreground);
                    border: 1px solid var(--border);
                    border-radius: var(--radius-md);
                    font-size: 0.9rem;
                    cursor: pointer;
                    transition: all 0.2s ease;
                    text-decoration: none;
                    margin-bottom: 1.5rem;
                }

                .back-btn:hover {
                    background: var(--accent);
                    color: var(--accent-foreground);
                }

                /* Search Results */
                .search-results {
                    display: none;
                }

                .tree-list {
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                }

                .tree-card {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 1.25rem 1.5rem;
                    background: var(--card);
                    border: 1px solid var(--border);
                    border-radius: var(--radius-lg);
                    cursor: pointer;
                    transition: all 0.2s ease;
                    text-decoration: none;
                    color: inherit;
                }

                .tree-card:hover {
                    border-color: var(--primary);
                    box-shadow: var(--shadow-md);
                }

                .tree-info h3 {
                    font-size: 1.1rem;
                    font-weight: 600;
                    color: var(--foreground);
                    margin-bottom: 0.25rem;
                }

                .tree-meta {
                    display: flex;
                    gap: 1rem;
                    font-size: 0.85rem;
                    color: var(--muted-foreground);
                }

                .tree-rating {
                    color: oklch(0.7336 0.1758 50.5517);
                }

                .empty-state {
                    text-align: center;
                    padding: 4rem 2rem;
                    color: var(--muted-foreground);
                }

                .empty-state h3 {
                    font-size: 1.25rem;
                    margin-bottom: 0.5rem;
                    color: var(--foreground);
                }

                /* Loading */
                .loading {
                    text-align: center;
                    padding: 3rem;
                    color: var(--muted-foreground);
                }
            </style>
        </head>

        <body>
            <%@ include file="/pages/shared/header.jsp" %>

                <c:choose>
                    <c:when test="${empty sessionScope.currentUser}">
                        <div style="text-align:center; padding: 8rem 2rem; margin-top: 100px;">
                            <i class="ph ph-lock" style="font-size: 4rem; color: var(--muted-foreground);"></i>
                            <h2 style="margin: 1rem 0 0.5rem; color: var(--foreground);">Login Required</h2>
                            <p style="color: var(--muted-foreground); margin-bottom: 1.5rem;">You need to be logged in to access the Diagnostic Tool.</p>
                            <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp"
                               style="padding: 0.75rem 2rem; background: var(--primary); color: var(--primary-foreground); border-radius: var(--radius-lg); text-decoration: none; font-weight: 600;">
                                Login
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                <div class="diagnostic-container" style="margin-top: 100px;">
                    <div class="page-title">
                        <h1>Diagnostic Tool</h1>
                        <p>Find solutions to common problems with our interactive troubleshooting guides</p>
                    </div>

                    <!-- Search Section -->
                    <div class="search-section">
                        <div class="search-box">
                            <input type="text" id="searchInput"
                                placeholder="Search for a problem (e.g., 'leaking faucet')...">
                            <button onclick="performSearch()"><i class="ph ph-magnifying-glass"></i></button>
                        </div>
                    </div>

                    <!-- Main Categories View -->
                    <div id="mainCategoriesView">
                        <h2 class="section-title">Browse by Category</h2>
                        <div class="categories-grid" id="categoriesGrid">
                            <div class="loading">Loading categories...</div>
                        </div>
                    </div>

                    <!-- Sub-categories View -->
                    <div id="subCategoriesView" class="subcategories-container">
                        <button onclick="goBackToMain()" class="back-btn">← Back to Categories</button>
                        <h2 class="section-title" id="subCategoryTitle">Sub-Categories</h2>
                        <div class="categories-grid" id="subCategoriesGrid"></div>
                    </div>

                    <!-- Trees List View -->
                    <div id="treesView" class="subcategories-container">
                        <button onclick="goBackToSub()" class="back-btn" id="treesBackBtn">← Back</button>
                        <div class="breadcrumb" id="treesBreadcrumb"></div>
                        <h2 class="section-title" id="treesTitle">Available Guides</h2>
                        <div class="tree-list" id="treesList"></div>
                    </div>

                    <!-- Search Results View -->
                    <div id="searchResultsView" class="search-results">
                        <button onclick="clearSearch()" class="back-btn">← Clear Search</button>
                        <h2 class="section-title">Search Results</h2>
                        <div class="tree-list" id="searchResultsList"></div>
                    </div>
                </div>
                    </c:otherwise>
                </c:choose>

<%--                <%@ include file="/pages/shared/footer.jsp" %>--%>

                    <script>
                        const contextPath = '${pageContext.request.contextPath}';
                        let currentMainCategory = null;
                        let currentSubCategory = null;
                        let categoriesData = [];

                        const categoryIcons = {
                            'Home Repair': '<i class="ph ph-house"></i>',
                            'Home Electronic Repair': '<i class="ph ph-devices"></i>',
                            'Vehicle Repair': '<i class="ph ph-van"></i>',
                        };

                        document.addEventListener('DOMContentLoaded', function () {
                            loadMainCategories();

                            // Search on enter key
                            document.getElementById('searchInput').addEventListener('keypress', function (e) {
                                if (e.key === 'Enter') {
                                    performSearch();
                                }
                            });
                        });

                        function loadMainCategories() {
                            fetch(contextPath + '/api/diagnostic/categories')
                                .then(response => response.json())
                                .then(categories => {
                                    categoriesData = categories;
                                    renderMainCategories(categories);
                                })
                                .catch(function (err) {
                                    console.error('Failed to load categories:', err);
                                    document.getElementById('categoriesGrid').innerHTML = '<div class="empty-state"><h3>Failed to load categories</h3><p>Please try refreshing the page.</p></div>';
                                });
                        }

                        function renderMainCategories(categories) {
                            const grid = document.getElementById('categoriesGrid');

                            if (categories.length === 0) {
                                grid.innerHTML = '<div class="empty-state"><h3>No categories available</h3><p>Check back later for diagnostic guides.</p></div>';
                                return;
                            }

                            let html = '';
                            categories.forEach(function (cat) {
                                var icon = categoryIcons[cat.name] || '🔧';
                                html += '<div class="category-card" onclick="showSubCategories(' + cat.categoryId + ', \'' + escapeJs(cat.name) + '\')">' +
                                    '<div class="category-icon">' + icon + '</div>' +
                                    '<div class="category-name">' + escapeHtml(cat.name) + '</div>' +
                                    '<div class="category-count">Click to explore</div>' +
                                    '</div>';
                            });
                            grid.innerHTML = html;
                        }

                        function showSubCategories(categoryId, categoryName) {
                            currentMainCategory = { id: categoryId, name: categoryName };

                            document.getElementById('mainCategoriesView').style.display = 'none';
                            document.getElementById('subCategoriesView').style.display = 'block';
                            document.getElementById('treesView').style.display = 'none';
                            document.getElementById('searchResultsView').style.display = 'none';
                            document.getElementById('subCategoryTitle').textContent = categoryName + ' - Sub-Categories';

                            const grid = document.getElementById('subCategoriesGrid');
                            grid.innerHTML = '<div class="loading">Loading sub-categories...</div>';

                            fetch(contextPath + '/api/diagnostic/categories?parent=' + categoryId)
                                .then(response => response.json())
                                .then(function (subCategories) {
                                    if (subCategories.length === 0) {
                                        grid.innerHTML = '<div class="empty-state"><h3>No sub-categories</h3><p>This category does not have any sub-categories yet.</p></div>';
                                        return;
                                    }

                                    var html = '';
                                    subCategories.forEach(function (cat) {
                                        html += '<div class="category-card" onclick="showTrees(' + cat.categoryId + ', \'' + escapeJs(cat.name) + '\')">' +
                                            '<div class="category-icon"><i class="ph ph-folder"></i></div>' +
                                            '<div class="category-name">' + escapeHtml(cat.name) + '</div>' +
                                            '<div class="category-count">View Guides</div>' +
                                            '</div>';
                                    });
                                    grid.innerHTML = html;
                                })
                                .catch(function (err) {
                                    console.error('Failed to load sub-categories:', err);
                                    grid.innerHTML = '<div class="empty-state"><h3>Failed to load sub-categories</h3></div>';
                                });
                        }

                        function showTrees(categoryId, categoryName) {
                            currentSubCategory = { id: categoryId, name: categoryName };

                            document.getElementById('mainCategoriesView').style.display = 'none';
                            document.getElementById('subCategoriesView').style.display = 'none';
                            document.getElementById('treesView').style.display = 'block';
                            document.getElementById('searchResultsView').style.display = 'none';

                            document.getElementById('treesTitle').textContent = categoryName + ' - Guides';
                            document.getElementById('treesBreadcrumb').innerHTML = '<a href="javascript:goBackToMain()">' + escapeHtml(currentMainCategory.name) + '</a>' +
                                '<span>/</span>' +
                                '<span>' + escapeHtml(categoryName) + '</span>';

                            var list = document.getElementById('treesList');
                            list.innerHTML = '<div class="loading">Loading guides...</div>';

                            fetch(contextPath + '/api/diagnostic/trees?category=' + categoryId)
                                .then(function (response) { return response.json(); })
                                .then(function (trees) {
                                    renderTreesList(trees, list);
                                })
                                .catch(function (err) {
                                    console.error('Failed to load trees:', err);
                                    list.innerHTML = '<div class="empty-state"><h3>Failed to load guides</h3></div>';
                                });
                        }

                        function renderTreesList(trees, container) {
                            if (trees.length === 0) {
                                container.innerHTML = '<div class="empty-state"><h3>No guides available</h3><p>There are no diagnostic guides in this category yet.</p></div>';
                                return;
                            }

                            var html = '';
                            trees.forEach(function (tree) {
                                var stars = '<i class="ph-fill ph-star"></i>'.repeat(Math.round(tree.averageRating)) + '<i class="ph ph-star"></i>'.repeat(5 - Math.round(tree.averageRating));
                                html += '<a href="' + contextPath + '/pages/diagnostic/diagnostic-runner.jsp?id=' + tree.treeId + '" class="tree-card">' +
                                    '<div class="tree-info">' + '<i class="ph ph-tree"></i>'+
                                    '<h3>' + escapeHtml(tree.title) + '</h3>' +
                                    '<div class="tree-meta">' +
                                    '<span>By ' + escapeHtml(tree.creatorUsername) + '</span>' +
                                    '<span class="tree-rating">' + stars + ' (' + tree.ratingCount + ')</span>' +
                                    '</div>' +
                                    '</div>' +
                                    '<span style="color: var(--primary);">Start →</span>' +
                                    '</a>';
                            });
                            container.innerHTML = html;
                        }

                        function performSearch() {
                            const query = document.getElementById('searchInput').value.trim();
                            if (!query) return;

                            document.getElementById('mainCategoriesView').style.display = 'none';
                            document.getElementById('subCategoriesView').style.display = 'none';
                            document.getElementById('treesView').style.display = 'none';
                            document.getElementById('searchResultsView').style.display = 'block';

                            const list = document.getElementById('searchResultsList');
                            list.innerHTML = '<div class="loading">Searching...</div>';

                            fetch(contextPath + '/api/diagnostic/trees?search=' + encodeURIComponent(query))
                                .then(function (response) { return response.json(); })
                                .then(function (trees) {
                                    renderTreesList(trees, list);
                                })
                                .catch(function (err) {
                                    console.error('Search failed:', err);
                                    list.innerHTML = '<div class="empty-state"><h3>Search failed</h3><p>Please try again.</p></div>';
                                });
                        }

                        function clearSearch() {
                            document.getElementById('searchInput').value = '';
                            document.getElementById('searchResultsView').style.display = 'none';
                            document.getElementById('mainCategoriesView').style.display = 'block';
                        }

                        function goBackToMain() {
                            document.getElementById('mainCategoriesView').style.display = 'block';
                            document.getElementById('subCategoriesView').style.display = 'none';
                            document.getElementById('treesView').style.display = 'none';
                            document.getElementById('searchResultsView').style.display = 'none';
                            currentMainCategory = null;
                            currentSubCategory = null;
                        }

                        function goBackToSub() {
                            if (currentMainCategory) {
                                showSubCategories(currentMainCategory.id, currentMainCategory.name);
                            } else {
                                goBackToMain();
                            }
                        }

                        function escapeHtml(text) {
                            if (!text) return '';
                            const div = document.createElement('div');
                            div.textContent = text;
                            return div.innerHTML;
                        }

                        function escapeJs(text) {
                            if (!text) return '';
                            return text.replace(/'/g, "\\'").replace(/"/g, '\\"');
                        }
                    </script>
        </body>

        </html>