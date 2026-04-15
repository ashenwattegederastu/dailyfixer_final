<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Store" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.dao.StoreDAO" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
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

    // Resolve current store and load delivered assignments.
    StoreDAO storeDAO = new StoreDAO();
    Store currentStore = storeDAO.getStoreByUsername(user.getUsername());
    int storeId = currentStore != null ? currentStore.getStoreId() : 0;

    DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    List<DeliveryAssignment> allAssignments = storeId > 0 ? assignmentDAO.getByStore(storeId) : new ArrayList<>();
    List<DeliveryAssignment> deliveredAssignments = new ArrayList<>();

    for (DeliveryAssignment assignment : allAssignments) {
        String assignmentStatus = assignment.getStatus() != null ? assignment.getStatus().trim().toUpperCase() : "";
        if ("DELIVERED".equals(assignmentStatus)) {
            deliveredAssignments.add(assignment);
        }
    }

    OrderDAO orderDAO = new OrderDAO();
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Completed Orders | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-tables.css">
</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp" class="active">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Completed Orders</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Order Date</th>
                <th>Delivery Date</th>
                <th>Status</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% if (deliveredAssignments.isEmpty()) { %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 30px; color: var(--muted-foreground);">
                        No completed orders yet.
                    </td>
                </tr>
            <% } else {
                for (DeliveryAssignment assignment : deliveredAssignments) {
                    Order order = orderDAO.findOrderById(assignment.getOrderId());

                    String customerName = assignment.getCustomerName();
                    if ((customerName == null || customerName.trim().isEmpty()) && order != null) {
                        String firstName = order.getFirstName() != null ? order.getFirstName() : "";
                        String lastName = order.getLastName() != null ? order.getLastName() : "";
                        customerName = (firstName + " " + lastName).trim();
                    }
                    if (customerName == null || customerName.trim().isEmpty()) {
                        customerName = "—";
                    }

                    String orderDate = (order != null && order.getCreatedAt() != null)
                        ? dateFormat.format(order.getCreatedAt()) : "—";
                    String deliveryDate = assignment.getCompletedAt() != null
                        ? dateFormat.format(assignment.getCompletedAt()) : "—";

                    String totalDisplay = "LKR 0.00";
                    if (order != null && order.getAmount() != null) {
                        String currency = (order.getCurrency() != null && !order.getCurrency().trim().isEmpty())
                            ? order.getCurrency().trim() : "LKR";
                        totalDisplay = currency + " " + String.format("%,.2f", order.getAmount());
                    }
            %>
                <tr>
                    <td><%= assignment.getOrderId() %></td>
                    <td><%= customerName %></td>
                    <td><%= orderDate %></td>
                    <td class="delivery-date"><%= deliveryDate %></td>
                    <td><span class="status delivered"></span>Delivered</td>
                    <td><%= totalDisplay %></td>
                    <td>
                        <button class="btn review-btn"
                                onclick="window.location.href='${pageContext.request.contextPath}/StoreReviewsServlet'">
                            View Reviews
                        </button>
                    </td>
                </tr>
            <%  }
            } %>
        </tbody>
    </table>
</main>
</body>
</html>
