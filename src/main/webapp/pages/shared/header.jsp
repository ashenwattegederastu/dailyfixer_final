<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page session="true" %>
<%@ page import="java.util.Map, com.dailyfixer.model.CartItem" %>
<%
    // Compute cart item count for nav cart icon
    @SuppressWarnings("unchecked")
    Map<String, CartItem> _navCart = (Map<String, CartItem>) session.getAttribute("cart");
    int _navCartCount = 0;
    if (_navCart != null) {
        for (CartItem _ci : _navCart.values()) _navCartCount += _ci.getQuantity();
    }
%>

        <head>
            <title></title>
        <link
            href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
        </head>

        <!-- Navigation -->
        <nav id="navbar" class="public-nav">
            <div class="nav-container">
                <div class="hamburger" id="hamburger-btn">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
                <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
                    <img src="${pageContext.request.contextPath}/assets/images/logo/logo_main.svg" alt="Logo" class="logo-icon">
                    DailyFixer
                </a>
                <ul class="nav-links" id="nav-links">
                    <li><a href="${pageContext.request.contextPath}/pages/diagnostic/diagnostic-browse.jsp">Diagnostic
                            Tool</a></li>
                    <li><a href="${pageContext.request.contextPath}/guides">Repair Guides</a></li>
                    <li><a href="${pageContext.request.contextPath}/services">Technicians</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/stores/store_main.jsp">Marketplace</a></li>
                </ul>

                <!-- Dynamic Login/Logout -->
                <div class="nav-buttons">
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <!-- User is logged in -->
                            <a href="${pageContext.request.contextPath}/pages/stores/Cart.jsp" class="nav-cart-link" title="Cart">
                                <i class="ph ph-shopping-cart"></i>
                                <span class="cart-count"><%= _navCartCount %></span>
                            </a>
                            <a href="${pageContext.request.contextPath}/pages/dashboards/${sessionScope.currentUser.role}dash/${sessionScope.currentUser.role}dashmain.jsp"
                                class="btn-login">
                                <i class="ph ph-user"></i>
                            </a>
                            <a href="#" class="btn-logout" id="logout-btn"><i class="ph ph-sign-out"></i></a>
                        </c:when>
                        <c:otherwise>
                            <!-- Guest -->
                            <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp" class="btn-login">Login</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </nav>

        <!-- Logout Confirmation Modal -->
        <div id="logout-modal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:9999; align-items:center; justify-content:center;">
            <div style="background:#fff; border-radius:12px; padding:2rem 2.5rem; max-width:360px; width:90%; text-align:center; box-shadow:0 8px 32px rgba(0,0,0,0.18);">
                <i class="ph ph-sign-out" style="font-size:2.5rem; color:#e74c3c; margin-bottom:0.75rem; display:block;"></i>
                <h3 style="margin:0 0 0.5rem; font-family:'Plus Jakarta Sans',sans-serif; font-size:1.2rem;">Log out?</h3>
                <p style="margin:0 0 1.5rem; color:#666; font-size:0.95rem;">Are you sure you want to log out of your account?</p>
                <div style="display:flex; gap:0.75rem; justify-content:center;">
                    <button id="logout-cancel" style="flex:1; padding:0.6rem 1rem; border:1px solid #ddd; border-radius:8px; background:#f5f5f5; cursor:pointer; font-size:0.95rem;">Cancel</button>
                    <a id="logout-confirm" href="${pageContext.request.contextPath}/logout" style="flex:1; padding:0.6rem 1rem; border:none; border-radius:8px; background:#e74c3c; color:#fff; cursor:pointer; font-size:0.95rem; text-decoration:none; display:inline-flex; align-items:center; justify-content:center;">Log out</a>
                </div>
            </div>
        </div>

        <script>
            // Navbar scroll effect
            const navbar = document.getElementById('navbar');
            window.addEventListener('scroll', () => {
                if (window.scrollY > 50) {
                    navbar.classList.add('scrolled');
                } else {
                    navbar.classList.remove('scrolled');
                }
            });

            // Mobile Menu Toggle
            const hamburger = document.getElementById('hamburger-btn');
            const navLinks = document.getElementById('nav-links');

            hamburger.addEventListener('click', () => {
                navLinks.classList.toggle('active');
                hamburger.classList.toggle('active');
            });

            // Logout confirmation modal
            const logoutBtn = document.getElementById('logout-btn');
            const logoutModal = document.getElementById('logout-modal');
            const logoutCancel = document.getElementById('logout-cancel');

            if (logoutBtn) {
                logoutBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    logoutModal.style.display = 'flex';
                });
            }

            if (logoutCancel) {
                logoutCancel.addEventListener('click', () => {
                    logoutModal.style.display = 'none';
                });
            }

            logoutModal.addEventListener('click', (e) => {
                if (e.target === logoutModal) logoutModal.style.display = 'none';
            });
        </script>