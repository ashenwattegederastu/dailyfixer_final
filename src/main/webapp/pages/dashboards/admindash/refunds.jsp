<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    List<Order> pendingRefunds = (List<Order>) request.getAttribute("pendingRefunds");
    SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Refund Management | Daily Fixer Admin</title>
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

/* Reason cell */
.reason-cell { font-size: 0.82em; color: var(--muted-foreground); font-style: italic; max-width: 200px; }

/* Refund form inline */
.refund-form { display: flex; gap: 8px; align-items: center; }
.refund-input {
    padding: 7px 10px;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    font-size: 0.85rem;
    background: var(--background);
    color: var(--foreground);
    width: 160px;
    font-family: 'IBM Plex Mono', monospace;
}
.refund-input:focus { outline: none; border-color: var(--primary); }
.refund-btn {
    padding: 7px 16px;
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.85rem;
    cursor: pointer;
    transition: all 0.2s;
    white-space: nowrap;
}
.refund-btn:hover { opacity: 0.9; transform: translateY(-1px); }
.refund-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

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
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Refund Management</h2>
    <p class="sub">Orders awaiting manual refund processing. Enter the PayHere or bank refund reference number and confirm.</p>

    <div class="stats-strip">
        <div class="strip-card">
            <div class="number"><%= pendingRefunds != null ? pendingRefunds.size() : 0 %></div>
            <div class="label">Pending Refunds</div>
        </div>
        <div class="strip-card">
            <%
                java.math.BigDecimal totalPending = java.math.BigDecimal.ZERO;
                if (pendingRefunds != null) {
                    for (Order o : pendingRefunds) {
                        if (o.getAmount() != null) totalPending = totalPending.add(o.getAmount());
                    }
                }
            %>
            <div class="number">LKR <%= String.format("%,.2f", totalPending) %></div>
            <div class="label">Total Refund Value</div>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Email</th>
                <th>Amount</th>
                <th>PayHere ID</th>
                <th>Flagged At</th>
                <th>Reason</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="refundTableBody">
        <% if (pendingRefunds == null || pendingRefunds.isEmpty()) { %>
            <tr>
                <td colspan="8" style="text-align:center; padding:40px; color: var(--muted-foreground);">
                    No pending refunds. All clear!
                </td>
            </tr>
        <% } else {
            for (Order o : pendingRefunds) {
                String amountStr = o.getAmount() != null
                    ? (o.getCurrency() != null ? o.getCurrency() : "LKR") + " " + String.format("%,.2f", o.getAmount())
                    : "—";
                String flaggedAt = o.getUpdatedAt() != null ? dtFmt.format(o.getUpdatedAt()) : "—";
                String payId     = o.getPayherePaymentId() != null ? o.getPayherePaymentId() : "—";
                String reason    = o.getRefundReason() != null ? o.getRefundReason() : "—";
        %>
            <tr id="row-<%= o.getOrderId() %>">
                <td><code style="font-family:'IBM Plex Mono',monospace;font-size:0.85em;"><%= o.getOrderId() %></code></td>
                <td><strong><%= o.getFullName() %></strong></td>
                <td><%= o.getEmail() != null ? o.getEmail() : "—" %></td>
                <td><strong><%= amountStr %></strong></td>
                <td><code style="font-family:'IBM Plex Mono',monospace;font-size:0.82em;"><%= payId %></code></td>
                <td><%= flaggedAt %></td>
                <td class="reason-cell"><%= reason %></td>
                <td>
                    <div class="refund-form">
                        <input type="text" class="refund-input"
                               id="refnum-<%= o.getOrderId() %>"
                               placeholder="Refund ref #"
                               title="Enter the refund reference number from PayHere or your bank">
                        <button class="refund-btn"
                                onclick="confirmRefund('<%= o.getOrderId() %>', this)">
                            Mark Refunded
                        </button>
                    </div>
                </td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</main>

<div id="toast"></div>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';

    function confirmRefund(orderId, btn) {
        const input = document.getElementById('refnum-' + orderId);
        const refundNumber = input.value.trim();

        if (!refundNumber) {
            input.focus();
            input.style.borderColor = '#dc3545';
            setTimeout(() => input.style.borderColor = '', 1500);
            return;
        }

        if (!confirm('Mark order ' + orderId + ' as REFUNDED with reference: ' + refundNumber + '?')) return;

        btn.disabled = true;
        btn.textContent = 'Processing...';

        fetch(CONTEXT_PATH + '/admin/refunds', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'orderId=' + encodeURIComponent(orderId)
                + '&refundNumber=' + encodeURIComponent(refundNumber)
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                const row = document.getElementById('row-' + orderId);
                if (row) {
                    row.style.opacity = '0.4';
                    row.style.textDecoration = 'line-through';
                    setTimeout(() => row.remove(), 900);
                }
                showToast('Order ' + orderId + ' marked as refunded.', 'success');
            } else {
                showToast(data.message || 'Failed to update.', 'error');
                btn.disabled = false;
                btn.textContent = 'Mark Refunded';
            }
        })
        .catch(err => {
            showToast('Error: ' + err.message, 'error');
            btn.disabled = false;
            btn.textContent = 'Mark Refunded';
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
