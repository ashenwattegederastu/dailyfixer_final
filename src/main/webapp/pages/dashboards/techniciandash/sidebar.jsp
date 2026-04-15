<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ page import="com.dailyfixer.model.User" %>
    <%@ page import="com.dailyfixer.dao.ChatDAO" %>

        <% User currentUser=(User) session.getAttribute("currentUser"); String firstName=currentUser !=null &&
            currentUser.getFirstName() !=null ? currentUser.getFirstName() : "Technician" ; String lastName=currentUser
            !=null && currentUser.getLastName() !=null ? currentUser.getLastName() : "" ; String username=currentUser
            !=null && currentUser.getUsername() !=null ? currentUser.getUsername() : "tech" ; String
            avatarLetter=firstName.length()> 0 ? firstName.substring(0, 1).toUpperCase() : "T";
            
            int unreadChatsCount = 0;
            if (currentUser != null) {
                try {
                    ChatDAO chatDAO = new ChatDAO();
                    unreadChatsCount = chatDAO.getTotalUnreadCountForUser(currentUser.getUserId());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            %>
            <link rel="stylesheet" type="text/css"
                href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
            <link rel="stylesheet" type="text/css"
                href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
            <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />

            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo">Daily Fixer</div>
                    <div class="panel-name">Technician View</div>
                </div>

                <div class="sidebar-nav">
                    <h3>Navigation</h3>
                    <ul>
                        <li>
                            <a href="${pageContext.request.contextPath}/technician/dashboard"
                                id="nav-dashboard">
                                <i class="ph ph-presentation-chart"></i>
                                Dashboard
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp"
                                id="nav-services">
                                <i class="ph ph-wrench"></i>
                                Service Listings
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/availability" id="nav-availability">
                                <i class="ph ph-calendar-dots"></i>
                                Set Availability
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/bookings/requests" id="nav-requests">
                                <i class="ph ph-envelope"></i>
                                Booking Requests
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/bookings/calendar" id="nav-calendar">
                                <i class="ph ph-clipboard-text"></i>
                                My Bookings
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/technician/bookings/completed"
                                id="nav-completed">
                                <i class="ph ph-check-square-offset"></i>
                                Completed Bookings
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/recurringContracts.jsp" id="nav-recurring">
                                <i class="ph ph-arrows-clockwise"></i>
                                Recurring Contracts
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/chats" id="nav-chats">
                                <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
                                    <div>
                                        <i class="ph ph-chats-circle"></i>
                                        Chats
                                    </div>
                                    <% if (unreadChatsCount > 0) { %>
                                        <span style="display: inline-flex; align-items: center; justify-content: center; background: var(--destructive, #ef4444); color: white; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; min-width: 1.25rem; height: 1.25rem; padding: 0 0.4rem; line-height: 1;">
                                            <%= unreadChatsCount %>
                                        </span>
                                    <% } %>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/technicianProfile.jsp"
                                id="nav-profile">
                                <i class="ph ph-user"></i>
                                My Profile
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/guides/my-guides.jsp" id="nav-my-guides">
                                <i class="ph ph-book-open-text"></i>
                                My Guides
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/guides/create" id="nav-create-guide">
                                <i class="ph ph-pencil-line"></i>
                                Create Guide
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/guideComments.jsp"
                                id="nav-guide-comments">
                                <i class="ph ph-chat-text"></i>
                                Guide Comments
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

                    // Special handling for servlet paths
                    if (currentPath.includes('/availability')) {
                        document.getElementById('nav-availability')?.classList.add('active');
                    } else if (currentPath.includes('/bookings/requests')) {
                        document.getElementById('nav-requests')?.classList.add('active');
                    } else if (currentPath.includes('/bookings/calendar')) {
                        document.getElementById('nav-calendar')?.classList.add('active');
                    } else if (currentPath.includes('/technician/bookings/completed')) {
                        document.getElementById('nav-completed')?.classList.add('active');
                    } else if (currentPath.includes('/chats')) {
                        document.getElementById('nav-chats')?.classList.add('active');
                    } else if (currentPath.includes('/my-guides')) {
                        document.getElementById('nav-my-guides')?.classList.add('active');
                    } else if (currentPath.includes('/guides/create')) {
                        document.getElementById('nav-create-guide')?.classList.add('active');
                    } else if (currentPath.includes('/guideComments')) {
                        document.getElementById('nav-guide-comments')?.classList.add('active');
                    }
                });
            </script>