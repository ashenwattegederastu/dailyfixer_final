<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - DailyFixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .password-wrapper {
            position: relative;
            width: 100%;
        }

        .form-input {
            width: 100%;
            padding-right: 70px; /* more space so text doesn't hit button */
            box-sizing: border-box;
        }

        .toggle-btn {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);

            background: transparent;
            border: none;
            color: #555;
            font-size: 14px;
            cursor: pointer;
        }

        .toggle-btn:hover {
            color: #000;
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-card">
        <!-- Added logo/branding section -->
        <div class="login-header">
            <h1 class="login-title">DailyFixer</h1>
            <p class="login-subtitle">Welcome back</p>
        </div>

        <!-- Improved message styling with better visual hierarchy -->
        <% String success = (String) session.getAttribute("successMsg");
            if (success != null) { %>
        <div class="alert alert-success"><%= success %></div>
        <% session.removeAttribute("successMsg"); } %>

        <% String loginError = (String) request.getAttribute("loginError");
            if (loginError != null) { %>
        <div class="alert alert-error"><%= loginError %></div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/login" class="login-form">
            <div class="form-group">
                <label for="username" class="form-label">Username</label>
                <input
                        type="text"
                        id="username"
                        name="username"
                        class="form-input"
                        placeholder="Enter your username"
                        required>
            </div>

            <div class="form-group">
                <label for="password" class="form-label">Password</label>
                <div class="password-input-wrapper">
                    <input
                            type="password"
                            id="password"
                            name="password"
                            class="form-input"
                            placeholder="Enter your password"
                            required>
                    <button type="button" class="toggle-btn" onclick="togglePassword()">Show</button>
                </div>
            </div>

            <!-- Improved button styling -->
            <button type="submit" class="login-btn">Sign In</button>
        </form>

        <!-- Better organized footer links with improved styling -->
        <div class="login-footer">
            <p class="footer-text">
                Don't have an account?
                <a href="${pageContext.request.contextPath}/pages/authentication/register/preliminarySignup.jsp" class="footer-link">Create one</a>
            </p>
            <p class="footer-text">
                <a href="${pageContext.request.contextPath}/pages/authentication/forgot_password/forgot_password.jsp" class="footer-link">Forgot your password?</a>
            </p>
            <p class="footer-text">
                <a href="${pageContext.request.contextPath}/index.jsp" class="footer-link-secondary">← Back to Home</a>
            </p>
        </div>
    </div>
</div>
<script>
    function togglePassword() {
        const input = document.getElementById("password");
        const btn = event.target;

        if (input.type === "password") {
            input.type = "text";
            btn.textContent = "Hide";
        } else {
            input.type = "password";
            btn.textContent = "Show";
        }
    }
</script>
</body>
</html>
