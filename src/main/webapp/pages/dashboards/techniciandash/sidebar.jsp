<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ page import="com.dailyfixer.model.User" %>
    <%@ page import="com.dailyfixer.dao.ChatDAO" %>
    <%@ page import="com.dailyfixer.dao.TechnicianAvailabilityDAO" %>

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

            boolean noAvailability = false;
            if (currentUser != null) {
                try {
                    TechnicianAvailabilityDAO availabilityDAO = new TechnicianAvailabilityDAO();
                    noAvailability = availabilityDAO.getAvailabilityByTechnicianId(currentUser.getUserId()) == null;
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
                                <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
                                    <div>
                                        <i class="ph ph-calendar-dots"></i>
                                        Set Availability
                                    </div>
                                    <% if (noAvailability) { %>
                                        <i class="ph-fill ph-warning" title="Availability not set — your services are hidden from users" style="color: #ef4444; font-size: 1.1rem;"></i>
                                    <% } %>
                                </div>
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
                        <a href="#" id="sidebar-logout-btn" class="action-btn logout-btn">
                            <i class="ph ph-sign-out"></i>
                            Log Out
                        </a>
                    </div>
                </div>
            </aside>

            <!-- Logout Confirmation Modal -->
            <div id="sidebar-logout-modal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:9999; align-items:center; justify-content:center;">
                <div style="background:#fff; border-radius:12px; padding:2rem 2.5rem; max-width:360px; width:90%; text-align:center; box-shadow:0 8px 32px rgba(0,0,0,0.18);">
                    <i class="ph ph-sign-out" style="font-size:2.5rem; color:#e74c3c; margin-bottom:0.75rem; display:block;"></i>
                    <h3 style="margin:0 0 0.5rem; font-family:'Plus Jakarta Sans',sans-serif; font-size:1.2rem;">Log out?</h3>
                    <p style="margin:0 0 1.5rem; color:#666; font-size:0.95rem;">Are you sure you want to log out of your account?</p>
                    <div style="display:flex; gap:0.75rem; justify-content:center;">
                        <button id="sidebar-logout-cancel" style="flex:1; padding:0.6rem 1rem; border:1px solid #ddd; border-radius:8px; background:#f5f5f5; cursor:pointer; font-size:0.95rem;">Cancel</button>
                        <a id="sidebar-logout-confirm" href="${pageContext.request.contextPath}/logout" style="flex:1; padding:0.6rem 1rem; border:none; border-radius:8px; background:#e74c3c; color:#fff; cursor:pointer; font-size:0.95rem; text-decoration:none; display:inline-flex; align-items:center; justify-content:center;">Log out</a>
                    </div>
                </div>
            </div>

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

                // Logout confirmation modal
                document.addEventListener('DOMContentLoaded', function () {
                    const sidebarLogoutBtn = document.getElementById('sidebar-logout-btn');
                    const sidebarLogoutModal = document.getElementById('sidebar-logout-modal');
                    const sidebarLogoutCancel = document.getElementById('sidebar-logout-cancel');
                    if (sidebarLogoutBtn) {
                        sidebarLogoutBtn.addEventListener('click', function (e) {
                            e.preventDefault();
                            sidebarLogoutModal.style.display = 'flex';
                        });
                    }
                    if (sidebarLogoutCancel) {
                        sidebarLogoutCancel.addEventListener('click', function () {
                            sidebarLogoutModal.style.display = 'none';
                        });
                    }
                    if (sidebarLogoutModal) {
                        sidebarLogoutModal.addEventListener('click', function (e) {
                            if (e.target === sidebarLogoutModal) sidebarLogoutModal.style.display = 'none';
                        });
                    }
                });
            </script>