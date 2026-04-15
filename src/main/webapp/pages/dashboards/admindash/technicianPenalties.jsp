<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.TechnicianPenalty" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<TechnicianPenalty> activePenalties = (List<TechnicianPenalty>) request.getAttribute("activePenalties");
    SimpleDateFormat dtFmt = new SimpleDateFormat("dd MMM yyyy, HH:mm");

    int countL1 = 0, countL2 = 0, countL3 = 0;
    if (activePenalties != null) {
        for (TechnicianPenalty p : activePenalties) {
            if      (p.getPenaltyLevel() == 1) countL1++;
            else if (p.getPenaltyLevel() == 2) countL2++;
            else if (p.getPenaltyLevel() == 3) countL3++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Technician Penalties | Daily Fixer Admin</title>
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

/* Penalty level badges */
.pb-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 600;
}
.pb-1 { background: #fef9c3; color: #854d0e; }
.pb-2 { background: #fed7aa; color: #9a3412; }
.pb-3 { background: #fee2e2; color: #991b1b; }

/* Action buttons */
.btn-lift {
    padding: 7px 16px;
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-lift:hover { opacity: 0.9; transform: translateY(-1px); }

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
    max-width: 420px;
    width: 90%;
    box-shadow: var(--shadow-lg);
}
.modal-box h3   { margin: 0 0 12px; font-size: 1.05em; color: var(--foreground); }
.modal-box p    { margin: 0 0 20px; color: var(--muted-foreground); font-size: 0.9em; line-height: 1.6; }
.modal-actions  { display: flex; gap: 10px; justify-content: flex-end; }
.btn-confirm {
    padding: 7px 16px;
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-confirm:hover { opacity: 0.9; }
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
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Technician Penalties</h2>
    <p class="sub">Active no-show penalties across all technicians. Lift a penalty to reinstate a technician's account or listing.</p>

    <div class="stats-strip">
        <div class="strip-card">
            <div class="number"><%= activePenalties != null ? activePenalties.size() : 0 %></div>
            <div class="label">Total Active Penalties</div>
        </div>
        <div class="strip-card">
            <div class="number" style="color:#854d0e;"><%= countL1 %></div>
            <div class="label">Level 1 &mdash; Warnings</div>
        </div>
        <div class="strip-card">
            <div class="number" style="color:#9a3412;"><%= countL2 %></div>
            <div class="label">Level 2 &mdash; Suppressed</div>
        </div>
        <div class="strip-card">
            <div class="number" style="color:#dc3545;"><%= countL3 %></div>
            <div class="label">Level 3 &mdash; Suspended</div>
        </div>
    </div>

    <table id="penaltyTable">
        <thead>
            <tr>
                <th>Technician</th>
                <th>Level</th>
                <th>Issued</th>
                <th>Expires</th>
                <th>Notes</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="penaltyTableBody">
        <% if (activePenalties == null || activePenalties.isEmpty()) { %>
            <tr>
                <td colspan="6" style="text-align:center; padding:40px; color:var(--muted-foreground);">
                    No active penalties found. All technicians are in good standing.
                </td>
            </tr>
        <% } else {
            for (TechnicianPenalty p : activePenalties) {
                String levelLabel = p.getPenaltyLevel() == 1 ? "Warning"
                                  : p.getPenaltyLevel() == 2 ? "Suppressed" : "Suspended";
                String issuedStr  = p.getIssuedAt()  != null ? dtFmt.format(p.getIssuedAt())  : "&#8212;";
                String expiresStr = p.getExpiresAt() != null ? dtFmt.format(p.getExpiresAt()) : "Indefinite";
        %>
            <tr id="penalty-row-<%= p.getPenaltyId() %>">
                <td><strong><%= p.getTechnicianName() != null ? p.getTechnicianName() : "Technician #" + p.getTechnicianId() %></strong>
                    <br><small style="color:var(--muted-foreground);font-size:0.8em;">ID #<%= p.getTechnicianId() %></small></td>
                <td><span class="pb-badge pb-<%= p.getPenaltyLevel() %>">Level <%= p.getPenaltyLevel() %> &mdash; <%= levelLabel %></span></td>
                <td><%= issuedStr %></td>
                <td style="<%= p.getExpiresAt() == null ? "color:#991b1b;font-weight:600;" : "" %>"><%= expiresStr %></td>
                <td style="max-width:240px; white-space:normal; color:var(--muted-foreground); font-size:0.85em;">
                    <%= p.getNotes() != null ? p.getNotes() : "&#8212;" %>
                </td>
                <td>
                    <button class="btn-lift"
                            onclick="openLiftModal(<%= p.getPenaltyId() %>, '<%= levelLabel %>', '<%= p.getTechnicianName() != null ? p.getTechnicianName().replace("'", "\\'") : "this technician" %>', <%= p.getPenaltyLevel() %>)">
                        Lift Penalty
                    </button>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</main>

<!-- Confirm Lift Modal -->
<div id="liftModal" class="modal-overlay">
    <div class="modal-box">
        <h3>Lift Penalty</h3>
        <p id="liftModalText">Are you sure you want to lift this penalty?</p>
        <div class="modal-actions">
            <button class="btn-cancel-modal" onclick="closeLiftModal()">Cancel</button>
            <button class="btn-confirm" onclick="confirmLift()">Yes, Lift Penalty</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    let _pendingPenaltyId   = null;
    let _pendingPenaltyLevel = null;

    function openLiftModal(penaltyId, levelLabel, techName, level) {
        _pendingPenaltyId    = penaltyId;
        _pendingPenaltyLevel = level;
        const extra = level === 3
            ? ' This will also reinstate the technician\'s account.'
            : level === 2
            ? ' This will immediately restore their service listing.'
            : '';
        document.getElementById('liftModalText').textContent =
            'Lift the ' + levelLabel + ' penalty for ' + techName + '?' + extra;
        document.getElementById('liftModal').classList.add('open');
    }

    function closeLiftModal() {
        document.getElementById('liftModal').classList.remove('open');
        _pendingPenaltyId    = null;
        _pendingPenaltyLevel = null;
    }

    function confirmLift() {
        if (!_pendingPenaltyId) return;
        const penaltyId = _pendingPenaltyId;
        closeLiftModal();

        fetch(CONTEXT_PATH + '/admin/lift-technician-penalty', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'penaltyId=' + encodeURIComponent(penaltyId)
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                const row = document.getElementById('penalty-row-' + penaltyId);
                if (row) row.remove();
                showToast('Penalty lifted successfully.', 'success');
            } else {
                showToast('Error: ' + (data.message || 'Unknown error'), 'error');
            }
        })
        .catch(() => showToast('Network error. Please try again.', 'error'));
    }

    function showToast(msg, type) {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.className = type;
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 3500);
    }
</script>

</body>
</html>
