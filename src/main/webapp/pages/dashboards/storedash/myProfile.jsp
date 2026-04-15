<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    // Correctly get the user from session
    User user = (User) session.getAttribute("currentUser");

    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-profile.css">
</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp" class="active">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>My Profile</h2>
    
    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-image">
                ${sessionScope.currentUser.firstName.charAt(0)}${sessionScope.currentUser.lastName.charAt(0)}
            </div>
            <div class="profile-info">
                <h3>${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</h3>
                <div class="role">${sessionScope.currentUser.role}</div>
            </div>
        </div>

        <div class="profile-details">
            <table>
                <tr>
                    <th>Store ID:</th>
                    <td>${sessionScope.currentUser.userId}</td>
                </tr>
                <tr>
                    <th>First Name:</th>
                    <td>${sessionScope.currentUser.firstName}</td>
                </tr>
                <tr>
                    <th>Last Name:</th>
                    <td>${sessionScope.currentUser.lastName}</td>
                </tr>
                <tr>
                    <th>Username:</th>
                    <td>${sessionScope.currentUser.username}</td>
                </tr>
                <tr>
                    <th>Email:</th>
                    <td>${sessionScope.currentUser.email}</td>
                </tr>
                <tr>
                    <th>Phone:</th>
                    <td>${sessionScope.currentUser.phoneNumber}</td>
                </tr>
                <tr>
                    <th>City:</th>
                    <td>${sessionScope.currentUser.city}</td>
                </tr>
                <tr>
                    <th>Role:</th>
                    <td>${sessionScope.currentUser.role}</td>
                </tr>
            </table>
        </div>

        <div class="profile-buttons">
            <form action="${pageContext.request.contextPath}/pages/authentication/resetPassword.jsp" method="get">
                <button type="submit" class="btn reset-btn">Reset Password</button>
            </form>
            <form action="${pageContext.request.contextPath}/pages/authentication/editProfile.jsp" method="get">
                <button type="submit" class="btn edit-btn">Edit Account Info</button>
            </form>
            <form action="${pageContext.request.contextPath}/SoftDeleteUserServlet" method="post"
                  onsubmit="return confirm('Are you sure you want to delete your account? This action cannot be undone.');">
                <button type="submit" class="btn reset-btn">Delete Account</button>
            </form>
        </div>
    </div>
</main>
</body>
</html>
