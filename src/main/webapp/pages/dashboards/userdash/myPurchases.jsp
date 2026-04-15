<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.OrderItem" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<% User user = (User) session.getAttribute("currentUser");
    if (user == null ||
            user.getRole() == null || !"user".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp"
        );
        return;
    } %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Purchases | Daily Fixer</title>
    <link
            href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
            rel="stylesheet">


    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        /* Order Cards Grid */
        .orders-grid {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /* Order Card */
        .order-card {
            background: var(--card);
            color: var(--card-foreground);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            padding: 24px;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .order-card:hover {
            border-color: var(--primary);
            box-shadow: 0 4px 12px color-mix(in srgb, var(--primary) 15%, transparent);
        }

        .order-header-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .order-date-no {
            color: var(--muted-foreground);
            font-size: 0.9em;
            margin-top: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .order-total-top {
            font-size: 1em;
            color: var(--foreground);
        }
        .order-total-top strong {
            font-size: 1.1em;
            color: var(--primary);
        }

        .order-separator {
            border-top: 1px solid var(--border);
            margin: 16px 0;
        }

        .order-items {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        /* Product Item */
        .product-item {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .product-image {
            width: 60px;
            height: 60px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            object-fit: cover;
            background: var(--muted);
            flex-shrink: 0;
        }

        .product-placeholder {
            width: 60px;
            height: 60px;
            border-radius: var(--radius-sm);
            background: var(--input);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--muted-foreground);
            font-size: 1.5em;
            flex-shrink: 0;
        }

        .product-details {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .product-name {
            font-weight: 600;
            color: var(--foreground);
            margin-bottom: 4px;
            font-size: 0.95em;
        }

        .product-meta {
            color: var(--muted-foreground);
            font-size: 0.85em;
        }

        .order-actions {
            margin-top: 16px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }



        /* Status Badges */
        .status-badge {
            padding: 6px 14px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 600;
        }

        .status-pending { background: #fef08a; color: #854d0e; }
        .status-paid { background: #d1fae5; color: #065f46; }
        .status-processing { background: #bfdbfe; color: #1e40af; }
        .status-out_for_delivery { background: #fde68a; color: #92400e; }
        .status-delivered { background: #10b981; color: #ffffff; }
        .status-store_accepted { background: #e9d5ff; color: #6b21a8; }
        .status-cancelled { background: #ef4444; color: #ffffff; }
        .status-refund_pending { background: #fed7aa; color: #9a3412; }
        .status-refunded { background: #818cf8; color: #ffffff; }

        /* Modal */
        .modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }
        .modal-overlay.active { display: flex; }
        .modal-content {
            background: var(--card);
            border-radius: var(--radius-lg);
            padding: 32px;
            text-align: center;
            max-width: 400px;
            width: 90%;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border);
        }
        .modal-title {
            font-size: 1.25em;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .delivery-pin-code {
            font-size: 2em;
            font-weight: 800;
            letter-spacing: 4px;
            color: var(--primary);
            font-family: 'IBM Plex Mono', monospace;
            margin: 24px 0;
            padding: 16px;
            background: var(--muted);
            border-radius: var(--radius-md);
        }

        .empty-state {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 40px;
            text-align: center;
        }

        .empty-icon {
            font-size: 4em;
            margin-bottom: 20px;
        }

        @media (max-width: 768px) {
            .order-date-no {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }
        }

        /* Order details modal */
        .order-details-modal-content {
            max-width: 640px;
            width: 92%;
            max-height: 90vh;
            overflow-y: auto;
            text-align: left;
            padding: 24px 28px;
        }
        .order-details-modal-content .modal-title { margin-bottom: 16px; }
        .order-detail-inner { font-size: 0.92em; color: var(--foreground); }
        .od-section { margin-bottom: 18px; }
        .od-section h4 {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--muted-foreground);
            margin: 0 0 8px 0;
            font-weight: 600;
        }
        .od-row { display: flex; gap: 8px; margin-bottom: 6px; flex-wrap: wrap; }
        .od-label { color: var(--muted-foreground); min-width: 120px; }
        .od-items-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.88em;
            margin-top: 6px;
        }
        .od-items-table th, .od-items-table td {
            padding: 10px 8px;
            border-bottom: 1px solid var(--border);
            text-align: left;
        }
        .od-items-table th { color: var(--muted-foreground); font-weight: 600; font-size: 0.8rem; }
        .od-items-table td:last-child, .od-items-table th:last-child { text-align: right; }
        .od-totals { margin-top: 12px; border-top: 1px solid var(--border); padding-top: 12px; }
        .od-totals .od-row { justify-content: space-between; }
        .od-totals .od-grand { font-weight: 700; font-size: 1.05em; color: var(--primary); }
        .modal-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }
        .modal-header-row .close-btn {
            background: none;
            border: none;
            font-size: 1.75rem;
            line-height: 1;
            cursor: pointer;
            color: var(--muted-foreground);
            padding: 0 4px;
        }
        .modal-header-row .close-btn:hover { color: var(--foreground); }
    </style>
</head>
<body>
<jsp:include page="sidebar.jsp" />
<main class="dashboard-container">
    <div class="page-header">
        <h2>My Purchases</h2>
        <p>Track your orders and view purchase history</p>
    </div>
    <c:choose>
        <c:when test="${not empty orders}">
            <div class="orders-grid">
                <c:forEach var="order" items="${orders}" varStatus="orderLoop">
                    <c:set var="statusClass" value="status-${fn:toLowerCase(order.status)}"/>
                    <div class="order-card">
                        <div class="order-header-info">
                            <div>
                                <c:choose>
                                    <c:when test="${order.status == 'PENDING'}"><span class="status-badge ${statusClass}">Pending Payment</span></c:when>
                                    <c:when test="${order.status == 'PAID'}"><span class="status-badge ${statusClass}">Paid</span></c:when>
                                    <c:when test="${order.status == 'STORE_ACCEPTED'}"><span class="status-badge ${statusClass}">Dispatching</span></c:when>
                                    <c:when test="${order.status == 'PROCESSING'}"><span class="status-badge ${statusClass}">Processing</span></c:when>
                                    <c:when test="${order.status == 'OUT_FOR_DELIVERY'}"><span class="status-badge ${statusClass}">Out for Delivery</span></c:when>
                                    <c:when test="${order.status == 'DELIVERED'}"><span class="status-badge ${statusClass}">Delivered</span></c:when>
                                    <c:when test="${order.status == 'CANCELLED'}"><span class="status-badge ${statusClass}">Cancelled</span></c:when>
                                    <c:when test="${order.status == 'REFUND_PENDING'}"><span class="status-badge ${statusClass}">Refund Pending</span></c:when>
                                    <c:when test="${order.status == 'REFUNDED'}"><span class="status-badge ${statusClass}">Refunded</span></c:when>
                                    <c:otherwise><span class="status-badge ${statusClass}">${order.status}</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="order-date-no">
                            <span>
                                <c:if test="${order.createdAt != null}">
                                    <fmt:formatDate value="${order.createdAt}" pattern="MM/dd/yyyy hh:mm a"/>
                                </c:if>
                                &nbsp;|&nbsp; Order No: ${order.orderId}
                            </span>
                            <span class="order-total-top">Total: <strong>${order.currency}${order.formattedAmount}</strong></span>
                        </div>

                        <div class="order-separator"></div>

                        <div class="order-items">
                            <c:choose>
                                <c:when test="${not empty orderItemsMap[order.orderId]}">
                                    <c:forEach var="item" items="${orderItemsMap[order.orderId]}">
                                        <div class="product-item">
                                            <div class="product-placeholder">📦</div>
                                            <div class="product-details">
                                                <div class="product-name">${item.productName}</div>
                                                <div class="product-meta">${order.currency}${item.unitPrice} &times; ${item.quantity}</div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="product-item">
                                        <div class="product-placeholder">📦</div>
                                        <div class="product-details">
                                            <div class="product-name">${order.productName}</div>
                                            <div class="product-meta">${order.currency}${order.formattedAmount}</div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="order-actions">
                            <c:if test="${not empty storeDetailsMap[order.orderId]}">
                                <button type="button" class="action-btn btn-view" 
                                        data-store-name="${fn:escapeXml(storeDetailsMap[order.orderId].storeName)}"
                                        data-store-phone="${fn:escapeXml(storeDetailsMap[order.orderId].phone)}"
                                        data-store-email="${fn:escapeXml(storeDetailsMap[order.orderId].email)}"
                                        data-store-address="${fn:escapeXml(storeDetailsMap[order.orderId].address)}"
                                        onclick="showStoreModal(this)">Store Details</button>
                            </c:if>
                            <c:if test="${not empty driverDetailsMap[order.orderId]}">
                                <button type="button" class="action-btn btn-view"
                                        data-driver-name="${fn:escapeXml(driverDetailsMap[order.orderId].name)}"
                                        data-driver-phone="${fn:escapeXml(driverDetailsMap[order.orderId].phone)}"
                                        data-driver-picture="${fn:escapeXml(driverDetailsMap[order.orderId].picture)}"
                                        data-completion-method="${fn:escapeXml(driverDetailsMap[order.orderId].completionMethod)}"
                                        onclick="showDriverModal(this)">Driver Details</button>
                            </c:if>
                            <c:if test="${not empty deliveryProofMap[order.orderId]}">
                                <button type="button" class="action-btn btn-view"
                                        data-photo-package="${fn:escapeXml(deliveryProofMap[order.orderId].photoPackage)}"
                                        data-photo-door="${fn:escapeXml(deliveryProofMap[order.orderId].photoDoor)}"
                                        data-proof-note="${fn:escapeXml(deliveryProofMap[order.orderId].note)}"
                                        onclick="showProofModal(this)">View Delivery Proof</button>
                            </c:if>
                            <c:if test="${not empty deliveryPinMap[order.orderId]}">
                                <button type="button" class="action-btn btn-view" onclick="showPinModal('${deliveryPinMap[order.orderId]}')">View Delivery PIN</button>
                            </c:if>
                            <c:if test="${order.status == 'DELIVERED'}">
                                <c:forEach var="item" items="${orderItemsForReviewMap[order.orderId]}">
                                    <button type="button" class="action-btn btn-resolve" 
                                            onclick="showReviewModal(${item.productId}, '${fn:escapeXml(item.productName)}')">
                                        Write Review
                                    </button>
                                </c:forEach>
                            </c:if>
                            <button type="button" class="action-btn btn-view" onclick="showOrderDetailsModal(${orderLoop.index})">Order Details</button>
                        </div>
                    </div>

                    <%-- Full order detail clone for modal --%>
                    <template id="order-detail-tpl-${orderLoop.index}">
                        <div class="order-detail-inner">
                            <div class="od-section">
                                <h4>Status</h4>
                                <c:choose>
                                    <c:when test="${order.status == 'PENDING'}"><span class="status-badge ${statusClass}">Pending Payment</span></c:when>
                                    <c:when test="${order.status == 'PAID'}"><span class="status-badge ${statusClass}">Paid</span></c:when>
                                    <c:when test="${order.status == 'STORE_ACCEPTED'}"><span class="status-badge ${statusClass}">Dispatching</span></c:when>
                                    <c:when test="${order.status == 'PROCESSING'}"><span class="status-badge ${statusClass}">Processing</span></c:when>
                                    <c:when test="${order.status == 'OUT_FOR_DELIVERY'}"><span class="status-badge ${statusClass}">Out for Delivery</span></c:when>
                                    <c:when test="${order.status == 'DELIVERED'}"><span class="status-badge ${statusClass}">Delivered</span></c:when>
                                    <c:when test="${order.status == 'CANCELLED'}"><span class="status-badge ${statusClass}">Cancelled</span></c:when>
                                    <c:when test="${order.status == 'REFUND_PENDING'}"><span class="status-badge ${statusClass}">Refund Pending</span></c:when>
                                    <c:when test="${order.status == 'REFUNDED'}"><span class="status-badge ${statusClass}">Refunded</span></c:when>
                                    <c:otherwise><span class="status-badge ${statusClass}">${fn:escapeXml(order.status)}</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="od-section">
                                <h4>Order</h4>
                                <div class="od-row"><span class="od-label">Order ID</span><span><code style="font-size:0.9em;">${fn:escapeXml(order.orderId)}</code></span></div>
                                <div class="od-row"><span class="od-label">Placed</span><span>
                                    <c:if test="${order.createdAt != null}"><fmt:formatDate value="${order.createdAt}" pattern="MMMM d, yyyy 'at' h:mm a"/></c:if>
                                    <c:if test="${order.createdAt == null}">—</c:if>
                                </span></div>
                                <c:if test="${not empty order.payherePaymentId}">
                                    <div class="od-row"><span class="od-label">PayHere payment ID</span><span><code style="font-size:0.85em;">${fn:escapeXml(order.payherePaymentId)}</code></span></div>
                                </c:if>
                                <c:if test="${not empty storeDetailsMap[order.orderId]}">
                                    <div class="od-row"><span class="od-label">Store</span><span>${fn:escapeXml(storeDetailsMap[order.orderId].storeName)}</span></div>
                                </c:if>
                            </div>
                            <div class="od-section">
                                <h4>Delivery &amp; contact</h4>
                                <div class="od-row"><span class="od-label">Name</span><span>${fn:escapeXml(order.fullName)}</span></div>
                                <div class="od-row"><span class="od-label">Email</span><span>${fn:escapeXml(order.email)}</span></div>
                                <div class="od-row"><span class="od-label">Phone</span><span>${fn:escapeXml(order.phone)}</span></div>
                                <div class="od-row"><span class="od-label">Address</span><span>${fn:escapeXml(order.address)}</span></div>
                                <div class="od-row"><span class="od-label">City</span><span>${fn:escapeXml(order.city)}</span></div>
                                <div class="od-row"><span class="od-label">Doorstep drop consent</span><span>${order.doorstepDropConsent ? 'Yes' : 'No'}</span></div>
                            </div>
                            <div class="od-section">
                                <h4>Items</h4>
                                <c:choose>
                                    <c:when test="${not empty orderItemsMap[order.orderId]}">
                                        <table class="od-items-table">
                                            <thead><tr><th>Product</th><th>Qty</th><th>Line total</th></tr></thead>
                                            <tbody>
                                                <c:forEach var="line" items="${orderItemsMap[order.orderId]}">
                                                    <tr>
                                                        <td>${fn:escapeXml(line.productName)}</td>
                                                        <td>${line.quantity}</td>
                                                        <td>${order.currency}<fmt:formatNumber value="${line.totalPrice}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:when>
                                    <c:otherwise>
                                        <p style="color:var(--muted-foreground);margin:0;">${fn:escapeXml(order.productName)}</p>
                                    </c:otherwise>
                                </c:choose>
                                <div class="od-totals">
                                    <c:if test="${not empty order.deliveryFee}">
                                        <div class="od-row"><span>Delivery fee</span><span>${order.currency}<fmt:formatNumber value="${order.deliveryFee}" minFractionDigits="2" maxFractionDigits="2"/></span></div>
                                    </c:if>
                                    <div class="od-row od-grand"><span>Order total</span><span>${order.currency}${order.formattedAmount}</span></div>
                                </div>
                            </div>
                            <c:if test="${order.status == 'REFUNDED' || order.status == 'REFUND_PENDING'}">
                                <div class="od-section">
                                    <h4>Refund</h4>
                                    <c:if test="${not empty order.refundReason}"><div class="od-row"><span class="od-label">Reason</span><span>${fn:escapeXml(order.refundReason)}</span></div></c:if>
                                    <c:if test="${not empty order.refundNumber}"><div class="od-row"><span class="od-label">Reference</span><span><code>${fn:escapeXml(order.refundNumber)}</code></span></div></c:if>
                                </div>
                            </c:if>
                        </div>
                    </template>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="empty-icon">🛒</div>
                <h3>No Orders Yet</h3>
                <p>You haven't made any purchases yet. Start exploring
                    our stores to find amazing products!</p>
                <a href="${pageContext.request.contextPath}/stores"
                   class="btn-primary">Browse Stores</a>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<div class="modal-overlay" id="pinModal">
    <div class="modal-content">
        <div class="modal-title">Delivery PIN</div>
        <p style="color: var(--muted-foreground); font-size: 0.9em;">Share this PIN with the driver upon delivery</p>
        <div class="delivery-pin-code" id="pinDisplay"></div>
        <button class="btn-secondary" onclick="closePinModal()" style="width: 100%;">Close</button>
    </div>
</div>

<div class="modal-overlay" id="driverModal">
    <div class="modal-content">
        <div class="modal-title" id="driverModalTitle">Driver Details</div>
        <p style="color: var(--muted-foreground); font-size: 0.9em; margin-bottom: 16px;">Contact your delivery driver if needed</p>

        <div style="display: flex; justify-content: center; margin-bottom: 16px;">
            <img id="driverModalPicture" alt="Driver profile" style="width: 76px; height: 76px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border); background: var(--muted);" />
        </div>

        <div style="text-align: left; background: var(--muted); padding: 16px; border-radius: var(--radius-md); margin-bottom: 24px;">
            <div style="margin-bottom: 8px;"><strong>Name:</strong> <span id="driverModalName"></span></div>
            <div style="margin-bottom: 8px;"><strong>Phone:</strong> <span id="driverModalPhone"></span></div>
            <div><strong>Completion Method:</strong> <span id="driverModalMethod"></span></div>
        </div>

        <button class="btn-secondary" onclick="closeDriverModal()" style="width: 100%;">Close</button>
    </div>
</div>

<div class="modal-overlay" id="proofModal">
    <div class="modal-content" style="max-width: 700px; text-align: left;">
        <div class="modal-title" style="margin-bottom: 16px;">Doorstep Delivery Proof</div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
            <div>
                <div style="font-size: 0.85em; color: var(--muted-foreground); margin-bottom: 6px;">Photo 1 - Package close-up</div>
                <img id="proofModalPackage" alt="Package proof" style="width: 100%; border-radius: var(--radius-md); border: 1px solid var(--border); object-fit: cover;" />
            </div>
            <div>
                <div style="font-size: 0.85em; color: var(--muted-foreground); margin-bottom: 6px;">Photo 2 - Package and door/house</div>
                <img id="proofModalDoor" alt="Doorstep proof" style="width: 100%; border-radius: var(--radius-md); border: 1px solid var(--border); object-fit: cover;" />
            </div>
        </div>

        <div id="proofModalNoteBox" style="background: var(--muted); border: 1px solid var(--border); border-radius: var(--radius-md); padding: 10px; margin-bottom: 16px; display: none;">
            <strong>Driver note:</strong> <span id="proofModalNote"></span>
        </div>

        <button class="btn-secondary" onclick="closeProofModal()" style="width: 100%;">Close</button>
    </div>
</div>

<div class="modal-overlay" id="storeModal">
    <div class="modal-content">
        <div class="modal-title" id="storeModalTitle">Store Details</div>
        <p style="color: var(--muted-foreground); font-size: 0.9em; margin-bottom: 24px;">Contact the store for inquiries about your order</p>
        
        <div style="text-align: left; background: var(--muted); padding: 16px; border-radius: var(--radius-md); margin-bottom: 24px;">
            <div style="margin-bottom: 8px;"><strong>Email:</strong> <span id="storeModalEmail"></span></div>
            <div style="margin-bottom: 8px;"><strong>Phone:</strong> <span id="storeModalPhone"></span></div>
            <div><strong>Address:</strong> <span id="storeModalAddress"></span></div>
        </div>

        <button class="btn-secondary" onclick="closeStoreModal()" style="width: 100%;">Close</button>
    </div>
</div>

<div class="modal-overlay" id="orderDetailsModal">
    <div class="modal-content order-details-modal-content" onclick="event.stopPropagation()">
        <div class="modal-header-row">
            <h3 class="modal-title" style="margin:0;">Order details</h3>
            <button type="button" class="close-btn" onclick="closeOrderDetailsModal()" aria-label="Close">&times;</button>
        </div>
        <div id="orderDetailsModalBody"></div>
        <button type="button" class="btn-secondary" style="width:100%;margin-top:16px;" onclick="closeOrderDetailsModal()">Close</button>
    </div>
</div>

<div class="modal-overlay" id="reviewModal">
    <div class="modal-content" style="max-width: 600px; padding: 32px;">
        <div class="modal-title" id="reviewModalTitle" style="margin-bottom: 24px;">Write a Review</div>
        <form id="reviewFormModal" style="display: flex; flex-direction: column; gap: 20px;">
            <input type="hidden" id="reviewProductId" name="productId" value="">
            
            <div style="display: flex; flex-direction: column; gap: 8px;">
                <label style="font-weight: 600; color: var(--foreground);">Your Rating (Click stars to rate)</label>
                <div id="ratingStarsModal" style="display: flex; gap: 10px; font-size: 2em; cursor: pointer;">
                    <span class="review-star-modal" data-rating="1" style="cursor: pointer;">☆</span>
                    <span class="review-star-modal" data-rating="2" style="cursor: pointer;">☆</span>
                    <span class="review-star-modal" data-rating="3" style="cursor: pointer;">☆</span>
                    <span class="review-star-modal" data-rating="4" style="cursor: pointer;">☆</span>
                    <span class="review-star-modal" data-rating="5" style="cursor: pointer;">☆</span>
                </div>
                <input type="hidden" id="reviewRatingValue" name="rating" value="">
                <span id="reviewRatingText" style="color: var(--muted-foreground); font-weight: 500; font-size: 0.9em; margin-top: 4px;">Click stars to rate</span>
            </div>

            <div style="display: flex; flex-direction: column; gap: 8px;">
                <label for="reviewCommentModal" style="font-weight: 600; color: var(--foreground);">Your Review</label>
                <textarea id="reviewCommentModal" name="comment" style="padding: 12px; border: 1px solid var(--border); border-radius: var(--radius-md); background: var(--input); color: var(--foreground); font-family: inherit; resize: vertical; min-height: 120px;" placeholder="Share your experience with this product..." required></textarea>
            </div>

            <div id="reviewMessageModal" style="margin-top: 8px; font-size: 0.9em;"></div>

            <div style="display: flex; gap: 12px; justify-content: flex-end;">
                <button type="button" class="btn-secondary" onclick="closeReviewModal()" style="padding: 10px 20px;">Cancel</button>
                <button type="submit" class="btn-primary" style="padding: 10px 20px;">Submit Review</button>
            </div>
        </form>
    </div>
</div>

<style>
    .review-star-modal {
        color: var(--muted);
        transition: color 0.2s ease;
    }
    .review-star-modal:hover,
    .review-star-modal.active {
        color: var(--chart-3);
    }
</style>

<script>
    const contextPath = "${pageContext.request.contextPath}";

    function showOrderDetailsModal(index) {
        const tpl = document.getElementById('order-detail-tpl-' + index);
        const body = document.getElementById('orderDetailsModalBody');
        if (!tpl || !body) return;
        body.innerHTML = '';
        body.appendChild(tpl.content.cloneNode(true));
        document.getElementById('orderDetailsModal').classList.add('active');
    }
    function closeOrderDetailsModal() {
        const el = document.getElementById('orderDetailsModal');
        if (el) el.classList.remove('active');
    }
    const orderDetailsModalEl = document.getElementById('orderDetailsModal');
    if (orderDetailsModalEl) {
        orderDetailsModalEl.addEventListener('click', function (e) {
            if (e.target.id === 'orderDetailsModal') closeOrderDetailsModal();
        });
    }

    function showPinModal(pin) {
        document.getElementById('pinDisplay').innerText = pin;
        document.getElementById('pinModal').classList.add('active');
    }
    function closePinModal() {
        document.getElementById('pinModal').classList.remove('active');
    }
    
    function showStoreModal(btn) {
        document.getElementById('storeModalTitle').innerText = btn.getAttribute('data-store-name');
        document.getElementById('storeModalEmail').innerText = btn.getAttribute('data-store-email');
        document.getElementById('storeModalPhone').innerText = btn.getAttribute('data-store-phone');
        document.getElementById('storeModalAddress').innerText = btn.getAttribute('data-store-address');
        document.getElementById('storeModal').classList.add('active');
    }
    function closeStoreModal() {
        document.getElementById('storeModal').classList.remove('active');
    }

    function resolveImagePath(rawPath) {
        if (!rawPath || rawPath.trim().length === 0) {
            return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='96' height='96' viewBox='0 0 96 96'%3E%3Crect width='96' height='96' rx='48' fill='%23e5e7eb'/%3E%3Ccircle cx='48' cy='36' r='16' fill='%239ca3af'/%3E%3Cpath d='M18 82c4-16 16-24 30-24s26 8 30 24' fill='%239ca3af'/%3E%3C/svg%3E";
        }
        if (rawPath.startsWith('http://') || rawPath.startsWith('https://') || rawPath.startsWith('data:')) {
            return rawPath;
        }
        return contextPath + '/' + rawPath.replace(/^\/+/, '');
    }

    function showDriverModal(btn) {
        const methodRaw = btn.getAttribute('data-completion-method') || '';
        let methodText = 'PIN';
        if (methodRaw === 'DOORSTEP_PHOTO') {
            methodText = 'Doorstep Proof';
        }

        document.getElementById('driverModalTitle').innerText = 'Driver Details';
        document.getElementById('driverModalName').innerText = btn.getAttribute('data-driver-name') || 'Delivery Driver';
        document.getElementById('driverModalPhone').innerText = btn.getAttribute('data-driver-phone') || 'No phone';
        document.getElementById('driverModalMethod').innerText = methodText;
        document.getElementById('driverModalPicture').src = resolveImagePath(btn.getAttribute('data-driver-picture'));
        document.getElementById('driverModal').classList.add('active');
    }

    function closeDriverModal() {
        document.getElementById('driverModal').classList.remove('active');
    }

    function showProofModal(btn) {
        document.getElementById('proofModalPackage').src = resolveImagePath(btn.getAttribute('data-photo-package'));
        document.getElementById('proofModalDoor').src = resolveImagePath(btn.getAttribute('data-photo-door'));

        const note = btn.getAttribute('data-proof-note') || '';
        const noteBox = document.getElementById('proofModalNoteBox');
        if (note.trim().length > 0) {
            document.getElementById('proofModalNote').innerText = note;
            noteBox.style.display = 'block';
        } else {
            document.getElementById('proofModalNote').innerText = '';
            noteBox.style.display = 'none';
        }

        document.getElementById('proofModal').classList.add('active');
    }

    function closeProofModal() {
        document.getElementById('proofModal').classList.remove('active');
    }

    function showReviewModal(productId, productName) {
        document.getElementById('reviewProductId').value = productId;
        document.getElementById('reviewModalTitle').innerText = 'Write a Review for ' + productName;
        document.getElementById('reviewModal').classList.add('active');
        resetReviewForm();
    }

    function closeReviewModal() {
        document.getElementById('reviewModal').classList.remove('active');
        resetReviewForm();
    }

    function resetReviewForm() {
        document.getElementById('reviewFormModal').reset();
        document.getElementById('reviewRatingValue').value = '';
        document.getElementById('reviewRatingText').innerText = 'Click stars to rate';
        document.querySelectorAll('.review-star-modal').forEach(star => {
            star.classList.remove('active');
            star.textContent = '☆';
            star.style.color = 'var(--muted)';
        });
    }

    function highlightStarsModal(rating) {
        document.querySelectorAll('.review-star-modal').forEach((star, index) => {
            if (index < rating) {
                star.textContent = '★';
                star.style.color = 'var(--chart-3)';
                star.classList.add('active');
            } else {
                star.textContent = '☆';
                star.style.color = 'var(--muted)';
                star.classList.remove('active');
            }
        });
    }

    document.querySelectorAll('.review-star-modal').forEach((star, index) => {
        star.addEventListener('mouseenter', () => {
            highlightStarsModal(index + 1);
        });

        star.addEventListener('click', () => {
            const rating = parseInt(star.getAttribute('data-rating'), 10);
            document.getElementById('reviewRatingValue').value = rating;
            document.getElementById('reviewRatingText').innerText = rating + ' out of 5 stars';
            highlightStarsModal(rating);
        });
    });

    const ratingStarsContainer = document.getElementById('ratingStarsModal');
    if (ratingStarsContainer) {
        ratingStarsContainer.addEventListener('mouseleave', () => {
            const selectedRating = parseInt(document.getElementById('reviewRatingValue').value, 10) || 0;
            highlightStarsModal(selectedRating);
        });
    }

    document.getElementById('reviewFormModal').addEventListener('submit', (e) => {
        e.preventDefault();

        const productId = document.getElementById('reviewProductId').value;
        const rating = document.getElementById('reviewRatingValue').value;
        const comment = document.getElementById('reviewCommentModal').value;
        const messageDiv = document.getElementById('reviewMessageModal');

        if (!rating || parseInt(rating, 10) < 1 || parseInt(rating, 10) > 5) {
            messageDiv.innerHTML = '<p style="color: var(--destructive);">Please select a rating (1-5 stars) before submitting.</p>';
            return;
        }

        if (!comment || comment.trim().length === 0) {
            messageDiv.innerHTML = '<p style="color: var(--destructive);">Please write a review before submitting.</p>';
            return;
        }

        messageDiv.innerHTML = '<p style="color: var(--muted-foreground);">Submitting review...</p>';

        const params = new URLSearchParams();
        params.append('productId', productId);
        params.append('rating', rating);
        params.append('comment', comment);

        fetch(contextPath + '/productReview', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    messageDiv.innerHTML = '<p style="color: var(--chart-1);">✓ Review submitted successfully!</p>';
                    setTimeout(() => {
                        closeReviewModal();
                        messageDiv.innerHTML = '';
                    }, 1500);
                } else {
                    messageDiv.innerHTML = '<p style="color: var(--destructive);">Error: ' + (data.error || 'Failed to submit review') + '</p>';
                }
            })
            .catch(err => {
                messageDiv.innerHTML = '<p style="color: var(--destructive);">Error submitting review: ' + err.message + '</p>';
            });
    });
</script>
</body>
</html>