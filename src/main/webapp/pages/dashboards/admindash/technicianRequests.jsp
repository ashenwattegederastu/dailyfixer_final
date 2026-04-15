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
    <title>Technician Requests | Daily Fixer Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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

        .status-PENDING  { background: #fef3c7; color: #92400e; }
        .status-APPROVED { background: #d1fae5; color: #065f46; }
        .status-REJECTED { background: #fee2e2; color: #991b1b; }

        .alert-box { padding: 12px 16px; border-radius: 10px; margin-bottom: 20px; font-weight: 500; font-size: 0.9rem; }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .alert-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

        .pill { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; margin-right: 4px; }
        .pill-yes { background: #d1fae5; color: #065f46; }
        .pill-no  { background: #f3f4f6; color: #6b7280; }

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

        .btn-review:hover { opacity: 0.9; transform: translateY(-1px); }
    </style>
</head>
<body>

    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

    <main class="main-content">
        <div class="dashboard-header">
            <h1>Technician Requests
                <c:if test="${pendingCount > 0}">
                    <span class="badge-count">${pendingCount}</span>
                </c:if>
            </h1>
            <p>Review and manage technician registration applications.</p>
        </div>

        <c:if test="${param.success == 'approved'}">
            <div class="alert-box alert-success">Technician request approved. They can now log in.</div>
        </c:if>
        <c:if test="${param.success == 'rejected'}">
            <div class="alert-box alert-success">Technician request has been rejected.</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert-box alert-error">An error occurred. Please try again.</div>
        </c:if>

        <!-- Filters -->
        <div class="search-container">
            <input type="text" id="requestSearch" class="search-input"
                   placeholder="Search by name, email, or city...">
            <select id="statusFilter" class="filter-select" onchange="filterByStatus()">
                <option value="">All Statuses</option>
                <option value="PENDING"  ${param.status == 'PENDING'  ? 'selected' : ''}>Pending</option>
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
                        <th>City</th>
                        <th>Qualifications</th>
                        <th>Experience</th>
                        <th>Status</th>
                        <th>Submitted</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="req" items="${techRequests}">
                        <tr>
                            <td>${req.requestId}</td>
                            <td><strong>${req.fullName}</strong></td>
                            <td>${req.email}</td>
                            <td>${not empty req.city ? req.city : '—'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${req.hasQualifications}"><span class="pill pill-yes">Yes</span></c:when>
                                    <c:otherwise><span class="pill pill-no">No</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${req.hasExperience}"><span class="pill pill-yes">Yes</span></c:when>
                                    <c:otherwise><span class="pill pill-no">No</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td><span class="status-badge status-${req.status}">${req.status}</span></td>
                            <td>${req.submittedDate}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/technician-requests?id=${req.requestId}"
                                   class="btn-review">Review</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty techRequests}">
                        <tr>
                            <td colspan="9" style="text-align: center; padding: 40px; color: var(--muted-foreground);">
                                No technician requests found.
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
            var url = '${pageContext.request.contextPath}/admin/technician-requests';
            if (status) url += '?status=' + status;
            window.location.href = url;
        }

        document.getElementById('requestSearch').addEventListener('input', function() {
            var query = this.value.toLowerCase();
            document.querySelectorAll('.table-container tbody tr').forEach(function(row) {
                row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
            });
        });
    </script>
</body>
</html>
