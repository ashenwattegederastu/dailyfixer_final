<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null || !"admin".equalsIgnoreCase(user.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Review Driver Request | Daily Fixer Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .main-content {
            flex: 1;
            margin-left: 240px;
            padding: 40px 30px;
        }

        @media (max-width: 900px) {
            .main-content {
                margin-left: 0 !important;
                margin-top: 60px !important;
                padding-top: 40px !important;
            }
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 30px;
        }

        .detail-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--shadow-sm);
        }

        .detail-card.full-width {
            grid-column: 1 / -1;
        }

        .detail-card h3 {
            font-size: 1rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid var(--border);
        }

        .detail-row:last-child { border-bottom: none; }

        .detail-label {
            font-weight: 600;
            font-size: 0.85rem;
            color: var(--muted-foreground);
        }

        .detail-value {
            font-weight: 500;
            font-size: 0.9rem;
            color: var(--foreground);
            text-align: right;
            max-width: 60%;
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-PENDING { background: #fef3c7; color: #92400e; }
        .status-APPROVED { background: #d1fae5; color: #065f46; }
        .status-REJECTED { background: #fee2e2; color: #991b1b; }

        .doc-gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 16px;
        }

        .doc-item {
            border: 1px solid var(--border);
            border-radius: 12px;
            overflow: hidden;
            background: var(--card);
        }

        .doc-item img {
            width: 100%;
            height: 180px;
            object-fit: cover;
            cursor: pointer;
            transition: transform 0.2s;
        }

        .doc-item img:hover { transform: scale(1.02); }

        .doc-info {
            padding: 10px 12px;
        }

        .doc-type {
            font-weight: 700;
            font-size: 0.8rem;
            color: var(--primary);
            margin-bottom: 4px;
        }

        .profile-pic-container { text-align: center; margin-bottom: 16px; }

        .profile-pic {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid var(--primary);
        }

        .profile-pic-placeholder {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: var(--muted);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin: 0 auto;
            border: 3px solid var(--border);
        }

        .action-panel {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--shadow-sm);
            margin-top: 24px;
        }

        .action-panel h3 {
            font-size: 1rem;
            font-weight: 700;
            color: var(--foreground);
            margin-bottom: 16px;
        }

        .action-buttons {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-approve {
            padding: 10px 24px;
            background: #10b981;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-approve:hover { background: #059669; transform: translateY(-1px); }

        .btn-reject {
            padding: 10px 24px;
            background: #ef4444;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-reject:hover { background: #dc2626; transform: translateY(-1px); }

        .btn-back-link {
            display: inline-block;
            padding: 10px 24px;
            background: var(--secondary);
            color: var(--secondary-foreground);
            border: 1px solid var(--border);
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.9rem;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-back-link:hover { background: var(--accent); }

        .rejection-box {
            display: none;
            margin-top: 16px;
        }

        .rejection-box textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid var(--border);
            border-radius: 10px;
            font-family: inherit;
            font-size: 0.9rem;
            resize: vertical;
            min-height: 80px;
            background: var(--input);
            color: var(--foreground);
        }

        .rejection-box textarea:focus { outline: none; border-color: var(--primary); }

        .rejection-actions {
            display: flex;
            gap: 8px;
            margin-top: 10px;
        }

        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        .modal-overlay.active { display: flex; }

        .modal-overlay img {
            max-width: 90%;
            max-height: 90%;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
        }

        @media (max-width: 768px) {
            .detail-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

    <main class="main-content">
        <div class="dashboard-header">
            <h1>Review Driver Application</h1>
            <p>Request #${driverRequest.requestId} — ${driverRequest.fullName}</p>
        </div>

        <div class="detail-grid">
            <!-- Profile Summary -->
            <div class="detail-card">
                <h3>👤 Profile Summary</h3>

                <div class="profile-pic-container">
                    <c:choose>
                        <c:when test="${not empty driverRequest.profilePicturePath}">
                            <img src="${pageContext.request.contextPath}/${driverRequest.profilePicturePath}"
                                 alt="Profile" class="profile-pic" onclick="openModal(this.src)">
                        </c:when>
                        <c:otherwise>
                            <div class="profile-pic-placeholder">👤</div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="detail-row">
                    <span class="detail-label">Full Name</span>
                    <span class="detail-value">${driverRequest.fullName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Username</span>
                    <span class="detail-value">${driverRequest.username}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Email</span>
                    <span class="detail-value">${driverRequest.email}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Phone</span>
                    <span class="detail-value">${not empty driverRequest.phone ? driverRequest.phone : '—'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">City</span>
                    <span class="detail-value">${not empty driverRequest.city ? driverRequest.city : '—'}</span>
                </div>
            </div>

            <!-- Request Status -->
            <div class="detail-card">
                <h3>📋 Request Status</h3>

                <div class="detail-row">
                    <span class="detail-label">Status</span>
                    <span class="detail-value">
                        <span class="status-badge status-${driverRequest.status}">${driverRequest.status}</span>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Submitted</span>
                    <span class="detail-value">${driverRequest.submittedDate}</span>
                </div>
                <c:if test="${not empty driverRequest.reviewedDate}">
                    <div class="detail-row">
                        <span class="detail-label">Reviewed</span>
                        <span class="detail-value">${driverRequest.reviewedDate}</span>
                    </div>
                </c:if>
                <div class="detail-row">
                    <span class="detail-label">Policy Accepted</span>
                    <span class="detail-value">${driverRequest.policyAccepted ? '✅ Yes' : '❌ No'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">NIC Number</span>
                    <span class="detail-value"><code>${driverRequest.nicNumber}</code></span>
                </div>
            </div>

            <!-- NIC Documents -->
            <div class="detail-card full-width">
                <h3>🪪 NIC Documents</h3>
                <div class="doc-gallery">
                    <c:if test="${not empty driverRequest.nicFrontPath}">
                        <div class="doc-item">
                            <img src="${pageContext.request.contextPath}/${driverRequest.nicFrontPath}"
                                 alt="NIC Front" onclick="openModal(this.src)">
                            <div class="doc-info">
                                <div class="doc-type">NIC — Front Side</div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${not empty driverRequest.nicBackPath}">
                        <div class="doc-item">
                            <img src="${pageContext.request.contextPath}/${driverRequest.nicBackPath}"
                                 alt="NIC Back" onclick="openModal(this.src)">
                            <div class="doc-info">
                                <div class="doc-type">NIC — Back Side</div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${empty driverRequest.nicFrontPath && empty driverRequest.nicBackPath}">
                        <p style="color: var(--muted-foreground);">No NIC documents uploaded.</p>
                    </c:if>
                </div>
            </div>

            <!-- Driver's License -->
            <div class="detail-card full-width">
                <h3>🚗 Driver's License</h3>
                <div class="doc-gallery">
                    <c:if test="${not empty driverRequest.licenseFrontPath}">
                        <div class="doc-item">
                            <img src="${pageContext.request.contextPath}/${driverRequest.licenseFrontPath}"
                                 alt="License Front" onclick="openModal(this.src)">
                            <div class="doc-info">
                                <div class="doc-type">License — Front Side</div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${not empty driverRequest.licenseBackPath}">
                        <div class="doc-item">
                            <img src="${pageContext.request.contextPath}/${driverRequest.licenseBackPath}"
                                 alt="License Back" onclick="openModal(this.src)">
                            <div class="doc-info">
                                <div class="doc-type">License — Back Side</div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${empty driverRequest.licenseFrontPath && empty driverRequest.licenseBackPath}">
                        <p style="color: var(--muted-foreground);">No license documents uploaded.</p>
                    </c:if>
                </div>
            </div>

            <!-- Rejection Reason (if rejected) -->
            <c:if test="${driverRequest.status == 'REJECTED' && not empty driverRequest.rejectionReason}">
                <div class="detail-card full-width">
                    <h3>❌ Rejection Reason</h3>
                    <div style="background: var(--muted); padding: 16px; border-radius: 10px; font-size: 0.9rem; line-height: 1.6; color: var(--foreground); border-left: 4px solid #ef4444; padding-left: 16px;">
                        ${driverRequest.rejectionReason}
                    </div>
                </div>
            </c:if>
        </div>

        <!-- Action Panel (only for PENDING requests) -->
        <c:if test="${driverRequest.status == 'PENDING'}">
            <div class="action-panel">
                <h3>⚡ Take Action</h3>
                <div class="action-buttons">
                    <form action="${pageContext.request.contextPath}/admin/driver-requests" method="post" style="display:inline;">
                        <input type="hidden" name="requestId" value="${driverRequest.requestId}">
                        <input type="hidden" name="action" value="approve">
                        <button type="submit" class="btn-approve"
                                onclick="return confirm('Are you sure you want to approve this driver? They will be able to log in immediately.')">
                            ✓ Approve
                        </button>
                    </form>

                    <button type="button" class="btn-reject" onclick="showRejectionBox()">✕ Reject</button>

                    <a href="${pageContext.request.contextPath}/admin/driver-requests" class="btn-back-link">← Back to List</a>
                </div>

                <div class="rejection-box" id="rejectionBox">
                    <form action="${pageContext.request.contextPath}/admin/driver-requests" method="post">
                        <input type="hidden" name="requestId" value="${driverRequest.requestId}">
                        <input type="hidden" name="action" value="reject">
                        <textarea name="rejectionReason"
                                  placeholder="Provide a reason for rejection (optional but recommended)..."></textarea>
                        <div class="rejection-actions">
                            <button type="submit" class="btn-reject"
                                    onclick="return confirm('Are you sure you want to reject this driver request?')">
                                Confirm Rejection
                            </button>
                            <button type="button" class="btn-back-link" onclick="hideRejectionBox()" style="font-size:0.85rem;">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

        <!-- Back link for non-pending -->
        <c:if test="${driverRequest.status != 'PENDING'}">
            <div style="margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/admin/driver-requests" class="btn-back-link">← Back to List</a>
            </div>
        </c:if>
    </main>

    <!-- Image Modal -->
    <div class="modal-overlay" id="imageModal" onclick="closeModal()">
        <img id="modalImage" src="" alt="Document Image">
    </div>

    <script>
        function openModal(src) {
            document.getElementById('modalImage').src = src;
            document.getElementById('imageModal').classList.add('active');
        }

        function closeModal() {
            document.getElementById('imageModal').classList.remove('active');
        }

        function showRejectionBox() {
            document.getElementById('rejectionBox').style.display = 'block';
        }

        function hideRejectionBox() {
            document.getElementById('rejectionBox').style.display = 'none';
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeModal();
        });
    </script>
</body>
</html>
