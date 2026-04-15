<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.dao.DeliveryRateDAO" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.OrderItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Get the currently logged-in user from session
    User user = (User) session.getAttribute("currentUser");

    // Redirect to login if no user or role is set
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    // Check role: allow only admin or store
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    // Fetch paid orders from database for this store only (excluding DELIVERED and STORE_ACCEPTED)
    OrderDAO orderDAO = new OrderDAO();
    String storeUsername = user.getUsername(); // Get logged-in store's username

    // Get orders filtered by store
    List<Order> allOrders = orderDAO.getOrdersByStatusAndStore("PAID", storeUsername);

    // Filter out DELIVERED and STORE_ACCEPTED orders
    List<Order> orders = new ArrayList<>();
    if (allOrders != null) {
        for (Order order : allOrders) {
            String status = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "";
            if (!"DELIVERED".equals(status) && !"STORE_ACCEPTED".equals(status)) {
                orders.add(order);
            }
        }
    }

    // Load active vehicle types for the dispatch modal
    DeliveryRateDAO deliveryRateDAO = new DeliveryRateDAO();
    List<String> vehicleTypes = deliveryRateDAO.getActiveVehicleTypes();

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>


<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Orders | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-tables.css">

<style>
/* Page-specific: Status dropdown, Vehicle modal, Order details modal */
.btn-delivery,
.delivery-btn {
  background-color: var(--destructive);
  color: var(--destructive-foreground);
}

.vehicle-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.6);
  justify-content: center;
  align-items: center;
  z-index: 500;
}

.vehicle-modal .modal-content {
  background: var(--card);
  color: var(--card-foreground);
  padding: 30px;
  border-radius: var(--radius-lg);
  max-width: 400px;
  width: 90%;
  text-align: center;
  box-shadow: var(--shadow-xl);
  border: 1px solid var(--border);
  position: relative;
}

.vehicle-modal h3 {
  color: var(--primary);
  margin-bottom: 20px;
}

.vehicle-modal .vehicle-options {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 20px;
}

.vehicle-modal .vehicle-btn {
  padding: 12px;
  border: 2px solid var(--border);
  border-radius: var(--radius-md);
  background: var(--card);
  color: var(--foreground);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.vehicle-modal .vehicle-icon-img {
  width: 48px;
  height: 48px;
  object-fit: contain;
}

.vehicle-modal .vehicle-btn:hover {
  border-color: var(--primary);
  background: var(--accent);
  color: var(--accent-foreground);
}

.vehicle-modal .vehicle-btn.selected {
  border-color: var(--primary);
  background: var(--muted);
}

.vehicle-modal .modal-buttons {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.vehicle-modal .modal-btn {
  padding: 10px 20px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.vehicle-modal .confirm-btn {
  background: var(--primary);
  color: var(--primary-foreground);
}

.vehicle-modal .confirm-btn:hover {
  opacity: 0.8;
}

.vehicle-modal .cancel-btn {
  background: var(--secondary);
  color: var(--secondary-foreground);
  border: 1px solid var(--border);
}

.vehicle-modal .cancel-btn:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.close-btn {
  position: absolute;
  top: 15px;
  right: 20px;
  font-size: 1.5em;
  font-weight: bold;
  cursor: pointer;
  color: var(--muted-foreground);
  transition: color 0.2s ease;
}

.close-btn:hover {
  color: var(--foreground);
}

.order-details-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  justify-content: center;
  align-items: center;
}

.order-details-modal.active {
  display: flex;
}

.order-details-content {
  background: var(--card);
  color: var(--card-foreground);
  border-radius: var(--radius-lg);
  padding: 30px;
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--shadow-2xl);
  position: relative;
  border: 1px solid var(--border);
}

.order-details-content h3 {
  color: var(--primary);
  margin-bottom: 20px;
  font-size: 1.5em;
  border-bottom: 2px solid var(--border);
  padding-bottom: 10px;
}

.order-details-content .detail-section {
  margin-bottom: 20px;
}

.order-details-content .detail-section h4 {
  font-size: 0.9em;
  font-weight: 600;
  margin-bottom: 5px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--muted-foreground);
}

.order-details-content .detail-section p {
  color: var(--foreground);
  font-size: 1em;
  margin: 0;
  padding: 8px 0;
  word-wrap: break-word;
}

.order-details-content .detail-row {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 15px;
  padding: 10px 0;
  border-bottom: 1px solid var(--border);
}

.order-details-content .detail-row:last-child {
  border-bottom: none;
}

.order-details-content .detail-label {
  font-weight: 600;
  color: var(--muted-foreground);
}

.order-details-content .detail-value {
  color: var(--foreground);
}

.order-details-content .close-order-modal {
  position: absolute;
  top: 15px;
  right: 20px;
  font-size: 1.5em;
  font-weight: bold;
  cursor: pointer;
  color: var(--muted-foreground);
  background: none;
  border: none;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.2s ease;
}

.order-details-content .close-order-modal:hover {
  color: var(--primary);
}
</style>
</head>
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <div style="display: flex; align-items: center; gap: 10px;">
        <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle dark mode">🌙 Dark</button>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp" class="active">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
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
    <h2>Orders</h2>
    
    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Status</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% if (orders == null || orders.isEmpty()) { %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 30px; color: #666;">
                        No paid orders found. Orders will appear here after successful payment.
                    </td>
                </tr>
            <% } else { 
                int orderIndex = 1;
                for (Order order : orders) {
                    String orderId = order.getOrderId();
                    String customerName = order.getFirstName() + (order.getLastName() != null && !order.getLastName().isEmpty() ? " " + order.getLastName() : "");
                    String orderDate = order.getCreatedAt() != null ? dateFormat.format(order.getCreatedAt()) : "N/A";
                    // Get actual status from order, default to PENDING if not set
                    String dbStatus = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "PENDING";
                    String displayStatus = "Pending";
                    String statusClass = "pending";
                    
                    // Map database status to display status and CSS class
                    if ("PENDING".equals(dbStatus)) {
                        displayStatus = "Pending";
                        statusClass = "pending";
                    } else if ("PROCESSING".equals(dbStatus)) {
                        displayStatus = "Processing";
                        statusClass = "processing";
                    } else if ("OUT_FOR_DELIVERY".equals(dbStatus) || "OUT FOR DELIVERY".equals(dbStatus)) {
                        displayStatus = "Out for Delivery";
                        statusClass = "out-delivery";
                    } else if ("DELIVERED".equals(dbStatus)) {
                        displayStatus = "Delivered";
                        statusClass = "delivered";
                    } else if ("STORE_ACCEPTED".equals(dbStatus)) {
                        displayStatus = "Dispatched";
                        statusClass = "processing";
                    } else if ("PAID".equals(dbStatus)) {
                        // If status is PAID, show as Pending (initial state for store)
                        displayStatus = "Pending";
                        statusClass = "pending";
                    }
                    
                    String totalAmount = String.format("LKR %.2f", order.getAmount());
                    // Escape single quotes for JavaScript
                    String escapedCustomerName = customerName.replace("'", "\\'");
                    String escapedAddress = (order.getAddress() != null ? order.getAddress() : "").replace("'", "\\'");
                    String escapedCity = (order.getCity() != null ? order.getCity() : "").replace("'", "\\'");
                    String escapedPhone = (order.getPhone() != null ? order.getPhone() : "").replace("'", "\\'");
                    String escapedEmail = (order.getEmail() != null ? order.getEmail() : "").replace("'", "\\'");
                    
                    // Get order items for this order
                    List<OrderItem> orderItems = orderDAO.getOrderItemsByOrderId(orderId);
                    // Build JSON string for order items
                    StringBuilder orderItemsJson = new StringBuilder();
                    if (orderItems != null && !orderItems.isEmpty()) {
                        orderItemsJson.append("[");
                        for (int i = 0; i < orderItems.size(); i++) {
                            OrderItem item = orderItems.get(i);
                            if (i > 0) orderItemsJson.append(",");
                            orderItemsJson.append("{");
                            // Escape JSON string properly
                            String productNameEscaped = item.getProductName() != null ? 
                                item.getProductName()
                                    .replace("\\", "\\\\")
                                    .replace("\"", "\\\"")
                                    .replace("\n", "\\n")
                                    .replace("\r", "\\r")
                                    .replace("\t", "\\t") : "";
                            orderItemsJson.append("\"productName\":\"").append(productNameEscaped).append("\",");
                            orderItemsJson.append("\"quantity\":").append(item.getQuantity()).append(",");
                            orderItemsJson.append("\"unitPrice\":").append(item.getUnitPrice()).append(",");
                            orderItemsJson.append("\"totalPrice\":").append(item.getTotalPrice());
                            orderItemsJson.append("}");
                        }
                        orderItemsJson.append("]");
                    } else {
                        orderItemsJson.append("[]");
                    }
                    String orderItemsJsonStr = orderItemsJson.toString();
            %>
                <tr>
                    <td><%= orderId %></td>
                    <td><%= customerName %></td>
                    <td><%= orderDate %></td>
                    <td id="status-<%= orderIndex %>"><span class="status <%= statusClass %>"></span><%= displayStatus %></td>
                    <td><%= totalAmount %></td>
                    <td>
                        <button class="btn view-btn" 
                                data-order-id="<%= orderId %>"
                                data-customer-name="<%= escapedCustomerName %>"
                                data-total="<%= totalAmount %>"
                                data-address="<%= escapedAddress %>"
                                data-city="<%= escapedCity %>"
                                data-phone="<%= escapedPhone %>"
                                data-email="<%= escapedEmail %>"
                                data-order-date="<%= orderDate %>"
                                data-order-items='<%= orderItemsJsonStr %>'
                                onclick="showOrderDetailsModalFromButton(this)">View Details</button>
                        <button class="btn delivery-btn" onclick="showVehicleModal('<%= orderId %>')">Ready to Deliver</button>
                    </td>
                </tr>
            <% 
                    orderIndex++;
                }
            } %>
        </tbody>
    </table>
</main>

<!-- Order Details Modal -->
<div id="orderDetailsModal" class="order-details-modal">
    <div class="order-details-content">
        <button class="close-order-modal" onclick="closeOrderDetailsModal()">&times;</button>
        <h3>Order Details</h3>
        
        <div class="detail-section">
            <div class="detail-row">
                <span class="detail-label">Order ID:</span>
                <span class="detail-value" id="modal-order-id">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Order Date:</span>
                <span class="detail-value" id="modal-order-date">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Customer Name:</span>
                <span class="detail-value" id="modal-customer-name">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Phone:</span>
                <span class="detail-value" id="modal-phone">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Email:</span>
                <span class="detail-value" id="modal-email">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Address:</span>
                <span class="detail-value" id="modal-address">-</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">City:</span>
                <span class="detail-value" id="modal-city">-</span>
            </div>
            <div class="detail-row" style="flex-direction: column; align-items: flex-start;">
                <span class="detail-label" style="margin-bottom: 10px;">Products:</span>
                <div id="modal-products" style="width: 100%; display: flex; flex-direction: column; gap: 8px;">
                    <span>-</span>
                </div>
            </div>
            <div class="detail-row">
                <span class="detail-label">Total Amount:</span>
                <span class="detail-value" id="modal-total" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462); font-size: 1.1em;">-</span>
            </div>
        </div>
    </div>
</div>

<!-- Vehicle Selection Modal -->
<div id="vehicleModal" class="vehicle-modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeVehicleModal()">&times;</span>
        <h3>Select Delivery Vehicle</h3>
        <p>Choose the type of vehicle needed for delivery:</p>
        
        <div class="vehicle-options" id="vehicleOptions">
            <% if (vehicleTypes != null && !vehicleTypes.isEmpty()) {
                for (String vt : vehicleTypes) { 
                    String vtLower = vt.toLowerCase().trim();
                    String iconFileName = "lorry.svg"; // Fallback
                    if (vtLower.contains("bike")) {
                        iconFileName = "bike.svg";
                    } else if (vtLower.contains("three") || vtLower.contains("tuk")) {
                        iconFileName = "threewheel.svg";
                    } else if (vtLower.contains("lorry")) {
                        iconFileName = "lorry.svg";
                    }
            %>
            <button class="vehicle-btn" onclick="selectVehicle('<%= vt.replace("'", "\\'") %>', this)">
                <img src="${pageContext.request.contextPath}/assets/images/icons/vehicles/<%= iconFileName %>" alt="<%= vt %>" class="vehicle-icon-img">
                <span><%= vt %></span>
            </button>
            <% } } else { %>
            <p style="color: var(--muted-foreground); font-size: 0.9em;">No vehicle types configured. Please ask admin to add delivery rates.</p>
            <% } %>
        </div>
        
        <div class="modal-buttons">
            <button class="modal-btn confirm-btn" onclick="confirmDelivery()">Confirm</button>
            <button class="modal-btn cancel-btn" onclick="closeVehicleModal()">Cancel</button>
        </div>
    </div>
</div>

<script>
let selectedOrderId = '';
let selectedVehicle = '';

function showOrderDetailsModalFromButton(button) {
    // Get data from button attributes
    const orderId = button.getAttribute('data-order-id') || '-';
    const customerName = button.getAttribute('data-customer-name') || '-';
    const total = button.getAttribute('data-total') || '-';
    const address = button.getAttribute('data-address') || '-';
    const city = button.getAttribute('data-city') || '-';
    const phone = button.getAttribute('data-phone') || '-';
    const email = button.getAttribute('data-email') || '-';
    const orderDate = button.getAttribute('data-order-date') || '-';
    const orderItemsJson = button.getAttribute('data-order-items') || '[]';
    
    // Parse order items JSON
    let orderItems = [];
    try {
        orderItems = JSON.parse(orderItemsJson);
    } catch (e) {
        console.error('Error parsing order items JSON:', e);
        orderItems = [];
    }
    
    // Populate modal with order details
    document.getElementById('modal-order-id').textContent = orderId;
    document.getElementById('modal-order-date').textContent = orderDate;
    document.getElementById('modal-customer-name').textContent = customerName;
    document.getElementById('modal-phone').textContent = phone;
    document.getElementById('modal-email').textContent = email;
    document.getElementById('modal-address').textContent = address;
    document.getElementById('modal-city').textContent = city;
    
    // Display order items with variant information
    const productsContainer = document.getElementById('modal-products');
    if (orderItems && Array.isArray(orderItems) && orderItems.length > 0) {
        let html = '';
        orderItems.forEach(item => {
            html += '<div style="padding: 8px; background: #f9f9f9; border-radius: 6px; border-left: 3px solid var(--accent); margin-bottom: 8px;">';
            html += '<div style="font-weight: 600; color: var(--text-dark);">' + escapeHtml(item.productName || '-') + '</div>';
            html += '<div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 4px;">';
            html += 'Quantity: ' + (item.quantity || 0) + ' × LKR ' + parseFloat(item.unitPrice || 0).toFixed(2) + ' = LKR ' + parseFloat(item.totalPrice || 0).toFixed(2);
            html += '</div>';
            html += '</div>';
        });
        productsContainer.innerHTML = html;
    } else {
        productsContainer.innerHTML = '<span>-</span>';
    }
    
    document.getElementById('modal-total').textContent = total;
    
    // Show modal
    document.getElementById('orderDetailsModal').classList.add('active');
}

// Keep the old function for backward compatibility
function showOrderDetailsModal(orderId, customerName, total, address, city, phone, email, orderDate, orderItems) {
    // Populate modal with order details
    document.getElementById('modal-order-id').textContent = orderId || '-';
    document.getElementById('modal-order-date').textContent = orderDate || '-';
    document.getElementById('modal-customer-name').textContent = customerName || '-';
    document.getElementById('modal-phone').textContent = phone || '-';
    document.getElementById('modal-email').textContent = email || '-';
    document.getElementById('modal-address').textContent = address || '-';
    document.getElementById('modal-city').textContent = city || '-';
    
    // Display order items with variant information
    const productsContainer = document.getElementById('modal-products');
    if (orderItems && Array.isArray(orderItems) && orderItems.length > 0) {
        let html = '';
        orderItems.forEach(item => {
            html += '<div style="padding: 8px; background: #f9f9f9; border-radius: 6px; border-left: 3px solid var(--accent); margin-bottom: 8px;">';
            html += '<div style="font-weight: 600; color: var(--text-dark);">' + escapeHtml(item.productName || '-') + '</div>';
            html += '<div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 4px;">';
            html += 'Quantity: ' + (item.quantity || 0) + ' × LKR ' + parseFloat(item.unitPrice || 0).toFixed(2) + ' = LKR ' + parseFloat(item.totalPrice || 0).toFixed(2);
            html += '</div>';
            html += '</div>';
        });
        productsContainer.innerHTML = html;
    } else {
        productsContainer.innerHTML = '<span>-</span>';
    }
    
    document.getElementById('modal-total').textContent = total || '-';
    
    // Show modal
    document.getElementById('orderDetailsModal').classList.add('active');
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function closeOrderDetailsModal() {
    document.getElementById('orderDetailsModal').classList.remove('active');
}

// Close modal on outside click
document.getElementById('orderDetailsModal').addEventListener('click', e => {
    if(e.target.id === 'orderDetailsModal') {
        closeOrderDetailsModal();
    }
});

function showVehicleModal(orderId) {
    selectedOrderId = orderId;
    document.getElementById('vehicleModal').style.display = 'flex';
}

function closeVehicleModal() {
    document.getElementById('vehicleModal').style.display = 'none';
    selectedVehicle = '';
    document.querySelectorAll('.vehicle-btn').forEach(btn => btn.classList.remove('selected'));
    const confirmBtn = document.querySelector('.confirm-btn');
    if (confirmBtn) { confirmBtn.disabled = false; confirmBtn.textContent = 'Confirm'; }
}

function selectVehicle(vehicle, btn) {
    selectedVehicle = vehicle;
    // Reset all buttons
    document.querySelectorAll('.vehicle-btn').forEach(b => b.classList.remove('selected'));
    // Highlight selected
    if (btn) btn.classList.add('selected');
}

function confirmDelivery() {
    if (!selectedVehicle) {
        alert('Please select a delivery vehicle type.');
        return;
    }

    const confirmBtn = document.querySelector('.confirm-btn');
    confirmBtn.disabled = true;
    confirmBtn.textContent = 'Dispatching...';

    const contextPath = '<%= request.getContextPath() %>';
    fetch(contextPath + '/store/dispatch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'orderId=' + encodeURIComponent(selectedOrderId) +
              '&vehicleType=' + encodeURIComponent(selectedVehicle)
    })
    .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(data => {
        if (data.success) {
            closeVehicleModal();
            // Remove the dispatched row from the table
            document.querySelectorAll('tr').forEach(row => {
                const cells = row.querySelectorAll('td');
                if (cells.length > 0 && cells[0].textContent.trim() === selectedOrderId) {
                    row.remove();
                }
            });
        } else {
            alert('Failed to dispatch: ' + (data.message || 'Unknown error'));
            confirmBtn.disabled = false;
            confirmBtn.textContent = 'Confirm';
        }
    })
    .catch(err => {
        alert('Error dispatching order: ' + err.message);
        confirmBtn.disabled = false;
        confirmBtn.textContent = 'Confirm';
    });
}

// Close modal on outside click
document.getElementById('vehicleModal').addEventListener('click', e => {
    if(e.target.id === 'vehicleModal') {
        closeVehicleModal();
    }
});
</script>
</body>
</html>
