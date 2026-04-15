<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    List<DeliveryAssignment> acceptedOrders = assignmentDAO.getByDriver(user.getUserId(), "ACCEPTED");
    List<DeliveryAssignment> pickedUpOrders = assignmentDAO.getByDriver(user.getUserId(), "PICKED_UP");

    // Merge both lists: ACCEPTED first, then PICKED_UP
    List<DeliveryAssignment> activeOrders = new ArrayList<>();
    activeOrders.addAll(acceptedOrders);
    activeOrders.addAll(pickedUpOrders);

    SimpleDateFormat dtFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Accepted Orders | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.container {
    flex: 1;
    margin-left: 240px;
    padding: 30px;
    background-color: var(--background);
}
.container h2 {
    font-size: 1.6em;
    margin-bottom: 20px;
    color: var(--foreground);
}

table {
    width: 100%;
    border-collapse: collapse;
    background: var(--card);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
}
thead { background-color: var(--muted); }
th, td {
    padding: 15px 12px;
    text-align: left;
    border-bottom: 1px solid var(--border);
}
th {
    font-weight: 600;
    color: var(--foreground);
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
td {
    color: var(--muted-foreground);
    font-weight: 500;
}
tbody tr:hover { background-color: var(--muted); }

.btn {
    padding: 8px 16px;
    border: none;
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    margin-right: 8px;
    margin-bottom: 6px;
    font-size: 0.85rem;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
}
.complete-btn {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
}
.navigate-btn {
    background: linear-gradient(135deg, #007bff, #0056b3);
    color: #fff;
}
.navigate-customer-btn {
    background: linear-gradient(135deg, #e67e22, #d35400);
    color: #fff;
}
.release-btn {
    background: linear-gradient(135deg, #dc3545, #b02a37);
    color: #fff;
}
.btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-sm);
    opacity: 0.9;
}

.status-badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: var(--radius-md);
    font-size: 0.8rem;
    font-weight: 600;
}
.status-accepted {
    background: #fff3cd;
    color: #856404;
}
.status-picked-up {
    background: #d4edda;
    color: #155724;
}
.waiting-label {
    display: block;
    font-size: 0.8rem;
    color: var(--muted-foreground);
    font-style: italic;
    margin-top: 4px;
}

/* PIN Entry Modal */
.pin-modal-overlay {
    display: none;
    position: fixed;
    top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.6);
    z-index: 1000;
    justify-content: center;
    align-items: center;
}
.pin-modal-overlay.active { display: flex; }
.pin-modal {
    background: var(--card);
    color: var(--card-foreground);
    padding: 30px;
    border-radius: var(--radius-lg);
    max-width: 380px;
    width: 90%;
    text-align: center;
    box-shadow: var(--shadow-xl);
    border: 1px solid var(--border);
}
.pin-modal h3 {
    color: var(--primary);
    margin-bottom: 8px;
    font-size: 1.3em;
}
.pin-modal p {
    color: var(--muted-foreground);
    font-size: 0.9rem;
    margin-bottom: 20px;
}
.pin-input {
    width: 100%;
    padding: 14px;
    font-size: 1.8rem;
    text-align: center;
    letter-spacing: 12px;
    font-weight: 700;
    border: 2px solid var(--border);
    border-radius: var(--radius-md);
    background: var(--input);
    color: var(--foreground);
    margin-bottom: 8px;
    outline: none;
    transition: border-color 0.2s;
}
.pin-input:focus { border-color: var(--primary); }
.pin-error {
    color: var(--destructive);
    font-size: 0.85rem;
    min-height: 1.2em;
    margin-bottom: 12px;
}
.pin-modal-btns {
    display: flex;
    gap: 10px;
    justify-content: center;
}
.pin-modal-btns .btn { min-width: 110px; }
.pin-cancel-btn {
    background: var(--secondary);
    color: var(--secondary-foreground);
    border: 1px solid var(--border);
}
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Active Deliveries</h2>

    <table>
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Phone</th>
                <th>Pickup</th>
                <th>Dropoff</th>
                <th>Delivery Fee</th>
                <th>Status</th>
                <th>Accepted At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if (activeOrders.isEmpty()) { %>
            <tr>
                <td colspan="9" style="text-align:center; padding:40px; color: var(--muted-foreground);">
                    No active deliveries. Accept a delivery from the Delivery Requests page.
                </td>
            </tr>
            <% } else {
                for (DeliveryAssignment a : activeOrders) {
                    String customerName = a.getCustomerName() != null ? a.getCustomerName() : "—";
                    String pickup       = a.getPickupAddress() != null ? a.getPickupAddress() : a.getStoreName();
                    String dropoff      = a.getDeliveryAddress() != null ? a.getDeliveryAddress() : "—";
                    String feeStr       = a.getDeliveryFeeEarned() != null
                                          ? String.format("LKR %.2f", a.getDeliveryFeeEarned()) : "LKR 0.00";
                    String buyerPhone   = a.getBuyerPhone() != null && !a.getBuyerPhone().isBlank() ? a.getBuyerPhone() : "—";
                    String acceptedAt   = a.getAssignedAt() != null ? dtFmt.format(a.getAssignedAt()) : "—";
                    boolean isPickedUp  = "PICKED_UP".equalsIgnoreCase(a.getStatus());

                    // Store coordinates for "Navigate to Store" (ACCEPTED phase)
                    double sLat = a.getStoreLat();
                    double sLng = a.getStoreLng();
                    boolean hasStoreCoords = sLat != 0 && sLng != 0;

                    // Customer coordinates for "Navigate to Customer" (PICKED_UP phase)
                    Double dLat = a.getDeliveryLat();
                    Double dLng = a.getDeliveryLng();
                    boolean hasDeliveryCoords = dLat != null && dLng != null && dLat != 0 && dLng != 0;
            %>
            <tr id="row-<%= a.getAssignmentId() %>">
                <td><%= a.getOrderId() %></td>
                <td><%= customerName %></td>
                <td><%= buyerPhone %></td>
                <td><%= pickup %></td>
                <td style="max-width: 180px; word-break: break-word;"><%= dropoff %></td>
                <td><strong><%= feeStr %></strong></td>
                <td>
                    <% if (isPickedUp) { %>
                        <span class="status-badge status-picked-up">Picked Up</span>
                    <% } else { %>
                        <span class="status-badge status-accepted">En Route to Store</span>
                    <% } %>
                </td>
                <td><%= acceptedAt %></td>
                <td>
                    <% if (!isPickedUp) { %>
                        <%-- Phase 1: Driver heading to store --%>
                        <% if (hasStoreCoords) { %>
                        <a class="btn navigate-btn"
                           href="https://www.google.com/maps/dir/?api=1&destination=<%= sLat %>,<%= sLng %>"
                           target="_blank" rel="noopener noreferrer">
                            Navigate to Store
                        </a>
                        <% } %>
                        <button class="btn release-btn"
                                onclick="openCancelAcceptedModal(<%= a.getAssignmentId() %>)">
                            Cancel Before Pickup
                        </button>
                        <span class="waiting-label">Waiting for store to confirm pickup</span>
                    <% } else { %>
                        <%-- Phase 2: Driver heading to customer --%>
                        <% if (hasDeliveryCoords) { %>
                        <a class="btn navigate-customer-btn"
                           href="https://www.google.com/maps/dir/?api=1&destination=<%= dLat %>,<%= dLng %>"
                           target="_blank" rel="noopener noreferrer">
                            Navigate to Customer
                        </a>
                        <% } %>
                        <button class="btn complete-btn"
                                onclick="completeDelivery(<%= a.getAssignmentId() %>, this)">
                            Mark Delivered
                        </button>
                        <button class="btn pin-cancel-btn"
                                onclick="openDoorstepModal(<%= a.getAssignmentId() %>)">
                            Buyer Unreachable Proof
                        </button>
                    <% } %>
                </td>
            </tr>
            <% } } %>
        </tbody>
    </table>
</main>

<!-- PIN Entry Modal -->
<div id="pinModal" class="pin-modal-overlay">
    <div class="pin-modal">
        <h3>Enter Delivery PIN</h3>
        <p>Ask the customer for their 6-digit delivery PIN to confirm handover.</p>
        <input type="text" id="pinInput" class="pin-input"
               maxlength="6" pattern="[0-9]*" inputmode="numeric"
               placeholder="------" autocomplete="off">
        <div id="pinError" class="pin-error"></div>
        <div class="pin-modal-btns">
            <button class="btn complete-btn" id="pinConfirmBtn" onclick="submitPin()">Confirm</button>
            <button class="btn pin-cancel-btn" onclick="closePinModal()">Cancel</button>
        </div>
    </div>
</div>

<!-- Doorstep Proof Modal -->
<div id="doorstepModal" class="pin-modal-overlay">
    <div class="pin-modal" style="max-width: 460px; text-align: left;">
        <h3>Doorstep Proof Completion</h3>
        <p>Upload two proof photos: package close-up and package with door/house context.</p>

        <label style="display:block; font-size:0.85rem; margin-bottom:6px; color: var(--foreground);">Photo 1 - Package close-up</label>
        <input type="file" id="proofPhotoPackage" accept="image/*" style="margin-bottom: 12px; width: 100%;">

        <label style="display:block; font-size:0.85rem; margin-bottom:6px; color: var(--foreground);">Photo 2 - Package and door/house</label>
        <input type="file" id="proofPhotoDoor" accept="image/*" style="margin-bottom: 12px; width: 100%;">

        <label style="display:block; font-size:0.85rem; margin-bottom:6px; color: var(--foreground);">Optional note</label>
        <textarea id="proofNote" rows="3" style="width: 100%; border: 1px solid var(--border); border-radius: var(--radius-md); padding: 8px; background: var(--input); color: var(--foreground);"></textarea>

        <div id="proofError" class="pin-error" style="margin-top: 10px;"></div>

        <div class="pin-modal-btns" style="margin-top: 12px;">
            <button class="btn complete-btn" id="proofSubmitBtn" onclick="submitDoorstepProof()">Submit Proof & Complete</button>
            <button class="btn pin-cancel-btn" onclick="closeDoorstepModal()">Cancel</button>
        </div>
    </div>
</div>

<!-- Cancel Accepted Modal -->
<div id="cancelAcceptedModal" class="pin-modal-overlay">
    <div class="pin-modal" style="max-width: 460px; text-align: left;">
        <h3>Cancel Accepted Delivery</h3>
        <p>Select a reason. The order will return to the delivery pool with no penalty.</p>

        <label style="display:block; font-size:0.85rem; margin-bottom:6px; color: var(--foreground);">Reason</label>
        <select id="cancelReasonCode" style="width: 100%; border: 1px solid var(--border); border-radius: var(--radius-md); padding: 10px; background: var(--input); color: var(--foreground); margin-bottom: 12px;">
            <option value="NOT_ENOUGH_SPACE">Not enough space</option>
            <option value="EMERGENCY">Emergency</option>
            <option value="VEHICLE_ISSUE">Vehicle issue</option>
            <option value="OTHER">Other</option>
        </select>

        <label style="display:block; font-size:0.85rem; margin-bottom:6px; color: var(--foreground);">Optional note</label>
        <textarea id="cancelReasonNote" rows="3" maxlength="400" style="width: 100%; border: 1px solid var(--border); border-radius: var(--radius-md); padding: 8px; background: var(--input); color: var(--foreground);"></textarea>

        <div id="cancelAcceptedError" class="pin-error" style="margin-top: 10px;"></div>

        <div class="pin-modal-btns" style="margin-top: 12px;">
            <button class="btn release-btn" id="cancelAcceptedSubmitBtn" onclick="submitCancelAccepted()">Cancel & Return to Pool</button>
            <button class="btn pin-cancel-btn" onclick="closeCancelAcceptedModal()">Close</button>
        </div>
    </div>
</div>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    let currentAssignmentId = null;
    let currentMarkBtn = null;
    let currentDoorstepAssignmentId = null;
    let currentCancelAcceptedAssignmentId = null;

    function completeDelivery(assignmentId, btn) {
        currentAssignmentId = assignmentId;
        currentMarkBtn = btn;
        document.getElementById('pinInput').value = '';
        document.getElementById('pinError').textContent = '';
        document.getElementById('pinConfirmBtn').disabled = false;
        document.getElementById('pinConfirmBtn').textContent = 'Confirm';
        document.getElementById('pinModal').classList.add('active');
        setTimeout(() => document.getElementById('pinInput').focus(), 100);
    }

    function closePinModal() {
        document.getElementById('pinModal').classList.remove('active');
        currentAssignmentId = null;
        currentMarkBtn = null;
    }

    function openDoorstepModal(assignmentId) {
        currentDoorstepAssignmentId = assignmentId;
        document.getElementById('proofPhotoPackage').value = '';
        document.getElementById('proofPhotoDoor').value = '';
        document.getElementById('proofNote').value = '';
        document.getElementById('proofError').textContent = '';
        document.getElementById('proofSubmitBtn').disabled = false;
        document.getElementById('proofSubmitBtn').textContent = 'Submit Proof & Complete';
        document.getElementById('doorstepModal').classList.add('active');
    }

    function closeDoorstepModal() {
        document.getElementById('doorstepModal').classList.remove('active');
        currentDoorstepAssignmentId = null;
    }

    function openCancelAcceptedModal(assignmentId) {
        currentCancelAcceptedAssignmentId = assignmentId;
        document.getElementById('cancelReasonCode').value = 'NOT_ENOUGH_SPACE';
        document.getElementById('cancelReasonNote').value = '';
        document.getElementById('cancelAcceptedError').textContent = '';
        document.getElementById('cancelAcceptedSubmitBtn').disabled = false;
        document.getElementById('cancelAcceptedSubmitBtn').textContent = 'Cancel & Return to Pool';
        document.getElementById('cancelAcceptedModal').classList.add('active');
    }

    function closeCancelAcceptedModal() {
        document.getElementById('cancelAcceptedModal').classList.remove('active');
        currentCancelAcceptedAssignmentId = null;
    }

    // Close on overlay click
    document.getElementById('pinModal').addEventListener('click', function(e) {
        if (e.target.id === 'pinModal') closePinModal();
    });

    document.getElementById('doorstepModal').addEventListener('click', function(e) {
        if (e.target.id === 'doorstepModal') closeDoorstepModal();
    });

    document.getElementById('cancelAcceptedModal').addEventListener('click', function(e) {
        if (e.target.id === 'cancelAcceptedModal') closeCancelAcceptedModal();
    });

    // Allow Enter key in PIN input
    document.getElementById('pinInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') submitPin();
    });

    // Only allow digits
    document.getElementById('pinInput').addEventListener('input', function(e) {
        this.value = this.value.replace(/\D/g, '');
    });

    function submitPin() {
        const pin = document.getElementById('pinInput').value.trim();
        const errorEl = document.getElementById('pinError');
        const confirmBtn = document.getElementById('pinConfirmBtn');

        if (pin.length !== 6) {
            errorEl.textContent = 'Please enter the full 6-digit PIN.';
            return;
        }

        errorEl.textContent = '';
        confirmBtn.disabled = true;
        confirmBtn.textContent = 'Verifying...';

        fetch(CONTEXT_PATH + '/driver/markDelivered', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'assignmentId=' + currentAssignmentId + '&deliveryPin=' + encodeURIComponent(pin)
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                closePinModal();
                const row = document.getElementById('row-' + currentAssignmentId);
                if (row) {
                    row.style.opacity = '0.4';
                    row.style.textDecoration = 'line-through';
                    if (currentMarkBtn) {
                        currentMarkBtn.textContent = 'Delivered';
                        currentMarkBtn.style.background = '#6c757d';
                        currentMarkBtn.disabled = true;
                    }
                    setTimeout(() => row.remove(), 1000);
                }
            } else {
                errorEl.textContent = data.message || 'Incorrect PIN. Please try again.';
                confirmBtn.disabled = false;
                confirmBtn.textContent = 'Confirm';
                document.getElementById('pinInput').value = '';
                document.getElementById('pinInput').focus();
            }
        })
        .catch(err => {
            errorEl.textContent = 'Error: ' + err.message;
            confirmBtn.disabled = false;
            confirmBtn.textContent = 'Confirm';
        });
    }

    function submitDoorstepProof() {
        const photoPackage = document.getElementById('proofPhotoPackage').files[0];
        const photoDoor = document.getElementById('proofPhotoDoor').files[0];
        const note = document.getElementById('proofNote').value.trim();
        const errorEl = document.getElementById('proofError');
        const submitBtn = document.getElementById('proofSubmitBtn');

        if (!photoPackage || !photoDoor) {
            errorEl.textContent = 'Both proof photos are required.';
            return;
        }

        errorEl.textContent = '';
        submitBtn.disabled = true;
        submitBtn.textContent = 'Submitting...';

        const formData = new FormData();
        formData.append('assignmentId', String(currentDoorstepAssignmentId));
        formData.append('photoPackage', photoPackage);
        formData.append('photoDoorContext', photoDoor);
        formData.append('note', note);

        fetch(CONTEXT_PATH + '/driver/markDeliveredDoorstep', {
            method: 'POST',
            body: formData
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                const row = document.getElementById('row-' + currentDoorstepAssignmentId);
                if (row) {
                    row.style.opacity = '0.4';
                    row.style.textDecoration = 'line-through';
                    setTimeout(() => row.remove(), 1000);
                }
                closeDoorstepModal();
            } else {
                errorEl.textContent = data.message || 'Could not complete delivery with proof.';
                submitBtn.disabled = false;
                submitBtn.textContent = 'Submit Proof & Complete';
            }
        })
        .catch(err => {
            errorEl.textContent = 'Error: ' + err.message;
            submitBtn.disabled = false;
            submitBtn.textContent = 'Submit Proof & Complete';
        });
    }

    function submitCancelAccepted() {
        const reasonCode = document.getElementById('cancelReasonCode').value;
        const reasonNote = document.getElementById('cancelReasonNote').value.trim();
        const errorEl = document.getElementById('cancelAcceptedError');
        const submitBtn = document.getElementById('cancelAcceptedSubmitBtn');

        submitBtn.disabled = true;
        submitBtn.textContent = 'Cancelling...';
        errorEl.textContent = '';

        fetch(CONTEXT_PATH + '/driver/cancelAccepted', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'assignmentId=' + encodeURIComponent(currentCancelAcceptedAssignmentId) +
                  '&reasonCode=' + encodeURIComponent(reasonCode) +
                  '&reasonNote=' + encodeURIComponent(reasonNote)
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                const row = document.getElementById('row-' + currentCancelAcceptedAssignmentId);
                closeCancelAcceptedModal();
                if (row) {
                    row.style.opacity = '0.4';
                    row.style.textDecoration = 'line-through';
                    setTimeout(() => row.remove(), 700);
                }
            } else {
                errorEl.textContent = data.message || 'Could not cancel this accepted delivery.';
                submitBtn.disabled = false;
                submitBtn.textContent = 'Cancel & Return to Pool';
            }
        })
        .catch(err => {
            errorEl.textContent = 'Error: ' + err.message;
            submitBtn.disabled = false;
            submitBtn.textContent = 'Cancel & Return to Pool';
        });
    }
</script>

</body>
</html>
