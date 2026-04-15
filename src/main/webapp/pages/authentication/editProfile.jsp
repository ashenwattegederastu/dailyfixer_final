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
            profilePath = "/pages/dashboards/driverdash/technicianProfile.jsp";
            break;
        case "admin":
            sidebarPage = "/pages/dashboards/admindash/sidebar.jsp";
            profilePath = "/pages/dashboards/admindash/adminProfile.jsp";
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
    <title>Edit Profile - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .form-group select {
            width: 100%;
            padding: 10px 15px;
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            background-color: var(--input);
            color: var(--foreground);
            transition: border-color 0.2s, background-color 0.3s ease, color 0.3s ease;
            font-family: var(--font-sans), serif;
        }
        .form-group select:focus {
            outline: none;
            border-color: var(--ring);
        }
    </style>
</head>
<body class="dashboard-layout" style="margin: 0; padding: 0;">

<jsp:include page="<%= sidebarPage %>" />

<main class="dashboard-container">
    <header class="dashboard-header" style="max-width: 800px; margin: 0 auto; margin-bottom: 20px;">
        <h1>Edit Account Information</h1>
    </header>

    <div class="form-container">
        <form action="${pageContext.request.contextPath}/UpdateProfileServlet" method="post">
            <input type="hidden" name="userId" value="${sessionScope.currentUser.userId}">

            <div class="form-group">
                <label>First Name</label>
                <input type="text" name="firstName" value="${sessionScope.currentUser.firstName}" required>
            </div>

            <div class="form-group">
                <label>Last Name</label>
                <input type="text" name="lastName" value="${sessionScope.currentUser.lastName}" required>
            </div>

            <div class="form-group">
                <label>Phone Number</label>
                <input type="text" name="phoneNumber" value="${sessionScope.currentUser.phoneNumber}" required pattern="[0-9]{10}" title="Enter 10 digit phone number">
            </div>

            <div class="form-group">
                <label>City</label>
                <select name="city" required>
                    <option value="">Select City</option>
                    <c:forEach var="city" items="${['Colombo','Kandy','Galle','Matara','Jaffna','Kurunegala','Negombo','Anuradhapura','Ratnapura','Nuwara Eliya','Gampaha','Trincomalee','Badulla','Hambantota','Batticaloa','Kalutara','Polonnaruwa']}">
                        <option value="${city}" <c:if test="${sessionScope.currentUser.city == city}">selected</c:if>>${city}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-primary">Save Changes</button>
                <a href="<%= request.getContextPath() + profilePath %>" class="btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</main>
</body>
</html>
