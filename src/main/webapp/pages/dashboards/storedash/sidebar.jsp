<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    String firstName = currentUser != null && currentUser.getFirstName() != null ? currentUser.getFirstName() : "Store";
    String lastName  = currentUser != null && currentUser.getLastName()  != null ? currentUser.getLastName()  : "";
    String username  = currentUser != null && currentUser.getUsername()  != null ? currentUser.getUsername()  : "store";
    String avatarLetter = firstName.length() > 0 ? firstName.substring(0, 1).toUpperCase() : "S";
%>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />

<!-- Mobile Toggle Button -->
<button class="mobile-sidebar-toggle" id="mobile-sidebar-toggle" aria-label="Toggle Sidebar">
    <i class="ph ph-list"></i>
</button>

<!-- Mobile Overlay -->
<div class="sidebar-overlay" id="sidebar-overlay"></div>

<aside class="sidebar" id="store-sidebar">
    <div class="sidebar-header">
        <div class="logo">Daily Fixer</div>
        <div class="panel-name">Store Panel</div>
    </div>

    <div class="sidebar-nav">
        <h3>Navigation</h3>
        <ul>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp" id="nav-dashboard">
                    <i class="ph ph-presentation-chart"></i>
                    Dashboard
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp" id="nav-orders">
                    <i class="ph ph-package"></i>
                    Orders
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp" id="nav-delivery">
                    <i class="ph ph-truck"></i>
                    Up for Delivery
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp" id="nav-completed">
                    <i class="ph ph-check-circle"></i>
                    Completed Orders
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/ListProductsServlet" id="nav-catalogue">
                    <i class="ph ph-storefront"></i>
                    Catalogue
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/ListDiscountsServlet" id="nav-discounts">
                    <i class="ph ph-percent"></i>
                    Discounts
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/StoreReviewsServlet" id="nav-reviews">
                    <i class="ph ph-star"></i>
                    Customer Reviews
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp" id="nav-finances">
                    <i class="ph ph-chart-line-up"></i>
                    Finances
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp" id="nav-store">
                    <i class="ph ph-buildings"></i>
                    My Store
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp" id="nav-profile">
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

        if (currentPath.includes('/storedashmain.jsp')) {
            document.getElementById('nav-dashboard')?.classList.add('active');
        } else if (currentPath.includes('/orders.jsp')) {
            document.getElementById('nav-orders')?.classList.add('active');
        } else if (currentPath.includes('/upfordelivery.jsp')) {
            document.getElementById('nav-delivery')?.classList.add('active');
        } else if (currentPath.includes('/completedorders.jsp')) {
            document.getElementById('nav-completed')?.classList.add('active');
        } else if (currentPath.includes('/ListProductsServlet') || currentPath.includes('/addProduct') || currentPath.includes('/editProduct') || currentPath.includes('/productList')) {
            document.getElementById('nav-catalogue')?.classList.add('active');
        } else if (currentPath.includes('/ListDiscountsServlet') || currentPath.includes('/addDiscount') || currentPath.includes('/editDiscount') || currentPath.includes('/discountList')) {
            document.getElementById('nav-discounts')?.classList.add('active');
        } else if (currentPath.includes('/StoreReviewsServlet') || currentPath.includes('/storeReviews')) {
            document.getElementById('nav-reviews')?.classList.add('active');
        } else if (currentPath.includes('/finances.jsp')) {
            document.getElementById('nav-finances')?.classList.add('active');
        } else if (currentPath.includes('/myStore.jsp')) {
            document.getElementById('nav-store')?.classList.add('active');
        } else if (currentPath.includes('/myProfile.jsp')) {
            document.getElementById('nav-profile')?.classList.add('active');
        }

        // Mobile Sidebar Toggle Logic
        const mobileToggle = document.getElementById('mobile-sidebar-toggle');
        const sidebar = document.getElementById('store-sidebar');
        const overlay = document.getElementById('sidebar-overlay');

        if (mobileToggle && sidebar && overlay) {
            function toggleSidebar() {
                sidebar.classList.toggle('mobile-open');
                overlay.classList.toggle('active');
            }

            mobileToggle.addEventListener('click', toggleSidebar);
            overlay.addEventListener('click', toggleSidebar);
        }
    });
</script>
