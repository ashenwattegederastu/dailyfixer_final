<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>
            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"admin".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/authentication/login.jsp" ); return; } %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Store Dashboard | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    <style>
                        /* Main content offset for new sidebar */
                        .main-content {
                            flex: 1;
                            margin-left: 240px;
                            padding: 40px 30px;
                        }

                        @media (max-width: 900px) {
                            .main-content {
                                margin-left: 0 !important;
                                margin-top: 60px !important;
                                padding-top: 40px !important;
                            }
                        }
                    </style>
                </head>

                <body>

                    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

                    <main class="main-content">
                        <div class="dashboard-header">
                            <h1>Store Overview</h1>
                            <p>Monitor store performance, products, and sales.</p>
                        </div>

                        <!-- Quick Stats -->
                        <div class="stats-container">
                            <div class="stat-card">
                                <div class="number">${totalStores}</div>
                                <p>Total Registered Stores</p>
                            </div>
                            <div class="stat-card">
                                <div class="number">${totalProducts}</div>
                                <p>Total Products Listed</p>
                            </div>
                            <div class="stat-card">
                                <div class="number">${totalSalesToday}</div>
                                <p>Sales Today</p>
                            </div>
                            <div class="stat-card">
                                <div class="number">LKR ${revenueToday}</div>
                                <p>Revenue Today</p>
                            </div>
                            <div class="stat-card">
                                <div class="number">LKR ${revenueMonth}</div>
                                <p>Revenue This Month</p>
                            </div>
                        </div>

                        <div class="section">
                            <div style="display: flex; gap: 2rem; flex-wrap: wrap;">

                                <!-- Best Selling Items -->
                                <div style="flex: 1; min-width: 300px;">
                                    <h2>Best Selling Items</h2>
                                    <div class="stat-card" style="padding: 0; overflow: hidden;">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>Item Name</th>
                                                    <th>Quantity Sold</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${not empty bestSellingItems}">
                                                        <c:forEach var="item" items="${bestSellingItems}">
                                                            <tr>
                                                                <td>${item.productName}</td>
                                                                <td>${item.quantitySold}</td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <tr>
                                                            <td colspan="2" style="text-align:center;">No data available
                                                            </td>
                                                        </tr>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <!-- Latest Transactions -->
                                <div style="flex: 2; min-width: 400px;">
                                    <h2>Transactions</h2>
                                    <div class="search-container">
                                        <form action="${pageContext.request.contextPath}/admin/store-dashboard"
                                            method="GET" style="display:flex; width:100%; gap:10px;">
                                            <input type="text" name="search"
                                                placeholder="Search by Order ID, Customer, or Email"
                                                class="search-input" value="${param.search}">
                                            <button type="submit" class="action-btn btn-view">Search</button>
                                            <c:if test="${not empty param.search}">
                                                <a href="${pageContext.request.contextPath}/admin/store-dashboard"
                                                    class="action-btn btn-dismiss"
                                                    style="display:flex;align-items:center;">Clear</a>
                                            </c:if>
                                        </form>
                                    </div>

                                    <div class="table-container">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>Order ID</th>
                                                    <th>Customer</th>
                                                    <th>Amount</th>
                                                    <th>Status</th>
                                                    <th>Date</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${not empty transactions}">
                                                        <c:forEach var="order" items="${transactions}">
                                                            <tr>
                                                                <td>${order.orderId}</td>
                                                                <td>${order.firstName} <c:if
                                                                        test="${not empty order.lastName}">
                                                                        ${order.lastName}</c:if>
                                                                </td>
                                                                <td class="amount">${order.amount} ${order.currency}
                                                                </td>
                                                                <td>
                                                                    <span class="
                                                        <c:choose>
                                                            <c:when test=" ${order.status=='PAID' }">status-completed
                                                    </c:when>
                                                    <c:when test="${order.status == 'PENDING'}">status-pending</c:when>
                                                    <c:when test="${order.status == 'CANCELLED'}">status-failed</c:when>
                                                    <c:otherwise>status-dismissed</c:otherwise>
                                                </c:choose>
                                                ">${order.status}</span>
                                                </td>
                                                <td>${order.createdAt}</td>
                                                </tr>
                                                </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="5" style="text-align:center;">No transactions found
                                                        </td>
                                                    </tr>
                                                </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </main>
                </body>
                </html>