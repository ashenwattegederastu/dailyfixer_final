<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    List<DeliveryAssignment> completedList = assignmentDAO.getByDriver(user.getUserId(), "DELIVERED");

    BigDecimal totalEarnings = BigDecimal.ZERO;
    for (DeliveryAssignment a : completedList) {
        if (a.getDeliveryFeeEarned() != null) totalEarnings = totalEarnings.add(a.getDeliveryFeeEarned());
    }
    int totalCount = completedList.size();

    SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Completed Orders | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.container {
    flex: 1;
    margin-left: 240px;
    padding: 30px;
    background-color: var(--background);
}
.container h2 {
    font-size: 1.6em;
    margin-bottom: 20px;
    color: var(--foreground);
}

.stats-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}
.stat-card {
    background: var(--card);
    padding: 20px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    text-align: center;
    border: 1px solid var(--border);
}
.stat-card .number {
    font-size: 2em;
    font-weight: 700;
    color: var(--primary);
    margin-bottom: 8px;
}
.stat-card p {
    color: var(--muted-foreground);
    font-weight: 500;
}

table {
    width: 100%;
    border-collapse: collapse;
    background: var(--card);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
}
thead { background-color: var(--muted); }
th, td {
    padding: 15px 12px;
    text-align: left;
    border-bottom: 1px solid var(--border);
}
th {
    font-weight: 600;
    color: var(--foreground);
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
td {
    color: var(--muted-foreground);
    font-weight: 500;
}
tbody tr:hover { background-color: var(--muted); }
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Completed Orders</h2>

    <div class="stats-container">
        <div class="stat-card">
            <p class="number"><%= totalCount %></p>
            <p>Total Completed</p>
        </div>
        <div class="stat-card">
            <p class="number">LKR <%= String.format("%,.2f", totalEarnings) %></p>
            <p>Total Earned</p>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Pickup</th>
                <th>Dropoff</th>
                <th>Vehicle Type</th>
                <th>Delivery Fee</th>
                <th>Completed At</th>
            </tr>
        </thead>
        <tbody>
            <% if (completedList.isEmpty()) { %>
            <tr>
                <td colspan="7" style="text-align:center; padding:40px; color: var(--muted-foreground);">
                    No completed deliveries yet.
                </td>
            </tr>
            <% } else {
                for (DeliveryAssignment a : completedList) {
                    String customerName = a.getCustomerName() != null ? a.getCustomerName() : "—";
                    String pickup       = a.getPickupAddress() != null ? a.getPickupAddress() : a.getStoreName();
                    String dropoff      = a.getDeliveryAddress() != null ? a.getDeliveryAddress() : "—";
                    String feeStr       = a.getDeliveryFeeEarned() != null
                                          ? String.format("LKR %.2f", a.getDeliveryFeeEarned()) : "LKR 0.00";
                    String completedAt  = a.getCompletedAt() != null ? dtFmt.format(a.getCompletedAt()) : "—";
            %>
            <tr>
                <td><%= a.getOrderId() %></td>
                <td><%= customerName %></td>
                <td><%= pickup %></td>
                <td style="max-width: 180px; word-break: break-word;"><%= dropoff %></td>
                <td><%= a.getRequiredVehicleType() %></td>
                <td><strong><%= feeStr %></strong></td>
                <td><%= completedAt %></td>
            </tr>
            <% } } %>
        </tbody>
    </table>
</main>

</body>
</html>
