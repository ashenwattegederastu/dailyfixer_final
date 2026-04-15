<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null || !"admin".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Driver Requests | Daily Fixer Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .main-content {
            flex: 1;
            margin-left: 240px;
            padding: 40px 30px;
        }

        @media (max-width: 900px) {
            .main-content {
                margin-left: 0 !important;
                margin-top: 60px !important;
                padding-top: 40px !important;
            }
        }

        .badge-count {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #7c3aed, #a78bfa);
            color: white;
            font-size: 0.75rem;
            font-weight: 700;
            min-width: 22px;
            height: 22px;
            border-radius: 11px;
            padding: 0 6px;
            margin-left: 8px;
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-PENDING { background: #fef3c7; color: #92400e; }
        .status-APPROVED { background: #d1fae5; color: #065f46; }
        .status-REJECTED { background: #fee2e2; color: #991b1b; }

        .alert-box {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-weight: 500;
            font-size: 0.9rem;
        }

        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

        .btn-review {
            background: var(--primary);
            color: var(--primary-foreground);
            padding: 6px 14px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s;
        }

        .btn-review:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
    </style>
</head>
<body>

    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

    <main class="main-content">
        <div class="dashboard-header">
            <h1>Driver Requests
                <c:if test="${pendingCount > 0}">
                    <span class="badge-count">${pendingCount}</span>
                </c:if>
            </h1>
            <p>Review and manage driver registration applications.</p>
        </div>

        <!-- Success / Error Messages -->
        <c:if test="${param.success == 'approved'}">
            <div class="alert-box alert-success">Driver request has been approved. The driver can now log in.</div>
        </c:if>
        <c:if test="${param.success == 'rejected'}">
            <div class="alert-box alert-success">Driver request has been rejected.</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert-box alert-error">An error occurred. Please try again.</div>
        </c:if>

        <!-- Filters -->
        <div class="search-container">
            <input type="text" id="requestSearch" class="search-input"
                   placeholder="Search by name, email, or NIC...">
            <select id="statusFilter" class="filter-select" onchange="filterByStatus()">
                <option value="">All Statuses</option>
                <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                <option value="APPROVED" ${param.status == 'APPROVED' ? 'selected' : ''}>Approved</option>
                <option value="REJECTED" ${param.status == 'REJECTED' ? 'selected' : ''}>Rejected</option>
            </select>
        </div>

        <!-- Table -->
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>NIC Number</th>
                        <th>City</th>
                        <th>Status</th>
                        <th>Submitted</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="req" items="${driverRequests}">
                        <tr>
                            <td>${req.requestId}</td>
                            <td><strong>${req.fullName}</strong></td>
                            <td>${req.email}</td>
                            <td><code style="font-size: 0.85em;">${req.nicNumber}</code></td>
                            <td>${not empty req.city ? req.city : '—'}</td>
                            <td><span class="status-badge status-${req.status}">${req.status}</span></td>
                            <td>${req.submittedDate}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/driver-requests?id=${req.requestId}"
                                   class="btn-review">Review</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty driverRequests}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 40px; color: var(--muted-foreground);">
                                No driver requests found.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </main>

    <script>
        function filterByStatus() {
            var status = document.getElementById('statusFilter').value;
            var url = '${pageContext.request.contextPath}/admin/driver-requests';
            if (status) url += '?status=' + status;
            window.location.href = url;
        }

        // Client-side search filter
        document.getElementById('requestSearch').addEventListener('input', function() {
            var query = this.value.toLowerCase();
            var rows = document.querySelectorAll('.table-container tbody tr');
            rows.forEach(function(row) {
                var text = row.textContent.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    </script>
</body>
</html>
