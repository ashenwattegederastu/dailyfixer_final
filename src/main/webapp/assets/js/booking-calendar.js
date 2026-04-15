/* booking-calendar.js
 * Reads window.bookings, window.contextPath, window.currentUserId,
 * window.pendingReschedules — all injected by booking-calendar.jsp.
 */

/* ─── Utility Helpers ────────────────────────────────────────────────────── */
function escHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
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

function formatDateStr(y, m, d) {
    var dt = new Date(y, m, d);
    var yy = dt.getFullYear();
    var mm = String(dt.getMonth() + 1).padStart(2, '0');
    var dd = String(dt.getDate()).padStart(2, '0');
    return yy + '-' + mm + '-' + dd;
}

function statusBadgeHtml(status) {
    switch (status) {
        case 'ACCEPTED':             return '<span class="status-badge accepted">ACCEPTED</span>';
        case 'IN_PROGRESS':          return '<span class="status-badge in-progress">IN PROGRESS</span>';
        case 'RESCHEDULE_PENDING':   return '<span class="status-badge reschedule-pending">RESCHEDULE PENDING</span>';
        case 'NO_SHOW':              return '<span class="status-badge no-show">NO SHOW</span>';
        case 'CLIENT_NO_SHOW':       return '<span class="status-badge client-no-show">CLIENT NOT HOME</span>';
        case 'TECHNICIAN_COMPLETED': return '<span class="status-badge" style="background:#e0e7ff;color:#3730a3;">AWAITING USER CONFIRM</span>';
        default:                     return '<span class="status-badge awaiting">' + escHtml(status) + '</span>';
    }
}

/* ─── View Toggle ────────────────────────────────────────────────────────── */
function switchView(view) {
    var showList = view === 'list';
    document.getElementById('list-view').style.display     = showList ? 'block' : 'none';
    document.getElementById('calendar-view').style.display = showList ? 'none'  : 'block';
    document.getElementById('btnListView').classList.toggle('active', showList);
    document.getElementById('btnCalendarView').classList.toggle('active', !showList);
    if (!showList) renderCalendar();
}

/* ─── Calendar ───────────────────────────────────────────────────────────── */
var calDate    = new Date();
var monthNames = ['January','February','March','April','May','June',
                  'July','August','September','October','November','December'];
var dayNames   = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

function renderCalendar() {
    var year  = calDate.getFullYear();
    var month = calDate.getMonth();

    document.getElementById('calMonthLabel').textContent = monthNames[month] + ' ' + year;

    var firstDay      = new Date(year, month, 1).getDay();
    var daysInMonth   = new Date(year, month + 1, 0).getDate();
    var prevMonthDays = new Date(year, month, 0).getDate();
    var today         = new Date();
    var todayStr      = formatDateStr(today.getFullYear(), today.getMonth(), today.getDate());

    var grid = document.getElementById('calendarGrid');
    grid.innerHTML = '';

    /* Day-name headers */
    dayNames.forEach(function (d) {
        var hdr = document.createElement('div');
        hdr.className   = 'cal-day-header';
        hdr.textContent = d;
        grid.appendChild(hdr);
    });

    /* Previous month's trailing days */
    for (var i = 0; i < firstDay; i++) {
        grid.appendChild(createDayCell(year, month - 1, prevMonthDays - firstDay + i + 1, true));
    }

    /* Current month */
    for (var day = 1; day <= daysInMonth; day++) {
        var dateStr = formatDateStr(year, month, day);
        grid.appendChild(createDayCell(year, month, day, false, dateStr === todayStr, dateStr));
    }

    /* Next month's leading days */
    var remaining = (7 - ((firstDay + daysInMonth) % 7)) % 7;
    for (var j = 1; j <= remaining; j++) {
        grid.appendChild(createDayCell(year, month + 1, j, true));
    }
}

function createDayCell(year, month, day, isOtherMonth, isToday, dateStr) {
    var cell = document.createElement('div');
    cell.className = 'cal-day' +
        (isOtherMonth ? ' other-month' : '') +
        (isToday      ? ' today'       : '');

    var num = document.createElement('span');
    num.className   = 'cal-day-number';
    num.textContent = day;
    cell.appendChild(num);

    if (dateStr) {
        window.bookings
            .filter(function (b) { return b.date === dateStr; })
            .forEach(function (b) {
                var pillClass = 'cal-booking-pill ';
                switch (b.status) {
                    case 'ACCEPTED':           pillClass += 'accepted';           break;
                    case 'IN_PROGRESS':        pillClass += 'in-progress';        break;
                    case 'RESCHEDULE_PENDING': pillClass += 'reschedule-pending'; break;
                    case 'NO_SHOW':            pillClass += 'no-show';            break;
                    case 'CLIENT_NO_SHOW':     pillClass += 'client-no-show';     break;
                    default:                   pillClass += 'awaiting';
                }
                var pill = document.createElement('div');
                pill.className = pillClass;
                var label = formatTime(b.time) + ' ' + b.service;
                if (b.recurring) label = '\u21BB ' + label + ' (' + b.recurringSeq + '/12)';
                pill.textContent = label;
                pill.title       = b.service + ' \u2014 ' + b.customer;
                pill.onclick     = function () { showDetailModal(b); };
                cell.appendChild(pill);
            });
    }

    return cell;
}

function changeMonth(offset) {
    calDate.setMonth(calDate.getMonth() + offset);
    renderCalendar();
}

function goToToday() {
    calDate = new Date();
    renderCalendar();
}

/* ─── Detail Modal (calendar click) ─────────────────────────────────────── */
function showDetailModal(b) {
    document.getElementById('detailServiceName').textContent = b.service;
    document.getElementById('detailCustomer').textContent    = b.customer;
    document.getElementById('detailPhone').textContent       = b.phone;
    document.getElementById('detailProblem').textContent     = b.problem;
    document.getElementById('detailAddress').textContent     = b.address;

    var dateText = b.date + ' at ' + formatTime(b.time);
    if (b.recurring) dateText += '  \u2014  \u21BB Recurring (Month ' + b.recurringSeq + ' of 12)';
    document.getElementById('detailDate').textContent = dateText;

    document.getElementById('detailStatusBadge').innerHTML = statusBadgeHtml(b.status);

    var mapLink = document.getElementById('detailMapLink');
    if (b.lat && b.lng && b.lat !== '' && b.lng !== '') {
        mapLink.href         = 'https://www.google.com/maps?q=' + b.lat + ',' + b.lng;
        mapLink.style.display = 'inline-block';
    } else {
        mapLink.style.display = 'none';
    }

    var actions = document.getElementById('detailActions');
    actions.innerHTML = '';

    /* Chat button — always present */
    var chatBtn = document.createElement('a');
    chatBtn.href        = window.contextPath + '/chats/view?chatId=' + b.id;
    chatBtn.className   = 'btn-chat';
    chatBtn.textContent = 'Open Chat';
    actions.appendChild(chatBtn);

    if (b.status === 'ACCEPTED') {
        var startForm = document.createElement('form');
        startForm.method = 'post';
        startForm.action = window.contextPath + '/bookings/complete';
        startForm.innerHTML =
            '<input type="hidden" name="bookingId" value="' + b.id + '">' +
            '<input type="hidden" name="completionType" value="start">' +
            '<button type="submit" class="btn-start-job" style="width:100%;">Mark In Progress</button>';
        actions.appendChild(startForm);

        var reschedBtn = document.createElement('button');
        reschedBtn.className   = 'btn-reschedule-req';
        reschedBtn.textContent = 'Request Reschedule';
        reschedBtn.onclick     = function () { closeDetailModal(); openRescheduleModal(b.id); };
        actions.appendChild(reschedBtn);

    } else if (b.status === 'IN_PROGRESS') {
        var completeForm = document.createElement('form');
        completeForm.method = 'post';
        completeForm.action = window.contextPath + '/bookings/complete';
        completeForm.innerHTML =
            '<input type="hidden" name="bookingId" value="' + b.id + '">' +
            '<input type="hidden" name="completionType" value="technician">' +
            '<button type="submit" class="btn-complete" style="width:100%;">Mark as Complete</button>';
        actions.appendChild(completeForm);

        var cnsBtn  = document.createElement('button');
        cnsBtn.className  = 'btn-client-no-show';
        var elapsed = b.updatedAt ? (Date.now() - b.updatedAt) : Infinity;
        var tenMin  = 10 * 60 * 1000;
        if (elapsed >= tenMin) {
            cnsBtn.textContent = 'Client Not Home';
            cnsBtn.onclick     = function () { closeDetailModal(); openClientNoShowModal(b.id); };
        } else {
            var remainMin = Math.ceil((tenMin - elapsed) / 60000);
            cnsBtn.textContent = 'Client Not Home (in ' + remainMin + ' min)';
            cnsBtn.disabled    = true;
            cnsBtn.title       = 'Available 10 minutes after marking In Progress';
            cnsBtn.style.cssText += 'opacity:0.45;cursor:not-allowed;';
        }
        actions.appendChild(cnsBtn);

    } else if (b.status === 'RESCHEDULE_PENDING') {
        var pr = window.pendingReschedules[b.id];
        if (pr) {
            if (pr.requestedBy === window.currentUserId) {
                var awaitMsg = document.createElement('div');
                awaitMsg.className   = 'reschedule-info-chip';
                awaitMsg.textContent = 'Requested reschedule to ' + pr.newDate + ' at ' + pr.newTime + ' \u2014 awaiting client response';
                actions.appendChild(awaitMsg);
            } else {
                var acceptForm = document.createElement('form');
                acceptForm.method = 'post';
                acceptForm.action = window.contextPath + '/bookings/reschedule/respond';
                acceptForm.innerHTML =
                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                    '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">' +
                    '<input type="hidden" name="action" value="accept">' +
                    '<input type="hidden" name="keepBooking" value="true">' +
                    '<button type="submit" class="btn-complete" style="width:100%;padding:0.75rem;">Accept Reschedule</button>';
                actions.appendChild(acceptForm);

                var rejectForm = document.createElement('form');
                rejectForm.method = 'post';
                rejectForm.action = window.contextPath + '/bookings/reschedule/respond';
                rejectForm.innerHTML =
                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                    '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">' +
                    '<input type="hidden" name="action" value="reject">' +
                    '<input type="hidden" name="keepBooking" value="true">' +
                    '<button type="submit" class="btn-cancel-booking" style="width:100%;padding:0.75rem;">Reject Reschedule</button>';
                actions.appendChild(rejectForm);
            }
        }
    }

    if (b.status !== 'NO_SHOW' && b.status !== 'TECHNICIAN_COMPLETED') {
        var cancelBtn = document.createElement('button');
        cancelBtn.className   = 'btn-cancel-booking';
        cancelBtn.textContent = 'Cancel Booking';
        cancelBtn.onclick     = function () { closeDetailModal(); showCancelModal(b.id); };
        actions.appendChild(cancelBtn);
    }

    document.getElementById('detailModal').style.display = 'flex';
}

function closeDetailModal()   { document.getElementById('detailModal').style.display   = 'none'; }

/* ─── Cancel Modal ───────────────────────────────────────────────────────── */
function showCancelModal(bookingId) {
    document.getElementById('cancelBookingId').value     = bookingId;
    document.getElementById('cancelModal').style.display = 'flex';
}

function closeCancelModal()   { document.getElementById('cancelModal').style.display    = 'none'; }

/* ─── Reschedule Modal ───────────────────────────────────────────────────── */
function openRescheduleModal(bookingId) {
    document.getElementById('rescheduleBookingId').value    = bookingId;
    document.getElementById('rescheduleModal').style.display = 'flex';
}

function closeRescheduleModal() { document.getElementById('rescheduleModal').style.display    = 'none'; }

/* ─── Client No-Show Modal ───────────────────────────────────────────────── */
function openClientNoShowModal(bookingId) {
    document.getElementById('clientNoShowBookingId').value    = bookingId;
    document.getElementById('clientNoShowModal').style.display = 'flex';
}

function closeClientNoShowModal() { document.getElementById('clientNoShowModal').style.display = 'none'; }

/* ─── List View ──────────────────────────────────────────────────────────── */
function toggleMonths(listId, toggleId, total) {
    var list = document.getElementById(listId);
    var btn  = document.getElementById(toggleId);
    var open = list.style.display === 'block';
    list.style.display = open ? 'none' : 'block';
    btn.textContent    = open ? 'Show all ' + total + ' months \u25BC' : 'Hide months \u25B2';
}

function buildActionsHtml(b) {
    var html   = '<a href="' + window.contextPath + '/chats/view?chatId=' + b.id + '" class="btn-chat">Open Chat</a>';
    var tenMin = 10 * 60 * 1000;

    if (b.status === 'ACCEPTED') {
        html +=
            '<form method="post" action="' + window.contextPath + '/bookings/complete">' +
            '<input type="hidden" name="bookingId" value="' + b.id + '">' +
            '<input type="hidden" name="completionType" value="start">' +
            '<button type="submit" class="btn-start-job" style="width:100%;">Mark In Progress</button></form>' +
            '<button onclick="openRescheduleModal(' + b.id + ')" class="btn-reschedule-req">Request Reschedule</button>';

    } else if (b.status === 'IN_PROGRESS') {
        html +=
            '<form method="post" action="' + window.contextPath + '/bookings/complete">' +
            '<input type="hidden" name="bookingId" value="' + b.id + '">' +
            '<input type="hidden" name="completionType" value="technician">' +
            '<button type="submit" class="btn-complete" style="width:100%;">Mark as Complete</button></form>';

        var elapsed = b.updatedAt ? (Date.now() - b.updatedAt) : Infinity;
        if (elapsed >= tenMin) {
            html += '<button onclick="openClientNoShowModal(' + b.id + ')" class="btn-client-no-show">Client Not Home</button>';
        } else {
            var remainMin = Math.ceil((tenMin - elapsed) / 60000);
            html += '<button disabled class="btn-client-no-show" style="opacity:0.45;cursor:not-allowed;" ' +
                    'title="Available 10 minutes after marking In Progress">Client Not Home (in ' + remainMin + ' min)</button>';
        }

        var pr = window.pendingReschedules[b.id];
        if (pr) {
            if (pr.requestedBy === window.currentUserId) {
                html += '<div class="reschedule-info-chip">Requested reschedule to ' +
                        pr.newDate + ' at ' + formatTime(pr.newTime) +
                        ' \u2014 awaiting client response</div>';
            } else {
                html +=
                    '<div class="reschedule-request-chip"><strong>' + escHtml(pr.requesterName) + '</strong> requested to ' +
                    pr.newDate + ' at ' + formatTime(pr.newTime) +
                    (pr.reason ? '<br><em>"' + escHtml(pr.reason) + '"</em>' : '') + '</div>' +
                    '<form method="post" action="' + window.contextPath + '/bookings/reschedule/respond">' +
                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                    '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">' +
                    '<input type="hidden" name="action" value="accept">' +
                    '<input type="hidden" name="keepBooking" value="true">' +
                    '<button type="submit" class="btn-complete" style="width:100%;padding:0.65rem;">Accept</button></form>' +
                    '<form method="post" action="' + window.contextPath + '/bookings/reschedule/respond">' +
                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                    '<input type="hidden" name="rescheduleId" value="' + pr.rescheduleId + '">' +
                    '<input type="hidden" name="action" value="reject">' +
                    '<input type="hidden" name="keepBooking" value="true">' +
                    '<button type="submit" class="btn-cancel-booking" style="width:100%;padding:0.65rem;">Reject</button></form>';
            }
        }

    } else if (b.status === 'RESCHEDULE_PENDING') {
        var pr2 = window.pendingReschedules[b.id];
        if (pr2) {
            if (pr2.requestedBy === window.currentUserId) {
                html += '<div class="reschedule-info-chip">Requested reschedule to ' +
                        pr2.newDate + ' at ' + formatTime(pr2.newTime) +
                        ' \u2014 awaiting client response</div>';
            } else {
                html +=
                    '<div class="reschedule-request-chip"><strong>' + escHtml(pr2.requesterName) + '</strong> requested to ' +
                    pr2.newDate + ' at ' + formatTime(pr2.newTime) +
                    (pr2.reason ? '<br><em>"' + escHtml(pr2.reason) + '"</em>' : '') + '</div>' +
                    '<form method="post" action="' + window.contextPath + '/bookings/reschedule/respond">' +
                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                    '<input type="hidden" name="rescheduleId" value="' + pr2.rescheduleId + '">' +
                    '<input type="hidden" name="action" value="accept">' +
                    '<input type="hidden" name="keepBooking" value="true">' +
                    '<button type="submit" class="btn-complete" style="width:100%;padding:0.65rem;">Accept</button></form>' +
                    '<form method="post" action="' + window.contextPath + '/bookings/reschedule/respond">' +
                    '<input type="hidden" name="bookingId" value="' + b.id + '">' +
                    '<input type="hidden" name="rescheduleId" value="' + pr2.rescheduleId + '">' +
                    '<input type="hidden" name="action" value="reject">' +
                    '<input type="hidden" name="keepBooking" value="true">' +
                    '<button type="submit" class="btn-cancel-booking" style="width:100%;padding:0.65rem;">Reject</button></form>';
            }
        }
    }

    if (b.status !== 'NO_SHOW' && b.status !== 'TECHNICIAN_COMPLETED' && b.status !== 'CLIENT_NO_SHOW') {
        html += '<button onclick="showCancelModal(' + b.id + ')" class="btn-cancel-booking">Cancel Booking</button>';
    }
    return html;
}

function renderListView() {
    var container = document.getElementById('listViewContainer');
    container.innerHTML = '';

    var nonRecurring    = [];
    var recurringGroups = {};
    var recurringOrder  = [];

    window.bookings.forEach(function (b) {
        if (!b.recurring || !b.contractId) {
            nonRecurring.push(b);
        } else {
            var key = b.contractId;
            if (!recurringGroups[key]) {
                recurringGroups[key] = { months: [] };
                recurringOrder.push(key);
            }
            recurringGroups[key].months.push(b);
        }
    });

    recurringOrder.forEach(function (key) {
        recurringGroups[key].months.sort(function (a, b) { return a.recurringSeq - b.recurringSeq; });
    });

    /* Recurring contract group cards */
    recurringOrder.forEach(function (key) {
        var group   = recurringGroups[key];
        var rep     = group.months[0];
        var total   = group.months.length;
        var today   = new Date().toISOString().split('T')[0];
        var next    = group.months.find(function (m) { return m.date >= today; }) || rep;
        var groupId  = 'months-' + key;
        var toggleId = 'toggle-' + key;

        var mapHtml = (rep.lat && rep.lng && rep.lat !== '' && rep.lng !== '')
            ? '<a href="https://www.google.com/maps?q=' + rep.lat + ',' + rep.lng +
              '" target="_blank" style="color:var(--primary);text-decoration:underline;margin-top:0.25rem;display:inline-block;">View on Google Maps</a>'
            : '';

        var monthRows = group.months.map(function (m) {
            return '<tr>' +
                '<td>Month ' + m.recurringSeq + '</td>' +
                '<td>' + m.date + ' at ' + formatTime(m.time) + '</td>' +
                '<td>' + statusBadgeHtml(m.status) + '</td>' +
                '<td><button onclick="showCancelModal(' + m.id + ')" class="btn-cancel-booking" ' +
                'style="padding:0.25rem 0.6rem;font-size:0.75rem;min-width:auto;flex:none;">Cancel</button></td>' +
                '</tr>';
        }).join('');

        var card = document.createElement('div');
        card.className = 'booking-card recurring-contract-card';
        card.innerHTML =
            '<div class="booking-card-header">' +
            '<div>' +
            '<h3>' + escHtml(rep.service) + ' <span class="recurring-badge">\u21BB Recurring (' + total + ' months)</span></h3>' +
            '<p><strong>Customer:</strong> ' + escHtml(rep.customer) + '</p>' +
            '<p><strong>Phone:</strong> '    + escHtml(rep.phone)    + '</p>' +
            '<p><strong>Next:</strong> Month ' + next.recurringSeq + ' \u2014 ' + next.date + ' at ' + formatTime(next.time) + '</p>' +
            '</div>' +
            '<div>' + statusBadgeHtml(next.status) + '</div>' +
            '</div>' +
            '<div class="info-block"><p class="label">Problem Description:</p><p>' + escHtml(rep.problem) + '</p></div>' +
            '<div class="info-block"><p class="label">Location:</p><p>' + escHtml(rep.address) + '</p>' + mapHtml + '</div>' +
            '<button class="months-toggle-btn" id="' + toggleId + '" ' +
            'onclick="toggleMonths(\'' + groupId + '\',\'' + toggleId + '\',' + total + ')">' +
            'Show all ' + total + ' months \u25BC</button>' +
            '<div class="months-list" id="' + groupId + '">' +
            '<table><thead><tr><th>Month</th><th>Date &amp; Time</th><th>Status</th><th>Action</th></tr></thead>' +
            '<tbody>' + monthRows + '</tbody></table></div>' +
            '<div class="booking-actions" style="margin-top:1rem;">' + buildActionsHtml(next) + '</div>';
        container.appendChild(card);
    });

    /* Individual non-recurring booking cards */
    nonRecurring.forEach(function (b) {
        var mapHtml = (b.lat && b.lng && b.lat !== '' && b.lng !== '')
            ? '<a href="https://www.google.com/maps?q=' + b.lat + ',' + b.lng +
              '" target="_blank" style="color:var(--primary);text-decoration:underline;margin-top:0.25rem;display:inline-block;">View on Google Maps</a>'
            : '';

        var card = document.createElement('div');
        card.className = 'booking-card';
        card.innerHTML =
            '<div class="booking-card-header">' +
            '<div>' +
            '<h3>' + escHtml(b.service) + '</h3>' +
            '<p><strong>Customer:</strong> ' + escHtml(b.customer) + '</p>' +
            '<p><strong>Phone:</strong> '    + escHtml(b.phone)    + '</p>' +
            '<p><strong>Date:</strong> '     + b.date + ' at ' + formatTime(b.time) + '</p>' +
            '</div>' +
            '<div>' + statusBadgeHtml(b.status) + '</div>' +
            '</div>' +
            '<div class="info-block"><p class="label">Problem Description:</p><p>' + escHtml(b.problem) + '</p></div>' +
            '<div class="info-block"><p class="label">Location:</p><p>' + escHtml(b.address) + '</p>' + mapHtml + '</div>' +
            '<div class="booking-actions">' + buildActionsHtml(b) + '</div>';
        container.appendChild(card);
    });
}

/* ─── Init ───────────────────────────────────────────────────────────────── */
(function init() {
    renderListView();

    /* Close modals on backdrop click */
    ['cancelModal', 'detailModal', 'rescheduleModal', 'clientNoShowModal'].forEach(function (id) {
        document.getElementById(id).addEventListener('click', function (e) {
            if (e.target === this) this.style.display = 'none';
        });
    });

    /* File validation for client no-show form */
    document.getElementById('clientNoShowForm').addEventListener('submit', function (e) {
        var fileInput = document.getElementById('techProofFileInput');
        var errDiv    = document.getElementById('techProofFileError');
        errDiv.style.display = 'none';
        errDiv.textContent   = '';

        if (!fileInput.files || fileInput.files.length === 0) {
            e.preventDefault();
            errDiv.textContent   = 'Please select an arrival proof photo.';
            errDiv.style.display = 'block';
            return;
        }
        var file = fileInput.files[0];
        if (file.size > 5 * 1024 * 1024) {
            e.preventDefault();
            errDiv.textContent   = 'File is too large. Maximum size is 5 MB.';
            errDiv.style.display = 'block';
            return;
        }
        if (['image/jpeg', 'image/png'].indexOf(file.type) === -1) {
            e.preventDefault();
            errDiv.textContent   = 'Only JPG and PNG images are allowed.';
            errDiv.style.display = 'block';
        }
    });
})();
