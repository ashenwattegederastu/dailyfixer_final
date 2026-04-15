<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<% User user = (User) session.getAttribute("currentUser");
   if (user == null || !"admin".equals(user.getRole())) {
       response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
       return;
   }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flagged Guides | Admin | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .main-content {
            flex: 1;
            margin-left: 240px;
            margin-top: 83px;
            padding: 40px 30px;
        }

        @media (max-width: 900px) {
            .main-content {
                margin-left: 0 !important;
                margin-top: 60px !important;
                padding-top: 40px !important;
            }
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .page-header h1 {
            font-size: 1.8rem;
            color: var(--foreground);
        }

        .tab-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
        }

        .tab-btn {
            padding: 10px 20px;
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            background: transparent;
            color: var(--foreground);
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
        }

        .tab-btn.active {
            background: var(--primary);
            color: var(--primary-foreground);
            border-color: var(--primary);
        }

        .success-message {
            background: oklch(0.6290 0.1902 156.4499);
            color: white;
            padding: 15px;
            border-radius: var(--radius-md);
            margin-bottom: 20px;
        }

        .guides-table {
            width: 100%;
            background: var(--card);
            border-radius: var(--radius-lg);
            overflow: hidden;
            border: 1px solid var(--border);
        }

        .guides-table th,
        .guides-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }

        .guides-table th {
            background: var(--muted);
            font-weight: 600;
            color: var(--foreground);
        }

        .guides-table tr:hover {
            background: var(--accent);
        }

        .guide-thumb {
            width: 80px;
            height: 60px;
            object-fit: cover;
            border-radius: var(--radius-sm);
        }

        .guide-title-cell {
            font-weight: 500;
            color: var(--foreground);
        }

        .guide-category {
            font-size: 0.85rem;
            color: var(--muted-foreground);
        }

        .flag-count-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 12px;
            background: #fef2f2;
            color: #dc2626;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.85rem;
        }

        .action-btns {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .no-guides {
            text-align: center;
            padding: 60px;
            background: var(--card);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
        }

        .no-guides h3 {
            color: var(--foreground);
            margin-bottom: 15px;
        }

        /* Hide modal */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-content {
            background: var(--card);
            border-radius: var(--radius-lg);
            padding: 30px;
            max-width: 500px;
            width: 90%;
            border: 1px solid var(--border);
        }

        .modal-content h2 {
            margin-bottom: 20px;
            color: var(--foreground);
        }

        .modal-content label {
            display: block;
            font-weight: 500;
            margin-bottom: 8px;
            color: var(--foreground);
        }

        .modal-content textarea {
            width: 100%;
            padding: 10px;
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            background: var(--input);
            color: var(--foreground);
            font-family: inherit;
            min-height: 80px;
            resize: vertical;
            margin-bottom: 15px;
        }

        .modal-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        .btn-cancel {
            padding: 10px 20px;
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            background: transparent;
            color: var(--foreground);
            cursor: pointer;
            font-weight: 500;
        }

        .btn-hide-submit {
            padding: 10px 20px;
            border: none;
            border-radius: var(--radius-md);
            background: #ef4444;
            color: white;
            cursor: pointer;
            font-weight: 500;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .status-badge.pending {
            background: #fefce8;
            color: #854d0e;
        }
    </style>
</head>

<body>

    <jsp:include page="/pages/dashboards/admindash/sidebar.jsp" />

    <main class="main-content">
        <div class="page-header">
            <h1>
                <c:choose>
                    <c:when test="${viewMode == 'pending'}">Guides Pending Review</c:when>
                    <c:otherwise>Flagged Guides</c:otherwise>
                </c:choose>
            </h1>
        </div>

        <!-- Tab navigation -->
        <div class="tab-bar">
            <a href="${pageContext.request.contextPath}/admin/flagged-guides"
                class="tab-btn ${viewMode == 'flagged' ? 'active' : ''}">
                Flagged Guides
            </a>
            <a href="${pageContext.request.contextPath}/admin/flagged-guides?view=pending"
                class="tab-btn ${viewMode == 'pending' ? 'active' : ''}">
                Pending Review
            </a>
        </div>

        <!-- Success messages -->
        <c:if test="${param.success == 'hidden'}">
            <div class="success-message">Guide has been hidden successfully.</div>
        </c:if>
        <c:if test="${param.success == 'dismissed'}">
            <div class="success-message">Flags have been dismissed.</div>
        </c:if>
        <c:if test="${param.success == 'unhidden'}">
            <div class="success-message">Guide has been approved and made visible again.</div>
        </c:if>

        <c:choose>
            <c:when test="${not empty guides}">
                <table class="guides-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Title</th>
                            <th>Category</th>
                            <th>Author</th>
                            <c:if test="${viewMode == 'flagged'}">
                                <th>Flags</th>
                            </c:if>
                            <c:if test="${viewMode == 'pending'}">
                                <th>Status</th>
                            </c:if>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="guide" items="${guides}">
                            <tr>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty guide.mainImagePath}">
                                            <img src="${pageContext.request.contextPath}/${guide.mainImagePath}"
                                                class="guide-thumb" alt="">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="guide-thumb"
                                                style="background: var(--muted); display: flex; align-items: center; justify-content: center;">
                                                📖</div>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="guide-title-cell">${guide.title}</td>
                                <td>
                                    <span class="guide-category">${guide.mainCategory}</span><br>
                                    <span class="guide-category">${guide.subCategory}</span>
                                </td>
                                <td>
                                    <span>${guide.creatorName}</span><br>
                                    <span class="guide-category">(${guide.createdRole})</span>
                                </td>

                                <c:if test="${viewMode == 'flagged'}">
                                    <td>
                                        <span class="flag-count-badge">
                                            <i class="ph ph-flag"></i> ${guide.flagCount}
                                        </span>
                                    </td>
                                </c:if>

                                <c:if test="${viewMode == 'pending'}">
                                    <td>
                                        <span class="status-badge pending">Pending Review</span>
                                    </td>
                                </c:if>

                                <td>
                                    <div class="action-btns">
                                        <a href="${pageContext.request.contextPath}/guides/view?id=${guide.guideId}"
                                            class="action-btn btn-view">View</a>

                                        <c:if test="${viewMode == 'flagged'}">
                                            <button class="action-btn btn-dismiss"
                                                onclick="openHideModal(${guide.guideId}, '${guide.title}')">
                                                Hide
                                            </button>
                                            <form action="${pageContext.request.contextPath}/admin/moderate-guide"
                                                method="post" style="display:inline;"
                                                onsubmit="return confirm('Dismiss all flags on this guide?');">
                                                <input type="hidden" name="guideId" value="${guide.guideId}">
                                                <input type="hidden" name="action" value="dismiss">
                                                <button type="submit" class="action-btn btn-resolve">Dismiss</button>
                                            </form>
                                        </c:if>

                                        <c:if test="${viewMode == 'pending'}">
                                            <form action="${pageContext.request.contextPath}/admin/moderate-guide"
                                                method="post" style="display:inline;"
                                                onsubmit="return confirm('Approve this guide and make it visible again?');">
                                                <input type="hidden" name="guideId" value="${guide.guideId}">
                                                <input type="hidden" name="action" value="unhide">
                                                <button type="submit" class="action-btn btn-resolve">Approve &amp; Unhide</button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="no-guides">
                    <h3>
                        <c:choose>
                            <c:when test="${viewMode == 'pending'}">No Guides Pending Review</c:when>
                            <c:otherwise>No Flagged Guides</c:otherwise>
                        </c:choose>
                    </h3>
                    <p style="color: var(--muted-foreground);">
                        <c:choose>
                            <c:when test="${viewMode == 'pending'}">
                                No edited guides are waiting for your review.
                            </c:when>
                            <c:otherwise>
                                No guides have reached the flag threshold (${threshold} flags) yet.
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <!-- Hide Guide Modal -->
    <div class="modal-overlay" id="hideModal">
        <div class="modal-content">
            <h2><i class="ph ph-eye-slash" style="color: #ef4444;"></i> Hide Guide</h2>
            <p style="margin-bottom: 15px; color: var(--muted-foreground);">
                Hiding "<span id="hideGuideTitle"></span>" will make it invisible to the public.
                The guide creator will be notified with your reason.
            </p>
            <form action="${pageContext.request.contextPath}/admin/moderate-guide" method="post">
                <input type="hidden" name="action" value="hide">
                <input type="hidden" name="guideId" id="hideGuideId" value="">

                <label for="hideReason">Reason for hiding:</label>
                <textarea name="reason" id="hideReason" placeholder="Explain why this guide is being hidden..." required></textarea>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeHideModal()">Cancel</button>
                    <button type="submit" class="btn-hide-submit">Hide Guide</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openHideModal(guideId, title) {
            document.getElementById('hideGuideId').value = guideId;
            document.getElementById('hideGuideTitle').textContent = title;
            document.getElementById('hideModal').classList.add('active');
        }

        function closeHideModal() {
            document.getElementById('hideModal').classList.remove('active');
            document.getElementById('hideReason').value = '';
        }

        document.getElementById('hideModal').addEventListener('click', function (e) {
            if (e.target === this) {
                closeHideModal();
            }
        });
    </script>
</body>
</html>
