<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    String firstName = currentUser != null && currentUser.getFirstName() != null ? currentUser.getFirstName() : "Driver";
    String lastName  = currentUser != null && currentUser.getLastName()  != null ? currentUser.getLastName()  : "";
    String username  = currentUser != null && currentUser.getUsername()  != null ? currentUser.getUsername()  : "driver";
    String avatarLetter = firstName.length() > 0 ? firstName.substring(0, 1).toUpperCase() : "D";
%>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />

<aside class="sidebar">
    <div class="sidebar-header">
        <div class="logo">Daily Fixer</div>
        <div class="panel-name">Driver Panel</div>
    </div>

    <div class="sidebar-nav">
        <h3>Navigation</h3>
        <ul>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/driverdashmain.jsp" id="nav-dashboard">
                    <i class="ph ph-presentation-chart"></i>
                    Dashboard
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp" id="nav-vehicles">
                    <i class="ph ph-van"></i>
                    Vehicle Management
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/deliveryrequests.jsp" id="nav-requests">
                    <i class="ph ph-map-pin-area"></i>
                    Delivery Requests
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/acceptedOrders.jsp" id="nav-accepted">
                    <i class="ph ph-package"></i>
                    Accepted Orders
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp" id="nav-completed">
                    <i class="ph ph-check-square-offset"></i>
                    Completed Orders
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/help/driverprocedure.jsp" id="nav-procedure">
                    <i class="ph ph-list-checks"></i>
                    Delivery Procedure
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/finances.jsp" id="nav-finances">
                    <i class="ph ph-wallet"></i>
                    Finances
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/myProfile.jsp" id="nav-profile">
                    <i class="ph ph-user"></i>
                    My Profile
                </a>
            </li>
        </ul>
    </div>

    <div class="sidebar-footer">
        <div class="user-profile-widget">
            <div class="user-avatar">
                <%= avatarLetter %>
            </div>
            <div class="user-info">
                <div class="user-name"><%= firstName %> <%= lastName %></div>
                <div class="user-handle">@<%= username %></div>
            </div>
        </div>

        <div class="sidebar-actions">
            <a href="${pageContext.request.contextPath}/logout" class="action-btn logout-btn">
                <i class="ph ph-sign-out"></i>
                Log Out
            </a>
        </div>
    </div>
</aside>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const currentPath = window.location.pathname;
        const navLinks = document.querySelectorAll('.sidebar-nav ul li a');

        navLinks.forEach(link => {
            const linkPath = new URL(link.href).pathname;
            if (currentPath.includes(linkPath) || currentPath === linkPath) {
                link.classList.add('active');
            }
        });

        // Special handling for sub-pages
        if (currentPath.includes('/vehicleManagement') || currentPath.includes('/editVehicle')) {
            document.getElementById('nav-vehicles')?.classList.add('active');
        } else if (currentPath.includes('/deliveryrequests')) {
            document.getElementById('nav-requests')?.classList.add('active');
        } else if (currentPath.includes('/acceptedOrders')) {
            document.getElementById('nav-accepted')?.classList.add('active');
        } else if (currentPath.includes('/completedOrders')) {
            document.getElementById('nav-completed')?.classList.add('active');
        } else if (currentPath.includes('/driverprocedure')) {
            document.getElementById('nav-procedure')?.classList.add('active');
        } else if (currentPath.includes('/myProfile')) {
            document.getElementById('nav-profile')?.classList.add('active');
        }
    });
</script>
