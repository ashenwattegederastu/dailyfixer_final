<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>

        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Repair Guides | Daily Fixer</title>
            <!-- Importing Phosphor Icon Library Locally from assets-->
            <link
                    rel="stylesheet"
                    type="text/css"
                    href="${pageContext.request.contextPath}/assets/icons/regular/style.css"
            />
            <link
                    rel="stylesheet"
                    type="text/css"
                    href="${pageContext.request.contextPath}/assets/icons/fill/style.css"
            />
            <style>
                .page-container {
                    max-width: 1400px;
                    margin: 0 auto;
                    padding: 100px 30px 50px;
                }

                .page-header {
                    margin-bottom: 30px;
                }

                .page-header h1 {
                    font-size: 2.2rem;
                    color: var(--foreground);
                    margin-bottom: 10px;
                }

                .page-header p {
                    color: var(--muted-foreground);
                }

                .filters-section {
                    background: var(--card);
                    padding: 20px;
                    border-radius: var(--radius-lg);
                    margin-bottom: 30px;
                    border: 1px solid var(--border);
                }

                .filters-form {
                    display: flex;
                    gap: 15px;
                    flex-wrap: wrap;
                    align-items: flex-end;
                }

                .filter-group {
                    flex: 1;
                    min-width: 200px;
                }

                .filter-group label {
                    display: block;
                    margin-bottom: 5px;
                    font-weight: 500;
                    color: var(--foreground);
                    font-size: 0.9rem;
                }

                .filter-group input,
                .filter-group select {
                    width: 100%;
                    padding: 10px 12px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: var(--input);
                    color: var(--foreground);
                    font-size: 0.95rem;
                }

                .filter-buttons {
                    display: flex;
                    gap: 10px;
                }

                .guides-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                    gap: 25px;
                }

                .guide-card {
                    background: var(--card);
                    border-radius: var(--radius-lg);
                    overflow: hidden;
                    border: 1px solid var(--border);
                    transition: transform 0.2s, box-shadow 0.2s;
                    text-decoration: none;
                    display: block;
                }

                .guide-card:hover {
                    transform: translateY(-4px);
                    box-shadow: var(--shadow-xl);
                }

                .guide-card-image {
                    width: 100%;
                    height: 200px;
                    object-fit: cover;
                    background: var(--muted);
                }

                .guide-card-body {
                    padding: 20px;
                }

                .guide-card-title {
                    font-size: 1.2rem;
                    font-weight: 600;
                    color: var(--foreground);
                    margin-bottom: 8px;
                    display: -webkit-box;
                    -webkit-line-clamp: 2;
                    -webkit-box-orient: vertical;
                    overflow: hidden;
                }

                .guide-card-meta {
                    display: flex;
                    gap: 10px;
                    flex-wrap: wrap;
                    margin-bottom: 10px;
                }

                .guide-card-badge {
                    display: inline-block;
                    padding: 4px 10px;
                    background: var(--accent);
                    color: var(--accent-foreground);
                    border-radius: 20px;
                    font-size: 0.75rem;
                    font-weight: 500;
                }

                .guide-card-author {
                    color: var(--muted-foreground);
                    font-size: 0.85rem;
                }

                .no-guides {
                    text-align: center;
                    padding: 60px 20px;
                    background: var(--card);
                    border-radius: var(--radius-lg);
                    border: 1px solid var(--border);
                }

                .no-guides h3 {
                    color: var(--foreground);
                    margin-bottom: 10px;
                }

                .no-guides p {
                    color: var(--muted-foreground);
                }
            </style>
        </head>

        <body>
            <!-- Shared Header -->
            <jsp:include page="/pages/shared/header.jsp" />

            <div class="page-container">
                <div class="page-header">
                    <h1>Repair Guides</h1>
                    <p>Learn how to fix things yourself with our community-created repair guides</p>
                </div>

                <!-- Filters -->
                <div class="filters-section">
                    <form class="filters-form" action="${pageContext.request.contextPath}/guides" method="get">
                        <div class="filter-group">
                            <label for="keyword"><i class="ph ph-magnifying-glass"></i> Search</label>
                            <input type="text" id="keyword" name="keyword" placeholder="Search guides..."
                                value="${keyword}">
                        </div>
                        <div class="filter-group">
                            <label for="mainCategory"><i class="ph ph-squares-four"></i> Category</label>
                            <select id="mainCategory" name="mainCategory" onchange="updateSubCategories()">
                                <option value="">Loading categories...</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="subCategory"><i class="ph ph-squares-four"></i> Sub-Category</label>
                            <select id="subCategory" name="subCategory">
                                <option value="">All Sub-Categories</option>
                            </select>
                        </div>
                        <div class="filter-buttons">
                            <button type="submit" class="btn-primary"><i class="ph ph-magnifying-glass"></i> Search</button>
                            <a href="${pageContext.request.contextPath}/guides" class="btn-secondary"><i class="ph ph-broom"></i> Clear</a>
                        </div>
                    </form>
                </div>

                <!-- Guides Grid -->
                <c:choose>
                    <c:when test="${not empty guides}">
                        <div class="guides-grid">
                            <c:forEach var="guide" items="${guides}">
                                <a href="${pageContext.request.contextPath}/guides/view?id=${guide.guideId}"
                                    class="guide-card">
                                    <c:choose>
                                        <c:when test="${not empty guide.mainImagePath}">
                                            <img src="${pageContext.request.contextPath}/${guide.mainImagePath}"
                                                alt="${guide.title}" class="guide-card-image">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="guide-card-image"
                                                style="display: flex; align-items: center; justify-content: center; font-size: 3rem;">
                                                <i class="ph ph-image-broken"></i></div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="guide-card-body">
                                        <h3 class="guide-card-title">${guide.title}</h3>
                                        <div class="guide-card-meta">
                                            <span class="guide-card-badge">${guide.mainCategory}</span>
                                            <span class="guide-card-badge">${guide.subCategory}</span>
                                            <span class="guide-card-badge"
                                                style="background: var(--muted); color: var(--foreground);"> <i class="ph ph-eye" style="margin-right:4px;"></i>
                                                ${guide.viewCount}</span>
                                        </div>
                                        <p class="guide-card-author">By ${guide.creatorName}</p>
                                    </div>
                                </a>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="no-guides">
                            <h3>No Guides Found</h3>
                            <p>Try adjusting your search or browse all categories.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>


            <script>
                // Dynamic category data loaded from server
                let categoriesData = [];
                const contextPath = '${pageContext.request.contextPath}';
                const currentMainCategory = '${mainCategory}';
                const currentSubCategory = '${subCategory}';

                // Load categories on page load
                document.addEventListener('DOMContentLoaded', function () {
                    loadCategories();
                });

                // Fetch categories from the server
                async function loadCategories() {
                    try {
                        const response = await fetch(contextPath + '/guides/categories');
                        const data = await response.json();
                        categoriesData = data.categories || [];
                        populateMainCategories();
                        updateSubCategories();
                    } catch (error) {
                        console.error('Failed to load categories:', error);
                        document.getElementById('mainCategory').innerHTML =
                            '<option value="">Failed to load categories</option>';
                    }
                }

                // Populate main category dropdown
                function populateMainCategories() {
                    const mainSelect = document.getElementById('mainCategory');
                    mainSelect.innerHTML = '<option value="">All Categories</option>';

                    categoriesData.forEach(cat => {
                        const option = document.createElement('option');
                        option.value = cat.name;
                        option.dataset.categoryId = cat.categoryId;
                        option.textContent = cat.name;
                        if (cat.name === currentMainCategory) {
                            option.selected = true;
                        }
                        mainSelect.appendChild(option);
                    });
                }

                // Update sub-category dropdown based on selected main category
                function updateSubCategories() {
                    const mainSelect = document.getElementById('mainCategory');
                    const subSelect = document.getElementById('subCategory');
                    subSelect.innerHTML = '<option value="">All Sub-Categories</option>';

                    const selectedOption = mainSelect.options[mainSelect.selectedIndex];
                    if (!selectedOption || !selectedOption.dataset.categoryId) {
                        return;
                    }

                    const categoryId = parseInt(selectedOption.dataset.categoryId);
                    const category = categoriesData.find(c => c.categoryId === categoryId);

                    if (category && category.subCategories) {
                        category.subCategories.forEach(sub => {
                            const option = document.createElement('option');
                            option.value = sub.name;
                            option.textContent = sub.name;
                            if (sub.name === currentSubCategory) {
                                option.selected = true;
                            }
                            subSelect.appendChild(option);
                        });
                    }
                }
            </script>
        </body>

        </html>