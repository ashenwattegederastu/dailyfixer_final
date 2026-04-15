<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dailyfixer.model.RecurringContract" %>
<%@ page import="com.dailyfixer.dao.RecurringContractDAO" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<% User user = (User) session.getAttribute("currentUser");
   if (user == null || user.getRole() == null || !"technician".equalsIgnoreCase(user.getRole())) {
       response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
       return;
   }
   RecurringContractDAO dao = new RecurringContractDAO();
   List<RecurringContract> contracts = dao.getContractsByTechnicianId(user.getUserId());
   request.setAttribute("contracts", contracts);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recurring Contracts | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .status-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 4px;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .badge-active   { background: #d1fae5; color: #065f46; }
        .badge-pending  { background: #fef3c7; color: #92400e; }
        .badge-cancelled { background: #fee2e2; color: #991b1b; }
        .badge-completed { background: #e0e7ff; color: #3730a3; }
    </style>
</head>
<body>
    <jsp:include page="sidebar.jsp" />

    <div class="dashboard-container">
        <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 0.5rem; color: var(--foreground);">Recurring Contracts</h1>
        <p style="color: var(--muted-foreground); margin-bottom: 1.5rem;">Active and past 1-year recurring service contracts with your customers.</p>

        <c:if test="${param.cancelled == 'true'}">
            <div style="background: #10b981; color: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                Contract cancelled. Future bookings have been removed.
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty contracts}">
                <div style="text-align: center; padding: 3rem; background: var(--card); border-radius: var(--radius); border: 1px solid var(--border);">
                    <p style="font-size: 1.125rem; color: var(--muted-foreground);">You have no recurring contracts yet.</p>
                    <p style="color: var(--muted-foreground); font-size: 0.9rem; margin-top: 0.5rem;">Enable recurring bookings on a service listing to get started.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Customer</th>
                                <th>Service</th>
                                <th>Monthly Fee</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${contracts}" varStatus="loop">
                                <tr>
                                    <td>${loop.index + 1}</td>
                                    <td>${c.userName}</td>
                                    <td>${c.serviceName}</td>
                                    <td>Rs. <fmt:formatNumber value="${c.recurringFee}" maxFractionDigits="2" minFractionDigits="2"/>/mo</td>
                                    <td>${c.startDate}</td>
                                    <td>${c.endDate}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status == 'ACTIVE'}">
                                                <span class="status-badge badge-active">Active</span>
                                            </c:when>
                                            <c:when test="${c.status == 'PENDING'}">
                                                <span class="status-badge badge-pending">Pending</span>
                                            </c:when>
                                            <c:when test="${c.status == 'CANCELLED'}">
                                                <span class="status-badge badge-cancelled">Cancelled</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge badge-completed">Completed</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${c.status == 'ACTIVE' || c.status == 'PENDING'}">
                                            <button type="button"
                                                    onclick="handleTechRecurringCancel(${c.contractId}, ${c.bookingDayOfMonth})"
                                                    style="background: var(--destructive); color: var(--destructive-foreground); border: none; padding: 6px 14px; border-radius: 4px; font-size: 0.85rem; font-weight: 600; cursor: pointer;">
                                                Cancel
                                            </button>
                                        </c:if>
                                        <c:if test="${c.status != 'ACTIVE' && c.status != 'PENDING'}">
                                            <span style="color: var(--muted-foreground); font-size: 0.85rem;">—</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
<!-- Hidden forms for recurring cancel POST -->
<form id="techRecurringCancelForm" method="post" action="${pageContext.request.contextPath}/recurring/cancel" style="display:none;">
    <input type="hidden" name="contractId" id="techRecurringContractId">
    <input type="hidden" name="role" value="technician">
</form>

<!-- Technician Early Recurring Cancel Modal (≤15 days to next booking) -->
<div id="techRecurringEarlyModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:var(--card);padding:2rem;border-radius:0.75rem;max-width:520px;width:90%;border:1px solid var(--border);">
        <h3 style="font-size:1.2rem;font-weight:700;margin-bottom:0.75rem;color:#991b1b;">&#9888; Early Recurring Contract Cancellation</h3>
        <p style="color:var(--muted-foreground);font-size:0.88em;margin-bottom:0.75rem;line-height:1.6;">
            The next scheduled booking for this contract is within <strong>15 days</strong>.
            Cancelling now will count as an <strong>early recurring cancellation</strong>.
        </p>
        <p style="color:var(--muted-foreground);font-size:0.88em;line-height:1.6;">
            Technicians are permitted a maximum of <strong>2 early recurring cancellations per calendar month</strong>.
            Each additional one beyond the limit will result in a <strong>strike</strong>.
            Accumulating <strong>3 strikes</strong> will lead to automatic <strong>account suspension</strong>.
        </p>
        <div style="display:flex;gap:0.75rem;margin-top:1.25rem;">
            <button type="button" onclick="confirmTechRecurringEarlyCancel()" style="flex:1;padding:0.7rem;background:#ef4444;color:white;border:none;border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Proceed to Cancel</button>
            <button type="button" onclick="closeTechRecurringEarlyModal()" style="flex:1;padding:0.7rem;background:var(--secondary);color:var(--secondary-foreground);border:1px solid var(--border);border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Go Back</button>
        </div>
    </div>
</div>

<!-- Technician Normal Recurring Cancel Confirm Modal (>15 days) -->
<div id="techRecurringConfirmModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:var(--card);padding:2rem;border-radius:0.75rem;max-width:460px;width:90%;border:1px solid var(--border);">
        <h3 style="font-size:1.2rem;font-weight:700;margin-bottom:0.75rem;">Cancel Recurring Contract</h3>
        <p style="color:var(--muted-foreground);font-size:0.88em;line-height:1.6;">
            Are you sure? This will cancel the contract and remove all future scheduled bookings.
        </p>
        <div style="display:flex;gap:0.75rem;margin-top:1.25rem;">
            <button type="button" onclick="confirmTechRecurringCancel()" style="flex:1;padding:0.7rem;background:#ef4444;color:white;border:none;border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Confirm Cancel</button>
            <button type="button" onclick="closeTechRecurringConfirmModal()" style="flex:1;padding:0.7rem;background:var(--secondary);color:var(--secondary-foreground);border:1px solid var(--border);border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Go Back</button>
        </div>
    </div>
</div>

<script>
    function nextOccurrence(dayOfMonth) {
        var now = new Date();
        var d = new Date(now.getFullYear(), now.getMonth(), dayOfMonth);
        if (d <= now) {
            d = new Date(now.getFullYear(), now.getMonth() + 1, dayOfMonth);
        }
        return d;
    }

    function handleTechRecurringCancel(contractId, dayOfMonth) {
        var next = nextOccurrence(dayOfMonth);
        var daysAway = (next - new Date()) / 86400000;
        document.getElementById('techRecurringContractId').value = contractId;
        if (daysAway <= 15) {
            document.getElementById('techRecurringEarlyModal').style.display = 'flex';
        } else {
            document.getElementById('techRecurringConfirmModal').style.display = 'flex';
        }
    }

    function confirmTechRecurringEarlyCancel() {
        closeTechRecurringEarlyModal();
        document.getElementById('techRecurringCancelForm').submit();
    }

    function confirmTechRecurringCancel() {
        closeTechRecurringConfirmModal();
        document.getElementById('techRecurringCancelForm').submit();
    }

    function closeTechRecurringEarlyModal() {
        document.getElementById('techRecurringEarlyModal').style.display = 'none';
    }

    function closeTechRecurringConfirmModal() {
        document.getElementById('techRecurringConfirmModal').style.display = 'none';
    }

    document.getElementById('techRecurringEarlyModal').addEventListener('click', function(e) {
        if (e.target === this) closeTechRecurringEarlyModal();
    });
    document.getElementById('techRecurringConfirmModal').addEventListener('click', function(e) {
        if (e.target === this) closeTechRecurringConfirmModal();
    });
</script>
</html>
