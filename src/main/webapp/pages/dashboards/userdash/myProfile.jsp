<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<% 
    User user=(User) session.getAttribute("currentUser"); 
    if (user==null || user.getRole()==null || !"user".equalsIgnoreCase(user.getRole().trim())) { 
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); 
        return; 
    } 
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    
    <style>
        /* Profile specific styles that build upon framework */
        .profile-wrapper {
            max-width: 1000px;
            margin: 0 auto;
            width: 100%;
        }

        .profile-card {
            background-color: var(--card);
            color: var(--card-foreground);
            border-radius: var(--radius-lg);
            padding: 30px;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border);
            margin-bottom: 30px;
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--muted);
        }

        .profile-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 4px solid var(--primary);
            object-fit: cover;
            box-shadow: var(--shadow-md);
        }

        .profile-info h3 {
            font-size: 1.8rem;
            margin-bottom: 5px;
            color: var(--foreground);
        }

        .profile-info .role {
            color: var(--primary);
            font-weight: 600;
            font-size: 1.1rem;
            text-transform: capitalize;
        }

        .profile-info .member-since {
            color: var(--muted-foreground);
            font-size: 0.9rem;
            margin-top: 5px;
        }

        .profile-details {
            background-color: var(--muted);
            border-radius: var(--radius-md);
            padding: 20px;
            margin-bottom: 30px;
        }

        .profile-details h4 {
            font-size: 1.2rem;
            margin-bottom: 15px;
            color: var(--foreground);
            border-bottom: 1px solid var(--border);
            padding-bottom: 10px;
        }

        .details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .detail-label {
            font-weight: 600;
            color: var(--foreground);
            font-size: 0.95rem;
        }

        .detail-value {
            color: var(--muted-foreground);
            font-size: 1rem;
        }

        .profile-actions {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
    </style>
</head>

<body class="dashboard-layout" style="margin: 0; padding: 0;">

    <jsp:include page="sidebar.jsp" />

    <main class="dashboard-container">
        <div class="profile-wrapper">
            <header class="dashboard-header">
                <h1>My Profile</h1>
            </header>

            <div class="profile-card">
                <div class="profile-header">
                    <img src="${pageContext.request.contextPath}/assets/images/default-profile.png" alt="Profile Picture" class="profile-image">
                    <div class="profile-info">
                        <h3>${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</h3>
                        <div class="role">${sessionScope.currentUser.role}</div>
                    </div>
                </div>

                <div class="profile-details">
                    <h4>Account Information</h4>
                    <div class="details-grid">
                        <div class="detail-item">
                            <span class="detail-label">First Name:</span>
                            <span class="detail-value">${sessionScope.currentUser.firstName}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Last Name:</span>
                            <span class="detail-value">${sessionScope.currentUser.lastName}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Username:</span>
                            <span class="detail-value">${sessionScope.currentUser.username}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Email:</span>
                            <span class="detail-value">${sessionScope.currentUser.email}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Phone:</span>
                            <span class="detail-value">${sessionScope.currentUser.phoneNumber}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">City:</span>
                            <span class="detail-value">${sessionScope.currentUser.city}</span>
                        </div>
                    </div>
                </div>

                <div class="profile-actions">
                    <form action="${pageContext.request.contextPath}/pages/authentication/resetPassword.jsp" method="get" style="display: inline;">
                        <button type="submit" class="btn-danger">Reset Password</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/pages/authentication/editProfile.jsp" method="get" style="display: inline;">
                        <button type="submit" class="btn-primary">Edit Profile</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/SoftDeleteUserServlet" method="post" style="display: inline;"
                          onsubmit="return confirm('Are you sure you want to delete your account? This action cannot be undone.');">
                        <button type="submit" class="btn-danger">Delete Account</button>
                    </form>
                </div>
            </div>
        </div>
    </main>
</body>
</html>