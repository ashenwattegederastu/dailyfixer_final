<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.DriverIncident" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.dao.DriverIncidentDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    OrderDAO orderDAO = new OrderDAO();
    DriverIncidentDAO incidentDAO = new DriverIncidentDAO();
    String storeUsername = user.getUsername();

    List<Order> refundOrders = orderDAO.getRefundOrdersByStore(storeUsername, 0);
    List<DriverIncident> storeIncidents = incidentDAO.getIncidentsByStoreOwnerUserId(user.getUserId());
    SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Finances | Daily Fixer Store</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-dashboard.css">
<style>
/* KPI cards for finances */
.finance-cards {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 20px;
    margin-bottom: 36px;
}
.kpi-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    padding: 24px;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}
.kpi-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 4px;
    opacity: 0;
    transition: opacity 0.3s;
}
.kpi-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); }
.kpi-card:hover::before { opacity: 1; }
.kpi-card:nth-child(1)::before { background: linear-gradient(90deg, var(--primary), oklch(0.6 0.2 280)); }
.kpi-card:nth-child(2)::before { background: linear-gradient(90deg, oklch(0.65 0.15 85), oklch(0.55 0.15 55)); }
.kpi-card:nth-child(3)::before { background: linear-gradient(90deg, oklch(0.6 0.18 145), oklch(0.5 0.18 165)); }
.kpi-card:nth-child(5)::before { background: linear-gradient(90deg, oklch(0.55 0.18 310), oklch(0.45 0.18 290)); }
.kpi-card--refund::before { background: linear-gradient(90deg, oklch(0.6 0.2 25), oklch(0.5 0.2 10)) !important; }
.kpi-card--refund .kpi-value { color: oklch(0.55 0.2 25); }
.kpi-label { font-size: 0.88em; font-weight: 600; color: var(--muted-foreground); margin-bottom: 10px; text-transform: uppercase; letter-spacing: 0.4px; }
.kpi-value { font-size: 1.9em; font-weight: 700; color: var(--primary); font-family: 'IBM Plex Mono', monospace; }
.kpi-sub { font-size: 0.82em; color: var(--muted-foreground); margin-top: 6px; }

/* Section headings */
.section-title {
    font-size: 1.2em;
    font-weight: 700;
    color: var(--foreground);
    margin-bottom: 16px;
}



/* Table */
table {
    width: 100%;
    border-collapse: collapse;
    background: var(--card);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
}
thead { background: var(--muted); }
th, td { padding: 14px 12px; text-align: left; border-bottom: 1px solid var(--border); }
th { font-weight: 600; color: var(--foreground); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.4px; }
td { color: var(--muted-foreground); font-size: 0.9em; }
tbody tr:hover { background: var(--muted); }

.badge {
    padding: 4px 12px;
    border-radius: 999px;
    font-weight: 600;
    font-size: 0.8rem;
    display: inline-block;
}
.badge-pending { background: oklch(0.9 0.12 85); color: oklch(0.4 0.12 85); }
.badge-processing { background: oklch(0.9 0.12 240); color: oklch(0.4 0.12 240); }
.badge-completed { background: oklch(0.9 0.12 145); color: oklch(0.35 0.12 145); }

.empty-state {
    text-align: center;
    padding: 40px 20px;
    color: var(--muted-foreground);
}

/* Toast */
#toast {
    position: fixed;
    bottom: 24px;
    right: 24px;
    padding: 14px 22px;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.95em;
    z-index: 9999;
    display: none;
    box-shadow: var(--shadow-lg);
}
#toast.success { background: #28a745; color: #fff; }
#toast.error   { background: #dc3545; color: #fff; }
</style>
</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp" class="active">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Finances</h2>
    <p class="dashboard-subtitle">Track your earnings, pending payouts, and manage your bank details.</p>

    <!-- KPI Cards -->
    <div class="finance-cards">
        <div class="kpi-card">
            <div class="kpi-label">Lifetime Earnings</div>
            <div class="kpi-value" id="kpi-lifetime">-</div>
            <div class="kpi-sub">Total from all delivered orders</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Pending (Maturing)</div>
            <div class="kpi-value" id="kpi-pending">-</div>
            <div class="kpi-sub">Completed within the last 7 days</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Available for Payout</div>
            <div class="kpi-value" id="kpi-available">-</div>
            <div class="kpi-sub">Mature &amp; not yet paid out</div>
        </div>
        <div class="kpi-card kpi-card--refund">
            <div class="kpi-label">Total Refunded</div>
            <div class="kpi-value" id="kpi-refunded">-</div>
            <div class="kpi-sub">Orders refunded or pending refund</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Commission Deducted</div>
            <div class="kpi-value" id="kpi-commission" style="color:oklch(0.45 0.18 310);">-</div>
            <div class="kpi-sub">10% platform fee on delivered orders</div>
        </div>
    </div>

    <!-- Bank Details – managed on My Store page -->
    <p style="margin-bottom:36px;color:var(--muted-foreground);font-size:0.95em;">
        Manage your bank account on the
        <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp"
           style="color:var(--primary);font-weight:600;">My Store</a> page.
    </p>

    <!-- Payout History -->
    <h3 class="section-title">Payout History</h3>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Date</th>
                <th>Receipt</th>
            </tr>
        </thead>
        <tbody id="payoutBody">
            <tr><td colspan="5" class="empty-state">Loading...</td></tr>
        </tbody>
    </table>

    <!-- Refunded Orders -->
    <h3 class="section-title" style="margin-top:36px;">Refunded / Pending Refund Orders</h3>
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Buyer Email</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Date</th>
            </tr>
        </thead>
        <tbody>
        <% if (refundOrders == null || refundOrders.isEmpty()) { %>
            <tr><td colspan="5" class="empty-state">No refunded orders.</td></tr>
        <% } else {
            for (Order o : refundOrders) {
                String badgeCls = "REFUNDED".equalsIgnoreCase(o.getStatus()) ? "badge-completed" : "badge-pending";
        %>
            <tr>
                <td><code style="font-family:'IBM Plex Mono',monospace;font-size:0.85em;"><%= o.getOrderId() %></code></td>
                <td><%= o.getEmail() != null ? o.getEmail() : "—" %></td>
                <td><strong><%= o.getCurrency() != null ? o.getCurrency() : "LKR" %> <%= String.format("%,.2f", o.getAmount()) %></strong></td>
                <td><span class="badge <%= badgeCls %>"><%= o.getStatus() %></span></td>
                <td><%= o.getCreatedAt() != null ? dtFmt.format(o.getCreatedAt()) : "—" %></td>
            </tr>
        <% } } %>
        </tbody>
    </table>

    <!-- Delivery Incidents on Your Orders -->
    <h3 class="section-title" style="margin-top:36px;">Delivery Incidents on Your Orders</h3>
    <table>
        <thead>
            <tr>
                <th>Incident ID</th>
                <th>Order ID</th>
                <th>Driver</th>
                <th>Type</th>
                <th>Description</th>
                <th>Reviewed</th>
                <th>Date</th>
            </tr>
        </thead>
        <tbody>
        <% if (storeIncidents == null || storeIncidents.isEmpty()) { %>
            <tr><td colspan="7" class="empty-state">No delivery incidents on your orders.</td></tr>
        <% } else {
            for (DriverIncident inc : storeIncidents) {
        %>
            <tr>
                <td>#<%= inc.getIncidentId() %></td>
                <td><code style="font-family:'IBM Plex Mono',monospace;font-size:0.85em;"><%= inc.getOrderId() %></code></td>
                <td><%= inc.getDriverName() != null ? inc.getDriverName() : "Driver #" + inc.getDriverId() %></td>
                <td><span class="badge badge-pending"><%= inc.getIncidentType() %></span></td>
                <td style="max-width:220px;white-space:normal;"><%= inc.getDescription() != null ? inc.getDescription() : "—" %></td>
                <td>
                    <% if (inc.isReviewed()) { %>
                        <span class="badge badge-completed">Reviewed</span>
                    <% } else { %>
                        <span class="badge badge-pending">Pending</span>
                    <% } %>
                </td>
                <td><%= inc.getCreatedAt() != null ? dtFmt.format(inc.getCreatedAt()) : "—" %></td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</main>

<div id="toast"></div>

<script>
    const CTX = '<%= request.getContextPath() %>';

    // ── Load balances ──
    function loadBalances() {
        fetch(CTX + '/financial-dashboard')
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('kpi-lifetime').textContent = 'LKR ' + Number(data.lifetime).toLocaleString('en-US', {minimumFractionDigits: 2});
                    document.getElementById('kpi-pending').textContent = 'LKR ' + Number(data.pending).toLocaleString('en-US', {minimumFractionDigits: 2});
                    document.getElementById('kpi-available').textContent = 'LKR ' + Number(data.available).toLocaleString('en-US', {minimumFractionDigits: 2});
                    if (data.refunded != null) {
                        document.getElementById('kpi-refunded').textContent = 'LKR ' + Number(data.refunded).toLocaleString('en-US', {minimumFractionDigits: 2});
                    }
                    if (data.commission != null) {
                        document.getElementById('kpi-commission').textContent = 'LKR ' + Number(data.commission).toLocaleString('en-US', {minimumFractionDigits: 2});
                    }
                }
            })
            .catch(err => console.error('Balance load error:', err));
    }



    // ── Load payout history ──
    function loadPayouts() {
        fetch(CTX + '/payout-history')
            .then(r => r.json())
            .then(data => {
                const tbody = document.getElementById('payoutBody');
                if (!data.success || !data.payouts || !data.payouts.length) {
                    tbody.innerHTML = '<tr><td colspan="5" class="empty-state">No payouts yet.</td></tr>';
                    return;
                }
                let html = '';
                data.payouts.forEach(p => {
                    const badgeCls = p.status === 'COMPLETED' ? 'badge-completed' : p.status === 'PROCESSING' ? 'badge-processing' : 'badge-pending';
                    html += '<tr>';
                    html += '<td><code style="font-family:\'IBM Plex Mono\',monospace;font-size:0.85em;">#' + p.payoutId + '</code></td>';
                    html += '<td><strong>LKR ' + Number(p.amount).toLocaleString('en-US', {minimumFractionDigits: 2}) + '</strong></td>';
                    html += '<td><span class="badge ' + badgeCls + '">' + p.status + '</span></td>';
                    html += '<td>' + (p.updatedAt || p.createdAt || '—') + '</td>';
                    html += '<td>';
                    if (p.receiptImagePath) {
                        html += '<a href="' + CTX + '/' + esc(p.receiptImagePath) + '" target="_blank" style="color:var(--primary);font-weight:600;">View</a>';
                    } else {
                        html += '—';
                    }
                    html += '</td></tr>';
                });
                tbody.innerHTML = html;
            })
            .catch(err => console.error('Payout history load error:', err));
    }

    function esc(s) { if (!s) return ''; const d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
    function showToast(msg, type) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.className = type;
        t.style.display = 'block';
        setTimeout(() => { t.style.display = 'none'; }, 3500);
    }

    document.addEventListener('DOMContentLoaded', function() {
        loadBalances();
        loadPayouts();
    });
</script>
</body>
</html>
