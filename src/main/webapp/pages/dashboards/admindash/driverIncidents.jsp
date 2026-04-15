<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.DriverIncident" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    List<DriverIncident> incidentsSummary = (List<DriverIncident>) request.getAttribute("incidentsSummary");
    List<DriverIncident> allIncidents = (List<DriverIncident>) request.getAttribute("allIncidents");
    SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Driver Incidents | Daily Fixer Admin</title>
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

/* Status tags */
.status-tag {
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.8rem;
    font-weight: 600;
}
.status-active { background: #d4edda; color: #155724; }
.status-suspended { background: #f8d7da; color: #721c24; }

/* Action buttons */
.btn-suspend {
    padding: 7px 16px;
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-suspend:hover { opacity: 0.9; transform: translateY(-1px); }

.btn-activate {
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
.btn-activate:hover { opacity: 0.9; transform: translateY(-1px); }

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

/* Review modal */
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
    max-width: 480px;
    width: 90%;
    box-shadow: var(--shadow-lg);
}
.modal-box h3 { margin: 0 0 16px; font-size: 1.1em; color: var(--foreground); }
.modal-box textarea {
    width: 100%;
    min-height: 90px;
    padding: 10px 12px;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 0.9rem;
    background: var(--background);
    color: var(--foreground);
    resize: vertical;
    box-sizing: border-box;
}
.modal-actions { display: flex; gap: 10px; margin-top: 16px; justify-content: flex-end; }
.btn-review {
    padding: 7px 16px;
    background: linear-gradient(135deg, #0d6efd, #0056d2);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-review:hover { opacity: 0.9; transform: translateY(-1px); }
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
.badge-reviewed { background: #d4edda; color: #155724; }
.badge-unreviewed { background: #fff3cd; color: #856404; }
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Driver Incidents</h2>
    <p class="sub">Monitor delivery failures (Rule 3 & Rule 4 timeouts) and manage driver suspensions.</p>

    <div class="stats-strip">
        <div class="strip-card">
            <%
                int totalDriversWithIncidents = incidentsSummary != null ? incidentsSummary.size() : 0;
            %>
            <div class="number"><%= totalDriversWithIncidents %></div>
            <div class="label">Drivers with Incidents</div>
        </div>
        <div class="strip-card">
            <%
                int totalSevere = 0;
                if (incidentsSummary != null) {
                    for (DriverIncident i : incidentsSummary) {
                        totalSevere += i.getPickupMissCount();
                    }
                }
            %>
            <div class="number" style="color:#dc3545;"><%= totalSevere %></div>
            <div class="label">Total 'Picked Up, Not Delivered'</div>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>Driver Name</th>
                <th>Email</th>
                <th>Total Incidents</th>
                <th title="Driver accepted assignment but never picked up">Accept No Pickup</th>
                <th title="Driver picked up but never delivered">Pickup No Delivery</th>
                <th>Status</th>
                <th>Last Incident</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="incidentsTableBody">
        <% if (incidentsSummary == null || incidentsSummary.isEmpty()) { %>
            <tr>
                <td colspan="8" style="text-align:center; padding:40px; color: var(--muted-foreground);">
                    No driver incidents found.
                </td>
            </tr>
        <% } else {
            for (DriverIncident incident : incidentsSummary) {
                String lastIncidentStr = incident.getLastIncident() != null ? dtFmt.format(incident.getLastIncident()) : "—";
                boolean isSuspended = "suspended".equalsIgnoreCase(incident.getDriverStatus());
        %>
            <tr id="row-<%= incident.getDriverId() %>">
                <td><strong><%= incident.getDriverName() %></strong></td>
                <td><%= incident.getDriverEmail() %></td>
                <td><strong><%= incident.getTotalIncidents() %></strong></td>
                <td><%= incident.getAcceptMissCount() %></td>
                <td style="color:#dc3545; font-weight:600;"><%= incident.getPickupMissCount() %></td>
                <td>
                    <% if (isSuspended) { %>
                        <span class="status-tag status-suspended">Suspended</span>
                    <% } else { %>
                        <span class="status-tag status-active">Active</span>
                    <% } %>
                </td>
                <td><%= lastIncidentStr %></td>
                <td>
                    <% if (isSuspended) { %>
                        <button class="btn-activate" onclick="toggleStatus(<%= incident.getDriverId() %>, 'activate', this)">Activate</button>
                    <% } else { %>
                        <button class="btn-suspend" onclick="toggleStatus(<%= incident.getDriverId() %>, 'suspend', this)">Suspend</button>
                    <% } %>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>

    <!-- Individual Incidents Review -->
    <h3 style="margin-top:36px; font-size:1.2em; font-weight:700; color:var(--foreground); margin-bottom:16px;">
        Individual Incident Log
    </h3>
    <p style="color:var(--muted-foreground); margin-bottom:18px; font-size:0.92em;">
        Review and annotate each incident. Reviewed incidents are shown with admin notes.
    </p>
    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Driver</th>
                <th>Order ID</th>
                <th>Type</th>
                <th>Description</th>
                <th>Status</th>
                <th>Date</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <% if (allIncidents == null || allIncidents.isEmpty()) { %>
            <tr><td colspan="8" style="text-align:center; padding:40px; color:var(--muted-foreground);">No incidents found.</td></tr>
        <% } else {
            for (DriverIncident inc : allIncidents) {
                String incDate = inc.getCreatedAt() != null ? dtFmt.format(inc.getCreatedAt()) : "—";
        %>
            <tr id="inc-row-<%= inc.getIncidentId() %>">
                <td>#<%= inc.getIncidentId() %></td>
                <td>
                    <strong><%= inc.getDriverName() != null ? inc.getDriverName() : "Driver #" + inc.getDriverId() %></strong>
                    <% if (inc.getDriverEmail() != null) { %>
                        <br><small style="color:var(--muted-foreground);"><%= inc.getDriverEmail() %></small>
                    <% } %>
                </td>
                <td><code style="font-family:'IBM Plex Mono',monospace;font-size:0.82em;"><%= inc.getOrderId() %></code></td>
                <td><span class="status-tag <%= "PICKUP_NO_DELIVERY".equals(inc.getIncidentType()) ? "status-suspended" : "status-active" %>">
                    <%= inc.getIncidentType() %></span>
                </td>
                <td style="max-width:200px; white-space:normal;"><%= inc.getDescription() != null ? inc.getDescription() : "—" %></td>
                <td>
                    <% if (inc.isReviewed()) { %>
                        <span class="status-tag badge-reviewed">Reviewed</span>
                        <% if (inc.getReviewNotes() != null && !inc.getReviewNotes().isEmpty()) { %>
                            <br><small style="color:var(--muted-foreground); font-style:italic; display:block; margin-top:4px;">"<%= inc.getReviewNotes() %>"</small>
                        <% } %>
                    <% } else { %>
                        <span class="status-tag badge-unreviewed">Pending Review</span>
                    <% } %>
                </td>
                <td><%= incDate %></td>
                <td>
                    <% if (!inc.isReviewed()) { %>
                        <button class="btn-review" onclick="openReviewModal(<%= inc.getIncidentId() %>)">Review</button>
                    <% } else { %>
                        <span style="color:var(--muted-foreground); font-size:0.85em;">Done</span>
                    <% } %>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</main>

<!-- Review Modal -->
<div id="reviewModal" class="modal-overlay">
    <div class="modal-box">
        <h3>Mark Incident as Reviewed</h3>
        <p style="color:var(--muted-foreground); font-size:0.9em; margin-bottom:12px;">
            Add optional notes for this incident (e.g. outcome, action taken).
        </p>
        <textarea id="reviewNotes" placeholder="Admin notes (optional)..."></textarea>
        <div class="modal-actions">
            <button class="btn-cancel-modal" onclick="closeReviewModal()">Cancel</button>
            <button class="btn-review" onclick="submitReview()">Mark Reviewed</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    let _pendingIncidentId = null;

    function openReviewModal(incidentId) {
        _pendingIncidentId = incidentId;
        document.getElementById('reviewNotes').value = '';
        document.getElementById('reviewModal').classList.add('open');
    }

    function closeReviewModal() {
        _pendingIncidentId = null;
        document.getElementById('reviewModal').classList.remove('open');
    }

    function submitReview() {
        if (!_pendingIncidentId) return;
        const notes = document.getElementById('reviewNotes').value.trim();

        fetch(CONTEXT_PATH + '/admin/review-incident', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'incidentId=' + _pendingIncidentId + '&notes=' + encodeURIComponent(notes)
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            closeReviewModal();
            if (data.success) {
                showToast('Incident marked as reviewed.', 'success');
                setTimeout(() => window.location.reload(), 800);
            } else {
                showToast(data.message || 'Failed to mark reviewed.', 'error');
            }
        })
        .catch(err => {
            closeReviewModal();
            showToast('Error: ' + err.message, 'error');
        });
    }

    function toggleStatus(driverId, action, btn) {
        if (!confirm('Are you sure you want to ' + action + ' this driver?')) return;

        btn.disabled = true;
        const orgText = btn.textContent;
        btn.textContent = 'Processing...';

        fetch(CONTEXT_PATH + '/admin/suspend-driver', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'driverId=' + driverId + '&action=' + action
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                showToast('Driver successfully ' + (action === 'suspend' ? 'suspended' : 'activated') + '.', 'success');
                setTimeout(() => window.location.reload(), 800);
            } else {
                showToast(data.message || 'Failed to update status.', 'error');
                btn.disabled = false;
                btn.textContent = orgText;
            }
        })
        .catch(err => {
            showToast('Error: ' + err.message, 'error');
            btn.disabled = false;
            btn.textContent = orgText;
        });
    }

    function showToast(msg, type) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.className = type;
        t.style.display = 'block';
        setTimeout(() => { t.style.display = 'none'; }, 3500);
    }
</script>
</body>
</html>
