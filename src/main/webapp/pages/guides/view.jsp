<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>

        <!DOCTYPE html>
        <html lang="en">
        <!-- Importing Phosphor Icon Library Locally from assets-->
        <link
                rel="stylesheet"
                type="text/css"
                href="${pageContext.request.contextPath}/assets/icons/regular/style.css"
        />
        <link
                rel="stylesheet"
                type="text/css"
                href="${pageContext.request.contextPath}/assets/icons/fill/style.css"
        />
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>${guide.title} | Daily Fixer</title>

            <style>
                .page-container {
                    max-width: 1000px;
                    margin: 0 auto;
                    padding: 100px 30px 50px;
                }

                .breadcrumb {
                    margin-bottom: 20px;
                    font-size: 0.9rem;
                }

                .breadcrumb a {
                    color: var(--primary);
                    text-decoration: none;
                }

                .breadcrumb span {
                    color: var(--muted-foreground);
                }

                .guide-header {
                    background: var(--card);
                    border-radius: var(--radius-lg);
                    padding: 30px;
                    border: 1px solid var(--border);
                    margin-bottom: 30px;
                }

                .guide-main-image {
                    width: 100%;
                    max-height: 400px;
                    object-fit: cover;
                    border-radius: var(--radius-md);
                    margin-bottom: 20px;
                }

                .guide-title {
                    font-size: 2rem;
                    color: var(--foreground);
                    margin-bottom: 15px;
                }

                .guide-meta {
                    display: flex;
                    gap: 15px;
                    flex-wrap: wrap;
                    margin-bottom: 20px;
                }

                .guide-badge {
                    padding: 6px 14px;
                    background: var(--accent);
                    color: var(--accent-foreground);
                    border-radius: 20px;
                    font-size: 0.85rem;
                    font-weight: 500;
                }

                .guide-author {
                    color: var(--muted-foreground);
                }

                .requirements-section,
                .steps-section,
                .video-section,
                .comments-section {
                    background: var(--card);
                    border-radius: var(--radius-lg);
                    padding: 25px;
                    border: 1px solid var(--border);
                    margin-bottom: 25px;
                }

                .section-title {
                    font-size: 1.4rem;
                    color: var(--primary);
                    margin-bottom: 15px;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }

                .requirements-list {
                    list-style: none;
                    padding: 0;
                }

                .requirements-list li {
                    padding: 10px 0;
                    border-bottom: 1px solid var(--border);
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }

                .requirements-list li:last-child {
                    border-bottom: none;
                }

                .step-item {
                    margin-bottom: 30px;
                    padding-bottom: 30px;
                    border-bottom: 1px solid var(--border);
                }

                .step-item:last-child {
                    border-bottom: none;
                    margin-bottom: 0;
                    padding-bottom: 0;
                }

                .step-header {
                    display: flex;
                    align-items: center;
                    gap: 15px;
                    margin-bottom: 15px;
                }

                .step-number {
                    width: 40px;
                    height: 40px;
                    background: var(--primary);
                    color: var(--primary-foreground);
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-weight: 700;
                    flex-shrink: 0;
                }

                .step-title {
                    font-size: 1.2rem;
                    color: var(--foreground);
                }

                .step-images {
                    display: flex;
                    gap: 15px;
                    overflow-x: auto;
                    margin-bottom: 15px;
                }

                .step-image {
                    width: 280px;
                    height: 200px;
                    object-fit: cover;
                    border-radius: var(--radius-md);
                    flex-shrink: 0;
                }

                .step-body {
                    color: var(--foreground);
                    line-height: 1.7;
                    white-space: pre-wrap;
                }

                .video-embed {
                    position: relative;
                    padding-bottom: 56.25%;
                    height: 0;
                    overflow: hidden;
                    border-radius: var(--radius-md);
                }

                .video-embed iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: none;
                }

                .rating-section {
                    display: flex;
                    align-items: center;
                    gap: 20px;
                    padding: 20px 0;
                    border-top: 1px solid var(--border);
                    margin-top: 20px;
                }

                .rating-btn {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 10px 20px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: transparent;
                    cursor: pointer;
                    font-size: 1rem;
                    transition: all 0.2s;
                    color: var(--foreground);
                }

                .rating-btn:hover {
                    border-color: var(--primary);
                }

                .rating-btn.active-up {
                    background: #22c55e;
                    border-color: #22c55e;
                    color: white;
                }

                .rating-btn.active-down {
                    background: #ef4444;
                    border-color: #ef4444;
                    color: white;
                }

                .comment-form {
                    margin-bottom: 25px;
                }

                .comment-form textarea {
                    width: 100%;
                    padding: 15px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: var(--input);
                    color: var(--foreground);
                    resize: vertical;
                    min-height: 100px;
                    font-family: inherit;
                    margin-bottom: 10px;
                }

                .comment-item {
                    padding: 15px;
                    background: var(--muted);
                    border-radius: var(--radius-md);
                    margin-bottom: 15px;
                }

                .comment-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 8px;
                }

                .comment-author {
                    font-weight: 600;
                    color: var(--foreground);
                }

                .comment-date {
                    font-size: 0.8rem;
                    color: var(--muted-foreground);
                }

                .comment-text {
                    color: var(--foreground);
                    line-height: 1.5;
                }

                .delete-comment-btn {
                    background: transparent;
                    border: none;
                    color: var(--destructive);
                    cursor: pointer;
                    font-size: 0.8rem;
                }

                .edit-comment-btn, .reply-btn, .edit-reply-btn, .delete-reply-btn {
                    background: transparent;
                    border: none;
                    cursor: pointer;
                    font-size: 0.8rem;
                    margin-left: 6px;
                }

                .edit-comment-btn { color: var(--primary); }
                .reply-btn { color: var(--primary); }
                .edit-reply-btn { color: var(--primary); }
                .delete-reply-btn { color: var(--destructive); }

                .inline-edit-form, .inline-reply-form {
                    display: none;
                    margin-top: 10px;
                }

                .inline-edit-form textarea, .inline-reply-form textarea {
                    width: 100%;
                    padding: 10px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: var(--input);
                    color: var(--foreground);
                    resize: vertical;
                    min-height: 70px;
                    font-family: inherit;
                    margin-bottom: 8px;
                }

                .inline-form-actions {
                    display: flex;
                    gap: 8px;
                }

                .creator-reply {
                    margin-top: 12px;
                    padding: 12px 14px;
                    background: var(--accent);
                    border-left: 3px solid var(--primary);
                    border-radius: var(--radius-md);
                }

                .creator-reply-label {
                    font-size: 0.78rem;
                    font-weight: 600;
                    color: var(--primary);
                    margin-bottom: 4px;
                }

                .creator-reply-text {
                    color: var(--foreground);
                    line-height: 1.5;
                    font-size: 0.95rem;
                }

                .creator-reply-date {
                    font-size: 0.75rem;
                    color: var(--muted-foreground);
                    margin-top: 4px;
                }

                .edit-actions {
                    display: flex;
                    gap: 15px;
                    margin-bottom: 20px;
                }

                /* Flag button styles */
                .flag-btn {
                    display: flex;
                    align-items: center;
                    gap: 6px;
                    padding: 8px 16px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: transparent;
                    cursor: pointer;
                    font-size: 0.9rem;
                    color: var(--muted-foreground);
                    transition: all 0.2s;
                }

                .flag-btn:hover {
                    border-color: #ef4444;
                    color: #ef4444;
                }

                .flag-btn.flagged {
                    background: #fef2f2;
                    border-color: #ef4444;
                    color: #ef4444;
                    cursor: default;
                }

                .hidden-banner {
                    background: #fef2f2;
                    border: 2px solid #ef4444;
                    border-radius: var(--radius-md);
                    padding: 20px;
                    margin-bottom: 20px;
                    color: #991b1b;
                }

                .hidden-banner h3 {
                    margin-bottom: 8px;
                    color: #991b1b;
                }

                .pending-banner {
                    background: #fefce8;
                    border: 2px solid #eab308;
                    border-radius: var(--radius-md);
                    padding: 20px;
                    margin-bottom: 20px;
                    color: #854d0e;
                }

                .pending-banner h3 {
                    margin-bottom: 8px;
                    color: #854d0e;
                }

                /* Flag modal styles */
                .modal-overlay {
                    display: none;
                    position: fixed;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
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

                .modal-content select,
                .modal-content textarea {
                    width: 100%;
                    padding: 10px;
                    border: 2px solid var(--border);
                    border-radius: var(--radius-md);
                    background: var(--input);
                    color: var(--foreground);
                    font-family: inherit;
                    margin-bottom: 15px;
                }

                .modal-content textarea {
                    min-height: 80px;
                    resize: vertical;
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

                .btn-flag-submit {
                    padding: 10px 20px;
                    border: none;
                    border-radius: var(--radius-md);
                    background: #ef4444;
                    color: white;
                    cursor: pointer;
                    font-weight: 500;
                }
            </style>
        </head>

        <body>
            <!-- Shared Header -->
            <jsp:include page="/pages/shared/header.jsp" />

            <div class="page-container">
                <!-- Breadcrumb -->
                <div class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/guides">Repair Guides</a>
                    <span> / ${guide.mainCategory} / ${guide.subCategory}</span>
                </div>

                <!-- Hidden Guide Banner (shown to creator and admin) -->
                <c:if test="${guide.status == 'HIDDEN'}">
                    <div class="hidden-banner">
                        <h3><i class="ph ph-warning"></i> This Guide Has Been Hidden</h3>
                        <p><strong>Reason:</strong> ${guide.hideReason}</p>
                        <p style="margin-top: 8px;">You can edit this guide to address the issues, then it will be sent for admin review.</p>
                    </div>
                </c:if>

                <c:if test="${guide.status == 'PENDING_REVIEW'}">
                    <div class="pending-banner">
                        <h3><i class="ph ph-clock"></i> Pending Admin Review</h3>
                        <p>This guide has been edited and is awaiting admin approval before it becomes visible again.</p>
                    </div>
                </c:if>

                <!-- Edit Actions (for owners/admins) -->
                <c:if test="${canEdit}">
                    <div class="edit-actions">
                        <a href="${pageContext.request.contextPath}/guides/edit?id=${guide.guideId}"
                            class="btn-primary">Edit Guide</a>
                        <form action="${pageContext.request.contextPath}/guides/delete" method="post"
                            style="display:inline;"
                            onsubmit="return confirm('Are you sure you want to delete this guide?');">
                            <input type="hidden" name="id" value="${guide.guideId}">
                            <button type="submit" class="btn-danger">Delete Guide</button>
                        </form>
                    </div>
                </c:if>

                <!-- Guide Header -->
                <div class="guide-header">
                    <c:if test="${not empty guide.mainImagePath}">
                        <img src="${pageContext.request.contextPath}/${guide.mainImagePath}" alt="${guide.title}"
                            class="guide-main-image">
                    </c:if>
                    <h1 class="guide-title">${guide.title}</h1>
                    <div class="guide-meta">
                        <span class="guide-badge">${guide.mainCategory}</span>
                        <span class="guide-badge">${guide.subCategory}</span>
                    </div>
                    <p class="guide-author">Created by <strong>${guide.creatorName}</strong></p>

                    <!-- Rating Section -->
                    <div class="rating-section">
                        <span style="font-weight: 500;">Was this guide helpful?</span>
                        <button class="rating-btn ${userRating == 'UP' ? 'active-up' : ''}" id="upBtn"
                            onclick="rateGuide('UP')">
                            <i class="ph ph-thumbs-up" style="font-size: 1.5rem;"></i>
                            <span id="upCount">${upCount}</span>
                        </button>
                        <button class="rating-btn ${userRating == 'DOWN' ? 'active-down' : ''}" id="downBtn"
                            onclick="rateGuide('DOWN')">
                            <i class="ph ph-thumbs-down" style="font-size: 1.5rem;"></i>
                            <span id="downCount">${downCount}</span>
                        </button>
                        <div
                            style="margin-left: auto; display: flex; align-items: center; gap: 15px; color: var(--muted-foreground);">
                            <span><i class="ph ph-eye" style="margin-right:4px;"></i> ${guide.viewCount} views</span>

                            <!-- Flag button (for logged-in users, not the guide creator) -->
                            <c:if test="${not empty sessionScope.currentUser && sessionScope.currentUser.userId != guide.createdBy && guide.status == 'ACTIVE'}">
                                <c:choose>
                                    <c:when test="${hasUserFlagged}">
                                        <button class="flag-btn flagged" disabled>
                                            <i class="ph-fill ph-flag"></i> Flagged
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="flag-btn" onclick="openFlagModal()">
                                            <i class="ph ph-flag"></i> Flag
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Requirements -->
                <c:if test="${not empty guide.requirements}">
                    <div class="requirements-section">
                        <h2 class="section-title"><i class="ph ph-list-checks"></i> Things You Need</h2>
                        <ul class="requirements-list">
                            <c:forEach var="req" items="${guide.requirements}">
                                <li><i class="ph ph-check-fat"></i> ${req}</li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>

                <!-- Video Section -->
                <c:if test="${not empty guide.youtubeEmbedUrl}">
                    <div class="video-section">
                        <h2 class="section-title"><i class="ph ph-youtube-logo"></i> Video Overview</h2>
                        <div class="video-embed">
                            <iframe src="${guide.youtubeEmbedUrl}" allowfullscreen></iframe>
                        </div>
                    </div>
                </c:if>

                <!-- Steps -->
                <c:if test="${not empty guide.steps}">
                    <div class="steps-section">
                        <h2 class="section-title"><i class="ph ph-clipboard-text"></i> Step-by-Step Guide</h2>
                        <c:forEach var="step" items="${guide.steps}" varStatus="status">
                            <div class="step-item">
                                <div class="step-header">
                                    <span class="step-number">${status.index + 1}</span>
                                    <h3 class="step-title">${step.stepTitle}</h3>
                                </div>
                                <c:if test="${not empty step.imagePaths}">
                                    <div class="step-images">
                                        <c:forEach var="imgPath" items="${step.imagePaths}">
                                            <img src="${pageContext.request.contextPath}/${imgPath}" alt="Step image"
                                                class="step-image">
                                        </c:forEach>
                                    </div>
                                </c:if>
                                <div class="step-body">${step.stepBody}</div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <!-- Comments -->
                <div class="comments-section">
                    <h2 class="section-title"><i class="ph ph-chat-dots"></i> Comments</h2>

                    <c:if test="${not empty sessionScope.currentUser}">
                        <form class="comment-form" action="${pageContext.request.contextPath}/guides/comment"
                            method="post">
                            <input type="hidden" name="guideId" value="${guide.guideId}">
                            <input type="hidden" name="action" value="add">
                            <textarea name="comment" placeholder="Write a comment..." required></textarea>
                            <button type="submit" class="btn-primary">Post Comment</button>
                        </form>
                    </c:if>
                    <c:if test="${empty sessionScope.currentUser}">
                        <p style="margin-bottom: 20px; color: var(--muted-foreground);">
                            <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp">Login</a> to leave a comment.
                        </p>
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty comments}">
                            <c:forEach var="comment" items="${comments}">
                                <div class="comment-item">
                                    <div class="comment-header">
                                        <span class="comment-author">${comment.userFirstName}
                                            (@${comment.username})</span>
                                        <div>
                                            <span class="comment-date">${comment.createdAt}</span>
                                            <%-- Edit button: only visible to the comment owner --%>
                                            <c:if test="${comment.userId == currentUserId}">
                                                <button type="button" class="edit-comment-btn"
                                                    onclick="toggleForm('edit-${comment.commentId}')">Edit</button>
                                                <form action="${pageContext.request.contextPath}/guides/comment"
                                                    method="post" style="display:inline;">
                                                    <input type="hidden" name="guideId" value="${guide.guideId}">
                                                    <input type="hidden" name="commentId" value="${comment.commentId}">
                                                    <input type="hidden" name="action" value="delete">
                                                    <button type="submit" class="delete-comment-btn">Delete</button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>

                                    <p class="comment-text">${comment.comment}</p>

                                    <%-- Inline edit form: only for comment owner --%>
                                    <c:if test="${comment.userId == currentUserId}">
                                        <div class="inline-edit-form" id="edit-${comment.commentId}">
                                            <form action="${pageContext.request.contextPath}/guides/comment" method="post">
                                                <input type="hidden" name="guideId" value="${guide.guideId}">
                                                <input type="hidden" name="commentId" value="${comment.commentId}">
                                                <input type="hidden" name="action" value="edit">
                                                <textarea name="comment" required>${comment.comment}</textarea>
                                                <div class="inline-form-actions">
                                                    <button type="submit" class="btn-primary" style="font-size:0.85rem; padding:6px 14px;">Save</button>
                                                    <button type="button" class="btn-secondary" style="font-size:0.85rem; padding:6px 14px;"
                                                        onclick="toggleForm('edit-${comment.commentId}')">Cancel</button>
                                                </div>
                                            </form>
                                        </div>
                                    </c:if>

                                    <%-- Creator reply block --%>
                                    <c:if test="${not empty comment.reply}">
                                        <div class="creator-reply">
                                            <div class="creator-reply-label">Creator Reply</div>
                                            <div class="creator-reply-text">${comment.reply}</div>
                                            <div class="creator-reply-date">${comment.replyAt}</div>
                                            <%-- Edit / delete reply: only for the guide creator --%>
                                            <c:if test="${guide.createdBy == currentUserId}">
                                                <div style="margin-top:8px; display:flex; gap:6px;">
                                                    <button type="button" class="edit-reply-btn"
                                                        onclick="toggleForm('editreply-${comment.commentId}')">Edit Reply</button>
                                                    <form action="${pageContext.request.contextPath}/guides/comment" method="post" style="display:inline;">
                                                        <input type="hidden" name="guideId" value="${guide.guideId}">
                                                        <input type="hidden" name="commentId" value="${comment.commentId}">
                                                        <input type="hidden" name="action" value="deleteReply">
                                                        <button type="submit" class="delete-reply-btn">Delete Reply</button>
                                                    </form>
                                                </div>
                                                <div class="inline-reply-form" id="editreply-${comment.commentId}">
                                                    <form action="${pageContext.request.contextPath}/guides/comment" method="post">
                                                        <input type="hidden" name="guideId" value="${guide.guideId}">
                                                        <input type="hidden" name="commentId" value="${comment.commentId}">
                                                        <input type="hidden" name="action" value="editReply">
                                                        <textarea name="reply" required>${comment.reply}</textarea>
                                                        <div class="inline-form-actions">
                                                            <button type="submit" class="btn-primary" style="font-size:0.85rem; padding:6px 14px;">Save</button>
                                                            <button type="button" class="btn-secondary" style="font-size:0.85rem; padding:6px 14px;"
                                                                onclick="toggleForm('editreply-${comment.commentId}')">Cancel</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:if>

                                    <%-- Reply form: guide creator, only when no reply exists yet --%>
                                    <c:if test="${guide.createdBy == currentUserId && empty comment.reply}">
                                        <div style="margin-top:8px;">
                                            <button type="button" class="reply-btn"
                                                onclick="toggleForm('reply-${comment.commentId}')">Reply</button>
                                        </div>
                                        <div class="inline-reply-form" id="reply-${comment.commentId}">
                                            <form action="${pageContext.request.contextPath}/guides/comment" method="post">
                                                <input type="hidden" name="guideId" value="${guide.guideId}">
                                                <input type="hidden" name="commentId" value="${comment.commentId}">
                                                <input type="hidden" name="action" value="reply">
                                                <textarea name="reply" placeholder="Write your reply..." required></textarea>
                                                <div class="inline-form-actions">
                                                    <button type="submit" class="btn-primary" style="font-size:0.85rem; padding:6px 14px;">Post Reply</button>
                                                    <button type="button" class="btn-secondary" style="font-size:0.85rem; padding:6px 14px;"
                                                        onclick="toggleForm('reply-${comment.commentId}')">Cancel</button>
                                                </div>
                                            </form>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p style="color: var(--muted-foreground);">No comments yet. Be the first!</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>


            <!-- Flag Guide Modal -->
            <div class="modal-overlay" id="flagModal">
                <div class="modal-content">
                    <h2><i class="ph ph-flag" style="color: #ef4444;"></i> Flag This Guide</h2>
                    <label for="flagReason">Reason for flagging:</label>
                    <select id="flagReason">
                        <option value="">-- Select a reason --</option>
                        <option value="INACCURATE">Inaccurate information</option>
                        <option value="OUTDATED">Outdated content</option>
                        <option value="INAPPROPRIATE">Inappropriate content</option>
                        <option value="SPAM">Spam or advertising</option>
                        <option value="OTHER">Other</option>
                    </select>

                    <label for="flagDescription">Additional details (optional):</label>
                    <textarea id="flagDescription" placeholder="Describe the issue..." maxlength="500"></textarea>

                    <div class="modal-actions">
                        <button class="btn-cancel" onclick="closeFlagModal()">Cancel</button>
                        <button class="btn-flag-submit" onclick="submitFlag()">Submit Flag</button>
                    </div>
                </div>
            </div>

            <script>
                function rateGuide(rating) {
                    <c:if test="${empty sessionScope.currentUser}">
                        alert('Please login to rate guides.');
                        return;
                    </c:if>

                    fetch('${pageContext.request.contextPath}/guides/rate', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'guideId=${guide.guideId}&rating=' + rating
                    })
                        .then(response => response.json())
                        .then(data => {
                            document.getElementById('upCount').textContent = data.upCount;
                            document.getElementById('downCount').textContent = data.downCount;

                            document.getElementById('upBtn').classList.remove('active-up');
                            document.getElementById('downBtn').classList.remove('active-down');

                            if (data.userRating === 'UP') {
                                document.getElementById('upBtn').classList.add('active-up');
                            } else if (data.userRating === 'DOWN') {
                                document.getElementById('downBtn').classList.add('active-down');
                            }
                        })
                        .catch(err => console.error('Rating error:', err));
                }

                function openFlagModal() {
                    document.getElementById('flagModal').classList.add('active');
                }

                function closeFlagModal() {
                    document.getElementById('flagModal').classList.remove('active');
                    document.getElementById('flagReason').value = '';
                    document.getElementById('flagDescription').value = '';
                }

                function submitFlag() {
                    var reason = document.getElementById('flagReason').value;
                    var description = document.getElementById('flagDescription').value;

                    if (!reason) {
                        alert('Please select a reason for flagging.');
                        return;
                    }

                    fetch('${pageContext.request.contextPath}/guides/flag', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'guideId=${guide.guideId}&reason=' + encodeURIComponent(reason) + '&description=' + encodeURIComponent(description)
                    })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                closeFlagModal();
                                // Replace the flag button with "Flagged" state
                                var flagBtns = document.querySelectorAll('.flag-btn');
                                flagBtns.forEach(function(btn) {
                                    btn.classList.add('flagged');
                                    btn.disabled = true;
                                    btn.innerHTML = '<i class="ph-fill ph-flag"></i> Flagged';
                                    btn.onclick = null;
                                });
                                alert(data.message);
                            } else {
                                alert(data.message || data.error || 'Failed to submit flag.');
                            }
                        })
                        .catch(err => {
                            console.error('Flag error:', err);
                            alert('An error occurred. Please try again.');
                        });
                }

                // Close modal when clicking outside
                document.getElementById('flagModal').addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeFlagModal();
                    }
                });

                function toggleForm(id) {
                    var el = document.getElementById(id);
                    if (el) {
                        el.style.display = el.style.display === 'block' ? 'none' : 'block';
                    }
                }
            </script>
        </body>

        </html>