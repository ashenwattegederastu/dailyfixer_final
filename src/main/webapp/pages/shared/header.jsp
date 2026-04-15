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
                            <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="ph ph-sign-out"></i></a>
                        </c:when>
                        <c:otherwise>
                            <!-- Guest -->
                            <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp" class="btn-login">Login</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </nav>

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
        </script>