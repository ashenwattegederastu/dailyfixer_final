<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ page import="com.dailyfixer.model.User" %>

<% User user = (User) session.getAttribute("currentUser");
   if (user == null || user.getRole() == null || !"user".equalsIgnoreCase(user.getRole().trim())) {
       response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
       return;
   }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .notif-list {
            display: grid;
            gap: 0.75rem;
        }

        .notif-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1rem 1.25rem;
            display: grid;
            grid-template-columns: auto 1fr auto;
            align-items: start;
            gap: 0.9rem;
            transition: box-shadow 0.15s ease;
        }

        .notif-card:hover {
            box-shadow: var(--shadow-sm);
        }

        .notif-card.unread {
            border-left: 3px solid var(--primary);
            background: oklch(from var(--primary) l c h / 0.04);
        }

        .notif-dot {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background: var(--primary);
            margin-top: 6px;
            flex-shrink: 0;
        }

        .notif-dot.read {
            background: var(--border);
        }

        .notif-message {
            font-size: 0.9rem;
            color: var(--foreground);
            line-height: 1.5;
        }

        .notif-meta {
            font-size: 0.78rem;
            color: var(--muted-foreground);
            margin-top: 0.3rem;
        }

        .notif-booking-link {
            font-size: 0.78rem;
            color: var(--primary);
            text-decoration: underline;
            white-space: nowrap;
            margin-top: 4px;
        }

        .notif-timestamp {
            font-size: 0.75rem;
            color: var(--muted-foreground);
            white-space: nowrap;
            text-align: right;
            min-width: 90px;
        }

        .notif-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
            gap: 0.75rem;
        }

        .unread-badge {
            display: inline-block;
            background: var(--primary);
            color: var(--primary-foreground);
            font-size: 0.78rem;
            font-weight: 700;
            padding: 0.2rem 0.65rem;
            border-radius: 9999px;
            vertical-align: middle;
            margin-left: 0.5rem;
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            color: var(--muted-foreground);
        }
    </style>
</head>
<body class="dashboard-layout">
<jsp:include page="sidebar.jsp"/>

<main class="dashboard-container">
    <header class="dashboard-header">
        <div>
            <h1>Notifications
                <c:if test="${unreadCount > 0}">
                    <span class="unread-badge">${unreadCount} new</span>
                </c:if>
            </h1>
            <p>Updates about your bookings and reschedule requests</p>
        </div>
    </header>

    <div class="section">
        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state">
                    <h3>No Notifications</h3>
                    <p>You're all caught up. Notifications about your bookings will appear here.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="notif-list">
                    <c:forEach var="n" items="${notifications}">
                        <div class="notif-card ${n.read ? '' : 'unread'}">
                            <div class="notif-dot ${n.read ? 'read' : ''}"></div>
                            <div>
                                <div class="notif-message">${n.message}</div>
                                <div class="notif-meta">
                                    Booking #${n.bookingId} &nbsp;&mdash;&nbsp;
                                    <a href="${pageContext.request.contextPath}/user/bookings/active"
                                       class="notif-booking-link">View Active Bookings</a>
                                </div>
                            </div>
                            <div class="notif-timestamp">
                                <fmt:formatDate value="${n.createdAt}" pattern="MMM dd" /><br>
                                <fmt:formatDate value="${n.createdAt}" pattern="hh:mm a" />
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>
</body>
</html>
