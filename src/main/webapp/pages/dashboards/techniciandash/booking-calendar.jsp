<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.dailyfixer.model.ClientNoShowPenalty, java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings - Technician Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking-calendar.css">
    <%-- All styles live in booking-calendar.css --%>
</head>

<body>
    <jsp:include page="sidebar.jsp" />

    <div class="dashboard-container">
        <!-- Page header -->
        <div class="page-header">





                    <h1>My Bookings</h1>
                    <div class="view-toggle">
                        <button id="btnListView" class="active" onclick="switchView('list')">📋 List View</button>
                        <button id="btnCalendarView" onclick="switchView('calendar')">📅 Calendar View</button>
                    </div>
                </div>

                <!-- Alert banners -->
                <c:if test="${param.completed}">
                    <div class="alert-banner success">Booking marked as completed!</div>
                </c:if>
                <c:if test="${param.started}">
                    <div class="alert-banner success">Job started — booking is now In Progress.</div>
                </c:if>
                <c:if test="${param.cancelled}">
                    <div class="alert-banner warning">Booking cancelled successfully.</div>
                </c:if>
                <c:if test="${param.rescheduleRequested}">
                    <div class="alert-banner success">Reschedule request submitted. The client will be notified.</div>
                </c:if>
                <c:if test="${param.rescheduleAccepted}">
                    <div class="alert-banner success">Reschedule accepted. Booking has been updated to the new date and time.</div>
                </c:if>
                <c:if test="${param.rescheduleRejected}">
                    <div class="alert-banner warning">Reschedule request rejected. The booking continues at its original time.</div>
                </c:if>
                <c:if test="${param.limitReached}">
                    <div class="alert-banner warning">&#9888; Daily booking limit reached for <strong>${param.date}</strong>. You cannot accept more bookings on that day.</div>
                </c:if>
                <c:if test="${param.clientNoShow}">
                    <div class="alert-banner success">Client not home recorded. The client has been notified and a Rs. 2,500 penalty has been applied.</div>
                </c:if>
                <c:if test="${param.penaltyConfirmed}">
                    <div class="alert-banner success">Payment confirmed. The no-show penalty for this booking is now resolved.</div>
                </c:if>
                <c:if test="${param.penaltyDisputed}">
                    <div class="alert-banner warning">Payment disputed. The case has been escalated to admin for review.</div>
                </c:if>

                <!-- ════════ PENDING CLIENT PENALTY REVIEWS ════════ -->
                <c:if test="${not empty pendingPenaltyReviews}">
                <div class="penalty-review-section">
                    <h2>&#9888; Pending Client Payment Reviews (${fn:length(pendingPenaltyReviews)})</h2>
                    <p class="penalty-subtitle">
                        The following clients have uploaded payment proof for no-show penalties. You must confirm or dispute within 48 hours, after which the case auto-escalates to admin.
                    </p>
                    <c:forEach var="pr" items="${pendingPenaltyReviews}">
                    <div class="penalty-review-card">
                        <div class="penalty-review-info">
                            <strong>${pr.clientName} &mdash; ${pr.serviceName}</strong>
                            <small>Booking #${pr.bookingId} &bull; Date: ${pr.bookingDate} &bull; Penalty: Rs. 2,500</small>
                            <small>Proof uploaded: <fmt:formatDate value="${pr.proofUploadedAt}" pattern="dd MMM yyyy, HH:mm"/></small>
                        </div>
                        <div class="penalty-review-actions">
                            <a href="${pageContext.request.contextPath}/${pr.proofPath}"
                               target="_blank" class="btn-view-proof">View Proof</a>
                            <form method="post" action="${pageContext.request.contextPath}/technician/client-penalty/review">
                                <input type="hidden" name="penaltyId" value="${pr.penaltyId}">
                                <input type="hidden" name="action" value="confirm">
                                <button type="submit" class="btn-confirm-paid">Confirm Paid</button>
                            </form>
                            <form method="post" action="${pageContext.request.contextPath}/technician/client-penalty/review">
                                <input type="hidden" name="penaltyId" value="${pr.penaltyId}">
                                <input type="hidden" name="action" value="dispute">
                                <button type="submit" class="btn-dispute-paid">Mark Not Paid</button>
                            </form>
                        </div>
                    </div>
                    </c:forEach>
                </div>
                </c:if>

                <!-- Empty state -->
                <c:if test="${empty bookings}">
                    <div class="empty-state-card">
                        <p>No active bookings found.</p>
                    </div>
                </c:if>

                <!-- ════════════ LIST VIEW ════════════ -->
                <div id="list-view">
                    <div class="booking-list" id="listViewContainer"></div>
                </div>

                <!-- ════════════ CALENDAR VIEW ════════════ -->
                <div id="calendar-view" hidden>
                    <div class="calendar-controls">
                        <div class="calendar-nav">
                            <button onclick="changeMonth(-1)">&#9664;</button>
                            <span id="calMonthLabel" class="calendar-month-label"></span>
                            <button onclick="changeMonth(1)">&#9654;</button>
                        </div>
                        <button class="btn-today" onclick="goToToday()">Today</button>
                    </div>
                    <div id="calendarGrid" class="calendar-grid"></div>
                </div>
            </div>

            <!-- ════════════ CLIENT NOT HOME MODAL ════════════ -->
            <div id="clientNoShowModal" class="modal-overlay">
                <div class="modal-content modal-content--narrow">
                    <h3 class="modal-danger-title">&#9888; Mark Client Not Home</h3>
                    <p class="modal-subtitle">
                        You are about to record that the client was not available at the scheduled location.
                        A <strong>Rs. 2,500 no-show penalty</strong> will be applied to the client's account.
                        This action cannot be undone.
                    </p>
                    <form id="clientNoShowForm" method="post"
                          action="${pageContext.request.contextPath}/bookings/client-no-show"
                          enctype="multipart/form-data">
                        <input type="hidden" name="bookingId" id="clientNoShowBookingId">
                        <div class="modal-form-group">
                            <label>Arrival Proof Photo (JPG or PNG, max 5 MB) *</label>
                            <p class="field-hint">Upload a photo showing the client's door / location to confirm you arrived.</p>
                            <input type="file" name="techProofFile" id="techProofFileInput"
                                   accept="image/jpeg,image/png" required>
                            <div id="techProofFileError" class="field-error"></div>
                        </div>
                        <div class="modal-actions">
                            <button type="submit" class="btn-no-show-confirm">Confirm – Client Not Home</button>
                            <button type="button" class="modal-close-btn" onclick="closeClientNoShowModal()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
            <div id="cancelModal" class="modal-overlay">
                <div class="modal-content">
                    <h3>Cancel Booking</h3>
                    <form id="cancelForm" method="post" action="${pageContext.request.contextPath}/bookings/cancel">
                        <input type="hidden" name="bookingId" id="cancelBookingId">
                        <div class="modal-form-group">
                            <label>Reason for Cancellation *</label>
                            <textarea name="cancellationReason" required rows="4"
                                placeholder="Please provide a reason..."></textarea>
                        </div>
                        <div class="modal-actions">
                            <button type="submit" class="btn-cancel-booking">Cancel Booking</button>
                            <button type="button" class="modal-close-btn" onclick="closeCancelModal()">Close</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- ════════════ TECHNICIAN EARLY CANCEL WARNING MODAL ════════════ -->
            <div id="techEarlyCancelModal" class="modal-overlay">
                <div class="modal-content modal-content--narrow">
                    <h3 class="modal-danger-title">&#9888; Early Cancellation Warning</h3>
                    <p class="modal-subtitle">
                        This booking is scheduled within the next <strong>24 hours</strong>.
                        Cancelling at this stage is considered an <strong>emergency cancellation</strong>.
                    </p>
                    <p class="modal-subtitle" style="margin-top: 0.6rem;">
                        Technicians are permitted a maximum of <strong>2 emergency cancellations per calendar month</strong>.
                        Each cancellation beyond this limit will result in a <strong>strike</strong> on your account.
                        Accumulating <strong>3 strikes</strong> will result in automatic <strong>account suspension</strong>.
                    </p>
                    <input type="hidden" id="techEarlyCancelBookingId">
                    <div class="modal-actions">
                        <button type="button" class="btn-cancel-booking" onclick="proceedTechEarlyCancel()">Proceed to Cancel</button>
                        <button type="button" class="modal-close-btn" onclick="closeTechEarlyCancelModal()">Go Back</button>
                    </div>
                </div>
            </div>

            <!-- ════════════ RESCHEDULE REQUEST MODAL ════════════ -->
            <div id="rescheduleModal" class="modal-overlay">
                <div class="modal-content">
                    <h3>Request Reschedule</h3>
                    <form id="rescheduleForm" method="post" action="${pageContext.request.contextPath}/bookings/reschedule/request">
                        <input type="hidden" name="bookingId" id="rescheduleBookingId">
                        <div class="modal-form-group">
                            <label>New Date *</label>
                            <input type="date" name="newDate" id="rescheduleNewDate" required>
                        </div>
                        <div class="modal-form-group">
                            <label>New Time *</label>
                            <input type="time" name="newTime" id="rescheduleNewTime" required>
                        </div>
                        <div class="modal-form-group">
                            <label>Reason (optional)</label>
                            <textarea name="reason" rows="3" placeholder="Provide a reason for rescheduling..."></textarea>
                        </div>
                        <div class="modal-actions">
                            <button type="submit" class="btn-complete">Submit Request</button>
                            <button type="button" class="modal-close-btn" onclick="closeRescheduleModal()">Close</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- ════════════ BOOKING DETAIL MODAL (calendar click) ════════════ -->
            <div id="detailModal" class="modal-overlay">
                <div class="modal-content">
                    <h3 id="detailServiceName"></h3>
                    <div class="info-block">
                        <p><strong>Customer:</strong> <span id="detailCustomer"></span></p>
                        <p><strong>Phone:</strong> <span id="detailPhone"></span></p>
                        <p><strong>Date:</strong> <span id="detailDate"></span></p>
                        <p><strong>Status:</strong> <span id="detailStatusBadge"></span></p>
                    </div>
                    <div class="info-block">
                        <p class="label">Problem Description:</p>
                        <p id="detailProblem"></p>
                    </div>
                    <div class="info-block">
                        <p class="label">Location:</p>
                        <p id="detailAddress"></p>
                        <a id="detailMapLink" href="#" target="_blank" class="map-link">View on Google Maps</a>
                    </div>
                    <div id="detailActions" class="booking-actions"></div>
                    <div class="modal-footer-right">
                        <button class="modal-close-btn" onclick="closeDetailModal()">Close</button>
                    </div>
                </div>
            </div>

            <script>
                /* ── Serialize bookings from JSTL to JS ────────── */
                var bookings = [
                    <c:forEach var="booking" items="${bookings}" varStatus="loop">
                        {
                            id: ${booking.bookingId},
                        service: "${booking.serviceName}",
                        customer: "${booking.userName}",
                        date: "${booking.bookingDate}",
                        time: "${booking.bookingTime}",
                        status: "${booking.status}",
                        phone: "${booking.phoneNumber}",
                        problem: "${booking.problemDescription}",
                        address: "${booking.locationAddress}",
                        lat: "${booking.locationLatitude}",
                        lng: "${booking.locationLongitude}",
                        recurring: ${not empty booking.recurringContractId ? 'true' : 'false'},
                        recurringSeq: ${not empty booking.recurringSequence ? booking.recurringSequence : 0},
                        contractId: ${not empty booking.recurringContractId ? booking.recurringContractId : 0},
                        updatedAt: ${not empty booking.updatedAt ? booking.updatedAt.time : 0},
                        chatId: ${bookingChatIds[booking.bookingId]}
            }<c:if test="${!loop.last}">,</c:if>
                    </c:forEach>
                ];

                var contextPath = "${pageContext.request.contextPath}";
                var currentUserId = ${sessionScope.currentUser.userId};

                /* ── Pending reschedule requests (keyed by bookingId) ── */
                var pendingReschedules = {};
                <c:forEach var="entry" items="${pendingReschedules}">
                pendingReschedules[${entry.key}] = {
                    rescheduleId: ${entry.value.rescheduleId},
                    newDate: "${entry.value.newDate}",
                    newTime: "${entry.value.newTime}",
                    reason: "${entry.value.reason}",
                    requestedBy: ${entry.value.requestedBy},
                    requesterName: "${entry.value.requesterName}"
                };
                </c:forEach>

                /* ── View Toggle ───────────────────────────────── */
                function switchView(view) {
                    var listView = document.getElementById('list-view');
                    var calView = document.getElementById('calendar-view');
                    var btnList = document.getElementById('btnListView');
                    var btnCal = document.getElementById('btnCalendarView');

                    if (view === 'list') {
                        listView.style.display = 'block';
                        calView.style.display = 'none';
                        btnList.classList.add('active');
                        btnCal.classList.remove('active');
                    } else {
                        listView.style.display = 'none';
                        calView.style.display = 'block';
                        btnList.classList.remove('active');
                        btnCal.classList.add('active');
                        renderCalendar();
                    }
                }

                /* ── Calendar Logic ────────────────────────────── */
                var calDate = new Date();
                var monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
                var dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

                function renderCalendar() {
                    var year = calDate.getFullYear();
                    var month = calDate.getMonth();

                    document.getElementById('calMonthLabel').textContent = monthNames[month] + ' ' + year;

                    var firstDay = new Date(year, month, 1).getDay();
                    var daysInMonth = new Date(year, month + 1, 0).getDate();
                    var prevMonthDays = new Date(year, month, 0).getDate();

                    var grid = document.getElementById('calendarGrid');
                    grid.innerHTML = '';

                    /* Day headers */
                    for (var d = 0; d < 7; d++) {
                        var hdr = document.createElement('div');
                        hdr.className = 'cal-day-header';
                        hdr.textContent = dayNames[d];
                        grid.appendChild(hdr);
                    }

                    var today = new Date();
                    var todayStr = formatDateStr(today.getFullYear(), today.getMonth(), today.getDate());

                    /* Previous month's trailing days */
                    for (var i = 0; i < firstDay; i++) {
                        var dayNum = prevMonthDays - firstDay + i + 1;
                        var cell = createDayCell(year, month - 1, dayNum, true);
                        grid.appendChild(cell);
                    }

                    /* Current month days */
                    for (var day = 1; day <= daysInMonth; day++) {
                        var dateStr = formatDateStr(year, month, day);
                        var isToday = (dateStr === todayStr);
                        var cell = createDayCell(year, month, day, false, isToday, dateStr);
                        grid.appendChild(cell);
                    }

                    /* Fill remaining cells to complete the last week */
                    var totalCells = firstDay + daysInMonth;
                    var remaining = (7 - (totalCells % 7)) % 7;
                    for (var j = 1; j <= remaining; j++) {
                        var cell = createDayCell(year, month + 1, j, true);
                        grid.appendChild(cell);
                    }
                }

                function createDayCell(year, month, day, isOtherMonth, isToday, dateStr) {
                    var cell = document.createElement('div');
                    cell.className = 'cal-day';
                    if (isOtherMonth) cell.classList.add('other-month');
                    if (isToday) cell.classList.add('today');

                    var num = document.createElement('span');
                    num.className = 'cal-day-number';
                    num.textContent = day;
                    cell.appendChild(num);

                    /* Place booking pills for this day */
                    if (dateStr) {
                        var dayBookings = bookings.filter(function (b) { return b.date === dateStr; });
                        dayBookings.forEach(function (b) {
                            var pill = document.createElement('div');
                            var pillClass = 'cal-booking-pill ';
                            switch (b.status) {
                                case 'ACCEPTED': pillClass += 'accepted'; break;
                                case 'IN_PROGRESS': pillClass += 'in-progress'; break;
                                case 'RESCHEDULE_PENDING': pillClass += 'reschedule-pending'; break;
                                case 'NO_SHOW': pillClass += 'no-show'; break;
                                case 'CLIENT_NO_SHOW': pillClass += 'client-no-show'; break;
                                default: pillClass += 'awaiting';
                            }
                            pill.className = pillClass;
                            var pillLabel = formatTime(b.time) + ' ' + b.service;
                            if (b.recurring) pillLabel = '\u21BB ' + pillLabel + ' (' + b.recurringSeq + '/12)';
                            pill.textContent = pillLabel;
                            pill.title = b.service + ' — ' + b.customer;
                            pill.onclick = function () { showDetailModal(b); };
                            cell.appendChild(pill);
                        });
                    }

                    return cell;
                }

                function formatDateStr(y, m, d) {
                    var dt = new Date(y, m, d);
                    var yy = dt.getFullYear();
                    var mm = String(dt.getMonth() + 1).padStart(2, '0');
                    var dd = String(dt.getDate()).padStart(2, '0');
                    return yy + '-' + mm + '-' + dd;
                }

                function formatTime(t) {
                    if (!t) return '';
                    var parts = t.split(':');
                    var h = parseInt(parts[0], 10);
                    var m = parts[1];
                    var ampm = h >= 12 ? 'PM' : 'AM';
                    h = h % 12 || 12;
                    return h + ':' + m + ' ' + ampm;
                }

                function changeMonth(offset) {
                    calDate.setMonth(calDate.getMonth() + offset);
                    renderCalendar();
                }

                function goToToday() {
                    calDate = new Date();
                    renderCalendar();
                }

                /* ── Booking Detail Modal (calendar) ───────────── */
                function showDetailModal(b) {
                    document.getElementById('detailServiceName').textContent = b.service;
                    document.getElementById('detailCustomer').textContent = b.customer;
                    document.getElementById('detailPhone').textContent = b.phone;
                    var dateText = b.date + ' at ' + formatTime(b.time);
                    if (b.recurring) dateText += '  \u2014  \u21BB Recurring (Month ' + b.recurringSeq + ' of 12)';
                    document.getElementById('detailDate').textContent = dateText;
                    document.getElementById('detailProblem').textContent = b.problem;
                    document.getElementById('detailAddress').textContent = b.address;

                    /* Status badge */
                    var badgeEl = document.getElementById('detailStatusBadge');
                    switch (b.status) {
                        case 'ACCEPTED':
                            badgeEl.innerHTML = '<span class="status-badge accepted">ACCEPTED</span>';
                            break;
                        case 'IN_PROGRESS':
                            badgeEl.innerHTML = '<span class="status-badge in-progress">IN PROGRESS</span>';
                            break;
                        case 'RESCHEDULE_PENDING':
                            badgeEl.innerHTML = '<span class="status-badge reschedule-pending">RESCHEDULE PENDING</span>';
                            break;
                        case 'NO_SHOW':
                            badgeEl.innerHTML = '<span class="status-badge no-show">NO SHOW</span>';
                            break;
                        case 'CLIENT_NO_SHOW':
                            badgeEl.innerHTML = '<span class="status-badge client-no-show">CLIENT NOT HOME</span>';
                            break;
                        default:
                            badgeEl.innerHTML = '<span class="status-badge awaiting">' + b.status + '</span>';
                    }

                    /* Map link */
                    var mapLink = document.getElementById('detailMapLink');
                    if (b.lat && b.lng && b.lat !== '' && b.lng !== '') {
                        mapLink.href = 'https://www.google.com/maps?q=' + b.lat + ',' + b.lng;
                        mapLink.classList.add('visible');
                    } else {
                        mapLink.classList.remove('visible');
                    }

                    /* Action buttons */
                    var actions = document.getElementById('detailActions');
                    actions.innerHTML = '';

                    if (b.chatId) {
                        var chatBtn = document.createElement('a');
                        chatBtn.href = contextPath + '/chats/view?chatId=' + b.chatId;
                        chatBtn.className = 'btn-chat';
                        chatBtn.textContent = 'Open Chat';
                        actions.appendChild(chatBtn);
                    }

                    if (b.status === 'ACCEPTED') {
                        var startForm = document.createElement('form');
                        startForm.method = 'post';
                        startForm.action = contextPath + '/bookings/complete';
                        startForm.className = 'action-form';
                        startForm.innerHTML =
                            '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                            '<input type="hidden" name="completionType" value="start">' +
                            '<button type="submit" class="btn-start-job btn-full">Mark In Progress</button>';
                        actions.appendChild(startForm);

                        var reschedBtn = document.createElement('button');
                        reschedBtn.className = 'btn-reschedule-req';
                        reschedBtn.textContent = 'Request Reschedule';
                        reschedBtn.onclick = function () {
                            closeDetailModal();
                            openRescheduleModal(b.id);
                        };
                        actions.appendChild(reschedBtn);

                    } else if (b.status === 'IN_PROGRESS') {
                        var completeForm = document.createElement('form');
                        completeForm.method = 'post';
                        completeForm.action = contextPath + '/bookings/complete';
                        completeForm.className = 'action-form';
                        completeForm.innerHTML =
                            '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                            '<input type="hidden" name="completionType" value="technician">' +
                            '<button type="submit" class="btn-complete" btn-full">Mark as Complete</button>';
                        actions.appendChild(completeForm);

                        var cnsBtn2 = document.createElement('button');
                        cnsBtn2.className = 'btn-client-no-show';
                        var elapsed2 = b.updatedAt ? (Date.now() - b.updatedAt) : Infinity;
                        var tenMin = 10 * 60 * 1000;
                        if (elapsed2 >= tenMin) {
                            cnsBtn2.textContent = 'Client Not Home';
                            cnsBtn2.onclick = function () {
                                closeDetailModal();
                                openClientNoShowModal(b.id);
                            };
                        } else {
                            var remainMin2 = Math.ceil((tenMin - elapsed2) / 60000);
                            cnsBtn2.textContent = 'Client Not Home (in ' + remainMin2 + ' min)';
                            cnsBtn2.disabled = true;
                            cnsBtn2.title = 'Available 10 minutes after marking In Progress';
                            cnsBtn2.classList.add('btn-disabled');
                        }
                        actions.appendChild(cnsBtn2);

                        // Auto-refresh countdown if still waiting
                        if (elapsed2 < tenMin) {
                            setTimeout(function () {
                                // Re-open the modal with fresh data when timer expires
                            }, tenMin - elapsed2);
                        }
                    } else if (b.status === 'RESCHEDULE_PENDING') {
                        var pr = pendingReschedules[b.id];
                        if (pr) {
                            if (pr.requestedBy === currentUserId) {
                                var awaitMsg = document.createElement('div');
                                awaitMsg.className = 'reschedule-info-chip';
                                awaitMsg.textContent = 'Requested reschedule to ' + pr.newDate + ' at ' + pr.newTime + ' — awaiting client response';
                                actions.appendChild(awaitMsg);
                            } else {
                                var acceptForm = document.createElement('form');
                                acceptForm.method = 'post';
                                acceptForm.action = contextPath + '/bookings/reschedule/respond';
                                acceptForm.className = 'action-form';
                                acceptForm.innerHTML =
                                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                                    '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">' +
                                    '<input type="hidden" name="action" value="accept">' +
                                    '<input type="hidden" name="keepBooking" value="true">' +
                                    '<button type="submit" class="btn-complete" btn-full">Accept Reschedule</button>';
                                actions.appendChild(acceptForm);
                                var rejectForm = document.createElement('form');
                                rejectForm.method = 'post';
                                rejectForm.action = contextPath + '/bookings/reschedule/respond';
                                rejectForm.className = 'action-form';
                                rejectForm.innerHTML =
                                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                                    '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">' +
                                    '<input type="hidden" name="action" value="reject">' +
                                    '<input type="hidden" name="keepBooking" value="true">' +
                                    '<button type="submit" class="btn-cancel-booking" btn-full">Reject Reschedule</button>';
                                actions.appendChild(rejectForm);
                            }
                        }
                    }

                    if (b.status !== 'NO_SHOW' && b.status !== 'TECHNICIAN_COMPLETED') {
                        var cancelBtn = document.createElement('button');
                        cancelBtn.className = 'btn-cancel-booking';
                        cancelBtn.textContent = 'Cancel Booking';
                        cancelBtn.onclick = function () {
                            closeDetailModal();
                            handleTechCancelClick(b.id, b.date, b.time);
                        };
                        actions.appendChild(cancelBtn);
                    }

                    document.getElementById('detailModal').style.display = 'flex';
                }

                function closeDetailModal() {
                    document.getElementById('detailModal').style.display = 'none';
                }

                /* ── Cancel Modal ──────────────────────────────── */
                function handleTechCancelClick(bookingId, date, time) {
                    var bookingMs = new Date(date + 'T' + time).getTime();
                    var hoursAway = (bookingMs - Date.now()) / 3600000;
                    if (hoursAway > 0 && hoursAway <= 24) {
                        document.getElementById('techEarlyCancelBookingId').value = bookingId;
                        document.getElementById('techEarlyCancelModal').style.display = 'flex';
                    } else {
                        showCancelModal(bookingId);
                    }
                }

                function proceedTechEarlyCancel() {
                    var bookingId = document.getElementById('techEarlyCancelBookingId').value;
                    closeTechEarlyCancelModal();
                    showCancelModal(bookingId);
                }

                function closeTechEarlyCancelModal() {
                    document.getElementById('techEarlyCancelModal').style.display = 'none';
                }

                function showCancelModal(bookingId) {
                    document.getElementById('cancelBookingId').value = bookingId;
                    document.getElementById('cancelModal').style.display = 'flex';
                }

                function closeCancelModal() {
                    document.getElementById('cancelModal').style.display = 'none';
                }

                /* ── Reschedule Modal ──────────────────────────── */
                function openRescheduleModal(bookingId) {
                    document.getElementById('rescheduleBookingId').value = bookingId;
                    document.getElementById('rescheduleModal').style.display = 'flex';
                }

                function closeRescheduleModal() {
                    document.getElementById('rescheduleModal').style.display = 'none';
                }

                /* ── Client No-Show Modal ─────────────────────── */
                function openClientNoShowModal(bookingId) {
                    document.getElementById('clientNoShowBookingId').value = bookingId;
                    document.getElementById('clientNoShowModal').style.display = 'flex';
                }

                function closeClientNoShowModal() {
                    document.getElementById('clientNoShowModal').style.display = 'none';
                }

                document.getElementById('clientNoShowForm').addEventListener('submit', function (e) {
                    var fileInput = document.getElementById('techProofFileInput');
                    var errDiv   = document.getElementById('techProofFileError');
                    errDiv.style.display = 'none';
                    errDiv.textContent   = '';
                    if (!fileInput.files || fileInput.files.length === 0) {
                        e.preventDefault();
                        errDiv.textContent = 'Please select an arrival proof photo.';
                        errDiv.style.display = 'block';
                        return;
                    }
                    var file = fileInput.files[0];
                    if (file.size > 5 * 1024 * 1024) {
                        e.preventDefault();
                        errDiv.textContent = 'File is too large. Maximum size is 5 MB.';
                        errDiv.style.display = 'block';
                        return;
                    }
                    if (['image/jpeg', 'image/png'].indexOf(file.type) === -1) {
                        e.preventDefault();
                        errDiv.textContent = 'Only JPG and PNG images are allowed.';
                        errDiv.style.display = 'block';
                    }
                });

                /* Close modals on overlay click */
                document.getElementById('cancelModal').addEventListener('click', function (e) {
                    if (e.target === this) closeCancelModal();
                });
                document.getElementById('techEarlyCancelModal').addEventListener('click', function (e) {
                    if (e.target === this) closeTechEarlyCancelModal();
                });
                document.getElementById('detailModal').addEventListener('click', function (e) {
                    if (e.target === this) closeDetailModal();
                });
                document.getElementById('rescheduleModal').addEventListener('click', function (e) {
                    if (e.target === this) closeRescheduleModal();
                });
                document.getElementById('clientNoShowModal').addEventListener('click', function (e) {
                    if (e.target === this) closeClientNoShowModal();
                });

                /* ── List view rendering with recurring grouping ── */
                function escHtml(str) {
                    if (!str) return '';
                    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                }

                function toggleMonths(listId, toggleId, total) {
                    var list = document.getElementById(listId);
                    var btn = document.getElementById(toggleId);
                    if (list.style.display === 'block') {
                        list.style.display = 'none';
                        btn.textContent = 'Show all ' + total + ' months \u25BC';
                    } else {
                        list.style.display = 'block';
                        btn.textContent = 'Hide months \u25B2';
                    }
                }

                function renderListView() {
                    var container = document.getElementById('listViewContainer');
                    container.innerHTML = '';

                    var nonRecurring = [];
                    var recurringGroups = {};
                    var recurringOrder = [];

                    bookings.forEach(function (b) {
                        if (!b.recurring || !b.contractId) {
                            nonRecurring.push(b);
                        } else {
                            var key = b.contractId;
                            if (!recurringGroups[key]) {
                                recurringGroups[key] = { contractId: key, months: [] };
                                recurringOrder.push(key);
                            }
                            recurringGroups[key].months.push(b);
                        }
                    });

                    recurringOrder.forEach(function (key) {
                        recurringGroups[key].months.sort(function (a, b) { return a.recurringSeq - b.recurringSeq; });
                    });

                    function statusBadgeHtml(status) {
                        switch (status) {
                            case 'ACCEPTED': return '<span class="status-badge accepted">ACCEPTED</span>';
                            case 'IN_PROGRESS': return '<span class="status-badge in-progress">IN PROGRESS</span>';
                            case 'RESCHEDULE_PENDING': return '<span class="status-badge reschedule-pending">RESCHEDULE PENDING</span>';
                            case 'NO_SHOW': return '<span class="status-badge no-show">NO SHOW</span>';
                            case 'CLIENT_NO_SHOW': return '<span class="status-badge client-no-show">CLIENT NOT HOME</span>';
                            case 'TECHNICIAN_COMPLETED': return '<span class="status-badge tech-completed">AWAITING USER CONFIRM</span>';
                            default: return '<span class="status-badge awaiting">' + status + '</span>';
                        }
                    }

                    function buildActionsHtml(b) {
                        var html   = b.chatId
                            ? '<a href="' + contextPath + '/chats/view?chatId=' + b.chatId + '" class="btn-chat">Open Chat</a>'
                            : '';
                        var tenMin = 10 * 60 * 1000;
                        if (b.status === 'ACCEPTED') {
                            html += '<form method="post" action="' + contextPath + '/bookings/complete" class="action-form">'
                                + '<input type="hidden" name="bookingId" value="' + b.id + '">'
                                + '<input type="hidden" name="completionType" value="start">'
                                + '<button type="submit" class="btn-start-job btn-full">Mark In Progress</button>'
                                + '</form>'
                                + '<button onclick="openRescheduleModal(' + b.id + ')" class="btn-reschedule-req">Request Reschedule</button>';
                        } else if (b.status === 'IN_PROGRESS') {
                            html += '<form method="post" action="' + contextPath + '/bookings/complete" class="action-form">'
                                + '<input type="hidden" name="bookingId" value="' + b.id + '">'
                                + '<input type="hidden" name="completionType" value="technician">'
                                + '<button type="submit" class="btn-complete" btn-full">Mark as Complete</button>'
                                + '</form>';
                            var elapsed = b.updatedAt ? (Date.now() - b.updatedAt) : Infinity;
                            if (elapsed >= tenMin) {
                                html += '<button onclick="openClientNoShowModal(' + b.id + ')" class="btn-client-no-show">Client Not Home</button>';
                            } else {
                                var remainMin = Math.ceil((tenMin - elapsed) / 60000);
                                html += '<button disabled class="btn-client-no-show btn-disabled" title="Available 10 minutes after marking In Progress">Client Not Home (in ' + remainMin + ' min)</button>';
                            }
                            var pr = pendingReschedules[b.id];
                            if (pr) {
                                if (pr.requestedBy === currentUserId) {
                                    html += '<div class="reschedule-info-chip">'
                                        + 'Requested reschedule to ' + pr.newDate + ' at ' + formatTime(pr.newTime) + ' \u2014 awaiting client response</div>';
                                } else {
                                    html += '<div class="reschedule-request-chip">'
                                        + '<strong>' + escHtml(pr.requesterName) + '</strong> requested to ' + pr.newDate + ' at ' + formatTime(pr.newTime)
                                        + (pr.reason ? '<br><em>"' + escHtml(pr.reason) + '"</em>' : '') + '</div>'
                                        + '<form method="post" action="' + contextPath + '/bookings/reschedule/respond" class="action-form-sm">'
                                        + '<input type="hidden" name="bookingId" value="' + b.id + '">'
                                        + '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">'
                                        + '<input type="hidden" name="action" value="accept">'
                                        + '<input type="hidden" name="keepBooking" value="true">'
                                        + '<button type="submit" class="btn-complete" btn-full">Accept</button></form>'
                                        + '<form method="post" action="' + contextPath + '/bookings/reschedule/respond" class="action-form-sm">'
                                        + '<input type="hidden" name="bookingId" value="' + b.id + '">'
                                        + '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">'
                                        + '<input type="hidden" name="action" value="reject">'
                                        + '<input type="hidden" name="keepBooking" value="true">'
                                        + '<button type="submit" class="btn-cancel-booking" btn-full">Reject</button></form>';
                                }
                            }
                        }
                        if (b.status !== 'NO_SHOW' && b.status !== 'TECHNICIAN_COMPLETED' && b.status !== 'CLIENT_NO_SHOW') {
                            html += '<button onclick="handleTechCancelClick(' + b.id + ',\'' + b.date + '\',\'' + b.time + '\')" class="btn-cancel-booking">Cancel Booking</button>';
                        }
                        return html;
                    }

                    /* Recurring contract group cards */
                    recurringOrder.forEach(function (key) {
                        var group = recurringGroups[key];
                        var rep = group.months[0];
                        var total = group.months.length;
                        var today = new Date().toISOString().split('T')[0];
                        var next = group.months.find(function (m) { return m.date >= today; }) || rep;

                        var groupId = 'months-' + key;
                        var toggleId = 'toggle-' + key;

                        var monthRows = group.months.map(function (m) {
                            return '<tr>' +
                                '<td>Month ' + m.recurringSeq + '</td>' +
                                '<td>' + m.date + ' at ' + formatTime(m.time) + '</td>' +
                                '<td>' + statusBadgeHtml(m.status) + '</td>' +
                                '<td><button onclick="handleTechCancelClick(' + m.id + ',\'' + m.date + '\',\'' + m.time + '\')" class="btn-cancel-booking btn-sm">Cancel</button></td>' +
                                '</tr>';
                        }).join('');

                        var mapHtml = (rep.lat && rep.lng && rep.lat !== '' && rep.lng !== '')
                            ? '<a href="https://www.google.com/maps?q=' + rep.lat + ',' + rep.lng + '" target="_blank" class="map-link visible">View on Google Maps</a>'
                            : '';

                        var card = document.createElement('div');
                        card.className = 'booking-card recurring-contract-card';
                        card.innerHTML =
                            '<div class="booking-card-header">'
                            + '<div>'
                            + '<h3>' + escHtml(rep.service) + ' <span class="recurring-badge">\u21BB Recurring (' + total + ' months)</span></h3>'
                            + '<p><strong>Customer:</strong> ' + escHtml(rep.customer) + '</p>'
                            + '<p><strong>Phone:</strong> ' + escHtml(rep.phone) + '</p>'
                            + '<p><strong>Next:</strong> Month ' + next.recurringSeq + ' \u2014 ' + next.date + ' at ' + formatTime(next.time) + '</p>'
                            + '</div>'
                            + '<div>' + statusBadgeHtml(next.status) + '</div>'
                            + '</div>'
                            + '<div class="info-block"><p class="label">Problem Description:</p><p>' + escHtml(rep.problem) + '</p></div>'
                            + '<div class="info-block"><p class="label">Location:</p><p>' + escHtml(rep.address) + '</p>' + mapHtml + '</div>'
                            + '<button class="months-toggle-btn" id="' + toggleId + '" onclick="toggleMonths(\'' + groupId + '\',\'' + toggleId + '\',' + total + ')">'
                            + 'Show all ' + total + ' months \u25BC</button>'
                            + '<div class="months-list" id="' + groupId + '">'
                            + '<table><thead><tr><th>Month</th><th>Date &amp; Time</th><th>Status</th><th>Action</th></tr></thead>'
                            + '<tbody>' + monthRows + '</tbody></table></div>'
                            + '<div class="booking-actions">'
                            + buildActionsHtml(next)
                            + '</div>';
                        container.appendChild(card);
                    });

                    /* Individual non-recurring booking cards */
                    nonRecurring.forEach(function (b) {
                        var mapHtml = (b.lat && b.lng && b.lat !== '' && b.lng !== '')
                            ? '<a href="https://www.google.com/maps?q=' + b.lat + ',' + b.lng + '" target="_blank" class="map-link visible">View on Google Maps</a>'
                            : '';

                        var card = document.createElement('div');
                        card.className = 'booking-card';
                        card.innerHTML =
                            '<div class="booking-card-header">'
                            + '<div>'
                            + '<h3>' + escHtml(b.service) + '</h3>'
                            + '<p><strong>Customer:</strong> ' + escHtml(b.customer) + '</p>'
                            + '<p><strong>Phone:</strong> ' + escHtml(b.phone) + '</p>'
                            + '<p><strong>Date:</strong> ' + b.date + ' at ' + formatTime(b.time) + '</p>'
                            + '</div>'
                            + '<div>' + statusBadgeHtml(b.status) + '</div>'
                            + '</div>'
                            + '<div class="info-block"><p class="label">Problem Description:</p><p>' + escHtml(b.problem) + '</p></div>'
                            + '<div class="info-block"><p class="label">Location:</p><p>' + escHtml(b.address) + '</p>' + mapHtml + '</div>'
                            + '<div class="booking-actions">'
                            + buildActionsHtml(b)
                            + '</div>';
                        container.appendChild(card);
                    });
                }

                renderListView();
            </script>
        </body>

        </html>