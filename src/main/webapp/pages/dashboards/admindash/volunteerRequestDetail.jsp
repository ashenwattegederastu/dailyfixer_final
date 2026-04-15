<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"admin".equalsIgnoreCase(user.getRole().trim())) { response.sendRedirect(request.getContextPath()
                + "/pages/authentication/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <title>Review Volunteer Request | Daily Fixer Admin</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    <style>
                        /* Main content offset for new sidebar */
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

                        .detail-row:last-child {
                            border-bottom: none;
                        }

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

                        .status-PENDING {
                            background: #fef3c7;
                            color: #92400e;
                        }

                        .status-APPROVED {
                            background: #d1fae5;
                            color: #065f46;
                        }

                        .status-REJECTED {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        .expertise-tags {
                            display: flex;
                            flex-wrap: wrap;
                            gap: 6px;
                            justify-content: flex-end;
                        }

                        .expertise-tag {
                            background: #ede9fe;
                            color: #6d28d9;
                            padding: 4px 10px;
                            border-radius: 6px;
                            font-size: 0.8rem;
                            font-weight: 600;
                        }

                        .bio-text,
                        .guide-text {
                            background: var(--muted);
                            padding: 16px;
                            border-radius: 10px;
                            font-size: 0.9rem;
                            line-height: 1.6;
                            color: var(--foreground);
                            white-space: pre-wrap;
                        }

                        .proof-gallery {
                            display: grid;
                            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                            gap: 16px;
                        }

                        .proof-item {
                            border: 1px solid var(--border);
                            border-radius: 12px;
                            overflow: hidden;
                            background: var(--card);
                        }

                        .proof-item img {
                            width: 100%;
                            height: 160px;
                            object-fit: cover;
                            cursor: pointer;
                            transition: transform 0.2s;
                        }

                        .proof-item img:hover {
                            transform: scale(1.02);
                        }

                        .proof-info {
                            padding: 10px 12px;
                        }

                        .proof-type {
                            font-weight: 700;
                            font-size: 0.8rem;
                            color: var(--primary);
                            margin-bottom: 4px;
                        }

                        .proof-desc {
                            font-size: 0.8rem;
                            color: var(--muted-foreground);
                        }

                        .profile-pic-container {
                            text-align: center;
                            margin-bottom: 16px;
                        }

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

                        /* Action buttons */
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

                        .btn-approve:hover {
                            background: #059669;
                            transform: translateY(-1px);
                        }

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

                        .btn-reject:hover {
                            background: #dc2626;
                            transform: translateY(-1px);
                        }

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

                        .btn-back-link:hover {
                            background: var(--accent);
                        }

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

                        .rejection-box textarea:focus {
                            outline: none;
                            border-color: var(--primary);
                        }

                        .rejection-actions {
                            display: flex;
                            gap: 8px;
                            margin-top: 10px;
                        }

                        /* Image modal */
                        .modal-overlay {
                            display: none;
                            position: fixed;
                            top: 0;
                            left: 0;
                            width: 100%;
                            height: 100%;
                            background: rgba(0, 0, 0, 0.8);
                            z-index: 9999;
                            align-items: center;
                            justify-content: center;
                            cursor: pointer;
                        }

                        .modal-overlay.active {
                            display: flex;
                        }

                        .modal-overlay img {
                            max-width: 90%;
                            max-height: 90%;
                            border-radius: 12px;
                            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
                        }

                        @media (max-width: 768px) {
                            .detail-grid {
                                grid-template-columns: 1fr;
                            }
                        }
                    </style>
                </head>

                <body>

                    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

                    <main class="main-content">
                        <div class="dashboard-header">
                            <h1>Review Volunteer Application</h1>
                            <p>Request #${volunteerRequest.requestId} — ${volunteerRequest.fullName}</p>
                        </div>

                        <div class="detail-grid">
                            <!-- Profile Summary -->
                            <div class="detail-card">
                                <h3>👤 Profile Summary</h3>

                                <div class="profile-pic-container">
                                    <c:choose>
                                        <c:when test="${not empty volunteerRequest.profilePicturePath}">
                                            <img src="${pageContext.request.contextPath}/${volunteerRequest.profilePicturePath}"
                                                alt="Profile" class="profile-pic">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="profile-pic-placeholder">👤</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="detail-row">
                                    <span class="detail-label">Full Name</span>
                                    <span class="detail-value">${volunteerRequest.fullName}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Username</span>
                                    <span class="detail-value">${volunteerRequest.username}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Email</span>
                                    <span class="detail-value">${volunteerRequest.email}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Phone</span>
                                    <span class="detail-value">${not empty volunteerRequest.phone ?
                                        volunteerRequest.phone : '—'}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">City</span>
                                    <span class="detail-value">${volunteerRequest.city}</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Status</span>
                                    <span class="detail-value">
                                        <span
                                            class="status-badge status-${volunteerRequest.status}">${volunteerRequest.status}</span>
                                    </span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Submitted</span>
                                    <span class="detail-value">${volunteerRequest.submittedDate}</span>
                                </div>
                            </div>

                            <!-- Professional Info -->
                            <div class="detail-card">
                                <h3>💼 Professional Information</h3>

                                <div class="detail-row">
                                    <span class="detail-label">Expertise</span>
                                    <span class="detail-value">
                                        <div class="expertise-tags">
                                            <c:forEach var="tag" items="${volunteerRequest.expertise.split(', ')}">
                                                <span class="expertise-tag">${tag}</span>
                                            </c:forEach>
                                        </div>
                                    </span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Skill Level</span>
                                    <span class="detail-value">${volunteerRequest.skillLevel}</span>
                                </div>
                            </div>

                            <!-- Bio -->
                            <div class="detail-card full-width">
                                <h3>📝 Bio</h3>
                                <div class="bio-text">${not empty volunteerRequest.bio ? volunteerRequest.bio : 'No bio provided.'}</div>
                            </div>

                            <!-- Sample Guide -->
                            <div class="detail-card full-width">
                                <h3>📄 Sample Guide</h3>
                                <c:choose>
                                    <c:when test="${not empty volunteerRequest.sampleGuide}">
                                        <div class="guide-text">${volunteerRequest.sampleGuide}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <p style="color: var(--muted-foreground);">No sample guide text provided.</p>
                                    </c:otherwise>
                                </c:choose>

                                <c:if test="${not empty volunteerRequest.sampleGuideFilePath}">
                                    <div style="margin-top: 12px;">
                                        <a href="${pageContext.request.contextPath}/${volunteerRequest.sampleGuideFilePath}"
                                            target="_blank" class="btn-back-link" style="font-size: 0.85rem;">
                                            📎 View Uploaded PDF
                                        </a>
                                    </div>
                                </c:if>
                            </div>

                            <!-- Qualification Proofs -->
                            <div class="detail-card full-width">
                                <h3>🎓 Qualification Proofs</h3>
                                <c:choose>
                                    <c:when test="${not empty volunteerRequest.proofs}">
                                        <div class="proof-gallery">
                                            <c:forEach var="proof" items="${volunteerRequest.proofs}">
                                                <div class="proof-item">
                                                    <img src="${pageContext.request.contextPath}/${proof.imagePath}"
                                                        alt="${proof.proofType}" onclick="openModal(this.src)">
                                                    <div class="proof-info">
                                                        <div class="proof-type">${proof.proofType}</div>
                                                        <div class="proof-desc">${not empty proof.description ?
                                                            proof.description : '—'}</div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <p style="color: var(--muted-foreground);">No qualification proofs uploaded.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Rejection Reason (if rejected) -->
                            <c:if
                                test="${volunteerRequest.status == 'REJECTED' && not empty volunteerRequest.rejectionReason}">
                                <div class="detail-card full-width">
                                    <h3>❌ Rejection Reason</h3>
                                    <div class="bio-text" style="border-left: 4px solid #ef4444; padding-left: 16px;">
                                        ${volunteerRequest.rejectionReason}
                                    </div>
                                </div>
                            </c:if>
                        </div>

                        <!-- Action Panel (only for PENDING requests) -->
                        <c:if test="${volunteerRequest.status == 'PENDING'}">
                            <div class="action-panel">
                                <h3>⚡ Take Action</h3>
                                <div class="action-buttons">
                                    <form action="${pageContext.request.contextPath}/admin/volunteer-requests"
                                        method="post" style="display:inline;">
                                        <input type="hidden" name="requestId" value="${volunteerRequest.requestId}">
                                        <input type="hidden" name="action" value="approve">
                                        <button type="submit" class="btn-approve"
                                            onclick="return confirm('Are you sure you want to approve this volunteer? They will be able to log in immediately.')">
                                            ✓ Approve
                                        </button>
                                    </form>

                                    <button type="button" class="btn-reject" onclick="showRejectionBox()">✕
                                        Reject</button>

                                    <a href="${pageContext.request.contextPath}/admin/volunteer-requests"
                                        class="btn-back-link">← Back to List</a>
                                </div>

                                <div class="rejection-box" id="rejectionBox">
                                    <form action="${pageContext.request.contextPath}/admin/volunteer-requests"
                                        method="post">
                                        <input type="hidden" name="requestId" value="${volunteerRequest.requestId}">
                                        <input type="hidden" name="action" value="reject">
                                        <textarea name="rejectionReason"
                                            placeholder="Provide a reason for rejection (optional but recommended)..."></textarea>
                                        <div class="rejection-actions">
                                            <button type="submit" class="btn-reject"
                                                onclick="return confirm('Are you sure you want to reject this volunteer request?')">
                                                Confirm Rejection
                                            </button>
                                            <button type="button" class="btn-back-link" onclick="hideRejectionBox()"
                                                style="font-size:0.85rem;">Cancel</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </c:if>

                        <!-- Back link for non-pending -->
                        <c:if test="${volunteerRequest.status != 'PENDING'}">
                            <div style="margin-top: 20px;">
                                <a href="${pageContext.request.contextPath}/admin/volunteer-requests"
                                    class="btn-back-link">← Back to List</a>
                            </div>
                        </c:if>

                    </main>

                    <!-- Image Modal -->
                    <div class="modal-overlay" id="imageModal" onclick="closeModal()">
                        <img id="modalImage" src="" alt="Proof Image">
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

                        // Close modal on Escape key
                        document.addEventListener('keydown', function (e) {
                            if (e.key === 'Escape') closeModal();
                        });
                    </script>

                </body>

                </html>