<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.DeliveryRate" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null || !"admin".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<DeliveryRate> rates = (List<DeliveryRate>) request.getAttribute("rates");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Rates | Daily Fixer Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .main-content {
            flex: 1;
            margin-left: 240px;
            padding: 40px 30px;
        }
        @media (max-width: 900px) {
            .main-content { margin-left: 0 !important; margin-top: 60px !important; }
        }

        .rates-table {
            width: 100%;
            border-collapse: collapse;
            background: var(--card);
            border-radius: var(--radius-md);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            margin-top: 24px;
        }
        .rates-table th, .rates-table td {
            padding: 14px 18px;
            text-align: left;
            border-bottom: 1px solid var(--border);
            font-size: 0.9rem;
        }
        .rates-table th {
            background: var(--secondary);
            font-weight: 600;
            color: var(--secondary-foreground);
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .rates-table tr:last-child td { border-bottom: none; }
        .rates-table tr:hover td { background: var(--muted); }

        .badge-active {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 99px;
            font-size: 0.78rem;
            font-weight: 600;
            background: #dcfce7;
            color: #166534;
        }
        .badge-inactive {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 99px;
            font-size: 0.78rem;
            font-weight: 600;
            background: #fee2e2;
            color: #991b1b;
        }

        .action-btns { display: flex; gap: 8px; }
        .btn-edit, .btn-delete {
            padding: 6px 14px;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        .btn-edit { background: var(--primary); color: var(--primary-foreground); }
        .btn-delete { background: var(--destructive); color: var(--destructive-foreground); }
        .btn-edit:hover, .btn-delete:hover { opacity: 0.85; }

        /* Modal */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.45);
            z-index: 500;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: var(--card);
            border-radius: var(--radius-md);
            padding: 32px;
            width: 100%;
            max-width: 460px;
            box-shadow: var(--shadow-xl);
        }
        .modal h3 { margin-bottom: 20px; font-size: 1.1rem; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 0.85rem; font-weight: 500; margin-bottom: 6px; }
        .form-group input[type="text"],
        .form-group input[type="number"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            background: var(--input);
            color: var(--foreground);
            font-family: inherit;
            font-size: 0.9rem;
        }
        .form-group input:focus { outline: 2px solid var(--primary); outline-offset: 1px; }
        .checkbox-row { display: flex; align-items: center; gap: 10px; }
        .checkbox-row input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 24px; }
        .btn-primary {
            padding: 10px 22px;
            background: var(--primary);
            color: var(--primary-foreground);
            border: none;
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
        }
        .btn-secondary {
            padding: 10px 22px;
            background: var(--secondary);
            color: var(--secondary-foreground);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
        }
        .btn-primary:hover { opacity: 0.9; }
        .btn-secondary:hover { background: var(--muted); }

        .info-box {
            background: var(--accent);
            color: var(--accent-foreground);
            padding: 14px 18px;
            border-radius: var(--radius-sm);
            font-size: 0.875rem;
            margin-bottom: 24px;
            border-left: 4px solid var(--primary);
        }
        .info-box strong { display: block; margin-bottom: 4px; }
    </style>
</head>
<body>

<jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

<main class="main-content">
    <div class="dashboard-header">
        <h1>Delivery Rates</h1>
        <p>Manage per-vehicle-category delivery pricing. The weighted average is used at checkout.</p>
    </div>

    <div class="info-box">
        <strong>How the weighted average works</strong>
        Customer delivery fee = Base Fee + (Distance km × weighted rate), where the weighted rate is
        <code>SUM(cost_per_km × distribution_weight / 100)</code> across all active vehicle types.
        Distribution weights should sum to 100%.
    </div>

    <button class="btn-primary" onclick="openAddModal()" style="margin-bottom:8px;">+ Add Vehicle Type</button>

    <table class="rates-table">
        <thead>
            <tr>
                <th>Vehicle Type</th>
                <th>Base Fee (Rs)</th>
                <th>Cost / km (Rs)</th>
                <th>Distribution Weight (%)</th>
                <th>Max Orders</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if (rates != null) { for (DeliveryRate r : rates) { %>
            <tr>
                <td><strong><%= r.getVehicleType() %></strong></td>
                <td>Rs <%= String.format("%.2f", r.getBaseFee()) %></td>
                <td>Rs <%= String.format("%.2f", r.getCostPerKm()) %></td>
                <td><%= r.getDistributionWeight().stripTrailingZeros().toPlainString() %>%</td>
                <td><%= r.getMaxSimultaneousOrders() %></td>
                <td>
                    <% if (r.isActive()) { %>
                        <span class="badge-active">Active</span>
                    <% } else { %>
                        <span class="badge-inactive">Inactive</span>
                    <% } %>
                </td>
                <td>
                    <div class="action-btns">
                        <button class="btn-edit" onclick="openEditModal(<%= r.getRateId() %>, '<%= r.getVehicleType().replace("'", "\\'") %>', '<%= r.getBaseFee() %>', '<%= r.getCostPerKm() %>', '<%= r.getDistributionWeight() %>', <%= r.isActive() %>, <%= r.getMaxSimultaneousOrders() %>)">Edit</button>
                        <form method="post" action="${pageContext.request.contextPath}/admin/deliveryRates" style="margin:0;"
                              onsubmit="return confirm('Delete <%= r.getVehicleType().replace("'", "\\'") %>?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="rateId" value="<%= r.getRateId() %>">
                            <button type="submit" class="btn-delete">Delete</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } } %>
            <% if (rates == null || rates.isEmpty()) { %>
            <tr><td colspan="7" style="text-align:center; color: var(--muted-foreground); padding: 30px;">No delivery rates configured yet.</td></tr>
            <% } %>
        </tbody>
    </table>
</main>

<!-- Add / Edit Modal -->
<div class="modal-overlay" id="rateModal">
    <div class="modal">
        <h3 id="modal-title">Add Vehicle Type</h3>
        <form method="post" action="${pageContext.request.contextPath}/admin/deliveryRates" id="rateForm">
            <input type="hidden" name="action" id="form-action" value="add">
            <input type="hidden" name="rateId" id="form-rateId" value="">

            <div class="form-group">
                <label>Vehicle Type Name</label>
                <input type="text" name="vehicleType" id="form-vehicleType" placeholder="e.g. Bike, Three-wheel, Lorry" required>
            </div>
            <div class="form-group">
                <label>Base Fee (Rs)</label>
                <input type="number" name="baseFee" id="form-baseFee" placeholder="e.g. 100.00" step="0.01" min="0" required>
            </div>
            <div class="form-group">
                <label>Cost per km (Rs)</label>
                <input type="number" name="costPerKm" id="form-costPerKm" placeholder="e.g. 85.00" step="0.01" min="0" required>
            </div>
            <div class="form-group">
                <label>Distribution Weight (%)</label>
                <input type="number" name="distributionWeight" id="form-distributionWeight" placeholder="e.g. 50" step="0.01" min="0" max="100" required>
                <small style="color: var(--muted-foreground); font-size: 0.78rem;">All active weights should sum to 100%.</small>
            </div>
            <div class="form-group">
                <label>Max Simultaneous Orders</label>
                <input type="number" name="maxSimultaneousOrders" id="form-maxSimultaneousOrders" placeholder="e.g. 3" min="1" step="1" required>
                <small style="color: var(--muted-foreground); font-size: 0.78rem;">How many ACCEPTED + PICKED_UP orders a driver of this type can hold at once.</small>
            </div>
            <div class="form-group">
                <div class="checkbox-row">
                    <input type="checkbox" name="isActive" id="form-isActive" value="on" checked>
                    <label for="form-isActive" style="margin:0;">Active (used in checkout calculations)</label>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">Cancel</button>
                <button type="submit" class="btn-primary" id="modal-submit-btn">Add Rate</button>
            </div>
        </form>
    </div>
</div>
<script>
    function openAddModal() {
        document.getElementById('modal-title').textContent = 'Add Vehicle Type';
        document.getElementById('form-action').value = 'add';
        document.getElementById('form-rateId').value = '';
        document.getElementById('form-vehicleType').value = '';
        document.getElementById('form-baseFee').value = '';
        document.getElementById('form-costPerKm').value = '';
        document.getElementById('form-distributionWeight').value = '';
        document.getElementById('form-maxSimultaneousOrders').value = '';
        document.getElementById('form-isActive').checked = true;
        document.getElementById('modal-submit-btn').textContent = 'Add Rate';
        document.getElementById('rateModal').classList.add('open');
    }

    function openEditModal(rateId, vehicleType, baseFee, costPerKm, distributionWeight, isActive, maxOrders) {
        document.getElementById('modal-title').textContent = 'Edit Vehicle Type';
        document.getElementById('form-action').value = 'edit';
        document.getElementById('form-rateId').value = rateId;
        document.getElementById('form-vehicleType').value = vehicleType;
        document.getElementById('form-baseFee').value = baseFee;
        document.getElementById('form-costPerKm').value = costPerKm;
        document.getElementById('form-distributionWeight').value = distributionWeight;
        document.getElementById('form-maxSimultaneousOrders').value = maxOrders;
        document.getElementById('form-isActive').checked = isActive;
        document.getElementById('modal-submit-btn').textContent = 'Save Changes';
        document.getElementById('rateModal').classList.add('open');
    }

    function closeModal() {
        document.getElementById('rateModal').classList.remove('open');
    }

    // Close modal on overlay click
    document.getElementById('rateModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });
</script>
</body>
</html>
