<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.TechnicianPenalty" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Technician Dashboard | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.info-box {
    background: var(--muted);
    padding: 15px 18px;
    border-radius: var(--radius-md);
    border-left: 4px solid var(--primary);
}
.info-box p {
    margin: 0;
    color: var(--foreground);
    font-size: 0.95em;
}
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 15px;
}
.section-card {
    background: var(--card);
    padding: 25px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-lg);
    border: 1px solid var(--border);
    margin-bottom: 30px;
}
.section-card h3 {
    margin-bottom: 20px;
    color: var(--foreground);
    font-size: 1.1em;
    font-weight: 600;
}
.status-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 4px;
    font-size: 0.78em;
    font-weight: 600;
}
.status-REQUESTED            { background: #fef3c7; color: #92400e; }
.status-ACCEPTED             { background: #d1fae5; color: #065f46; }
.status-REJECTED             { background: #fee2e2; color: #991b1b; }
.status-CANCELLED            { background: #f3f4f6; color: #6b7280; }
.status-TECHNICIAN_COMPLETED { background: #dbeafe; color: #1e40af; }
.status-FULLY_COMPLETED      { background: #d1fae5; color: #065f46; }
.rating-star {
    color: #f59e0b;
}
/* Penalty standing card */
.penalty-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    padding: 24px 28px;
    margin-bottom: 30px;
    box-shadow: var(--shadow-sm);
}
.penalty-card h3 {
    margin: 0 0 16px;
    font-size: 1.05rem;
    font-weight: 600;
    color: var(--foreground);
}
.penalty-standing {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 16px 20px;
    border-radius: var(--radius-md);
    margin-bottom: 16px;
}
.standing-clear  { background: #dcfce7; border: 1px solid #86efac; }
.standing-warn   { background: #fef9c3; border: 1px solid #fde047; }
.standing-supp   { background: #ffedd5; border: 1px solid #fdba74; }
.standing-susp   { background: #fee2e2; border: 1px solid #fca5a5; }
.standing-icon { font-size: 1.5rem; }
.standing-text h4 { margin: 0 0 2px; font-size: 0.95rem; font-weight: 700; }
.standing-text p  { margin: 0; font-size: 0.85rem; line-height: 1.5; }
.penalty-history-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.88rem;
}
.penalty-history-table th, .penalty-history-table td {
    padding: 9px 10px;
    text-align: left;
    border-bottom: 1px solid var(--border);
}
.penalty-history-table th { color: var(--muted-foreground); font-weight: 600; font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.4px; }
.penalty-history-table td { color: var(--foreground); }
.penalty-badge {
    display: inline-block;
    padding: 2px 9px;
    border-radius: 20px;
    font-size: 0.78rem;
    font-weight: 600;
}
.pb-1 { background: #fef9c3; color: #854d0e; }
.pb-2 { background: #fed7aa; color: #9a3412; }
.pb-3 { background: #fee2e2; color: #991b1b; }
.pb-lifted { background: #f3f4f6; color: #6b7280; text-decoration: line-through; }
</style>
</head>

<body class="dashboard-layout">

<jsp:include page="sidebar.jsp" />

<main class="dashboard-container">
    <header class="dashboard-header">
        <h1>Dashboard</h1>
        <p>Welcome back, ${sessionScope.currentUser.firstName}. Here's your activity at a glance.</p>
    </header>

    <!-- Stat Cards -->
    <div class="stats-container">
        <div class="stat-card">
            <p class="number">${pendingCount}</p>
            <p>Pending Requests</p>
        </div>
        <div class="stat-card">
            <p class="number">${activeCount}</p>
            <p>Active Bookings</p>
        </div>
        <div class="stat-card">
            <p class="number">${completedCount}</p>
            <p>Completed Jobs</p>
        </div>
        <div class="stat-card">
            <p class="number"><span class="rating-star">★</span> ${avgRatingStr}</p>
            <p>Average Rating</p>
        </div>
    </div>

    <!-- Performance Overview -->
    <div class="section-card">
        <h3>Performance Overview</h3>
        <div class="stats-grid">
            <div class="info-box">
                <p><strong>Service Listings:</strong> ${serviceCount} active listing<c:if test="${serviceCount != 1}">s</c:if></p>
            </div>
            <div class="info-box">
                <p><strong>Total Ratings:</strong> ${ratingCount} review<c:if test="${ratingCount != 1}">s</c:if></p>
            </div>
            <div class="info-box">
                <p><strong>Completed This Month:</strong> ${thisMonthCount} job<c:if test="${thisMonthCount != 1}">s</c:if></p>
            </div>
            <div class="info-box">
                <p><strong>All-Time Completed:</strong> ${completedCount} job<c:if test="${completedCount != 1}">s</c:if></p>
            </div>
        </div>
    </div>

    <!-- Penalty Standing -->
    <%
        int activePenaltyLevel = request.getAttribute("activePenaltyLevel") != null
            ? (Integer) request.getAttribute("activePenaltyLevel") : 0;
        @SuppressWarnings("unchecked")
        List<TechnicianPenalty> recentPenalties =
            (List<TechnicianPenalty>) request.getAttribute("recentPenalties");
        SimpleDateFormat dtFmt = new SimpleDateFormat("dd MMM yyyy, HH:mm");
    %>
    <div class="penalty-card" id="account-standing">
        <h3>Account Standing</h3>

        <% if (activePenaltyLevel == 0) { %>
        <div class="penalty-standing standing-clear">
            <div class="standing-icon">&#10003;</div>
            <div class="standing-text">
                <h4 style="color:#166534;">All Clear</h4>
                <p style="color:#166534;">No active penalties on your account. Keep up the great work!</p>
            </div>
        </div>
        <% } else if (activePenaltyLevel == 1) { %>
        <div class="penalty-standing standing-warn">
            <div class="standing-icon">&#9888;</div>
            <div class="standing-text">
                <h4 style="color:#854d0e;">Level 1 &mdash; Warning</h4>
                <p style="color:#854d0e;">A formal warning has been recorded. One more no-show within 90 days will suppress your listings for 7 days.</p>
            </div>
        </div>
        <% } else if (activePenaltyLevel == 2) { %>
        <div class="penalty-standing standing-supp">
            <div class="standing-icon">&#128683;</div>
            <div class="standing-text">
                <h4 style="color:#9a3412;">Level 2 &mdash; Listing Suppressed</h4>
                <p style="color:#9a3412;">Your service listings are hidden from clients for 7 days. Accepted bookings are unaffected. The restriction lifts automatically.</p>
            </div>
        </div>
        <% } else { %>
        <div class="penalty-standing standing-susp">
            <div class="standing-icon">&#128274;</div>
            <div class="standing-text">
                <h4 style="color:#991b1b;">Level 3 &mdash; Account Suspended</h4>
                <p style="color:#991b1b;">Your account is suspended. Please contact DailyFixer support to have it reviewed and reinstated.</p>
            </div>
        </div>
        <% } %>

        <a href="${pageContext.request.contextPath}/pages/policies/technician-noshowpolicy.jsp"
           style="display:inline-block;margin-top:10px;font-size:0.85rem;color:var(--primary);font-weight:600;text-decoration:none;">
            View No-Show Policy &#8594;
        </a>

        <% if (recentPenalties != null && !recentPenalties.isEmpty()) { %>
        <table class="penalty-history-table" style="margin-top: 20px;">
            <thead>
                <tr>
                    <th>Level</th>
                    <th>Issued</th>
                    <th>Expires / Status</th>
                    <th>Notes</th>
                </tr>
            </thead>
            <tbody>
                <% for (TechnicianPenalty p : recentPenalties) {
                    boolean lifted = p.getLiftedAt() != null;
                    String badgeClass = lifted ? "pb-lifted" : ("pb-" + p.getPenaltyLevel());
                    String levelLabel = p.getPenaltyLevel() == 1 ? "Warning"
                                      : p.getPenaltyLevel() == 2 ? "Suppressed" : "Suspended";
                %>
                <tr>
                    <td><span class="penalty-badge <%= badgeClass %>">Level <%= p.getPenaltyLevel() %> &mdash; <%= levelLabel %></span></td>
                    <td><%= p.getIssuedAt() != null ? dtFmt.format(p.getIssuedAt()) : "&#8212;" %></td>
                    <td>
                        <% if (lifted) { %>
                            <span style="color:var(--muted-foreground);font-size:0.85rem;">Lifted <%= p.getLiftedAt() != null ? dtFmt.format(p.getLiftedAt()) : "" %></span>
                        <% } else if (p.getExpiresAt() != null) { %>
                            <span style="color:var(--muted-foreground);font-size:0.85rem;">Expires <%= dtFmt.format(p.getExpiresAt()) %></span>
                        <% } else { %>
                            <span style="color:#991b1b;font-size:0.85rem;font-weight:600;">Indefinite</span>
                        <% } %>
                    </td>
                    <td style="color:var(--muted-foreground);font-size:0.85rem;"><%= p.getNotes() != null ? p.getNotes() : "&#8212;" %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <!-- Recent Bookings -->
    <div class="section">
        <h2>Recent Bookings</h2>
        <div class="table-container">
            <c:choose>
                <c:when test="${empty recentBookings}">
                    <div style="text-align:center; padding:2.5rem; background:var(--card); border-radius:var(--radius-lg); border:1px solid var(--border);">
                        <p style="color:var(--muted-foreground);">No bookings yet. They will appear here once customers book your services.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Service</th>
                                <th>Customer</th>
                                <th>Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${recentBookings}">
                                <tr>
                                    <td style="font-family: monospace; color: var(--muted-foreground);">#${b.bookingId}</td>
                                    <td style="font-weight: 500;">${b.serviceName}</td>
                                    <td>${b.userName}</td>
                                    <td>${b.bookingDate}</td>
                                    <td>
                                        <span class="status-badge status-${b.status}">
                                            <c:out value="${fn:replace(b.status, '_', ' ')}" default="${b.status}" />
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
        <c:if test="${not empty recentBookings}">
            <div style="margin-top: 12px; text-align: right;">
                <a href="${pageContext.request.contextPath}/bookings/calendar"
                   style="color: var(--primary); font-size: 0.9em; text-decoration: none; font-weight: 500;">
                    View all bookings →
                </a>
            </div>
        </c:if>
    </div>
</main>

</body>
</html>

