<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="com.dailyfixer.model.User" %>

        <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
            !"technician".equalsIgnoreCase(user.getRole())) { response.sendRedirect(request.getContextPath()
            + "/pages/authentication/login.jsp" ); return; } %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>My Profile | Daily Fixer</title>
                <!-- Use our shared framework font stack instead of directly loading Inter -->
                <link
                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                    rel="stylesheet">
                <!-- Include global framework.css for styles and dark mode -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">

                <style>
                    .profile-container {
                        background: var(--card);
                        padding: 30px;
                        border-radius: var(--radius-lg);
                        box-shadow: var(--shadow-sm);
                        max-width: 800px;
                        margin: 0 auto;
                        border: 1px solid var(--border);
                    }

                    .profile-header {
                        display: flex;
                        align-items: center;
                        margin-bottom: 30px;
                        padding-bottom: 20px;
                        border-bottom: 1px solid var(--border);
                    }

                    .profile-avatar {
                        width: 80px;
                        height: 80px;
                        border-radius: 50%;
                        background: var(--primary);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: var(--primary-foreground);
                        font-size: 2.5em;
                        font-weight: bold;
                        margin-right: 24px;
                        overflow: hidden;
                    }

                    .profile-avatar img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                    }

                    .about-section {
                        background: var(--muted);
                        padding: 24px;
                        border-radius: var(--radius-md);
                        border-left: 4px solid var(--primary);
                        grid-column: 1 / -1;
                    }

                    .about-section h4 {
                        margin-bottom: 12px;
                        color: var(--foreground);
                        font-size: 1.1em;
                    }

                    .about-section p {
                        color: var(--foreground);
                        line-height: 1.6;
                        white-space: pre-wrap;
                    }

                    .profile-info h3 {
                        margin-bottom: 5px;
                        color: var(--foreground);
                        font-size: 1.5em;
                    }

                    .profile-info p {
                        color: var(--muted-foreground);
                        margin-bottom: 5px;
                        font-weight: 500;
                    }

                    .profile-details {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                        gap: 24px;
                    }

                    .detail-section {
                        background: var(--muted);
                        padding: 24px;
                        border-radius: var(--radius-md);
                        border-left: 4px solid var(--primary);
                    }

                    .detail-section h4 {
                        margin-bottom: 16px;
                        color: var(--foreground);
                        font-size: 1.1em;
                    }

                    .detail-item {
                        display: flex;
                        justify-content: space-between;
                        margin-bottom: 12px;
                        padding-bottom: 8px;
                        border-bottom: 1px solid rgba(0, 0, 0, 0.05);
                    }

                    .dark-mode .detail-item {
                        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
                    }

                    .detail-item:last-child {
                        border-bottom: none;
                        margin-bottom: 0;
                    }

                    .detail-label {
                        font-weight: 600;
                        color: var(--muted-foreground);
                    }

                    .detail-value {
                        color: var(--foreground);
                        font-weight: 500;
                    }
                </style>
            </head>

            <body class="dashboard-layout">

                <jsp:include page="sidebar.jsp" />

                <main class="dashboard-container">

                    <div class="dashboard-header" style="margin-bottom: 24px;">
                        <h1>My Profile</h1>
                        <p>View and manage your personal and professional information.</p>
                    </div>

                    <div class="profile-container">
                        <div class="profile-header">
                            <div class="profile-avatar">
                                <% if (user.getProfilePicturePath() !=null && !user.getProfilePicturePath().isEmpty()) {
                                    %>
                                    <img src="<%= request.getContextPath() + "/" + user.getProfilePicturePath() %>"
                                    alt="Profile Picture">
                                    <% } else { %>
                                        <%= user.getFirstName() !=null && user.getFirstName().length()> 0 ?
                                            user.getFirstName().substring(0, 1).toUpperCase() :
                                            user.getUsername().substring(0,
                                            1).toUpperCase() %>
                                            <% } %>
                            </div>
                            <div class="profile-info">
                                <h3>
                                    <%= user.getFirstName() !=null ? user.getFirstName() + " " + user.getLastName() :
                                        user.getUsername() %>
                                </h3>
                                <p>@<%= user.getUsername() %> &bull; Technician</p>
                            </div>
                        </div>

                        <div class="profile-details">
                            <div class="detail-section">
                                <h4>Personal Information</h4>
                                <div class="detail-item">
                                    <span class="detail-label">Email:</span>
                                    <span class="detail-value">
                                        <%= user.getEmail() !=null ? user.getEmail() : "Not provided" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Phone Number:</span>
                                    <span class="detail-value">
                                        <%= user.getPhoneNumber() !=null ? user.getPhoneNumber() : "Not provided" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">City:</span>
                                    <span class="detail-value">
                                        <%= user.getCity() !=null ? user.getCity() : "Not provided" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">User ID:</span>
                                    <span class="detail-value">#<%= user.getUserId() %></span>
                                </div>
                            </div>

                            <div class="detail-section">
                                <h4>Professional Stats</h4>
                                <div class="detail-item">
                                    <span class="detail-label">Completed Bookings:</span>
                                    <span class="detail-value">
                                        <%= request.getAttribute("completedBookings") !=null ?
                                            request.getAttribute("completedBookings") : 0 %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Average Rating:</span>
                                    <span class="detail-value">N/A</span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Active Listings:</span>
                                    <span class="detail-value">
                                        <%= request.getAttribute("activeListings") !=null ?
                                            request.getAttribute("activeListings") : 0 %>
                                    </span>
                                </div>
                            </div>

                            <% if (user.getBio() !=null && !user.getBio().isEmpty()) { %>
                                <div class="about-section">
                                    <h4>About Me</h4>
                                    <p>
                                        <%= user.getBio() %>
                                    </p>
                                </div>
                                <% } %>
                        </div>

                        <div style="margin-top: 30px; display: flex; justify-content: flex-end;">
                            <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/technicianProfileEdit.jsp"
                                class="btn-primary" style="display: flex; align-items: center; gap: 8px;">
                                Edit Profile Details
                            </a>
                        </div>
                    </div>
                </main>
            </body>
            </html>