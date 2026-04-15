<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Payout Management | Daily Fixer Admin</title>
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

/* Toolbar */
.toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 12px;
}
.generate-btn {
    padding: 10px 24px;
    background: linear-gradient(135deg, var(--primary), oklch(0.6 0.2 280));
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.95rem;
    cursor: pointer;
    transition: all 0.2s;
}
.generate-btn:hover { opacity: 0.9; transform: translateY(-1px); }
.generate-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

/* Tabs */
.tabs {
    display: flex;
    gap: 0;
    border-bottom: 2px solid var(--border);
    margin-bottom: 24px;
}
.tab-btn {
    padding: 12px 28px;
    border: none;
    background: none;
    font-weight: 600;
    font-size: 0.92rem;
    color: var(--muted-foreground);
    cursor: pointer;
    border-bottom: 3px solid transparent;
    margin-bottom: -2px;
    transition: all 0.2s;
}
.tab-btn.active { color: var(--primary); border-bottom-color: var(--primary); }
.tab-btn:hover { color: var(--foreground); }
.tab-panel { display: none; }
.tab-panel.active { display: block; }

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

/* Status badges */
.badge {
    padding: 4px 12px;
    border-radius: 999px;
    font-weight: 600;
    font-size: 0.8rem;
    display: inline-block;
}
.badge-pending { background: oklch(0.9 0.12 85); color: oklch(0.4 0.12 85); }
.badge-processing { background: oklch(0.9 0.12 240); color: oklch(0.4 0.12 240); }
.badge-completed { background: oklch(0.9 0.12 145); color: oklch(0.35 0.12 145); }

/* Action buttons */
.action-btn-sm {
    padding: 6px 14px;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.82rem;
    cursor: pointer;
    transition: all 0.2s;
    margin-right: 4px;
}
.btn-lock { background: oklch(0.88 0.1 240); color: oklch(0.35 0.12 240); }
.btn-lock:hover { opacity: 0.85; }
.btn-complete { background: oklch(0.88 0.1 145); color: oklch(0.35 0.12 145); }
.btn-complete:hover { opacity: 0.85; }
.btn-unlock { background: oklch(0.90 0.08 30); color: oklch(0.4 0.12 30); }
.btn-unlock:hover { opacity: 0.85; }
.btn-disabled { opacity: 0.4; cursor: not-allowed; }

/* Modal */
.modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.45);
    z-index: 9998;
    align-items: center;
    justify-content: center;
}
.modal-overlay.open { display: flex; }
.modal {
    background: var(--card);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-xl);
    border: 1px solid var(--border);
    width: 520px;
    max-width: 90vw;
    max-height: 85vh;
    overflow-y: auto;
    padding: 30px;
}
.modal h3 { margin-top: 0; color: var(--foreground); }
.modal-field { margin-bottom: 14px; }
.modal-field label { display: block; font-weight: 600; font-size: 0.85rem; color: var(--foreground); margin-bottom: 4px; }
.modal-field .value { font-family: 'IBM Plex Mono', monospace; font-size: 0.92rem; color: var(--muted-foreground); }
.modal-actions { display: flex; gap: 10px; margin-top: 20px; justify-content: flex-end; }
.modal-btn {
    padding: 10px 22px;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.9rem;
    cursor: pointer;
    transition: all 0.2s;
}
.modal-btn-primary { background: linear-gradient(135deg, #28a745, #20c997); color: #fff; }
.modal-btn-primary:hover { opacity: 0.9; }
.modal-btn-cancel { background: var(--muted); color: var(--foreground); }
.modal-btn-cancel:hover { background: var(--border); }

/* File input styling */
.file-input-wrapper { position: relative; }
.file-input-wrapper input[type="file"] {
    padding: 8px;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    background: var(--background);
    color: var(--foreground);
    width: 100%;
    font-size: 0.88rem;
}

/* Empty state */
.empty-state {
    text-align: center;
    padding: 50px 20px;
    color: var(--muted-foreground);
    font-size: 0.95em;
}

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
#toast.warning { background: #ffc107; color: #333; }
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Payout Management</h2>
    <p class="sub">Process manual payouts for stores and delivery drivers. Generate payouts, lock, attach receipt, and complete.</p>

    <div class="stats-strip" id="statsStrip">
        <div class="strip-card">
            <div class="number" id="stat-pending">-</div>
            <div class="label">Pending Payouts</div>
        </div>
        <div class="strip-card">
            <div class="number" id="stat-processing">-</div>
            <div class="label">Processing</div>
        </div>
        <div class="strip-card">
            <div class="number" id="stat-completed">-</div>
            <div class="label">Completed</div>
        </div>
        <div class="strip-card" style="border-top: 3px solid oklch(0.55 0.18 310);">
            <div class="number" id="stat-commission" style="color:oklch(0.45 0.18 310);">-</div>
            <div class="label">Total Commission Collected</div>
        </div>
    </div>

    <div class="toolbar">
        <div class="tabs">
            <button class="tab-btn active" data-tab="pending">Pending</button>
            <button class="tab-btn" data-tab="processing">Processing</button>
            <button class="tab-btn" data-tab="completed">Completed</button>
        </div>
        <button class="generate-btn" id="generateBtn" onclick="generatePayouts()">Generate Payouts</button>
    </div>

    <!-- PENDING tab -->
    <div class="tab-panel active" id="panel-pending">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Type</th>
                    <th>Payee</th>
                    <th>Amount</th>
                    <th>Created</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tbody-pending">
                <tr><td colspan="6" class="empty-state">Loading...</td></tr>
            </tbody>
        </table>
    </div>

    <!-- PROCESSING tab -->
    <div class="tab-panel" id="panel-processing">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Type</th>
                    <th>Payee</th>
                    <th>Amount</th>
                    <th>Locked By</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tbody-processing">
                <tr><td colspan="6" class="empty-state">Loading...</td></tr>
            </tbody>
        </table>
    </div>

    <!-- COMPLETED tab -->
    <div class="tab-panel" id="panel-completed">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Type</th>
                    <th>Payee</th>
                    <th>Amount</th>
                    <th>Completed</th>
                    <th>Receipt</th>
                </tr>
            </thead>
            <tbody id="tbody-completed">
                <tr><td colspan="6" class="empty-state">Loading...</td></tr>
            </tbody>
        </table>
    </div>
</main>

<!-- Complete Payout Modal -->
<div class="modal-overlay" id="completeModal">
    <div class="modal">
        <h3>Complete Payout</h3>
        <div class="modal-field">
            <label>Payout ID</label>
            <div class="value" id="modal-payout-id"></div>
        </div>
        <div class="modal-field">
            <label>Payee</label>
            <div class="value" id="modal-payee"></div>
        </div>
        <div class="modal-field">
            <label>Amount</label>
            <div class="value" id="modal-amount"></div>
        </div>
        <div class="modal-field" id="modal-bank-section">
            <label>Bank Details</label>
            <div class="value" id="modal-bank"></div>
        </div>
        <div class="modal-field" id="modal-balance-section">
            <label>Balances (Lifetime / Pending / Available)</label>
            <div class="value" id="modal-balances"></div>
        </div>
        <form id="completeForm" enctype="multipart/form-data">
            <input type="hidden" id="modal-payout-id-val" name="payoutId">
            <div class="modal-field file-input-wrapper">
                <label>Receipt Image (required)</label>
                <input type="file" name="receipt" id="receiptInput" accept="image/*" required>
            </div>
            <div class="modal-actions">
                <button type="button" class="modal-btn modal-btn-cancel" onclick="closeModal()">Cancel</button>
                <button type="submit" class="modal-btn modal-btn-primary">Confirm &amp; Complete</button>
            </div>
        </form>
    </div>
</div>

<div id="toast"></div>

<script>
    const CTX = '<%= request.getContextPath() %>';
    const ADMIN_ID = <%= user.getUserId() %>;

    // ── Tab switching ──
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
            btn.classList.add('active');
            document.getElementById('panel-' + btn.dataset.tab).classList.add('active');
        });
    });

    // ── Load data ──
    function loadPayouts() {
        fetch(CTX + '/admin/payouts?action=list')
            .then(r => r.json())
            .then(data => {
                renderTable('pending', data.pending || [], true);
                renderTable('processing', data.processing || [], true);
                renderTable('completed', data.completed || [], false);
                document.getElementById('stat-pending').textContent = (data.pending || []).length;
                document.getElementById('stat-processing').textContent = (data.processing || []).length;
                document.getElementById('stat-completed').textContent = (data.completed || []).length;
                if (data.totalCommission != null) {
                    document.getElementById('stat-commission').textContent =
                        'LKR ' + Number(data.totalCommission).toLocaleString('en-US', {minimumFractionDigits: 2});
                }
            })
            .catch(err => showToast('Failed to load payouts: ' + err.message, 'error'));
    }

    function renderTable(status, payouts, showActions) {
        const tbody = document.getElementById('tbody-' + status);
        if (!payouts.length) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No ' + status + ' payouts.</td></tr>';
            return;
        }
        let html = '';
        payouts.forEach(p => {
            html += '<tr>';
            html += '<td><code style="font-family:\'IBM Plex Mono\',monospace;font-size:0.85em;">#' + p.payoutId + '</code></td>';
            html += '<td><span class="badge ' + (p.payeeType === 'STORE' ? 'badge-processing' : 'badge-pending') + '">' + p.payeeType + '</span></td>';
            html += '<td><strong>' + esc(p.payeeName || '—') + '</strong></td>';
            html += '<td><strong>LKR ' + Number(p.amount).toLocaleString('en-US', {minimumFractionDigits: 2}) + '</strong></td>';

            if (status === 'pending') {
                html += '<td>' + (p.createdAt || '—') + '</td>';
                html += '<td><button class="action-btn-sm btn-lock" onclick="lockPayout(' + p.payoutId + ', this)">Lock &amp; Process</button></td>';
            } else if (status === 'processing') {
                html += '<td>' + esc(p.adminName || '—') + '</td>';
                html += '<td>';
                if (p.lockedByAdminId === ADMIN_ID) {
                    html += '<button class="action-btn-sm btn-complete" onclick="openCompleteModal(' + p.payoutId + ')">Complete</button>';
                    html += '<button class="action-btn-sm btn-unlock" onclick="unlockPayout(' + p.payoutId + ', this)">Release</button>';
                } else {
                    html += '<span style="font-size:0.82em;color:var(--muted-foreground);">Locked by another admin</span>';
                }
                html += '</td>';
            } else {
                html += '<td>' + (p.updatedAt || '—') + '</td>';
                html += '<td>';
                if (p.receiptImagePath) {
                    html += '<a href="' + CTX + '/' + esc(p.receiptImagePath) + '" target="_blank" style="color:var(--primary);font-weight:600;">View Receipt</a>';
                } else {
                    html += '—';
                }
                html += '</td>';
            }
            html += '</tr>';
        });
        tbody.innerHTML = html;
    }

    // ── Generate payouts ──
    function generatePayouts() {
        const btn = document.getElementById('generateBtn');
        btn.disabled = true;
        btn.textContent = 'Generating...';
        fetch(CTX + '/admin/payouts', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=generate'
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                showToast(data.message || 'Payouts generated.', 'success');
                loadPayouts();
            } else {
                showToast(data.message || 'Generation failed.', 'error');
            }
        })
        .catch(err => showToast('Error: ' + err.message, 'error'))
        .finally(() => { btn.disabled = false; btn.textContent = 'Generate Payouts'; });
    }

    // ── Lock ──
    function lockPayout(payoutId, btn) {
        btn.disabled = true;
        btn.textContent = 'Locking...';
        fetch(CTX + '/admin/payouts', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=lock&payoutId=' + payoutId
        })
        .then(r => {
            if (r.status === 409) { showToast('Already locked by another admin.', 'warning'); return null; }
            return r.json();
        })
        .then(data => {
            if (data && data.success) {
                showToast('Payout #' + payoutId + ' locked.', 'success');
                loadPayouts();
            } else if (data) {
                showToast(data.message || 'Lock failed.', 'error');
            }
        })
        .catch(err => showToast('Error: ' + err.message, 'error'))
        .finally(() => { btn.disabled = false; btn.textContent = 'Lock & Process'; });
    }

    // ── Unlock ──
    function unlockPayout(payoutId, btn) {
        btn.disabled = true;
        fetch(CTX + '/admin/payouts', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=unlock&payoutId=' + payoutId
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                showToast('Payout released.', 'success');
                loadPayouts();
            } else {
                showToast(data.message || 'Unlock failed.', 'error');
            }
        })
        .catch(err => showToast('Error: ' + err.message, 'error'));
    }

    // ── Complete modal ──
    function openCompleteModal(payoutId) {
        document.getElementById('modal-payout-id').textContent = '#' + payoutId;
        document.getElementById('modal-payout-id-val').value = payoutId;
        document.getElementById('modal-payee').textContent = 'Loading...';
        document.getElementById('modal-amount').textContent = '';
        document.getElementById('modal-bank').textContent = 'Loading...';
        document.getElementById('modal-balances').textContent = 'Loading...';
        document.getElementById('receiptInput').value = '';
        document.getElementById('completeModal').classList.add('open');

        fetch(CTX + '/admin/payouts?action=detail&payoutId=' + payoutId)
            .then(r => r.json())
            .then(data => {
                if (data.payout) {
                    const p = data.payout;
                    document.getElementById('modal-payee').textContent = (p.payeeType || '') + ' — ' + (p.payeeName || 'Unknown');
                    document.getElementById('modal-amount').textContent = 'LKR ' + Number(p.amount).toLocaleString('en-US', {minimumFractionDigits: 2});
                }
                if (data.bank) {
                    const b = data.bank;
                    document.getElementById('modal-bank').textContent =
                        b.bankName + (b.branch ? ' (' + b.branch + ')' : '') + ' — Acc: ' + b.accountNumber + ' — ' + b.accountHolderName;
                } else {
                    document.getElementById('modal-bank').textContent = 'No bank details on file';
                }
                if (data.balances) {
                    document.getElementById('modal-balances').textContent =
                        'LKR ' + Number(data.balances.lifetime).toLocaleString('en-US', {minimumFractionDigits: 2}) + ' / '
                        + 'LKR ' + Number(data.balances.pending).toLocaleString('en-US', {minimumFractionDigits: 2}) + ' / '
                        + 'LKR ' + Number(data.balances.available).toLocaleString('en-US', {minimumFractionDigits: 2});
                }
            })
            .catch(() => {
                document.getElementById('modal-bank').textContent = 'Error loading details';
            });
    }

    function closeModal() {
        document.getElementById('completeModal').classList.remove('open');
    }

    // ── Complete form submit ──
    document.getElementById('completeForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const formData = new FormData(this);
        formData.append('action', 'complete');
        const submitBtn = this.querySelector('[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.textContent = 'Processing...';

        fetch(CTX + '/admin/payouts', {
            method: 'POST',
            body: formData
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                showToast('Payout completed!', 'success');
                closeModal();
                loadPayouts();
            } else {
                showToast(data.message || 'Failed to complete.', 'error');
            }
        })
        .catch(err => showToast('Error: ' + err.message, 'error'))
        .finally(() => { submitBtn.disabled = false; submitBtn.textContent = 'Confirm & Complete'; });
    });

    // ── Helpers ──
    function esc(s) { if (!s) return ''; const d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
    function showToast(msg, type) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.className = type;
        t.style.display = 'block';
        setTimeout(() => { t.style.display = 'none'; }, 3500);
    }

    // ── Init ──
    document.addEventListener('DOMContentLoaded', loadPayouts);
</script>

<script>
    // Highlight sidebar
    document.addEventListener('DOMContentLoaded', function() {
        const link = document.getElementById('nav-payouts');
        if (link) link.classList.add('active');
    });
</script>
</body>
</html>
