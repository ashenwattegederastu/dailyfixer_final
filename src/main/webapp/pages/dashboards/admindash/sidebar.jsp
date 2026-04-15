<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ page import="com.dailyfixer.model.User" %>

        <% User currentUser=(User) session.getAttribute("currentUser"); String firstName=currentUser !=null &&
            currentUser.getFirstName() !=null ? currentUser.getFirstName() : "Admin" ; String lastName=currentUser
            !=null && currentUser.getLastName() !=null ? currentUser.getLastName() : "" ; String username=currentUser
            !=null && currentUser.getUsername() !=null ? currentUser.getUsername() : "admin" ; String
            avatarLetter=firstName.length()> 0 ? firstName.substring(0, 1).toUpperCase() : "A";
            %>
            <link rel="stylesheet" type="text/css"
                href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
            <link rel="stylesheet" type="text/css"
                href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
            <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />

            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo">Daily Fixer</div>
                    <div class="panel-name">Admin View</div>
                </div>

                <div class="sidebar-nav">
                    <h3>Navigation</h3>
                    <ul>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/dashboard"
                                id="nav-dashboard">
                                <i class="ph ph-presentation-chart"></i>
                                Dashboard
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/store-dashboard" id="nav-store">
                                <i class="ph ph-storefront"></i>
                                Store Dashboard
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/products" id="nav-products">
                                <i class="ph ph-package"></i>
                                Manage Products
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/users" id="nav-users">
                                <i class="ph ph-users"></i>
                                User Management
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/guides/admin-list.jsp" id="nav-guides">
                                <i class="ph ph-book-open-text"></i>
                                Manage Guides
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/flagged-guides" id="nav-flagged-guides">
                                <i class="ph ph-flag"></i>
                                Flagged Guides
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/admindash/diagnostic-trees.jsp"
                                id="nav-diagnostic">
                                <i class="ph ph-tree-structure"></i>
                                Diagnostic Trees
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/volunteer-requests"
                                id="nav-volunteer-requests">
                                <i class="ph ph-hand-heart"></i>
                                Volunteer Requests
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/driver-requests"
                                id="nav-driver-requests">
                                <i class="ph ph-steering-wheel"></i>
                                Driver Requests
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/technician-requests"
                                id="nav-technician-requests">
                                <i class="ph ph-toolbox"></i>
                                Technician Requests
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/deliveryRates"
                                id="nav-delivery-rates">
                                <i class="ph ph-truck"></i>
                                Delivery Rates
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/refunds"
                                id="nav-refunds">
                                <i class="ph ph-arrows-counter-clockwise"></i>
                                Refund Management
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/driver-incidents"
                                id="nav-driver-incidents">
                                <i class="ph ph-warning-circle"></i>
                                Driver Incidents
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/technician-penalties"
                                id="nav-technician-penalties">
                                <i class="ph ph-shield-warning"></i>
                                Technician Penalties
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/client-penalties"
                                id="nav-client-penalties">
                                <i class="ph ph-user-minus"></i>
                                Client Penalties
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/admindash/payouts.jsp"
                                id="nav-payouts">
                                <i class="ph ph-wallet"></i>
                                Payouts
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
                            <div class="user-name">
                                <%= firstName %>
                                    <%= lastName %>
                            </div>
                            <div class="user-handle">@<%= username %>
                            </div>
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
                // Highlight active navigation item based on current URL
                document.addEventListener('DOMContentLoaded', function () {
                    const currentPath = window.location.pathname;
                    const navLinks = document.querySelectorAll('.sidebar-nav ul li a');

                    navLinks.forEach(link => {
                        const linkPath = new URL(link.href).pathname;
                        if (currentPath.includes(linkPath) || currentPath === linkPath) {
                            link.classList.add('active');
                        }
                    });

                    // Special handling for servlet paths and varied query params
                    if (currentPath.includes('/admin/store-dashboard')) {
                        document.getElementById('nav-store')?.classList.add('active');
                    } else if (currentPath.includes('/admin/products')) {
                        document.getElementById('nav-products')?.classList.add('active');
                    } else if (currentPath.includes('/admin/users')) {
                        document.getElementById('nav-users')?.classList.add('active');
                    } else if (currentPath.includes('/admin-list.jsp')) {
                        document.getElementById('nav-guides')?.classList.add('active');
                    } else if (currentPath.includes('/diagnostic')) {
                        document.getElementById('nav-diagnostic')?.classList.add('active');
                    } else if (currentPath.includes('/volunteer-request')) {
                        document.getElementById('nav-volunteer-requests')?.classList.add('active');
                    } else if (currentPath.includes('/admin/dashboard') || currentPath.includes('/admindashmain.jsp')) {
                        document.getElementById('nav-dashboard')?.classList.add('active');
                    } else if (currentPath.includes('/deliveryRates')) {
                        document.getElementById('nav-delivery-rates')?.classList.add('active');
                    } else if (currentPath.includes('/admin/refunds')) {
                        document.getElementById('nav-refunds')?.classList.add('active');
                    } else if (currentPath.includes('/admin/driver-incidents')) {
                        document.getElementById('nav-driver-incidents')?.classList.add('active');
                    } else if (currentPath.includes('/admin/technician-penalties') || currentPath.includes('/lift-technician-penalty')) {
                        document.getElementById('nav-technician-penalties')?.classList.add('active');
                    } else if (currentPath.includes('/admin/client-penalties') || currentPath.includes('/admin/client-penalty-action')) {
                        document.getElementById('nav-client-penalties')?.classList.add('active');
                    } else if (currentPath.includes('/admin/driver-requests') || currentPath.includes('/driver-request')) {
                        document.getElementById('nav-driver-requests')?.classList.add('active');
                    } else if (currentPath.includes('/admin/technician-requests') || currentPath.includes('/technician-request')) {
                        document.getElementById('nav-technician-requests')?.classList.add('active');
                    }
                });

                function toggleTheme() {
                    const body = document.body;
                    const isDark = body.classList.toggle('dark-theme');
                    localStorage.setItem('theme', isDark ? 'dark' : 'light');
                }
            </script>