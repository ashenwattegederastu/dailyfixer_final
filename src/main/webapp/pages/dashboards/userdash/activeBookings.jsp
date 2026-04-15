<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.ClientNoShowPenalty" %>

<% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
        !"user".equalsIgnoreCase(user.getRole().trim())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); return; } %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Active Bookings | Daily Fixer</title>
    <link
            href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
            rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .alert-banner { padding: 0.9rem 1.2rem; border-radius: 0.5rem; margin-bottom: 1rem; font-weight: 500; }
        .alert-banner.success { background: #10b981; color: white; }
        .alert-banner.warning { background: #f59e0b; color: white; }
        .alert-banner.error   { background: #ef4444; color: white; }
        .reschedule-info { background: #fef3c7; border: 1px solid #fcd34d; border-radius: 0.4rem; padding: 0.55rem 0.85rem; font-size: 0.82rem; margin-top: 0.4rem; color: #92400e; }
        .reschedule-info strong { color: #78350f; }
        /* Client no-show penalty styles */
        .penalty-info { background: #fee2e2; border: 1px solid #fca5a5; border-radius: 0.4rem; padding: 0.55rem 0.85rem; font-size: 0.82rem; margin-top: 0.4rem; color: #991b1b; }
        .penalty-info strong { color: #7f1d1d; }
        .btn-pay-penalty {
            padding: 5px 12px;
            font-size: 0.82em;
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-family: inherit;
            font-weight: 600;
        }
        .btn-pay-penalty:hover { opacity: 0.9; }
    </style>
</head>

<body class="dashboard-layout">
<jsp:include page="sidebar.jsp"/>

<main class="dashboard-container">
    <header class="dashboard-header">
        <h1>Active Bookings</h1>
        <p>Manage and track your ongoing service requests</p>
    </header>

    <!-- Alert banners -->
    <c:if test="${param.rescheduleRequested}">
        <div class="alert-banner success">Reschedule request submitted. Your technician will be notified.</div>
    </c:if>
    <c:if test="${param.rescheduleAccepted}">
        <div class="alert-banner success">Reschedule accepted. Your booking date has been updated.</div>
    </c:if>
    <c:if test="${param.rescheduleRejected}">
        <div class="alert-banner warning">Reschedule request rejected. Your booking continues at the original time.</div>
    </c:if>
    <c:if test="${param.penaltyProofSubmitted}">
        <div class="alert-banner success">Payment proof submitted. Your technician will review it within 48 hours.</div>
    </c:if>
    <c:if test="${param.penaltyError}">
        <div class="alert-banner error">Could not submit payment proof. Please try again.</div>
    </c:if>

    <div class="section">
        <div class="table-container">
            <c:choose>
                <c:when test="${empty activeBookings}">
                    <div class="empty-state">
                        <h3>No Active Bookings</h3>
                        <p>You don't have any requested or accepted bookings at the moment.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                        <tr>
                            <th>Service</th>
                            <th>Technician</th>
                            <th>Date & Time</th>
                            <th>Address</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="b" items="${activeBookings}">
                            <tr>
                                <td>
                                    <strong>${b.serviceName}</strong>
                                    <c:if test="${not empty b.recurringContractId}">
                                        <br><span style="display:inline-block; background:#dbeafe; color:#1e40af; border-radius:4px; padding:1px 6px; font-size:0.75rem; font-weight:700; margin-top:2px;">&#8635; Recurring &mdash; Month ${b.recurringSequence}/12</span>
                                        <br><a href="${pageContext.request.contextPath}/pages/dashboards/userdash/recurringContracts.jsp" style="font-size:0.78rem; color:var(--muted-foreground); text-decoration:underline;">View full contract</a>
                                    </c:if>
                                    <br><small>${b.problemDescription}</small>
                                </td>
                                <td>${b.technicianName}</td>
                                <td>
                                    <fmt:formatDate value="${b.bookingDate}" pattern="MMM dd, yyyy"/><br>
                                    <fmt:formatDate value="${b.bookingTime}" pattern="hh:mm a" type="time"/>
                                </td>
                                <td>${b.locationAddress}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${b.status eq 'ACCEPTED'}">
                                            <span class="status-badge" style="background:#d1fae5;color:#065f46;">Accepted</span>
                                        </c:when>
                                        <c:when test="${b.status eq 'IN_PROGRESS'}">
                                            <span class="status-badge" style="background:#dbeafe;color:#1e40af;">In Progress</span>
                                        </c:when>
                                        <c:when test="${b.status eq 'RESCHEDULE_PENDING'}">
                                            <span class="status-badge" style="background:#fef3c7;color:#92400e;">Reschedule Pending</span>
                                            <c:set var="pr" value="${pendingReschedules[b.bookingId]}"/>
                                            <c:if test="${not empty pr}">
                                                <div class="reschedule-info">
                                                    New time: <strong><fmt:formatDate value="${pr.newDate}" pattern="MMM dd, yyyy"/> at <fmt:formatDate value="${pr.newTime}" pattern="hh:mm a" type="time"/></strong>
                                                    <c:if test="${not empty pr.reason}"> &mdash; &ldquo;${pr.reason}&rdquo;</c:if>
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:when test="${b.status eq 'NO_SHOW'}">
                                            <span class="status-badge" style="background:#fee2e2;color:#991b1b;">No Show</span>
                                        </c:when>
                                        <c:when test="${b.status eq 'CLIENT_NO_SHOW'}">
                                            <span class="status-badge" style="background:#fce7f3;color:#9d174d;">Client Not Home</span>
                                            <c:set var="cp" value="${clientPenalties[b.bookingId]}"/>
                                            <c:if test="${not empty cp}">
                                                <div class="penalty-info">
                                                    Penalty: <strong>Rs. 2,500</strong>
                                                    <c:choose>
                                                        <c:when test="${cp.status eq 'PENDING'}">&mdash; Awaiting payment</c:when>
                                                        <c:when test="${cp.status eq 'PROOF_UPLOADED'}">&mdash; Proof submitted, awaiting review</c:when>
                                                        <c:when test="${cp.status eq 'ADMIN_REVIEW'}">&mdash; Under admin review</c:when>
                                                        <c:when test="${cp.status eq 'CONFIRMED_PAID'}">&mdash; <span style="color:#065f46;font-weight:700;">Paid &#10003;</span></c:when>
                                                        <c:when test="${cp.status eq 'RESOLVED'}">&mdash; <span style="color:#065f46;font-weight:700;">Resolved</span></c:when>
                                                        <c:when test="${cp.status eq 'FRAUD_SUSPENDED'}">&mdash; <span style="color:#7f1d1d;">Account suspended</span></c:when>
                                                    </c:choose>
                                                </div>
                                                <c:if test="${not empty cp.techProofPath}">
                                                    <div class="penalty-info" style="margin-top:0.4rem;background:#fff1f2;border-color:#fca5a5;">
                                                        <a href="${pageContext.request.contextPath}/${cp.techProofPath}" target="_blank"
                                                           style="color:#7f1d1d;font-weight:600;text-decoration:underline;font-size:0.85em;">
                                                            View Technician Arrival Proof
                                                        </a>
                                                    </div>
                                                </c:if>
                                            </c:if>
                                        </c:when>
                                        <c:when test="${b.status eq 'TECHNICIAN_COMPLETED'}">
                                            <span class="status-badge" style="background:#e0e7ff;color:#3730a3;">Awaiting Confirmation</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge priority-low" style="background:#fef3c7;color:#92400e;">Pending</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <c:if test="${bookingChatIds[b.bookingId] > 0}">
                                            <a href="${pageContext.request.contextPath}/chats/view?chatId=${bookingChatIds[b.bookingId]}"
                                               class="btn-primary"
                                               style="padding: 4px 10px; font-size: 0.8em; margin-right: 5px;">Message</a>
                                        </c:if>

                                        <%-- Confirm completion (TECHNICIAN_COMPLETED) --%>
                                        <c:if test="${b.status eq 'TECHNICIAN_COMPLETED'}">
                                            <form method="post" action="${pageContext.request.contextPath}/bookings/complete" style="display:inline;">
                                                <input type="hidden" name="bookingId" value="${b.bookingId}">
                                                <input type="hidden" name="completionType" value="user">
                                                <button type="submit" class="btn-secondary"
                                                        style="padding:4px 10px;font-size:0.8em;background:#4f46e5;color:white;border:none;cursor:pointer;">Confirm Completion</button>
                                            </form>
                                        </c:if>

                                        <%-- Request reschedule (ACCEPTED only) --%>
                                        <c:if test="${b.status eq 'ACCEPTED'}">
                                            <button onclick="openRescheduleModal(${b.bookingId})"
                                                    style="padding:4px 10px;font-size:0.8em;background:#6b7280;color:white;border:none;border-radius:4px;cursor:pointer;font-family:inherit;">Reschedule</button>
                                        </c:if>

                                        <%-- Respond to technician's reschedule request --%>
                                        <c:if test="${b.status eq 'RESCHEDULE_PENDING'}">
                                            <c:set var="pr" value="${pendingReschedules[b.bookingId]}"/>
                                            <c:choose>
                                                <c:when test="${not empty pr and pr.requestedBy eq sessionScope.currentUser.userId}">
                                                    <span style="font-size:0.78rem;color:#92400e;font-weight:600;">Awaiting technician response</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:if test="${not empty pr}">
                                                        <form method="post" action="${pageContext.request.contextPath}/bookings/reschedule/respond" style="display:inline;">
                                                            <input type="hidden" name="bookingId" value="${b.bookingId}">
                                                            <input type="hidden" name="rescheduleId" value="${pr.rescheduleId}">
                                                            <input type="hidden" name="action" value="accept">
                                                            <input type="hidden" name="keepBooking" value="true">
                                                            <button type="submit" style="padding:4px 10px;font-size:0.8em;background:#10b981;color:white;border:none;border-radius:4px;cursor:pointer;font-family:inherit;">Accept</button>
                                                        </form>
                                                        <form method="post" action="${pageContext.request.contextPath}/bookings/reschedule/respond" style="display:inline;">
                                                            <input type="hidden" name="bookingId" value="${b.bookingId}">
                                                            <input type="hidden" name="rescheduleId" value="${pr.rescheduleId}">
                                                            <input type="hidden" name="action" value="reject">
                                                            <input type="hidden" name="keepBooking" value="true">
                                                            <button type="submit" style="padding:4px 10px;font-size:0.8em;background:#f59e0b;color:white;border:none;border-radius:4px;cursor:pointer;font-family:inherit;">Reject</button>
                                                        </form>
                                                        <form method="post" action="${pageContext.request.contextPath}/bookings/reschedule/respond" style="display:inline;">
                                                            <input type="hidden" name="bookingId" value="${b.bookingId}">
                                                            <input type="hidden" name="rescheduleId" value="${pr.rescheduleId}">
                                                            <input type="hidden" name="action" value="reject">
                                                            <input type="hidden" name="keepBooking" value="false">
                                                            <button type="submit" style="padding:4px 10px;font-size:0.8em;background:#ef4444;color:white;border:none;border-radius:4px;cursor:pointer;font-family:inherit;">Reject &amp; Cancel</button>
                                                        </form>
                                                    </c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>

                                        <%-- NO_SHOW note --%>
                                        <c:if test="${b.status eq 'NO_SHOW'}">
                                            <span style="font-size:0.78rem;color:#991b1b;font-weight:600;">Technician did not show up.</span>
                                        </c:if>

                                        <%-- CLIENT_NO_SHOW: Pay Penalty button --%>
                                        <c:if test="${b.status eq 'CLIENT_NO_SHOW'}">
                                            <c:set var="cp" value="${clientPenalties[b.bookingId]}"/>
                                            <c:if test="${not empty cp and cp.status eq 'PENDING'}">
                                                <button class="btn-pay-penalty"
                                                        onclick="openPayPenaltyModal(${cp.penaltyId})">Pay Penalty</button>
                                            </c:if>
                                            <c:if test="${not empty cp and cp.status eq 'PROOF_UPLOADED'}">
                                                <span style="font-size:0.78rem;color:#9d174d;font-weight:600;">Awaiting technician review.</span>
                                            </c:if>
                                            <c:if test="${not empty cp and cp.status eq 'ADMIN_REVIEW'}">
                                                <span style="font-size:0.78rem;color:#92400e;font-weight:600;">Under admin review.</span>
                                            </c:if>
                                        </c:if>
                                        <%-- Cancel Booking (REQUESTED or ACCEPTED) --%>
                                        <c:if test="${b.status eq 'REQUESTED' or b.status eq 'ACCEPTED'}">
                                            <button onclick="handleClientCancelClick(${b.bookingId}, '${b.bookingDate}', '${b.bookingTime}')"
                                                    style="padding:4px 10px;font-size:0.8em;background:#ef4444;color:white;border:none;border-radius:4px;cursor:pointer;font-family:inherit;font-weight:600;margin-top:4px;">Cancel Booking</button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<!-- Client Early Cancel Warning Modal -->
<div id="clientEarlyCancelModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:var(--card);padding:2rem;border-radius:0.75rem;max-width:500px;width:90%;border:1px solid var(--border);">
        <h3 style="font-size:1.2rem;font-weight:700;margin-bottom:0.75rem;color:#991b1b;">&#9888; Late Cancellation Fee Required</h3>
        <p style="color:var(--muted-foreground);font-size:0.88em;margin-bottom:0.75rem;line-height:1.6;">
            This booking is scheduled within the next <strong>24 hours</strong>. Cancelling at this stage requires a
            <strong style="color:#991b1b;">penalty fee equal to 50% of the booking amount</strong> to be paid to the
            Daily Fixer system before the cancellation is processed.
        </p>
        <div style="display:flex;gap:0.75rem;margin-top:1.25rem;">
            <button type="button" style="flex:1;padding:0.7rem;background:#ef4444;color:white;border:none;border-radius:0.4rem;font-weight:600;font-family:inherit;cursor:pointer;">Cancel and Pay</button>
            <button type="button" onclick="closeClientEarlyCancelModal()" style="flex:1;padding:0.7rem;background:var(--secondary);color:var(--secondary-foreground);border:1px solid var(--border);border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Go Back</button>
        </div>
    </div>
</div>

<!-- Client Cancel Booking Modal -->
<div id="clientCancelModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:var(--card);padding:2rem;border-radius:0.75rem;max-width:480px;width:90%;border:1px solid var(--border);">
        <h3 style="font-size:1.3rem;font-weight:700;margin-bottom:1rem;">Cancel Booking</h3>
        <form id="clientCancelForm" method="post" action="${pageContext.request.contextPath}/bookings/cancel">
            <input type="hidden" name="bookingId" id="clientCancelBookingId">
            <div style="margin-bottom:0.9rem;">
                <label style="display:block;margin-bottom:0.4rem;font-weight:600;">Reason for Cancellation *</label>
                <textarea name="cancellationReason" required rows="4" placeholder="Please provide a reason..."
                    style="width:100%;padding:0.65rem;border:1px solid var(--border);border-radius:0.4rem;background:var(--input);color:var(--foreground);resize:vertical;font-family:inherit;"></textarea>
            </div>
            <div style="display:flex;gap:0.75rem;">
                <button type="submit" style="flex:1;padding:0.7rem;background:#ef4444;color:white;border:none;border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Cancel Booking</button>
                <button type="button" onclick="closeClientCancelModal()" style="flex:1;padding:0.7rem;background:var(--secondary);color:var(--secondary-foreground);border:1px solid var(--border);border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Go Back</button>
            </div>
        </form>
    </div>
</div>

<!-- Pay Penalty Modal -->
<div id="payPenaltyModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:var(--card);padding:2rem;border-radius:0.75rem;max-width:500px;width:90%;border:1px solid var(--border);">
        <h3 style="font-size:1.2rem;font-weight:700;margin-bottom:0.5rem;color:var(--foreground);">Pay No-Show Penalty</h3>
        <p style="color:var(--muted-foreground);font-size:0.88em;margin-bottom:1rem;line-height:1.6;">
            A <strong style="color:#991b1b;">Rs. 2,500</strong> penalty has been issued because the technician arrived but you were not available.
            Please transfer the amount and upload proof of payment below.
        </p>
        <div style="background:#fef3c7;border:1px solid #fcd34d;border-radius:0.4rem;padding:0.75rem 1rem;font-size:0.85em;color:#92400e;margin-bottom:1.2rem;">
            <strong>Payment Instructions:</strong> Transfer Rs. 2,500 to the Daily Fixer account and upload a screenshot or photo of the payment confirmation.
        </div>
        <form id="payPenaltyForm" method="post"
              action="${pageContext.request.contextPath}/client/penalty/upload-proof"
              enctype="multipart/form-data">
            <input type="hidden" name="penaltyId" id="payPenaltyId">
            <div style="margin-bottom:1rem;">
                <label style="display:block;margin-bottom:0.4rem;font-weight:600;color:var(--foreground);">Payment Proof (JPG or PNG, max 2 MB) *</label>
                <input type="file" name="proofFile" id="proofImageInput" accept="image/jpeg,image/png" required
                       style="width:100%;padding:0.65rem;border:1px solid var(--border);border-radius:0.4rem;background:var(--input);color:var(--foreground);font-family:inherit;">
                <div id="proofFileError" style="color:#dc2626;font-size:0.8em;margin-top:0.3rem;display:none;"></div>
            </div>
            <div style="display:flex;gap:0.75rem;">
                <button type="submit" style="flex:1;padding:0.7rem;background:#ef4444;color:white;border:none;border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Submit Proof</button>
                <button type="button" onclick="closePayPenaltyModal()" style="flex:1;padding:0.7rem;background:var(--secondary);color:var(--secondary-foreground);border:1px solid var(--border);border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Reschedule Request Modal -->
<div id="rescheduleModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
    <div style="background:var(--card);padding:2rem;border-radius:0.75rem;max-width:480px;width:90%;border:1px solid var(--border);">
        <h3 style="font-size:1.3rem;font-weight:700;margin-bottom:1rem;">Request Reschedule</h3>
        <form id="rescheduleForm" method="post" action="${pageContext.request.contextPath}/bookings/reschedule/request">
            <input type="hidden" name="bookingId" id="rescheduleBookingId">
            <div style="margin-bottom:0.9rem;">
                <label style="display:block;margin-bottom:0.4rem;font-weight:600;">New Date *</label>
                <input type="date" name="newDate" required style="width:100%;padding:0.65rem;border:1px solid var(--border);border-radius:0.4rem;background:var(--input);color:var(--foreground);font-family:inherit;">
            </div>
            <div style="margin-bottom:0.9rem;">
                <label style="display:block;margin-bottom:0.4rem;font-weight:600;">New Time *</label>
                <input type="time" name="newTime" required style="width:100%;padding:0.65rem;border:1px solid var(--border);border-radius:0.4rem;background:var(--input);color:var(--foreground);font-family:inherit;">
            </div>
            <div style="margin-bottom:0.9rem;">
                <label style="display:block;margin-bottom:0.4rem;font-weight:600;">Reason (optional)</label>
                <textarea name="reason" rows="3" placeholder="Reason for rescheduling..."
                    style="width:100%;padding:0.65rem;border:1px solid var(--border);border-radius:0.4rem;background:var(--input);color:var(--foreground);resize:vertical;font-family:inherit;"></textarea>
            </div>
            <div style="display:flex;gap:0.75rem;">
                <button type="submit" style="flex:1;padding:0.7rem;background:#10b981;color:white;border:none;border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Submit Request</button>
                <button type="button" onclick="closeRescheduleModal()" style="flex:1;padding:0.7rem;background:var(--secondary);color:var(--secondary-foreground);border:1px solid var(--border);border-radius:0.4rem;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openPayPenaltyModal(penaltyId) {
        document.getElementById('payPenaltyId').value = penaltyId;
        document.getElementById('proofFileError').style.display = 'none';
        document.getElementById('proofImageInput').value = '';
        document.getElementById('payPenaltyModal').style.display = 'flex';
    }
    function closePayPenaltyModal() {
        document.getElementById('payPenaltyModal').style.display = 'none';
    }
    document.getElementById('payPenaltyModal').addEventListener('click', function(e) {
        if (e.target === this) closePayPenaltyModal();
    });
    document.getElementById('payPenaltyForm').addEventListener('submit', function(e) {
        var fileInput = document.getElementById('proofImageInput');
        var errDiv = document.getElementById('proofFileError');
        errDiv.style.display = 'none';
        if (!fileInput.files || fileInput.files.length === 0) {
            e.preventDefault();
            errDiv.textContent = 'Please select a file.';
            errDiv.style.display = 'block';
            return;
        }
        var file = fileInput.files[0];
        if (file.size > 2 * 1024 * 1024) {
            e.preventDefault();
            errDiv.textContent = 'File must be under 2 MB.';
            errDiv.style.display = 'block';
            return;
        }
        var allowed = ['image/jpeg', 'image/png'];
        if (allowed.indexOf(file.type) === -1) {
            e.preventDefault();
            errDiv.textContent = 'Only JPG and PNG files are allowed.';
            errDiv.style.display = 'block';
        }
    });

    function openRescheduleModal(bookingId) {
        document.getElementById('rescheduleBookingId').value = bookingId;
        document.getElementById('rescheduleModal').style.display = 'flex';
    }
    function closeRescheduleModal() {
        document.getElementById('rescheduleModal').style.display = 'none';
    }
    document.getElementById('rescheduleModal').addEventListener('click', function(e) {
        if (e.target === this) closeRescheduleModal();
    });
    document.getElementById('clientEarlyCancelModal').addEventListener('click', function(e) {
        if (e.target === this) closeClientEarlyCancelModal();
    });
    document.getElementById('clientCancelModal').addEventListener('click', function(e) {
        if (e.target === this) closeClientCancelModal();
    });

    function handleClientCancelClick(bookingId, dateStr, timeStr) {
        var bookingMs = new Date(dateStr + 'T' + timeStr).getTime();
        var hoursAway = (bookingMs - Date.now()) / 3600000;
        if (hoursAway > 0 && hoursAway <= 24) {
            document.getElementById('clientEarlyCancelModal').style.display = 'flex';
        } else {
            document.getElementById('clientCancelBookingId').value = bookingId;
            document.getElementById('clientCancelModal').style.display = 'flex';
        }
    }
    function closeClientEarlyCancelModal() {
        document.getElementById('clientEarlyCancelModal').style.display = 'none';
    }
    function closeClientCancelModal() {
        document.getElementById('clientCancelModal').style.display = 'none';
    }
</script>
</body>
</html>