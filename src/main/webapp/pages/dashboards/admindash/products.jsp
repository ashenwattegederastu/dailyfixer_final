<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>
            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"admin".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/authentication/login.jsp" ); return; } %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Manage Products | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    <style>
                        /* Main content offset for new sidebar */
                        .main-content {
                            flex: 1;
                            margin-left: 240px;
                            padding: 40px 30px;
                        }

                        @media (max-width: 900px) {
                            .main-content {
                                margin-left: 0 !important;
                                margin-top: 60px !important;
                                padding-top: 40px !important;
                            }
                        }
                    </style>
                </head>

                <body>

                    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

                    <main class="main-content">
                        <div class="dashboard-header">
                            <h1>Manage Products</h1>
                            <p>View, search, and delete products from the entire site.</p>
                        </div>

                        <div class="section">
                            <div class="search-container">
                                <form action="${pageContext.request.contextPath}/admin/products" method="GET"
                                    style="display:flex; width:100%; gap:10px;">
                                    <input type="text" name="search" placeholder="Search by Product Name or Description"
                                        class="search-input" value="${param.search}">
                                    <button type="submit" class="action-btn btn-view">Search</button>
                                    <c:if test="${not empty param.search}">
                                        <a href="${pageContext.request.contextPath}/admin/products"
                                            class="action-btn btn-dismiss"
                                            style="display:flex;align-items:center;">Clear</a>
                                    </c:if>
                                </form>
                            </div>

                            <c:if test="${not empty param.success}">
                                <div
                                    style="background-color: oklch(0.6290 0.1902 156.4499 / 0.2); color: oklch(0.6290 0.1902 156.4499); padding: 10px; border-radius: var(--radius-md); margin-bottom: 20px;">
                                    Product deleted successfully.
                                </div>
                            </c:if>

                            <c:if test="${not empty param.error}">
                                <div
                                    style="background-color: oklch(0.6290 0.1902 23.0704 / 0.2); color: var(--destructive); padding: 10px; border-radius: var(--radius-md); margin-bottom: 20px;">
                                    Failed to delete product. Please try again.
                                </div>
                            </c:if>

                            <div class="table-container">
                                <table>
                                    <thead>
                                        <tr>
                                            <th style="width: 80px;">Image</th>
                                            <th>Name</th>
                                            <th>Category</th>
                                            <th>Price</th>
                                            <th>Stock</th>
                                            <th>Store</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty products}">
                                                <c:forEach var="p" items="${products}">
                                                    <tr>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty p.imagePath}">
                                                                    <img src="${pageContext.request.contextPath}/${p.imagePath}"
                                                                        alt="${p.name}"
                                                                        style="width: 50px; height: 50px; object-fit: cover; border-radius: var(--radius-sm);">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div
                                                                        style="width: 50px; height: 50px; background-color: var(--muted); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; color: var(--muted-foreground); font-size: 0.8rem;">
                                                                        No Img</div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>${p.name}</td>
                                                        <td>${p.type}</td>
                                                        <td class="amount">
                                                            <c:choose>
                                                                <c:when test="${p.hasVariants}">
                                                                    ${p.minPrice} - ${p.maxPrice} LKR
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${p.price} LKR
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${p.hasVariants}">
                                                                    <c:choose>
                                                                        <c:when test="${p.variantQuantity > 0}">
                                                                            <span
                                                                                style="color: var(--primary); font-weight: 500;">${p.variantQuantity}
                                                                                (Total)</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                style="color: var(--destructive); font-weight: 500;">Out
                                                                                of Stock</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:choose>
                                                                        <c:when test="${p.quantity > 0}">
                                                                            <span
                                                                                style="color: var(--primary); font-weight: 500;">${p.quantity}
                                                                                ${p.quantityUnit}</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                style="color: var(--destructive); font-weight: 500;">Out
                                                                                of Stock</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>${p.storeUsername}</td>
                                                        <td>
                                                            <div style="display: flex; gap: 5px;">
                                                                <a href="${pageContext.request.contextPath}/product_details?productId=${p.productId}"
                                                                    target="_blank" class="action-btn btn-view"
                                                                    title="View Public Listing">View</a>
                                                                <form
                                                                    action="${pageContext.request.contextPath}/admin/products"
                                                                    method="POST"
                                                                    onsubmit="return confirm('Are you sure you want to delete this product? This action cannot be undone.');">
                                                                    <input type="hidden" name="action" value="delete">
                                                                    <input type="hidden" name="id"
                                                                        value="${p.productId}">
                                                                    <button type="submit" class="action-btn btn-dismiss"
                                                                        title="Delete Product">Delete</button>
                                                                </form>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="7" style="text-align:center;">No products found</td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </main>
                </body>
                </html>