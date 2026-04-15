<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.ClientNoShowPenalty" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<ClientNoShowPenalty> pendingCases = (List<ClientNoShowPenalty>) request.getAttribute("pendingCases");
    SimpleDateFormat dtFmt = new SimpleDateFormat("dd MMM yyyy, HH:mm");
    int totalCases = (pendingCases != null) ? pendingCases.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Client Penalties | Daily Fixer Admin</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.container {
    flex: 1;
    margin-left: 240px;
    padding: 30px;
    background-color: var(--background);
}
.container > h2 { font-size: 1.6em; margin-bottom: 6px; color: var(--foreground); }
.container > .sub { color: var(--muted-foreground); margin-bottom: 28px; font-size: 0.95em; }

/* Stats strip */
.stats-strip {
    display: flex;
    gap: 20px;
    margin-bottom: 28px;
}
.strip-card {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 18px 24px;
    flex: 1;
    box-shadow: var(--shadow-sm);
}
.strip-card .number { font-size: 1.8em; font-weight: 700; color: var(--primary); }
.strip-card .label  { color: var(--muted-foreground); font-size: 0.88em; font-weight: 500; margin-top: 4px; }

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

/* Status badge */
.status-badge-admin-review {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 600;
    background: #fee2e2;
    color: #991b1b;
}

/* Action buttons */
.btn-mark-paid {
    padding: 7px 14px;
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.83rem;
    cursor: pointer;
    transition: all 0.2s;
    margin-right: 6px;
}
.btn-mark-paid:hover { opacity: 0.9; transform: translateY(-1px); }

.btn-suspend {
    padding: 7px 14px;
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.83rem;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-suspend:hover { opacity: 0.9; transform: translateY(-1px); }

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

/* Confirm modal */
.modal-overlay {
    position: fixed; inset: 0;
    background: rgba(0,0,0,0.5);
    z-index: 1000;
    display: none;
    align-items: center;
    justify-content: center;
}
.modal-overlay.open { display: flex; }
.modal-box {
    background: var(--card);
    border-radius: var(--radius-lg);
    padding: 28px 32px;
    max-width: 440px;
    width: 90%;
    box-shadow: var(--shadow-lg);
}
.modal-box h3 { margin: 0 0 12px; font-size: 1.05em; color: var(--foreground); }
.modal-box p  { margin: 0 0 20px; color: var(--muted-foreground); font-size: 0.9em; line-height: 1.6; }
.modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
.btn-confirm-paid-modal {
    padding: 7px 16px;
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
}
.btn-confirm-suspend-modal {
    padding: 7px 16px;
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
}
.btn-cancel-modal {
    padding: 7px 16px;
    background: var(--muted);
    color: var(--foreground);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
}

/* Proof image link */
.proof-link {
    color: var(--primary);
    text-decoration: underline;
    font-size: 0.85em;
    cursor: pointer;
}
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Client No-Show Penalties</h2>
    <p class="sub">Cases escalated to admin review. Verify payment proof and take appropriate action.</p>

    <div class="stats-strip">
        <div class="strip-card">
            <div class="number"><%= totalCases %></div>
            <div class="label">Pending Admin Review</div>
        </div>
    </div>

    <table id="penaltyTable">
        <thead>
            <tr>
                <th>Client</th>
                <th>Technician</th>
                <th>Service</th>
                <th>Booking Date</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Proof</th>
                <th>Created</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody id="penaltyTableBody">
        <% if (pendingCases == null || pendingCases.isEmpty()) { %>
            <tr>
                <td colspan="9" style="text-align:center; padding:40px; color:var(--muted-foreground);">
                    No cases pending admin review. All client penalties are resolved or awaiting technician action.
                </td>
            </tr>
        <% } else {
            for (ClientNoShowPenalty p : pendingCases) {
                String createdStr  = p.getCreatedAt()       != null ? dtFmt.format(p.getCreatedAt())       : "&#8212;";
                String bookingStr  = p.getBookingDate()     != null ? dtFmt.format(p.getBookingDate())     : "&#8212;";
                String clientName  = p.getClientName()      != null ? p.getClientName()      : "Client #"     + p.getClientId();
                String techName    = p.getTechnicianName()  != null ? p.getTechnicianName()  : "Technician #"  + p.getTechnicianId();
                String svcName     = p.getServiceName()     != null ? p.getServiceName()     : "&#8212;";
                String escapedClientName = clientName.replace("'", "\\'");
                String escapedTechName   = techName.replace("'", "\\'");
        %>
            <tr id="penalty-row-<%= p.getPenaltyId() %>">
                <td>
                    <strong><%= clientName %></strong>
                    <br><small style="color:var(--muted-foreground);font-size:0.8em;">ID #<%= p.getClientId() %></small>
                </td>
                <td>
                    <%= techName %>
                    <br><small style="color:var(--muted-foreground);font-size:0.8em;">ID #<%= p.getTechnicianId() %></small>
                </td>
                <td><%= svcName %></td>
                <td><%= bookingStr %></td>
                <td style="font-weight:700; color:#991b1b;">Rs. <%= String.format("%.0f", p.getAmount()) %></td>
                <td><span class="status-badge-admin-review">Admin Review</span></td>
                <td>
                    <% if (p.getProofPath() != null && !p.getProofPath().isEmpty()) { %>
                        <a href="${pageContext.request.contextPath}/<%= p.getProofPath() %>"
                           target="_blank" class="proof-link">View Proof</a>
                    <% } else { %>
                        <span style="color:var(--muted-foreground);font-size:0.85em;">&#8212;</span>
                    <% } %>
                </td>
                <td><%= createdStr %></td>
                <td>
                    <button class="btn-mark-paid"
                            onclick="openMarkPaidModal(<%= p.getPenaltyId() %>, '<%= escapedClientName %>')">
                        Mark Paid
                    </button>
                    <button class="btn-suspend"
                            onclick="openSuspendModal(<%= p.getPenaltyId() %>, '<%= escapedClientName %>')">
                        Suspend Client
                    </button>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</main>

<!-- Mark Paid Confirm Modal -->
<div id="markPaidModal" class="modal-overlay">
    <div class="modal-box">
        <h3>Confirm Payment</h3>
        <p id="markPaidModalText">Mark this penalty as resolved — the client has paid?</p>
        <div class="modal-actions">
            <button class="btn-cancel-modal" onclick="closeMarkPaidModal()">Cancel</button>
            <button class="btn-confirm-paid-modal" onclick="confirmMarkPaid()">Yes, Mark Paid</button>
        </div>
    </div>
</div>

<!-- Suspend Client Confirm Modal -->
<div id="suspendModal" class="modal-overlay">
    <div class="modal-box">
        <h3>Suspend Client</h3>
        <p id="suspendModalText">Suspend this client's account for fraudulent payment proof?</p>
        <div class="modal-actions">
            <button class="btn-cancel-modal" onclick="closeSuspendModal()">Cancel</button>
            <button class="btn-confirm-suspend-modal" onclick="confirmSuspend()">Yes, Suspend Client</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    let _pendingPenaltyId = null;

    /* ── Mark Paid ─────────────────────────────────── */
    function openMarkPaidModal(penaltyId, clientName) {
        _pendingPenaltyId = penaltyId;
        document.getElementById('markPaidModalText').textContent =
            'Mark the Rs. 2,500 penalty for ' + clientName + ' as resolved — the client has paid?';
        document.getElementById('markPaidModal').classList.add('open');
    }
    function closeMarkPaidModal() {
        document.getElementById('markPaidModal').classList.remove('open');
        _pendingPenaltyId = null;
    }
    function confirmMarkPaid() {
        if (!_pendingPenaltyId) return;
        const penaltyId = _pendingPenaltyId;
        closeMarkPaidModal();
        sendAction(penaltyId, 'markPaid');
    }

    /* ── Suspend Client ────────────────────────────── */
    function openSuspendModal(penaltyId, clientName) {
        _pendingPenaltyId = penaltyId;
        document.getElementById('suspendModalText').textContent =
            'Suspend ' + clientName + '\'s account for submitting fraudulent payment proof? This will permanently suspend the account.';
        document.getElementById('suspendModal').classList.add('open');
    }
    function closeSuspendModal() {
        document.getElementById('suspendModal').classList.remove('open');
        _pendingPenaltyId = null;
    }
    function confirmSuspend() {
        if (!_pendingPenaltyId) return;
        const penaltyId = _pendingPenaltyId;
        closeSuspendModal();
        sendAction(penaltyId, 'suspendClient');
    }

    /* ── Shared AJAX ───────────────────────────────── */
    function sendAction(penaltyId, action) {
        fetch(CONTEXT_PATH + '/admin/client-penalty-action', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'penaltyId=' + encodeURIComponent(penaltyId) + '&action=' + encodeURIComponent(action)
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                const row = document.getElementById('penalty-row-' + penaltyId);
                if (row) row.remove();
                showToast(data.message || 'Action completed successfully.', 'success');
            } else {
                showToast('Error: ' + (data.message || 'Unknown error'), 'error');
            }
        })
        .catch(() => showToast('Network error. Please try again.', 'error'));
    }

    /* ── Toast ─────────────────────────────────────── */
    function showToast(msg, type) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.className = type;
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 3500);
    }

    /* ── Overlay click to close ────────────────────── */
    document.getElementById('markPaidModal').addEventListener('click', function(e) {
        if (e.target === this) closeMarkPaidModal();
    });
    document.getElementById('suspendModal').addEventListener('click', function(e) {
        if (e.target === this) closeSuspendModal();
    });
</script>

</body>
</html>
