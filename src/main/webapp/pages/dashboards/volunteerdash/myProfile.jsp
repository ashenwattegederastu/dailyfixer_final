<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"volunteer".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/authentication/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>My Profile | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
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

                        /* Profile Specific Styles */
                        .profile-card {
                            background: var(--card);
                            border-radius: var(--radius-lg);
                            padding: 30px;
                            box-shadow: var(--shadow-sm);
                            border: 1px solid var(--border);
                            margin-top: 20px;
                        }

                        .profile-header {
                            display: flex;
                            align-items: center;
                            margin-bottom: 30px;
                            padding-bottom: 20px;
                            border-bottom: 1px solid var(--border);
                        }

                        .profile-image {
                            width: 80px;
                            height: 80px;
                            border-radius: 50%;
                            background: var(--muted);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin-right: 20px;
                            font-size: 2em;
                            color: var(--primary);
                            border: 2px solid var(--border);
                        }

                        .profile-info h3 {
                            font-size: 1.5em;
                            margin-bottom: 5px;
                            color: var(--foreground);
                        }

                        .profile-info .role {
                            color: var(--muted-foreground);
                            font-weight: 500;
                            text-transform: capitalize;
                            background: var(--secondary);
                            color: var(--secondary-foreground);
                            padding: 4px 12px;
                            border-radius: 20px;
                            font-size: 0.85em;
                            display: inline-block;
                        }

                        .profile-details {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                            gap: 20px;
                        }

                        .detail-section {
                            background: var(--muted);
                            padding: 20px;
                            border-radius: var(--radius-md);
                            border: 1px solid var(--border);
                        }

                        .detail-section h4 {
                            margin-bottom: 15px;
                            color: var(--primary);
                            font-size: 1.1em;
                            display: flex;
                            align-items: center;
                            gap: 8px;
                        }

                        .detail-row {
                            display: flex;
                            justify-content: space-between;
                            margin-bottom: 12px;
                            padding-bottom: 12px;
                            border-bottom: 1px solid var(--border);
                        }

                        .detail-row:last-child {
                            border-bottom: none;
                            margin-bottom: 0;
                            padding-bottom: 0;
                        }

                        .detail-label {
                            font-weight: 500;
                            color: var(--muted-foreground);
                        }

                        .detail-value {
                            color: var(--foreground);
                            font-weight: 600;
                        }

                        .profile-actions {
                            margin-top: 30px;
                            display: flex;
                            gap: 15px;
                            flex-wrap: wrap;
                            padding-top: 20px;
                            border-top: 1px solid var(--border);
                        }
                    </style>
                </head>

                <body>

                    <jsp:include page="/pages/dashboards/volunteerdash/sidebar.jsp" />

                    <main class="container">
                        <h2>My Profile</h2>
                        <p style="color: var(--muted-foreground); margin-bottom: 25px;">View and manage your volunteer
                            account information</p>

                        <div class="profile-card">
                            <div class="profile-header">
                                <div class="profile-image">
                                    👤
                                </div>
                                <div class="profile-info">
                                    <h3>${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</h3>
                                    <span class="role">${sessionScope.currentUser.role}</span>
                                </div>
                            </div>

                            <div class="profile-details">
                                <div class="detail-section">
                                    <h4>👤 Personal Information</h4>
                                    <div class="detail-row">
                                        <span class="detail-label">User ID</span>
                                        <span class="detail-value">#${sessionScope.currentUser.userId}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">First Name</span>
                                        <span class="detail-value">${sessionScope.currentUser.firstName}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Last Name</span>
                                        <span class="detail-value">${sessionScope.currentUser.lastName}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Username</span>
                                        <span class="detail-value">@${sessionScope.currentUser.username}</span>
                                    </div>
                                </div>

                                <div class="detail-section">
                                    <h4>📞 Contact Information</h4>
                                    <div class="detail-row">
                                        <span class="detail-label">Email</span>
                                        <span class="detail-value">${sessionScope.currentUser.email}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Phone</span>
                                        <span class="detail-value">${sessionScope.currentUser.phoneNumber}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">City</span>
                                        <span class="detail-value">${sessionScope.currentUser.city}</span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Status</span>
                                        <span class="detail-value" style="color: var(--primary);">Active</span>
                                    </div>
                                </div>
                            </div>

                            <div class="profile-actions">
                                <!-- Note: Linking to existing pages, maintaining original functionality -->
                                <form action="${pageContext.request.contextPath}/pages/authentication/resetPassword.jsp" method="get"
                                    style="display: inline;">
                                    <button type="submit" class="btn-secondary">Reset Password</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/pages/authentication/editProfile.jsp" method="get"
                                    style="display: inline;">
                                    <button type="submit" class="btn-primary">Edit Account Info</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/SoftDeleteUserServlet" method="post"
                                    style="display: inline;"
                                    onsubmit="return confirm('Are you sure you want to delete your account? This action cannot be undone.');">
                                    <button type="submit" class="btn-danger">Delete Account</button>
                                </form>
                            </div>
                        </div>
                    </main>
                </body>
                </html>