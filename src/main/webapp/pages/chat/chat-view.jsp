<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
    <style>
        .chat-container {
            background-color: var(--card);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 75vh;
        }
        .chat-header {
            background-color: var(--primary);
            color: var(--primary-foreground);
            padding: 20px 30px;
            border-bottom: 1px solid var(--border);
        }
        .chat-header-layout {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .chat-avatar-wrapper {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            border: 2px solid rgba(255,255,255,0.4);
        }
        .chat-avatar-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .chat-avatar-wrapper .ph {
            font-size: 26px;
            color: white;
        }
        .chat-header h2 {
            font-size: 1.4rem;
            font-weight: 600;
            margin-bottom: 5px;
        }
        .chat-header p {
            font-size: 0.95rem;
            opacity: 0.9;
        }
        .messages-container {
            flex: 1;
            overflow-y: auto;
            padding: 30px;
            background-color: var(--background);
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        .message-row {
            display: flex;
        }
        .message-row.sent {
            justify-content: flex-end;
        }
        .message-row.received {
            justify-content: flex-start;
        }
        .message-bubble {
            max-width: 70%;
            padding: 12px 18px;
            border-radius: var(--radius-md);
        }
        .message-row.sent .message-bubble {
            background-color: var(--primary);
            color: var(--primary-foreground);
            border-bottom-right-radius: 4px;
            box-shadow: var(--shadow-sm);
        }
        .message-row.received .message-bubble {
            background-color: var(--card);
            color: var(--foreground);
            border: 1px solid var(--border);
            border-bottom-left-radius: 4px;
            box-shadow: var(--shadow-sm);
        }
        .message-text {
            margin-bottom: 5px;
            font-size: 0.95rem;
            line-height: 1.4;
        }
        .message-meta {
            font-size: 0.75rem;
            opacity: 0.8;
            text-align: right;
        }
        .chat-input-area {
            padding: 20px 30px;
            border-top: 1px solid var(--border);
            background-color: var(--card);
        }
        .chat-form {
            display: flex;
            gap: 15px;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            transition: opacity 0.2s;
        }
        .back-link:hover {
            opacity: 0.8;
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
        <div style="max-width: 900px; margin: 0 auto; width: 100%;">
            <div class="chat-container">
                <!-- Chat Header -->
                <div class="chat-header">
                    <div class="chat-header-layout">
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
                        
                        <div>
                            <h2>
                                <c:choose>
                                    <c:when test="${sessionScope.currentUser.role == 'technician'}">
                                        ${chat.userName}
                                    </c:when>
                                    <c:otherwise>
                                        ${chat.technicianName}
                                    </c:otherwise>
                                </c:choose>
                            </h2>

                        </div>
                    </div>
                </div>

                <!-- Messages Container -->
                <div id="messagesContainer" class="messages-container">
                    <c:forEach var="message" items="${messages}">
                        <div class="message-row ${message.senderId == sessionScope.currentUser.userId ? 'sent' : 'received'}">
                            <div class="message-bubble">
                                <p class="message-text">${message.message}</p>
                                <p class="message-meta">
                                    <c:choose>
                                        <c:when test="${message.senderId != sessionScope.currentUser.userId}">
                                            ${message.senderName} •
                                        </c:when>
                                    </c:choose>
                                    ${message.createdAt}
                                </p>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Message Input -->
                <div class="chat-input-area">
                    <form method="post" action="${pageContext.request.contextPath}/chats/send" class="chat-form">
                        <input type="hidden" name="chatId" value="${chat.chatId}">
                        <input type="text" name="message" class="search-input" required placeholder="Type your message...">
                        <button type="submit" class="btn-primary">Send</button>
                    </form>
                </div>
            </div>

            <div style="text-align: center;">
                <a href="${pageContext.request.contextPath}/chats" class="back-link">
                    &larr; Back to Chats
                </a>
            </div>
        </div>
    </main>
    <script>
        // Auto-scroll to bottom of messages
        const container = document.getElementById('messagesContainer');
        container.scrollTop = container.scrollHeight;

        // Poll for new messages every 5 seconds using AJAX
        let lastMessageCount = ${messages.size() != null ? messages.size() : 0};

        setInterval(function() {
            fetch('${pageContext.request.contextPath}/chats/messages?chatId=${chat.chatId}')
                .then(response => response.json())
                .then(data => {
                    if (data.messages && data.messages.length > lastMessageCount) {
                        // New messages available, reload page
                        location.reload();
                    }
                })
                .catch(err => console.error('Error polling messages:', err));
        }, 5000);
    </script>
</body>
</html>