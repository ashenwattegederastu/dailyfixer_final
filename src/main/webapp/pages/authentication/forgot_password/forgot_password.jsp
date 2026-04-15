<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - DailyFixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
</head>
<body>

<div class="login-container">
    <div style="position: fixed; top: 20px; right: 20px; z-index: 1000;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
    </div>
    <div class="login-card">
        <div class="login-header">
            <h1 class="login-title">Forgot Password</h1>
            <p class="login-subtitle">Enter your email to reset your password</p>
        </div>

        <% String message = (String) request.getAttribute("message");
            if (message != null) { %>
        <div class="alert alert-success"><%= message %></div>
        <% } %>

        <% String error = (String) request.getAttribute("error");
            if (error != null) { %>
        <div class="alert alert-error"><%= error %></div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/ForgotPasswordServlet" class="login-form">
            <div class="form-group">
                <label for="email" class="form-label">Email Address</label>
                <input
                        type="email"
                        id="email"
                        name="email"
                        class="form-input"
                        placeholder="Enter your registered email"
                        required>
            </div>

            <button type="submit" class="login-btn">Send Reset Link</button>
        </form>

        <div class="login-footer">
            <p class="footer-text">
                Remember your password?
                <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp" class="footer-link">Sign In</a>
            </p>
            <p class="footer-text">
                <a href="${pageContext.request.contextPath}/index.jsp" class="footer-link-secondary">← Back to Home</a>
            </p>
        </div>
    </div>
</div>
</body>
</html>
