<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<% User user = (User) session.getAttribute("currentUser");
   if (user == null || (!"admin".equals(user.getRole()) &&
       !"volunteer".equals(user.getRole()) &&
       !"technician".equals(user.getRole()))) {
       response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
       return;
   }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hidden Guides | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
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

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .status-badge.hidden {
            background: #fef2f2;
            color: #dc2626;
        }

        .status-badge.pending {
            background: #fefce8;
            color: #854d0e;
        }

        .hide-reason {
            font-size: 0.85rem;
            color: var(--muted-foreground);
            margin-top: 4px;
        }

        .info-card {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: var(--radius-md);
            padding: 20px;
            margin-bottom: 25px;
            color: #1e40af;
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
                    <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()">🌙 Dark</button>
                    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
                </div>
            </header>

            <aside class="sidebar">
                <h3>Navigation</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/pages/dashboards/admindash/admindashmain.jsp">Dashboard</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/guides/my-guides.jsp">My Guides</a></li>
                    <li><a href="${pageContext.request.contextPath}/guides/flagged" class="active">Hidden Guides</a></li>
                    <li><a href="${pageContext.request.contextPath}/guides/create">Create Guide</a></li>
                    <li><a href="${pageContext.request.contextPath}/guides">View All Guides</a></li>
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
            <h1>Hidden Guides</h1>
            <a href="${pageContext.request.contextPath}/pages/guides/my-guides.jsp"
                style="padding: 10px 20px; border: 2px solid var(--border); border-radius: var(--radius-md); text-decoration: none; color: var(--foreground); font-weight: 500;">
                &larr; Back to My Guides
            </a>
        </div>

        <div class="info-card">
            <strong>What are hidden guides?</strong><br>
            These are guides that have been hidden by an admin due to community flags.
            You can edit a hidden guide to fix the issues. Once edited, it will be sent to admin for review
            and will be made visible again once approved.
        </div>

        <c:choose>
            <c:when test="${not empty guides}">
                <table class="guides-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Title</th>
                            <th>Status</th>
                            <th>Reason</th>
                            <th>Hidden Date</th>
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
                                    <c:choose>
                                        <c:when test="${guide.status == 'HIDDEN'}">
                                            <span class="status-badge hidden">Hidden</span>
                                        </c:when>
                                        <c:when test="${guide.status == 'PENDING_REVIEW'}">
                                            <span class="status-badge pending">Pending Review</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="hide-reason">${guide.hideReason}</span>
                                </td>
                                <td>
                                    <span class="guide-category">${guide.hiddenAt}</span>
                                </td>
                                <td>
                                    <div class="action-btns">
                                        <a href="${pageContext.request.contextPath}/guides/view?id=${guide.guideId}"
                                            class="action-btn btn-view">View</a>
                                        <c:if test="${guide.status == 'HIDDEN'}">
                                            <a href="${pageContext.request.contextPath}/guides/edit?id=${guide.guideId}"
                                                class="action-btn btn-resolve">Edit & Resubmit</a>
                                        </c:if>
                                        <c:if test="${guide.status == 'PENDING_REVIEW'}">
                                            <span class="guide-category" style="padding: 8px;">Awaiting review...</span>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="no-guides">
                    <h3>No Hidden Guides</h3>
                    <p style="color: var(--muted-foreground); margin-bottom: 20px;">
                        None of your guides have been hidden. Keep up the good work!
                    </p>
                    <a href="${pageContext.request.contextPath}/pages/guides/my-guides.jsp"
                        class="btn-primary">Back to My Guides</a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</body>

</html>
