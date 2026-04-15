<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ page import="com.dailyfixer.model.User" %>

<% 
    User user = (User) session.getAttribute("currentUser"); 
    if (user == null || user.getRole() == null || !"user".equalsIgnoreCase(user.getRole().trim())) { 
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp"); 
        return; 
    } 

    // If the dashboard metrics aren't loaded, redirect to the servlet to fetch them
    if (request.getAttribute("totalBookings") == null) {
        response.sendRedirect(request.getContextPath() + "/user/dashboard");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .recent-section {
            margin-top: 40px;
        }
        .recent-section h3 {
            margin-bottom: 20px;
            font-size: 1.3rem;
            color: var(--foreground);
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85rem;
            font-weight: 600;
            background-color: var(--muted);
            color: var(--foreground);
        }
    </style>
</head>

<body class="dashboard-layout" style="margin: 0; padding: 0;">
    <jsp:include page="sidebar.jsp" />

    <main class="dashboard-container">
        <div style="max-width: 1200px; margin: 0 auto; width: 100%;">
            <header class="dashboard-header">
                <div class="header-content">
                    <h1>Welcome back, ${sessionScope.currentUser.firstName}!</h1>
                    <p>Here is an overview of your activity on Daily Fixer.</p>
                </div>
            </header>

            <div class="stats-container">
                <div class="stat-card">
                    <p class="number">${activeBookings != null ? activeBookings : 0}</p>
                    <p>Active Bookings</p>
                </div>
                <div class="stat-card">
                    <p class="number">${totalPurchases != null ? totalPurchases : 0}</p>
                    <p>Total Purchases</p>
                </div>
                <div class="stat-card">
                    <p class="number">${pendingDeliveries != null ? pendingDeliveries : 0}</p>
                    <p>Pending Deliveries</p>
                </div>
            </div>

            <!-- User Stats -->
            <div class="section">
                <h2>User Activity Summary</h2>
                <div class="stats-container">
                    <div class="stat-card">
                        <p class="number">${totalBookings != null ? totalBookings : 0}</p>
                        <p>Total Bookings</p>
                    </div>
                    <div class="stat-card">
                        <p class="number">${completedBookings != null ? completedBookings : 0}</p>
                        <p>Completed Services</p>
                    </div>
                    <div class="stat-card">
                        <p class="number">Rs <fmt:formatNumber value="${totalSpent != null ? totalSpent : 0}" pattern="#,##0.00"/></p>
                        <p>Total Spent</p>
                    </div>
                </div>
            </div>

            <!-- Recent Bookings Table -->
            <div class="section recent-section">
                <h3>Recent Bookings</h3>
                <div class="table-container">
                    <c:choose>
                        <c:when test="${not empty recentBookings}">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Service</th>
                                        <th>Technician</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="booking" items="${recentBookings}">
                                        <tr>
                                            <td><fmt:formatDate value="${booking.bookingDate}" pattern="MMM dd, yyyy" /></td>
                                            <td>${booking.serviceName}</td>
                                            <td>${booking.technicianName}</td>
                                            <td><span class="status-badge">${booking.status}</span></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <p style="color: var(--muted-foreground); margin: 20px;">No recent bookings found.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Recent Orders Table -->
            <div class="section recent-section">
                <h3>Recent Purchases</h3>
                <div class="table-container">
                    <c:choose>
                        <c:when test="${not empty recentOrders}">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Date</th>
                                        <th>Product</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${recentOrders}">
                                        <tr>
                                            <td>${order.orderId}</td>
                                            <td><fmt:formatDate value="${order.createdAt}" pattern="MMM dd, yyyy" /></td>
                                            <td>${order.productName}</td>
                                            <td>Rs <fmt:formatNumber value="${order.amount}" pattern="#,##0.00"/></td>
                                            <td><span class="status-badge">${order.status}</span></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <p style="color: var(--muted-foreground); margin: 20px;">No recent purchases found.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </main>
</body>
</html>