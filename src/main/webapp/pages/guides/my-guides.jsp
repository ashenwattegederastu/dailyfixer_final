<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>
            <%@ page import="com.dailyfixer.dao.GuideDAO" %>
                <%@ page import="com.dailyfixer.model.Guide" %>
                    <%@ page import="java.util.List" %>

                        <% User user=(User) session.getAttribute("currentUser"); if (user==null ||
                            (!"admin".equals(user.getRole()) && !"volunteer".equals(user.getRole()) &&
                            !"technician".equals(user.getRole()))) { response.sendRedirect(request.getContextPath()
                            + "/pages/authentication/login.jsp" ); return; } GuideDAO guideDAO=new GuideDAO(); List<Guide> guides =
                            guideDAO.getGuidesByCreator(user.getUserId());
                            request.setAttribute("guides", guides);
                            %>

                            <!DOCTYPE html>
                            <html lang="en">

                            <head>
                                <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                <title>My Guides | Daily Fixer</title>
                                <link
                                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
                                    rel="stylesheet">
                                <link rel="stylesheet"
                                    href="${pageContext.request.contextPath}/assets/css/framework.css">
                                <c:if test="${sessionScope.currentUser.role == 'admin'}">
                                    <style>
                                        .topbar {
                                            position: fixed;
                                            top: 0;
                                            left: 0;
                                            right: 0;
                                            height: 76px;
                                            background-color: var(--card);
                                            border-bottom: 1px solid var(--border);
                                            display: flex;
                                            justify-content: space-between;
                                            align-items: center;
                                            padding: 0 30px;
                                            z-index: 200;
                                        }

                                        .topbar .logo {
                                            font-size: 1.5rem;
                                            font-weight: 700;
                                            color: var(--primary);
                                        }

                                        .topbar .panel-name {
                                            font-weight: 600;
                                            flex: 1;
                                            text-align: center;
                                            color: var(--foreground);
                                        }

                                        .sidebar {
                                            width: 240px;
                                            background-color: var(--card);
                                            height: 100vh;
                                            position: fixed;
                                            top: 0;
                                            left: 0;
                                            padding-top: 96px;
                                            border-right: 1px solid var(--border);
                                            z-index: 100;
                                        }

                                        .sidebar h3 {
                                            padding: 0 20px 15px;
                                            font-size: 0.85rem;
                                            color: var(--muted-foreground);
                                            text-transform: uppercase;
                                            letter-spacing: 0.5px;
                                        }

                                        .sidebar ul {
                                            list-style: none;
                                            padding: 0;
                                            margin: 0;
                                        }

                                        .sidebar li {
                                            margin-bottom: 5px;
                                        }

                                        .sidebar a {
                                            display: flex;
                                            align-items: center;
                                            padding: 12px 20px;
                                            color: var(--foreground);
                                            text-decoration: none;
                                            font-weight: 500;
                                            border-left: 3px solid transparent;
                                            transition: all 0.2s ease;
                                        }

                                        .sidebar a:hover,
                                        .sidebar a.active {
                                            background-color: var(--muted);
                                            color: var(--primary);
                                            border-left-color: var(--primary);
                                        }

                                        .main-content {
                                            margin-left: 240px;
                                            padding: 106px 30px 30px;
                                            min-height: 100vh;
                                        }
                                    </style>
                                </c:if>

                                <style>
                                    .page-header {
                                        display: flex;
                                        justify-content: space-between;
                                        align-items: center;
                                        margin-bottom: 30px;
                                    }

                                    .page-header h1 {
                                        font-size: 1.8rem;
                                        color: var(--foreground);
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

                                    .no-guides h3 {
                                        color: var(--foreground);
                                        margin-bottom: 15px;
                                    }
                                </style>
                            </head>

                            <body>

                                <c:choose>
                                    <c:when test="${sessionScope.currentUser.role == 'admin'}">
                                        <header class="topbar">
                                            <div class="logo">Daily Fixer</div>
                                            <div class="panel-name">Admin Panel</div>
                                            <div style="display: flex; align-items: center; gap: 10px;">
                                                <button id="theme-toggle-btn" class="theme-toggle"
                                                    onclick="toggleTheme()">🌙
                                                    Dark</button>
                                                <a href="${pageContext.request.contextPath}/logout"
                                                    class="logout-btn">Log
                                                    Out</a>
                                            </div>
                                        </header>

                                        <aside class="sidebar">
                                            <h3>Navigation</h3>
                                            <ul>
                                                <li><a
                                                        href="${pageContext.request.contextPath}/pages/dashboards/admindash/admindashmain.jsp">Dashboard</a>
                                                </li>
                                                <li><a href="${pageContext.request.contextPath}/pages/guides/my-guides.jsp"
                                                        class="active">My Guides</a></li>
                                                <li><a href="${pageContext.request.contextPath}/guides/create">Create
                                                        Guide</a>
                                                </li>
                                                <li><a href="${pageContext.request.contextPath}/guides">View All
                                                        Guides</a></li>
                                            </ul>
                                        </aside>
                                    </c:when>
                                    <c:when test="${sessionScope.currentUser.role == 'technician'}">
                                        <jsp:include page="/pages/dashboards/techniciandash/sidebar.jsp" />
                                    </c:when>
                                    <c:otherwise>
                                        <jsp:include page="/pages/dashboards/volunteerdash/sidebar.jsp" />
                                    </c:otherwise>
                                </c:choose>

                                <main class="main-content">
                                    <div class="page-header">
                                        <h1>My Guides</h1>
                                        <div style="display: flex; gap: 10px;">
                                            <a href="${pageContext.request.contextPath}/guides/flagged"
                                                class="btn-secondary"
                                                style="padding: 10px 20px; border: 2px solid var(--border); border-radius: var(--radius-md); text-decoration: none; color: var(--foreground); font-weight: 500;">
                                                Hidden Guides
                                            </a>
                                            <a href="${pageContext.request.contextPath}/guides/create" class="btn-primary">+
                                                Create New Guide</a>
                                        </div>
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
                                                <h3>No Guides Yet</h3>
                                                <p style="color: var(--muted-foreground); margin-bottom: 20px;">You
                                                    haven't created any guides yet. Start sharing your repair knowledge!
                                                </p>
                                                <a href="${pageContext.request.contextPath}/guides/create"
                                                    class="btn-primary">Create Your First Guide</a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </main>
                            </body>
                            </html>