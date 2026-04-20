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
                    <title>User Management | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
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
                            <h1>User Management</h1>
                            <p>Manage all platform users and their roles.</p>
                        </div>

                        <!-- Search -->
                        <form method="get" action="${pageContext.request.contextPath}/admin/users" class="search-container">
                            <input type="text" name="search" class="search-input"
                                placeholder="Search users by name, email, or username..."
                                value="${searchTerm}">
                            <button type="submit" class="action-btn btn-activate">Search</button>
                        </form>

                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Name</th>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>City</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="user" items="${users}">
                                        <tr>
                                            <td>${user.userId}</td>
                                            <td>${user.firstName} ${user.lastName}</td>
                                            <td>${user.username}</td>
                                            <td>${user.email}</td>
                                            <td>${user.phoneNumber}</td>
                                            <td>${user.city}</td>
                                            <td>${user.role}</td>
                                            <td>
                                                <span class="status-${user.status}">
                                                    ${user.status}
                                                </span>
                                            </td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/admin/toggleUserStatus"
                                                    method="post" style="display:inline;">
                                                    <input type="hidden" name="userId" value="${user.userId}">
                                                    <input type="hidden" name="currentStatus" value="${user.status}">
                                                    <input type="hidden" name="search" value="${searchTerm}">
                                                    <button type="submit"
                                                        class="action-btn ${user.status == 'active' ? 'btn-suspend' : 'btn-activate'}">
                                                        ${user.status == 'active' ? 'Suspend' : 'Activate'}
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </main>



                </body>

                </html>