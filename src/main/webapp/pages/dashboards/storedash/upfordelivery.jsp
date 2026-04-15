<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Store" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.dao.StoreDAO" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="com.dailyfixer.dao.DeliveryRateDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");

    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    // Get store for this user
    StoreDAO storeDAO = new StoreDAO();
    Store currentStore = storeDAO.getStoreByUsername(user.getUsername());
    int storeId = currentStore != null ? currentStore.getStoreId() : 0;

    // Load delivery assignments for this store
    DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    List<DeliveryAssignment> allAssignments = storeId > 0 ? assignmentDAO.getByStore(storeId) : new ArrayList<>();

    DeliveryRateDAO deliveryRateDAO = new DeliveryRateDAO();
    List<String> vehicleTypes = deliveryRateDAO.getActiveVehicleTypes();

    // Show active (PENDING / ACCEPTED / PICKED_UP) and recently cancelled (timed-out) assignments
    List<DeliveryAssignment> assignments = new ArrayList<>();
    for (DeliveryAssignment a : allAssignments) {
        String s = a.getStatus() != null ? a.getStatus().trim().toUpperCase() : "";
        if ("PENDING".equals(s) || "ACCEPTED".equals(s) || "PICKED_UP".equals(s) || "CANCELLED".equals(s)) {
            assignments.add(a);
        }
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>


<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Up for Delivery | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-tables.css">

</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp" class="active">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>Orders Up for Delivery</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Dispatched</th>
                <th>Vehicle Type</th>
                <th>Driver</th>
                <th>Delivery Fee</th>
                <th>Status</th>
                <th>Delivery Address</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if (assignments.isEmpty()) { %>
                <tr>
                    <td colspan="9" style="text-align: center; padding: 30px; color: var(--muted-foreground);">
                        No orders currently awaiting or in delivery.
                    </td>
                </tr>
            <% } else {
                for (DeliveryAssignment a : assignments) {
                    String statusVal = a.getStatus() != null ? a.getStatus().trim().toUpperCase() : "PENDING";
                    String displayStatus;
                    String statusClass;
                    if ("ACCEPTED".equals(statusVal)) {
                        displayStatus = "Driver Assigned";
                        statusClass = "processing";
                    } else if ("PICKED_UP".equals(statusVal)) {
                        displayStatus = "Picked Up – Out for Delivery";
                        statusClass = "out-delivery";
                    } else if ("CANCELLED".equals(statusVal)) {
                        displayStatus = "Timed Out – Refund Initiated";
                        statusClass = "cancelled";
                    } else {
                        displayStatus = "Awaiting Driver";
                        statusClass = "pending";
                    }
                    String driverName = a.getDriverName() != null && !a.getDriverName().isBlank()
                                        ? a.getDriverName() : "—";
                    String customerName = a.getCustomerName() != null && !a.getCustomerName().isBlank()
                                          ? a.getCustomerName() : "—";
                    String createdDate = a.getCreatedAt() != null ? dateFormat.format(a.getCreatedAt()) : "—";
                    String deliveryAddr = a.getDeliveryAddress() != null && !a.getDeliveryAddress().isBlank()
                                          ? a.getDeliveryAddress() : "—";
                    String feeStr = a.getDeliveryFeeEarned() != null
                                    ? String.format("LKR %.2f", a.getDeliveryFeeEarned()) : "LKR 0.00";
                        String currentVehicleTypeEscaped = (a.getRequiredVehicleType() != null ? a.getRequiredVehicleType() : "")
                            .replace("\\", "\\\\")
                            .replace("'", "\\'");
            %>
                <tr>
                    <td><%= a.getOrderId() %></td>
                    <td><%= customerName %></td>
                    <td><%= createdDate %></td>
                    <td><%= a.getRequiredVehicleType() %></td>
                    <td><%= driverName %></td>
                    <td><%= feeStr %></td>
                    <td><span class="status <%= statusClass %>"></span> <%= displayStatus %></td>
                    <td style="max-width: 200px; word-break: break-word;"><%= deliveryAddr %></td>
                    <td>
                        <% if ("ACCEPTED".equals(statusVal)) { %>
                        <button class="btn pickup-btn"
                                onclick="markPickedUp(<%= a.getAssignmentId() %>, this)"
                                style="padding:8px 16px; border:none; border-radius:6px; cursor:pointer; font-weight:600; font-size:0.85rem; background:linear-gradient(135deg,#007bff,#0056b3); color:#fff; transition:all 0.2s;">
                            Mark Picked Up
                        </button>
                        <% } else if ("PENDING".equals(statusVal)) { %>
                        <button class="btn"
                                onclick="openVehicleTypeModal(<%= a.getAssignmentId() %>, '<%= currentVehicleTypeEscaped %>')"
                                style="padding:8px 16px; border:none; border-radius:6px; cursor:pointer; font-weight:600; font-size:0.85rem; background:linear-gradient(135deg,#6f42c1,#59359a); color:#fff; transition:all 0.2s;">
                            Change Vehicle
                        </button>
                        <% } else if ("PICKED_UP".equals(statusVal)) { %>
                        <span style="color: var(--muted-foreground); font-style: italic; font-size: 0.85rem;">Out for delivery</span>
                        <% } else { %>
                        <span style="color: var(--muted-foreground);">—</span>
                        <% } %>
                    </td>
                </tr>
            <% } } %>
        </tbody>
    </table>
</main>

<div id="vehicleTypeModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:1100; align-items:center; justify-content:center;">
    <div style="background: var(--card); color: var(--card-foreground); border:1px solid var(--border); border-radius:12px; width:min(92vw,460px); padding:20px; box-shadow: var(--shadow-xl);">
        <h3 style="margin:0 0 8px; color: var(--foreground);">Change Vehicle Type</h3>
        <p style="margin:0 0 14px; color: var(--muted-foreground); font-size:0.92rem;">
            You can change vehicle type only before any driver accepts the order.
        </p>

        <label for="vehicleTypeSelect" style="display:block; margin-bottom:6px; font-size:0.85rem;">Vehicle Type</label>
        <select id="vehicleTypeSelect" style="width:100%; padding:10px; border:1px solid var(--border); border-radius:8px; background: var(--input); color: var(--foreground);">
            <% for (String vt : vehicleTypes) { %>
            <option value="<%= vt %>"><%= vt %></option>
            <% } %>
        </select>

        <div id="vehicleTypeErr" style="min-height:1.2em; margin-top:10px; color:#dc3545; font-size:0.85rem;"></div>

        <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:14px;">
            <button type="button" onclick="closeVehicleTypeModal()" style="padding:8px 14px; border:1px solid var(--border); background: var(--secondary); color: var(--secondary-foreground); border-radius:8px; cursor:pointer;">Cancel</button>
            <button type="button" id="saveVehicleTypeBtn" onclick="submitVehicleTypeChange()" style="padding:8px 14px; border:none; background:linear-gradient(135deg,#198754,#157347); color:#fff; border-radius:8px; cursor:pointer;">Save</button>
        </div>
    </div>
</div>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    let currentVehicleAssignmentId = null;

    function markPickedUp(assignmentId, btn) {
        if (!confirm('Confirm the driver has picked up this order?')) return;
        btn.disabled = true;
        btn.textContent = 'Updating...';

        fetch(CONTEXT_PATH + '/store/markPickedUp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'assignmentId=' + assignmentId
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                btn.textContent = 'Picked Up';
                btn.style.background = '#6c757d';
                btn.style.cursor = 'default';
                setTimeout(() => window.location.reload(), 800);
            } else {
                alert(data.message || 'Failed to mark as picked up.');
                btn.disabled = false;
                btn.textContent = 'Mark Picked Up';
            }
        })
        .catch(err => {
            alert('Error: ' + err.message);
            btn.disabled = false;
            btn.textContent = 'Mark Picked Up';
        });
    }

    function openVehicleTypeModal(assignmentId, currentVehicleType) {
        currentVehicleAssignmentId = assignmentId;
        const modal = document.getElementById('vehicleTypeModal');
        const select = document.getElementById('vehicleTypeSelect');
        const err = document.getElementById('vehicleTypeErr');
        const saveBtn = document.getElementById('saveVehicleTypeBtn');

        if (select && currentVehicleType) {
            select.value = currentVehicleType;
        }

        err.textContent = '';
        saveBtn.disabled = false;
        saveBtn.textContent = 'Save';
        modal.style.display = 'flex';
    }

    function closeVehicleTypeModal() {
        document.getElementById('vehicleTypeModal').style.display = 'none';
        currentVehicleAssignmentId = null;
    }

    function submitVehicleTypeChange() {
        const select = document.getElementById('vehicleTypeSelect');
        const err = document.getElementById('vehicleTypeErr');
        const saveBtn = document.getElementById('saveVehicleTypeBtn');
        const selectedType = select.value;

        if (!selectedType) {
            err.textContent = 'Please select a vehicle type.';
            return;
        }

        saveBtn.disabled = true;
        saveBtn.textContent = 'Saving...';
        err.textContent = '';

        fetch(CONTEXT_PATH + '/store/updateDeliveryVehicleType', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'assignmentId=' + encodeURIComponent(currentVehicleAssignmentId) +
                  '&vehicleType=' + encodeURIComponent(selectedType)
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                closeVehicleTypeModal();
                window.location.reload();
            } else {
                err.textContent = data.message || 'Could not change vehicle type.';
                saveBtn.disabled = false;
                saveBtn.textContent = 'Save';
            }
        })
        .catch(errObj => {
            err.textContent = 'Error: ' + errObj.message;
            saveBtn.disabled = false;
            saveBtn.textContent = 'Save';
        });
    }

    document.getElementById('vehicleTypeModal').addEventListener('click', function(e) {
        if (e.target.id === 'vehicleTypeModal') {
            closeVehicleTypeModal();
        }
    });
</script>
</body>
</html>
