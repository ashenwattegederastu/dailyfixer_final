<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    String sidebarPage;
    String profilePath;

    switch (user.getRole().toLowerCase()) {
        case "driver":
            sidebarPage = "/pages/dashboards/driverdash/sidebar.jsp";
            profilePath = "/pages/dashboards/driverdash/myProfile.jsp";
            break;
        case "volunteer":
            sidebarPage = "/pages/dashboards/volunteerdash/sidebar.jsp";
            profilePath = "/pages/dashboards/volunteerdash/myProfile.jsp";
            break;
        case "technician":
            sidebarPage = "/pages/dashboards/techniciandash/sidebar.jsp";
            profilePath = "/technician/profile";
            break;
        case "admin":
            sidebarPage = "/pages/dashboards/admindash/sidebar.jsp";
            profilePath = "/pages/dashboards/admindash/admindashmain.jsp";
            break;
        case "store":
            sidebarPage = "/pages/dashboards/storedash/sidebar.jsp";
            profilePath = "/pages/dashboards/storedash/myProfile.jsp";
            break;
        default:
            sidebarPage = "/pages/dashboards/userdash/sidebar.jsp";
            profilePath = "/pages/dashboards/userdash/myProfile.jsp";
            break;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
</head>
<body class="dashboard-layout" style="margin: 0; padding: 0;">

<jsp:include page="<%= sidebarPage %>" />

<main class="dashboard-container">
    <header class="dashboard-header" style="max-width: 600px; margin: 0 auto; margin-bottom: 20px;">
        <h1>Reset Password</h1>
        <p>Update your account password below.</p>
    </header>

    <div class="form-container">
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-error">${errorMsg}</div>
        </c:if>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success">${successMsg}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/ResetPasswordServlet" method="post">
            <div class="form-group">
                <label for="currentPassword">Current Password</label>
                <input type="password" id="currentPassword" name="currentPassword" required>
            </div>

            <div class="form-group">
                <label for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" minlength="6" required>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm New Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" minlength="6" required>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-primary">Reset Password</button>
                <a href="<%= request.getContextPath() + profilePath %>" class="btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>

</body>
</html>
