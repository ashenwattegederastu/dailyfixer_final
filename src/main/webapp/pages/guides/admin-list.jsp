<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>
            <%@ page import="com.dailyfixer.dao.GuideDAO" %>
                <%@ page import="com.dailyfixer.model.Guide" %>
                    <%@ page import="java.util.List" %>

                        <% User user=(User) session.getAttribute("currentUser"); if (user==null ||
                            !"admin".equals(user.getRole())) { response.sendRedirect(request.getContextPath()
                            + "/pages/authentication/login.jsp" ); return; } GuideDAO guideDAO=new GuideDAO(); String
                            filter=request.getParameter("filter"); List<Guide> guides;

                            if ("mine".equals(filter)) {
                            guides = guideDAO.getGuidesByCreator(user.getUserId());
                            } else {
                            guides = guideDAO.getAllGuidesAdmin();
                            }
                            request.setAttribute("guides", guides);
                            request.setAttribute("filter", filter);
                            %>

                            <!DOCTYPE html>
                            <html lang="en">

                            <head>
                                <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                <title>Manage Guides | Admin | Daily Fixer</title>
                                <link
                                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
                                    rel="stylesheet">
                                <link rel="stylesheet"
                                    href="${pageContext.request.contextPath}/assets/css/framework.css">
                                <style>
                                    /* Main content offset for new sidebar */
                                    .main-content {
                                        flex: 1;
                                        margin-left: 240px;
                                        margin-top: 83px;
                                        padding: 40px 30px;
                                    }

                                    @media (max-width: 900px) {
                                        .main-content {
                                            margin-left: 0 !important;
                                            margin-top: 60px !important;
                                            padding-top: 40px !important;
                                        }
                                    }

                                    .page-header {
                                        display: flex;
                                        justify-content: space-between;
                                        align-items: center;
                                        margin-bottom: 20px;
                                    }

                                    .page-header h1 {
                                        font-size: 1.8rem;
                                        color: var(--foreground);
                                    }

                                    .filter-bar {
                                        display: flex;
                                        gap: 15px;
                                        margin-bottom: 25px;
                                    }

                                    .filter-btn {
                                        padding: 10px 20px;
                                        border: 2px solid var(--border);
                                        border-radius: var(--radius-md);
                                        background: transparent;
                                        color: var(--foreground);
                                        cursor: pointer;
                                        font-weight: 500;
                                        text-decoration: none;
                                    }

                                    .filter-btn.active {
                                        background: var(--primary);
                                        color: var(--primary-foreground);
                                        border-color: var(--primary);
                                    }

                                    .success-message {
                                        background: oklch(0.6290 0.1902 156.4499);
                                        color: white;
                                        padding: 15px;
                                        border-radius: var(--radius-md);
                                        margin-bottom: 20px;
                                    }

                                    .guides-table {
                                        width: 100%;
                                        background: var(--card);
                                        border-radius: var(--radius-lg);
                                        overflow: hidden;
                                        border: 1px solid var(--border);
                                    }

                                    .guides-table th,
                                    .guides-table td {
                                        padding: 15px;
                                        text-align: left;
                                        border-bottom: 1px solid var(--border);
                                    }

                                    .guides-table th {
                                        background: var(--muted);
                                        font-weight: 600;
                                        color: var(--foreground);
                                    }

                                    .guides-table tr:hover {
                                        background: var(--accent);
                                    }

                                    .guide-thumb {
                                        width: 80px;
                                        height: 60px;
                                        object-fit: cover;
                                        border-radius: var(--radius-sm);
                                    }

                                    .guide-title-cell {
                                        font-weight: 500;
                                        color: var(--foreground);
                                    }

                                    .guide-category {
                                        font-size: 0.85rem;
                                        color: var(--muted-foreground);
                                    }

                                    .guide-author {
                                        font-size: 0.85rem;
                                    }

                                    .action-btns {
                                        display: flex;
                                        gap: 8px;
                                    }

                                    .no-guides {
                                        text-align: center;
                                        padding: 60px;
                                        background: var(--card);
                                        border-radius: var(--radius-lg);
                                        border: 1px solid var(--border);
                                    }
                                </style>
                            </head>

                            <body>

                                <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

                                <main class="main-content">
                                    <div class="page-header">
                                        <h1>Manage Repair Guides</h1>
                                        <a href="${pageContext.request.contextPath}/guides/create" class="btn-primary">+
                                            Create New Guide</a>
                                    </div>

                                    <div class="filter-bar">
                                        <a href="${pageContext.request.contextPath}/pages/guides/admin-list.jsp"
                                            class="filter-btn ${empty filter ? 'active' : ''}">All Guides</a>
                                        <a href="${pageContext.request.contextPath}/pages/guides/admin-list.jsp?filter=mine"
                                            class="filter-btn ${filter == 'mine' ? 'active' : ''}">My Guides</a>
                                    </div>

                                    <c:if test="${param.success == 'created'}">
                                        <div class="success-message">Guide created successfully!</div>
                                    </c:if>
                                    <c:if test="${param.success == 'deleted'}">
                                        <div class="success-message">Guide deleted successfully!</div>
                                    </c:if>

                                    <c:choose>
                                        <c:when test="${not empty guides}">
                                            <table class="guides-table">
                                                <thead>
                                                    <tr>
                                                        <th>Image</th>
                                                        <th>Title</th>
                                                        <th>Category</th>
                                                        <th>Views</th>
                                                        <th>Author</th>
                                                        <th>Created</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="guide" items="${guides}">
                                                        <tr>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty guide.mainImagePath}">
                                                                        <img src="${pageContext.request.contextPath}/${guide.mainImagePath}"
                                                                            class="guide-thumb" alt="">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="guide-thumb"
                                                                            style="background: var(--muted); display: flex; align-items: center; justify-content: center;">
                                                                            📖</div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="guide-title-cell">${guide.title}</td>
                                                            <td>
                                                                <span
                                                                    class="guide-category">${guide.mainCategory}</span><br>
                                                                <span class="guide-category">${guide.subCategory}</span>
                                                            </td>
                                                            <td><span class="guide-category">${guide.viewCount}</span>
                                                            </td>
                                                            <td>
                                                                <span
                                                                    class="guide-author">${guide.creatorName}</span><br>
                                                                <span
                                                                    class="guide-category">(${guide.createdRole})</span>
                                                            </td>
                                                            <td><span class="guide-category">${guide.createdAt}</span>
                                                            </td>
                                                            <td>
                                                                <div class="action-btns">
                                                                    <a href="${pageContext.request.contextPath}/guides/view?id=${guide.guideId}"
                                                                        class="action-btn btn-view">View</a>
                                                                    <a href="${pageContext.request.contextPath}/guides/edit?id=${guide.guideId}"
                                                                        class="action-btn btn-resolve">Edit</a>
                                                                    <form
                                                                        action="${pageContext.request.contextPath}/guides/delete"
                                                                        method="post" style="display:inline;"
                                                                        onsubmit="return confirm('Delete this guide?');">
                                                                        <input type="hidden" name="id"
                                                                            value="${guide.guideId}">
                                                                        <button type="submit"
                                                                            class="action-btn btn-dismiss">Delete</button>
                                                                    </form>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="no-guides">
                                                <h3>No Guides Found</h3>
                                                <p style="color: var(--muted-foreground);">No guides in the system yet.
                                                </p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </main>
                            </body>
                            </html>