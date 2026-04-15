<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chats - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
    <style>
        .chat-list-container {
            display: grid; 
            gap: 15px; 
            margin-top: 20px;
        }
        .chat-card {
            background-color: var(--card);
            border-radius: var(--radius-lg);
            padding: 20px;
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border);
            text-decoration: none;
            display: block;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .chat-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
        }
        .chat-card-layout {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        .chat-avatar-wrapper {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            overflow: hidden;
            background-color: var(--muted);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            border: 2px solid var(--border);
        }
        .chat-avatar-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .chat-avatar-wrapper .ph {
            font-size: 28px;
            color: var(--muted-foreground);
        }
        .chat-content {
            flex: 1;
            min-width: 0;
        }
        .chat-card h3 {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 5px;
            color: var(--foreground);
        }
        .chat-card .service-name {
            color: var(--primary);
            font-weight: 500;
            font-size: 0.9rem;
            margin-bottom: 8px;
        }
        .chat-card .last-message {
            color: var(--muted-foreground);
            font-size: 0.9rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .chat-card .unread-badge {
            display: inline-block;
            background-color: var(--destructive);
            color: var(--destructive-foreground);
            padding: 4px 10px;
            border-radius: var(--radius-md);
            font-size: 0.8rem;
            font-weight: 700;
        }
        .empty-chat {
            text-align: center;
            padding: 50px 20px;
            background-color: var(--card);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-md);
        }
        .empty-chat p {
            font-size: 1.1rem;
            color: var(--muted-foreground);
        }
    </style>
</head>
<body class="dashboard-layout" style="margin: 0; padding: 0;">
    <c:choose>
        <c:when test="${sessionScope.currentUser.role == 'technician'}">
            <jsp:include page="../dashboards/techniciandash/sidebar.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="../dashboards/userdash/sidebar.jsp" />
        </c:otherwise>
    </c:choose>

    <main class="dashboard-container">
        <div style="max-width: 800px; margin: 0 auto; width: 100%;">
            <header class="dashboard-header">
                <h1>My Chats</h1>
                <p>Manage your conversations.</p>
            </header>

            <c:if test="${empty chats}">
                <div class="empty-chat">
                    <p>No chats available yet.</p>
                </div>
            </c:if>

            <div class="chat-list-container">
                <c:forEach var="chat" items="${chats}">
                    <a href="${pageContext.request.contextPath}/chats/view?chatId=${chat.chatId}" class="chat-card">
                        <div class="chat-card-layout">
                            
                            <c:set var="targetProfilePic" value="${sessionScope.currentUser.role == 'technician' ? chat.userProfilePic : chat.technicianProfilePic}" />
                            
                            <div class="chat-avatar-wrapper">
                                <c:choose>
                                    <c:when test="${not empty targetProfilePic}">
                                        <img src="${pageContext.request.contextPath}/${targetProfilePic}" alt="Avatar">
                                    </c:when>
                                    <c:otherwise>
                                        <i class="ph ph-user-circle"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="chat-content">
                                <h3>
                                    <c:choose>
                                        <c:when test="${sessionScope.currentUser.role == 'technician'}">
                                            ${chat.userName}
                                        </c:when>
                                        <c:otherwise>
                                            ${chat.technicianName}
                                        </c:otherwise>
                                    </c:choose>
                                </h3>
                                <c:if test="${not empty chat.lastMessage}">
                                    <p class="last-message">${chat.lastMessage}</p>
                                </c:if>
                            </div>
                            <div style="text-align: right; flex-shrink: 0;">
                                <c:if test="${chat.unreadCount > 0}">
                                    <span class="unread-badge">${chat.unreadCount}</span>
                                </c:if>
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </div>
    </main>
</body>
</html>