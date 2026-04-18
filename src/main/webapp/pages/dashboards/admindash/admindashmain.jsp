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

        /* ── Report generation panel ── */
        .report-panel {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 24px;
            box-shadow: var(--shadow-sm);
            margin-bottom: 36px;
        }
        .report-panel h2 {
            font-size: 1.3rem;
            color: var(--primary);
            margin-bottom: 16px;
        }
        .report-fields {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }
        .report-fields label {
            display: flex;
            flex-direction: column;
            gap: 4px;
            font-size: .9rem;
            font-weight: 600;
            color: var(--foreground);
        }
        .report-fields input[type="date"] {
            padding: 8px 12px;
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            background: var(--background);
            color: var(--foreground);
            font-size: .9rem;
            font-family: inherit;
        }
        .report-sections {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            align-items: center;
            margin-bottom: 14px;
        }
        .report-sections .section-label {
            font-weight: 600;
            font-size: .9rem;
            color: var(--foreground);
        }
        .report-sections label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: .9rem;
            color: var(--foreground);
            cursor: pointer;
        }
        .report-error {
            display: block;
            color: var(--destructive);
            font-size: .87rem;
            font-weight: 600;
            min-height: 1.3em;
            margin-bottom: 10px;
        }
        .report-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
        }
        .btn-download {
            padding: 9px 20px;
            background: var(--primary);
            color: var(--primary-foreground);
            border: none;
            border-radius: var(--radius-md);
            font-size: .9rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity .2s;
            font-family: inherit;
        }
        .btn-download:hover { opacity: .85; }
        .btn-print {
            padding: 8px 18px;
            background: var(--secondary);
            color: var(--secondary-foreground);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            font-size: .9rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity .2s;
            font-family: inherit;
        }
        .btn-print:hover { opacity: .8; }

        /* ── Print styles ── */
        @media print {
            nav, .sidebar, .range-bar, .action-grid, .report-panel, .btn-print { display: none !important; }
            .main-content { margin-left: 0 !important; }
            .charts-row, .breakdown-row { grid-template-columns: 1fr 1fr; }
            .kpi-grid { grid-template-columns: repeat(3, 1fr); }
            body { background: white; }
        }
    </style>
</head>

<body>

    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

    <main class="main-content">
        <div class="dashboard-header" style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:12px;">
            <div>
                <h1>Dashboard</h1>
                <p>Platform Overview &amp; Analytics</p>
            </div>
            <button class="btn-print" onclick="window.print()">Print / Save as PDF</button>
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

        <!-- ════════ Report Generation ════════ -->
        <div class="report-panel">
            <h2>Generate Report</h2>
            <form id="reportForm" method="GET"
                  action="${pageContext.request.contextPath}/admin/report"
                  target="_blank" novalidate>
                <div class="report-fields">
                    <label>
                        Start Date
                        <input type="date" name="startDate" id="reportStart">
                    </label>
                    <label>
                        End Date
                        <input type="date" name="endDate" id="reportEnd">
                    </label>
                </div>
                <div class="report-sections">
                    <span class="section-label">Include sections:</span>
                    <label><input type="checkbox" name="sections" value="orders" checked> Orders</label>
                    <label><input type="checkbox" name="sections" value="revenue" checked> Revenue</label>
                    <label><input type="checkbox" name="sections" value="bookings" checked> Bookings</label>
                    <label><input type="checkbox" name="sections" value="users" checked> New Users</label>
                </div>
                <span id="reportErr" class="report-error" role="alert"></span>
                <div class="report-actions">
                    <button type="submit" class="btn-download">Download CSV</button>
                </div>
            </form>
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

    <script>
    (function () {
        "use strict";

        // ── Set today as the max for both date pickers and populate sensible defaults ──
        var today = new Date();
        var todayStr = today.toISOString().split("T")[0];

        var startInput = document.getElementById("reportStart");
        var endInput   = document.getElementById("reportEnd");

        startInput.max = todayStr;
        endInput.max   = todayStr;
        endInput.value = todayStr;

        var d30 = new Date(today);
        d30.setDate(d30.getDate() - 30);
        startInput.value = d30.toISOString().split("T")[0];

        // ── Client-side validation ──
        document.getElementById("reportForm").addEventListener("submit", function (e) {
            var err   = document.getElementById("reportErr");
            var start = startInput.value;
            var end   = endInput.value;

            err.textContent = "";

            if (!start) {
                err.textContent = "Start date is required.";
                e.preventDefault();
                startInput.focus();
                return;
            }
            if (!end) {
                err.textContent = "End date is required.";
                e.preventDefault();
                endInput.focus();
                return;
            }
            if (start > todayStr) {
                err.textContent = "Start date cannot be in the future.";
                e.preventDefault();
                startInput.focus();
                return;
            }
            if (end < start) {
                err.textContent = "End date must be on or after the start date.";
                e.preventDefault();
                endInput.focus();
                return;
            }

            var diffMs   = new Date(end) - new Date(start);
            var diffDays = Math.round(diffMs / (1000 * 60 * 60 * 24));
            if (diffDays > 365) {
                err.textContent = "Date range cannot exceed 365 days.";
                e.preventDefault();
                return;
            }

            var checked = document.querySelectorAll("input[name=\"sections\"]:checked");
            if (checked.length === 0) {
                err.textContent = "Select at least one report section.";
                e.preventDefault();
                return;
            }
        });
    }());
    </script>
</body>
</html>