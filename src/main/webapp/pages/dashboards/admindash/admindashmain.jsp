<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="java.util.Map" %>

<% User user=(User) session.getAttribute("currentUser");
   if (user==null || user.getRole()==null ||
       !"admin".equalsIgnoreCase(user.getRole().trim())) {
       response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
       return;
   }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .main-content {
            flex: 1;
            margin-left: 240px;
            padding: 40px 30px;
        }
        @media (max-width: 900px) {
            .main-content { margin-left: 0 !important; margin-top: 60px !important; padding-top: 40px !important; }
        }

        /* ── KPI stat cards ── */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 18px;
            margin-bottom: 36px;
        }
        .kpi-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 22px 20px;
            box-shadow: var(--shadow-sm);
            transition: transform .2s, box-shadow .2s;
        }
        .kpi-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); }
        .kpi-value { font-size: 2rem; font-weight: 700; color: var(--primary); margin-bottom: 4px; }
        .kpi-label { color: var(--muted-foreground); font-size: .9rem; }

        /* ── Action-needed cards ── */
        .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 18px;
            margin-bottom: 36px;
        }
        .action-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--shadow-sm);
            transition: transform .2s;
        }
        .action-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
        .action-card .info .count { font-size: 1.6rem; font-weight: 700; color: var(--destructive); }
        .action-card .info .label { color: var(--muted-foreground); font-size: .88rem; }
        .action-card .go-link {
            padding: 6px 14px;
            background: var(--primary);
            color: var(--primary-foreground);
            border-radius: var(--radius-md);
            text-decoration: none;
            font-size: .85rem;
            font-weight: 600;
            transition: opacity .2s;
        }
        .action-card .go-link:hover { opacity: .85; }

        /* ── Charts layout ── */
        .charts-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
            gap: 24px;
            margin-bottom: 36px;
        }
        .chart-box {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 24px;
            box-shadow: var(--shadow-sm);
            position: relative;
            overflow: hidden;
        }
        .chart-box h3 { margin-bottom: 14px; font-size: 1.05rem; color: var(--foreground); }
        .chart-box::after {
            content: "";
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at top right, rgba(59, 130, 246, .08), transparent 34%);
            pointer-events: none;
        }
        .chart-box canvas {
            position: relative;
            display: block;
            width: 100% !important;
            height: 280px !important;
            max-height: 280px;
            z-index: 1;
        }

        /* ── Date-range picker bar ── */
        .range-bar {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 28px; flex-wrap: wrap;
        }
        .range-bar a, .range-bar span.active-range {
            padding: 6px 14px; border-radius: var(--radius-md); font-size: .85rem;
            font-weight: 600; text-decoration: none; transition: .2s;
        }
        .range-bar a { background: var(--secondary); color: var(--secondary-foreground); }
        .range-bar a:hover { background: var(--accent); }
        .range-bar span.active-range { background: var(--primary); color: var(--primary-foreground); }

        /* ── Breakdown tables ── */
        .breakdown-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 24px;
            margin-bottom: 36px;
        }
        .breakdown-box {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 24px;
            box-shadow: var(--shadow-sm);
        }
        .breakdown-box h3 { margin-bottom: 14px; font-size: 1.05rem; color: var(--foreground); }
        .mini-table { width: 100%; border-collapse: collapse; }
        .mini-table th, .mini-table td {
            padding: 8px 12px; text-align: left; border-bottom: 1px solid var(--border);
        }
        .mini-table th { font-weight: 600; color: var(--muted-foreground); font-size: .85rem; }
        .mini-table td { font-size: .92rem; }
        .role-badge {
            display: inline-block; padding: 2px 10px; border-radius: var(--radius-sm);
            font-size: .8rem; font-weight: 600; text-transform: capitalize;
            background: var(--secondary); color: var(--secondary-foreground);
        }
    </style>
</head>

<body>

    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

    <main class="main-content">
        <div class="dashboard-header">
            <h1>Dashboard</h1>
            <p>Platform Overview &amp; Analytics</p>
        </div>

        <!-- ════════ KPI Cards ════════ -->
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-value">${totalUsers}</div>
                <div class="kpi-label">Total Users</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">${totalBookings}</div>
                <div class="kpi-label">Total Bookings</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">${activeBookings}</div>
                <div class="kpi-label">Active Bookings</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">${totalStores}</div>
                <div class="kpi-label">Stores</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">${totalGuides}</div>
                <div class="kpi-label">Guides</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-value">${totalDiagnosticTrees}</div>
                <div class="kpi-label">Diagnostic Trees</div>
            </div>
        </div>

        <!-- ════════ Action-Needed Cards ════════ -->
        <div class="section">
            <h2 style="color:var(--primary);font-size:1.3rem;margin-bottom:16px;">Needs Attention</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="info">
                        <div class="count">${pendingRefunds}</div>
                        <div class="label">Pending Refunds</div>
                    </div>
                    <a class="go-link" href="${pageContext.request.contextPath}/admin/refunds">View</a>
                </div>
                <div class="action-card">
                    <div class="info">
                        <div class="count">${pendingVolunteers}</div>
                        <div class="label">Volunteer Requests</div>
                    </div>
                    <a class="go-link" href="${pageContext.request.contextPath}/admin/volunteer-requests">Review</a>
                </div>
                <div class="action-card">
                    <div class="info">
                        <div class="count">${flaggedGuides}</div>
                        <div class="label">Flagged Guides</div>
                    </div>
                    <a class="go-link" href="${pageContext.request.contextPath}/admin/flagged-guides">Moderate</a>
                </div>
            </div>
        </div>

        <!-- ════════ Date-range selector ════════ -->
        <div class="range-bar">
            <span style="font-weight:600;color:var(--foreground);margin-right:6px;">Trend range:</span>
            <c:forEach var="d" items="${'7,14,30,90,120'}" >
                <%-- manual options --%>
            </c:forEach>
            <c:choose>
                <c:when test="${days == 7}"><span class="active-range">7 days</span></c:when>
                <c:otherwise><a href="${pageContext.request.contextPath}/admin/dashboard?days=7">7 days</a></c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${days == 14}"><span class="active-range">14 days</span></c:when>
                <c:otherwise><a href="${pageContext.request.contextPath}/admin/dashboard?days=14">14 days</a></c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${days == 30}"><span class="active-range">30 days</span></c:when>
                <c:otherwise><a href="${pageContext.request.contextPath}/admin/dashboard?days=30">30 days</a></c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${days == 90}"><span class="active-range">90 days</span></c:when>
                <c:otherwise><a href="${pageContext.request.contextPath}/admin/dashboard?days=90">90 days</a></c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${days == 120}"><span class="active-range">120 days</span></c:when>
                <c:otherwise><a href="${pageContext.request.contextPath}/admin/dashboard?days=120">120 days</a></c:otherwise>
            </c:choose>
        </div>

        <!-- ════════ Charts ════════ -->
        <div class="charts-row">
            <div class="chart-box">
                <h3>Orders Trend</h3>
                <canvas id="ordersChart"></canvas>
            </div>
            <div class="chart-box">
                <h3>Revenue Trend (LKR)</h3>
                <canvas id="revenueChart"></canvas>
            </div>
        </div>

        <div class="charts-row">
            <div class="chart-box">
                <h3>New Registrations</h3>
                <canvas id="usersChart"></canvas>
            </div>
            <div class="chart-box">
                <h3>Bookings Trend</h3>
                <canvas id="bookingsChart"></canvas>
            </div>
        </div>

        <div class="charts-row">
            <div class="chart-box">
                <h3>Users by Role</h3>
                <canvas id="roleChart"></canvas>
            </div>
            <div class="chart-box">
                <h3>Orders by Status</h3>
                <canvas id="statusChart"></canvas>
            </div>
        </div>

        <!-- ════════ Breakdown Tables ════════ -->
        <div class="breakdown-row">
            <div class="breakdown-box">
                <h3>Users by Role</h3>
                <table class="mini-table">
                    <thead><tr><th>Role</th><th>Count</th></tr></thead>
                    <tbody>
                        <c:forEach var="entry" items="${usersByRole}">
                            <tr>
                                <td><span class="role-badge">${entry.key}</span></td>
                                <td>${entry.value}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty usersByRole}">
                            <tr><td colspan="2" style="text-align:center;">No data</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            <div class="breakdown-box">
                <h3>Orders by Status</h3>
                <table class="mini-table">
                    <thead><tr><th>Status</th><th>Count</th></tr></thead>
                    <tbody>
                        <c:forEach var="entry" items="${ordersByStatus}">
                            <tr>
                                <td><span class="role-badge">${entry.key}</span></td>
                                <td>${entry.value}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty ordersByStatus}">
                            <tr><td colspan="2" style="text-align:center;">No data</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ════════ Quick Links ════════ -->
        <div class="section">
            <h2 style="color:var(--primary);font-size:1.3rem;margin-bottom:16px;">Quick Links</h2>
            <div class="stats-container">
                <a href="${pageContext.request.contextPath}/admin/users" class="stat-card" style="text-decoration:none;">
                    <div class="number">${totalUsers}</div>
                    <p>User Management</p>
                </a>
                <a href="${pageContext.request.contextPath}/admin/store-dashboard" class="stat-card" style="text-decoration:none;">
                    <div class="number">${totalStores}</div>
                    <p>Store Dashboard</p>
                </a>
                <a href="${pageContext.request.contextPath}/admin/products" class="stat-card" style="text-decoration:none;">
                    <div class="number">${totalProducts}</div>
                    <p>Manage Products</p>
                </a>
                <a href="${pageContext.request.contextPath}/admin/flagged-guides" class="stat-card" style="text-decoration:none;">
                    <div class="number">${flaggedGuides}</div>
                    <p>Flagged Guides</p>
                </a>
            </div>
        </div>

    </main>

    <%-- ══════ Build JS data payload for local chart renderer ══════ --%>
    <script>
    window.adminDashboardData = {
        ordersTrend: {
            labels: [<c:forEach var="e" items="${ordersPerDay}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="e" items="${ordersPerDay}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>]
        },
        revenueTrend: {
            labels: [<c:forEach var="e" items="${revenuePerDay}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="e" items="${revenuePerDay}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>]
        },
        registrationsTrend: {
            labels: [<c:forEach var="e" items="${newUsersPerDay}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="e" items="${newUsersPerDay}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>]
        },
        bookingsTrend: {
            labels: [<c:forEach var="e" items="${bookingsPerDay}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="e" items="${bookingsPerDay}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>]
        },
        usersByRole: {
            labels: [<c:forEach var="e" items="${usersByRole}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="e" items="${usersByRole}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>]
        },
        ordersByStatus: {
            labels: [<c:forEach var="e" items="${ordersByStatus}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
            values: [<c:forEach var="e" items="${ordersByStatus}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>]
        }
    };
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/admin-dashboard-charts.js"></script>
</body>
</html>