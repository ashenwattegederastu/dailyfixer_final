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

        <form id="resetPasswordForm" action="${pageContext.request.contextPath}/ResetPasswordServlet" method="post" novalidate>
            <div class="form-group">
                <label for="currentPassword">Current Password</label>
                <input type="password" id="currentPassword" name="currentPassword" required>
                <span class="field-error" id="currentPassword-error"></span>
            </div>

            <div class="form-group">
                <label for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" minlength="6" required>
                <span class="field-error" id="newPassword-error"></span>
                <div class="password-strength" id="passwordStrength" style="display:none;">
                    <div class="strength-bar"><div id="strengthFill"></div></div>
                    <span id="strengthLabel"></span>
                </div>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm New Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" minlength="6" required>
                <span class="field-error" id="confirmPassword-error"></span>
            </div>

            <div class="form-actions">
                <button type="submit" id="submitBtn" class="btn-primary">Reset Password</button>
                <a href="<%= request.getContextPath() + profilePath %>" class="btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>

<style>
  .field-error {
    display: block;
    color: #e53935;
    font-size: 0.8rem;
    margin-top: 4px;
    min-height: 1.1em;
  }
  .password-strength {
    margin-top: 6px;
  }
  .strength-bar {
    height: 6px;
    background: #e0e0e0;
    border-radius: 3px;
    overflow: hidden;
    margin-bottom: 4px;
  }
  .strength-bar > div {
    height: 100%;
    width: 0;
    border-radius: 3px;
    transition: width 0.3s, background 0.3s;
  }
  #strengthLabel {
    font-size: 0.78rem;
    font-weight: 600;
  }
  input.input-invalid {
    border-color: #e53935 !important;
    outline-color: #e53935;
  }
  input.input-valid {
    border-color: #43a047 !important;
    outline-color: #43a047;
  }
</style>

<script>
(function () {
  'use strict';

  const currentPasswordInput = document.getElementById('currentPassword');
  const newPasswordInput     = document.getElementById('newPassword');
  const confirmPasswordInput = document.getElementById('confirmPassword');
  const submitBtn            = document.getElementById('submitBtn');
  const form                 = document.getElementById('resetPasswordForm');

  // --- helpers ---
  function setError(input, errorId, message) {
    const el = document.getElementById(errorId);
    el.textContent = message;
    input.classList.toggle('input-invalid', !!message);
    input.classList.toggle('input-valid',   !message && input.value.length > 0);
  }

  function getPasswordStrength(pwd) {
    let score = 0;
    if (pwd.length >= 8)                          score++;
    if (pwd.length >= 12)                         score++;
    if (/[A-Z]/.test(pwd))                        score++;
    if (/[0-9]/.test(pwd))                        score++;
    if (/[^A-Za-z0-9]/.test(pwd))                score++;
    return score;
  }

  // --- validators ---
  function validateCurrentPassword() {
    const val = currentPasswordInput.value;
    if (val.trim() === '') {
      setError(currentPasswordInput, 'currentPassword-error', 'Current password is required.');
      return false;
    }
    setError(currentPasswordInput, 'currentPassword-error', '');
    return true;
  }

  function validateNewPassword() {
    const val = newPasswordInput.value;
    const strengthEl  = document.getElementById('passwordStrength');
    const fillEl      = document.getElementById('strengthFill');
    const labelEl     = document.getElementById('strengthLabel');

    if (val.length === 0) {
      setError(newPasswordInput, 'newPassword-error', 'New password is required.');
      strengthEl.style.display = 'none';
      return false;
    }
    if (val.length < 6) {
      setError(newPasswordInput, 'newPassword-error', 'Password must be at least 6 characters.');
      strengthEl.style.display = 'none';
      return false;
    }

    // strength indicator
    strengthEl.style.display = 'block';
    const score = getPasswordStrength(val);
    const levels = [
      { label: 'Very Weak', color: '#e53935', width: '20%'  },
      { label: 'Weak',      color: '#fb8c00', width: '40%'  },
      { label: 'Fair',      color: '#fdd835', width: '60%'  },
      { label: 'Strong',    color: '#43a047', width: '80%'  },
      { label: 'Very Strong', color: '#1b5e20', width: '100%' },
    ];
    const level = levels[Math.min(score, 4)];
    fillEl.style.width      = level.width;
    fillEl.style.background = level.color;
    labelEl.textContent     = level.label;
    labelEl.style.color     = level.color;

    setError(newPasswordInput, 'newPassword-error', '');
    return true;
  }

  function validateConfirmPassword() {
    const val     = confirmPasswordInput.value;
    const newVal  = newPasswordInput.value;
    if (val.length === 0) {
      setError(confirmPasswordInput, 'confirmPassword-error', 'Please confirm your new password.');
      return false;
    }
    if (val !== newVal) {
      setError(confirmPasswordInput, 'confirmPassword-error', 'Passwords do not match.');
      return false;
    }
    setError(confirmPasswordInput, 'confirmPassword-error', '');
    return true;
  }

  // --- event listeners ---
  currentPasswordInput.addEventListener('input', validateCurrentPassword);
  currentPasswordInput.addEventListener('blur',  validateCurrentPassword);

  newPasswordInput.addEventListener('input', function () {
    validateNewPassword();
    if (confirmPasswordInput.value.length > 0) validateConfirmPassword();
  });
  newPasswordInput.addEventListener('blur', validateNewPassword);

  confirmPasswordInput.addEventListener('input', validateConfirmPassword);
  confirmPasswordInput.addEventListener('blur',  validateConfirmPassword);

  // --- block submission if invalid ---
  form.addEventListener('submit', function (e) {
    const ok = validateCurrentPassword() & validateNewPassword() & validateConfirmPassword();
    if (!ok) {
      e.preventDefault();
    }
  });
})();
</script>

</body>
</html>
