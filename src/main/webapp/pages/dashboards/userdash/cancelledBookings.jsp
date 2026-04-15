<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
                <%@ page import="com.dailyfixer.model.User" %>

                    <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                        !"user".equalsIgnoreCase(user.getRole().trim())) {
                        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); return; } %>
                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>Cancelled Bookings | Daily Fixer</title>
                            <link
                                href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                                rel="stylesheet">
                            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                        </head>

                        <body class="dashboard-layout">
                            <jsp:include page="sidebar.jsp" />

                            <main class="dashboard-container">
                                <header class="dashboard-header">
                                    <h1>Cancelled Bookings</h1>
                                    <p>View your denied or cancelled requests</p>
                                </header>

                                <div class="section">
                                    <div class="table-container">
                                        <c:choose>
                                            <c:when test="${empty cancelledBookings}">
                                                <div class="empty-state">
                                                    <h3>No Cancelled Bookings</h3>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <table>
                                                    <thead>
                                                        <tr>
                                                            <th>Service</th>
                                                            <th>Technician</th>
                                                            <th>Date & Time</th>
                                                            <th>Reason</th>
                                                            <th>Status</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="b" items="${cancelledBookings}">
                                                            <tr>
                                                                <td><strong>${b.serviceName}</strong><br><small>${b.problemDescription}</small>
                                                                </td>
                                                                <td>${b.technicianName}</td>
                                                                <td>
                                                                    <fmt:formatDate value="${b.bookingDate}"
                                                                        pattern="MMM dd, yyyy" /><br>
                                                                    <fmt:formatDate value="${b.bookingTime}"
                                                                        pattern="hh:mm a" type="time" />
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${not empty b.rejectionReason}">
                                                                            ${b.rejectionReason}
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                style="color: var(--muted-foreground);">No
                                                                                reason provided</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td><span class="status-badge priority-high"
                                                                        style="background: #fee2e2; color: #991b1b;">Cancelled</span>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </main>
                        </body>
                        </html>