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
    <title>Review Technician Request | Daily Fixer Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .main-content {
            flex: 1;
            margin-left: 240px;
            padding: 40px 30px;
        }

        @media (max-width: 900px) {
            .main-content { margin-left: 0 !important; margin-top: 60px !important; padding-top: 40px !important; }
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

        .detail-card.full-width { grid-column: 1 / -1; }

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

        .detail-label { font-weight: 600; font-size: 0.85rem; color: var(--muted-foreground); }

        .detail-value { font-weight: 500; font-size: 0.9rem; color: var(--foreground); text-align: right; max-width: 60%; }

        .status-badge { padding: 4px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; }
        .status-PENDING  { background: #fef3c7; color: #92400e; }
        .status-APPROVED { background: #d1fae5; color: #065f46; }
        .status-REJECTED { background: #fee2e2; color: #991b1b; }

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

        /* File gallery (for images) */
        .doc-gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
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
            height: 160px;
            object-fit: cover;
            cursor: pointer;
            transition: transform 0.2s;
        }

        .doc-item img:hover { transform: scale(1.02); }

        .doc-info { padding: 10px 12px; }
        .doc-type { font-weight: 700; font-size: 0.8rem; color: var(--primary); margin-bottom: 4px; }
        .doc-filename { font-size: 0.78rem; color: var(--muted-foreground); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        /* PDF file item */
        .pdf-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px;
            border: 1px solid var(--border);
            border-radius: 12px;
            background: var(--card);
            margin-bottom: 10px;
        }

        .pdf-icon { font-size: 2rem; flex-shrink: 0; }

        .pdf-info { flex: 1; min-width: 0; }
        .pdf-name { font-weight: 600; font-size: 0.9rem; color: var(--foreground); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .pdf-link {
            display: inline-block;
            margin-top: 6px;
            padding: 4px 12px;
            background: var(--primary);
            color: var(--primary-foreground);
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            text-decoration: none;
        }

        .pdf-link:hover { opacity: 0.85; }

        /* Name match badge */
        .name-match-ok  { display: inline-block; background: #d1fae5; color: #065f46; padding: 2px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }
        .name-match-warn{ display: inline-block; background: #fef3c7; color: #92400e; padding: 2px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }

        /* Action panel */
        .action-panel {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--shadow-sm);
            margin-top: 24px;
        }

        .action-panel h3 { font-size: 1rem; font-weight: 700; color: var(--foreground); margin-bottom: 16px; }

        .action-buttons { display: flex; gap: 12px; flex-wrap: wrap; }

        .btn-approve {
            padding: 10px 24px; background: #10b981; color: white;
            border: none; border-radius: 10px; font-weight: 700; font-size: 0.9rem; cursor: pointer; transition: all 0.2s;
        }
        .btn-approve:hover { background: #059669; transform: translateY(-1px); }

        .btn-reject {
            padding: 10px 24px; background: #ef4444; color: white;
            border: none; border-radius: 10px; font-weight: 700; font-size: 0.9rem; cursor: pointer; transition: all 0.2s;
        }
        .btn-reject:hover { background: #dc2626; transform: translateY(-1px); }

        .btn-back-link {
            display: inline-block; padding: 10px 24px; background: var(--secondary);
            color: var(--secondary-foreground); border: 1px solid var(--border); border-radius: 10px;
            font-weight: 600; font-size: 0.9rem; text-decoration: none; transition: all 0.2s;
        }
        .btn-back-link:hover { background: var(--accent); }

        .rejection-box { display: none; margin-top: 16px; }
        .rejection-box textarea {
            width: 100%; padding: 12px; border: 2px solid var(--border); border-radius: 10px;
            font-family: inherit; font-size: 0.9rem; resize: vertical; min-height: 80px;
            background: var(--input); color: var(--foreground);
        }
        .rejection-box textarea:focus { outline: none; border-color: var(--primary); }
        .rejection-actions { display: flex; gap: 8px; margin-top: 10px; }

        /* Image modal */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0;
            width: 100%; height: 100%; background: rgba(0,0,0,0.85);
            z-index: 9999; align-items: center; justify-content: center; cursor: pointer;
        }
        .modal-overlay.active { display: flex; }
        .modal-overlay img { max-width: 90%; max-height: 90%; border-radius: 12px; box-shadow: 0 20px 60px rgba(0,0,0,0.5); }

        @media (max-width: 768px) { .detail-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

    <main class="main-content">
        <div class="dashboard-header">
            <h1>Review Technician Application</h1>
            <p>Request #${techRequest.requestId} — ${techRequest.fullName}</p>
        </div>

        <div class="detail-grid">

            <!-- Profile Summary -->
            <div class="detail-card">
                <h3>👤 Profile Summary</h3>

                <div class="profile-pic-container">
                    <c:choose>
                        <c:when test="${not empty techRequest.profilePicturePath}">
                            <img src="${pageContext.request.contextPath}/${techRequest.profilePicturePath}"
                                 alt="Profile" class="profile-pic"
                                 onclick="openModal(this.src)" style="cursor:pointer;">
                        </c:when>
                        <c:otherwise>
                            <div class="profile-pic-placeholder">👤</div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="detail-row">
                    <span class="detail-label">Full Name</span>
                    <span class="detail-value">${techRequest.fullName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Username</span>
                    <span class="detail-value">${techRequest.username}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Email</span>
                    <span class="detail-value">${techRequest.email}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Phone</span>
                    <span class="detail-value">${not empty techRequest.phone ? techRequest.phone : '—'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">City</span>
                    <span class="detail-value">${not empty techRequest.city ? techRequest.city : '—'}</span>
                </div>
            </div>

            <!-- Request Status -->
            <div class="detail-card">
                <h3>📋 Request Status</h3>

                <div class="detail-row">
                    <span class="detail-label">Status</span>
                    <span class="detail-value">
                        <span class="status-badge status-${techRequest.status}">${techRequest.status}</span>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Submitted</span>
                    <span class="detail-value">${techRequest.submittedDate}</span>
                </div>
                <c:if test="${not empty techRequest.reviewedDate}">
                    <div class="detail-row">
                        <span class="detail-label">Reviewed</span>
                        <span class="detail-value">${techRequest.reviewedDate}</span>
                    </div>
                </c:if>
                <div class="detail-row">
                    <span class="detail-label">Has Qualifications</span>
                    <span class="detail-value">${techRequest.hasQualifications ? '✅ Yes' : '❌ No'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Has Experience</span>
                    <span class="detail-value">${techRequest.hasExperience ? '✅ Yes' : '❌ No'}</span>
                </div>
            </div>

            <!-- Qualifications / Certifications -->
            <div class="detail-card full-width">
                <h3>🎓 Qualifications / Certifications</h3>
                <c:choose>
                    <c:when test="${not empty techRequest.qualificationFiles}">
                        <c:forEach var="f" items="${techRequest.qualificationFiles}">
                            <c:choose>
                                <c:when test="${f.pdf}">
                                    <div class="pdf-item">
                                        <div class="pdf-icon">📄</div>
                                        <div class="pdf-info">
                                            <div class="pdf-name">${not empty f.originalFilename ? f.originalFilename : 'Qualification Document'}</div>
                                            <a href="${pageContext.request.contextPath}/${f.filePath}"
                                               class="pdf-link" target="_blank">View PDF</a>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="doc-gallery" style="margin-bottom:12px;">
                                        <div class="doc-item">
                                            <img src="${pageContext.request.contextPath}/${f.filePath}"
                                                 alt="Qualification" onclick="openModal(this.src)">
                                            <div class="doc-info">
                                                <div class="doc-type">Qualification</div>
                                                <div class="doc-filename">${not empty f.originalFilename ? f.originalFilename : 'Certificate'}</div>
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p style="color: var(--muted-foreground);">No qualification files uploaded.</p>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Workplace Experience -->
            <c:if test="${techRequest.hasExperience}">
                <div class="detail-card full-width">
                    <h3>🏢 Workplace Experience</h3>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
                        <div>
                            <div class="detail-row">
                                <span class="detail-label">Company</span>
                                <span class="detail-value">${techRequest.experienceCompany}</span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Role</span>
                                <span class="detail-value">${not empty techRequest.experienceRole ? techRequest.experienceRole : '—'}</span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Years</span>
                                <span class="detail-value">${techRequest.experienceYears != null ? techRequest.experienceYears : '—'}</span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Name on ID Card</span>
                                <span class="detail-value">
                                    ${techRequest.empIdCardName}
                                    <c:choose>
                                        <c:when test="${techRequest.empIdCardName.equalsIgnoreCase(techRequest.fullName)}">
                                            <span class="name-match-ok" style="margin-left:6px;">✓ Matches</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="name-match-warn" style="margin-left:6px;">⚠ Check Name</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>

                        <c:if test="${not empty techRequest.empIdCardPath}">
                            <div>
                                <p style="font-weight:600; font-size:0.85rem; color:var(--muted-foreground); margin-bottom:8px;">Employee ID Card</p>
                                <div class="doc-item" style="max-width:240px;">
                                    <img src="${pageContext.request.contextPath}/${techRequest.empIdCardPath}"
                                         alt="Employee ID Card" onclick="openModal(this.src)">
                                    <div class="doc-info">
                                        <div class="doc-type">Employee ID Card</div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </c:if>

            <!-- Work Proof Images -->
            <c:if test="${not empty techRequest.workProofFiles}">
                <div class="detail-card full-width">
                    <h3>🔧 Work Proof</h3>
                    <div class="doc-gallery">
                        <c:forEach var="f" items="${techRequest.workProofFiles}">
                            <div class="doc-item">
                                <img src="${pageContext.request.contextPath}/${f.filePath}"
                                     alt="Work Proof" onclick="openModal(this.src)">
                                <div class="doc-info">
                                    <div class="doc-type">Work Proof</div>
                                    <div class="doc-filename">${not empty f.originalFilename ? f.originalFilename : ''}</div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <!-- Rejection Reason -->
            <c:if test="${techRequest.status == 'REJECTED' && not empty techRequest.rejectionReason}">
                <div class="detail-card full-width">
                    <h3>❌ Rejection Reason</h3>
                    <div style="background: var(--muted); padding: 16px; border-radius: 10px; font-size: 0.9rem; line-height: 1.6; color: var(--foreground); border-left: 4px solid #ef4444;">
                        ${techRequest.rejectionReason}
                    </div>
                </div>
            </c:if>

        </div><!-- /detail-grid -->

        <!-- Action Panel (PENDING only) -->
        <c:if test="${techRequest.status == 'PENDING'}">
            <div class="action-panel">
                <h3>⚡ Take Action</h3>
                <div class="action-buttons">
                    <form action="${pageContext.request.contextPath}/admin/technician-requests" method="post" style="display:inline;">
                        <input type="hidden" name="requestId" value="${techRequest.requestId}">
                        <input type="hidden" name="action" value="approve">
                        <button type="submit" class="btn-approve"
                                onclick="return confirm('Approve this technician application?')">
                            ✓ Approve
                        </button>
                    </form>

                    <button type="button" class="btn-reject" onclick="showRejectionBox()">✕ Reject</button>

                    <a href="${pageContext.request.contextPath}/admin/technician-requests" class="btn-back-link">← Back to List</a>
                </div>

                <div class="rejection-box" id="rejectionBox">
                    <form action="${pageContext.request.contextPath}/admin/technician-requests" method="post">
                        <input type="hidden" name="requestId" value="${techRequest.requestId}">
                        <input type="hidden" name="action" value="reject">
                        <textarea name="rejectionReason"
                                  placeholder="Provide a reason for rejection (optional but recommended)..."></textarea>
                        <div class="rejection-actions">
                            <button type="submit" class="btn-reject">Confirm Rejection</button>
                            <button type="button" class="btn-back-link" onclick="hideRejectionBox()">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

        <!-- Back link for non-pending -->
        <c:if test="${techRequest.status != 'PENDING'}">
            <div style="margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/admin/technician-requests" class="btn-back-link">← Back to List</a>
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
