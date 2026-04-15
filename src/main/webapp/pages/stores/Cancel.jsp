<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Payment Cancelled - DailyFixer">
    <title>Payment Cancelled - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/payment-status.css">
</head>

<body>
    <!-- Navigation -->
    <nav class="public-nav">
        <div class="nav-container">
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">Daily Fixer</a>
            <div style="display: flex; align-items: center; gap: 20px;">
                <div style="color: var(--text-muted); font-weight: 500;">Payment Status</div>
                <div class="nav-buttons">
                    <% if (isLoggedIn) { %>
                        <form action="<%=request.getContextPath()%>/logout" method="post" style="margin: 0; display: inline;">
                            <button type="submit" class="btn-logout">Logout</button>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
        <div class="result-card cancelled">
            <div class="result-icon cancelled">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <circle cx="12" cy="12" r="10"></circle>
                    <path d="M15 9l-6 6"></path>
                    <path d="M9 9l6 6"></path>
                </svg>
            </div>

            <h1 class="cancelled-title">Payment Cancelled</h1>
            <p class="subtitle">
                Your payment was cancelled or could not be completed.<br>
                Don't worry - no charges have been made to your account.
            </p>

            <div class="order-details">
                <div class="detail-row">
                    <span class="detail-label">Order ID</span>
                    <span class="detail-value" id="order-id">N/A</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status</span>
                    <span class="status-cancelled">CANCELLED</span>
                </div>
            </div>

            <div class="action-buttons">
                <a href="checkout.jsp" class="btn-primary">
                    🔄 Try Again
                </a>
                <a href="store_main.jsp" class="btn-secondary">
                    🛒 Back to Store
                </a>
            </div>

            <div class="info-box">
                <h3>Need Help?</h3>
                <p>If you're experiencing issues with payment, please contact us:</p>
                <div class="contact-info">
                    <p>📞 +94 11 234 5678</p>
                    <p>📧 support@dailyfixer.lk</p>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <p>&copy; 2026 DailyFixer. All rights reserved.</p>
    </footer>

    <script>
        // Get order info from URL params
        document.addEventListener('DOMContentLoaded', function () {
            const urlParams = new URLSearchParams(window.location.search);
            const orderId = urlParams.get('order_id');

            if (orderId) {
                document.getElementById('order-id').textContent = orderId;
            }
        });
    </script>
</body>
</html>
