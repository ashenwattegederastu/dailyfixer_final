<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Reset Password - Daily Fixer</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/resetPassword.css">
</head>
<body>

<header>
  <!-- Main Navbar -->
  <nav class="navbar">
    <div class="logo">Daily Fixer</div>
    <ul class="nav-links">
      <li><a href="${pageContext.request.contextPath}">Home</a></li>
      <li><a href="${pageContext.request.contextPath}/LogoutServlet">Log Out</a></li>
    </ul>
  </nav>

  <!-- Subnav -->
  <nav class="subnav">
    <div class="store-name">User Profile</div>
    <ul>
      <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/userdashmain.jsp">Dashboard</a></li>
      <li><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/myProfile.jsp">My Profile</a></li>
    </ul>
  </nav>
</header>

<div class="container">
  <h2>Reset Your Password</h2>

  <c:if test="${not empty errorMsg}">
    <div class="message error">${errorMsg}</div>
  </c:if>

  <c:if test="${not empty successMsg}">
    <div class="message success">${successMsg}</div>
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

    <div class="btn-container">
      <button type="submit">Reset Password</button>
      <button type="button" class="cancel" onclick="history.back()">Cancel</button>
    </div>
  </form>
</div>

<script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>

</body>
</html>
