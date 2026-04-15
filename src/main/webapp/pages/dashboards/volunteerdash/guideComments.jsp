<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="java.util.*,com.dailyfixer.dao.GuideCommentDAO,com.dailyfixer.model.GuideComment" %>
            <%@ page import="java.text.SimpleDateFormat" %>
                <%@ page import="com.dailyfixer.model.User" %>

                    <% User currentUser=(User) session.getAttribute("currentUser"); if (currentUser==null ||
                        (!"volunteer".equalsIgnoreCase(currentUser.getRole()) &&
                        !"technician".equalsIgnoreCase(currentUser.getRole()))) {
                        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); return; } int
                        userId=currentUser.getUserId(); GuideCommentDAO dao=new GuideCommentDAO(); List<GuideComment>
                        myComments = dao.getCommentsByGuideOwner(userId);
                        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                        %>

                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>Guide Comments | Daily Fixer</title>
                            <link
                                href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                                rel="stylesheet">
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

                                .comments-list {
                                    display: flex;
                                    flex-direction: column;
                                    gap: 15px;
                                }

                                .comment-card {
                                    background: var(--card);
                                    border: 1px solid var(--border);
                                    border-radius: var(--radius-md);
                                    padding: 20px;
                                    box-shadow: var(--shadow-sm);
                                    transition: all 0.2s;
                                }

                                .comment-card:hover {
                                    box-shadow: var(--shadow-md);
                                }

                                .comment-header {
                                    display: flex;
                                    justify-content: space-between;
                                    align-items: center;
                                    margin-bottom: 10px;
                                    border-bottom: 1px solid var(--border);
                                    padding-bottom: 10px;
                                }

                                .commenter-info {
                                    display: flex;
                                    align-items: center;
                                    gap: 10px;
                                }

                                .commenter-avatar {
                                    width: 40px;
                                    height: 40px;
                                    border-radius: 50%;
                                    background-color: var(--primary);
                                    color: var(--primary-foreground);
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    font-weight: bold;
                                    font-size: 1.2em;
                                }

                                .guide-link {
                                    font-size: 0.9em;
                                    color: var(--muted-foreground);
                                    text-decoration: none;
                                    display: flex;
                                    align-items: center;
                                    gap: 5px;
                                }

                                .guide-link:hover {
                                    color: var(--primary);
                                    text-decoration: underline;
                                }

                                .comment-body {
                                    font-size: 1rem;
                                    color: var(--foreground);
                                    line-height: 1.5;
                                    margin-bottom: 15px;
                                }

                                .comment-meta {
                                    font-size: 0.85em;
                                    color: var(--muted-foreground);
                                    display: flex;
                                    justify-content: space-between;
                                    align-items: center;
                                }

                                .empty-state {
                                    text-align: center;
                                    padding: 60px;
                                    color: var(--muted-foreground);
                                    background: var(--card);
                                    border-radius: var(--radius-lg);
                                    border: 1px solid var(--border);
                                }

                                .empty-state h3 {
                                    color: var(--foreground);
                                    margin-bottom: 10px;
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

                                .reply-action-btn {
                                    background: transparent;
                                    border: none;
                                    cursor: pointer;
                                    font-size: 0.82rem;
                                    padding: 0;
                                    margin-right: 8px;
                                }

                                .reply-action-btn.primary { color: var(--primary); }
                                .reply-action-btn.danger { color: var(--destructive); }

                                .inline-reply-form {
                                    display: none;
                                    margin-top: 10px;
                                }

                                .inline-reply-form textarea {
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
                                    box-sizing: border-box;
                                }

                                .inline-form-actions {
                                    display: flex;
                                    gap: 8px;
                                }
                            </style>
                        </head>

                        <body>
                            <c:choose>
                                <c:when test="${sessionScope.currentUser.role == 'technician'}">
                                    <jsp:include page="/pages/dashboards/techniciandash/sidebar.jsp" />
                                </c:when>
                                <c:otherwise>
                                    <jsp:include page="/pages/dashboards/volunteerdash/sidebar.jsp" />
                                </c:otherwise>
                            </c:choose>
                            <main class="container">
                                <h2>Guide Comments</h2>
                                <p style="color: var(--muted-foreground); margin-bottom: 25px;">Track all feedback on
                                    your
                                    contributions.</p>

                                <% if (myComments !=null && !myComments.isEmpty()) { %>
                                    <div class="comments-list">
                                        <% for (GuideComment c : myComments) { %>
                                            <div class="comment-card">
                                                <div class="comment-header">
                                                    <div class="commenter-info">
                                                        <div class="commenter-avatar">
                                                            <%= c.getUsername().substring(0, 1).toUpperCase() %>
                                                        </div>
                                                        <div>
                                                            <span style="font-weight: 600; color: var(--foreground);">
                                                                <%= c.getUsername() %>
                                                            </span>
                                                            <br>
                                                            <span
                                                                style="font-size: 0.8em; color: var(--muted-foreground);">
                                                                <%= sdf.format(c.getCreatedAt()) %>
                                                            </span>
                                                        </div>
                                                    </div>
                                                    <a href="${pageContext.request.contextPath}/guides/view?id=<%= c.getGuideId() %>"
                                                        class="guide-link">
                                                        On: <strong>
                                                            <%= c.getGuideTitle() %>
                                                        </strong> ↗
                                                    </a>
                                                </div>

                                                <div class="comment-body">
                                                    <%= c.getComment() %>
                                                </div>

                                                <% if (c.getReply() != null && !c.getReply().isEmpty()) { %>
                                                    <div class="creator-reply">
                                                        <div class="creator-reply-label">Your Reply</div>
                                                        <div class="creator-reply-text"><%= c.getReply() %></div>
                                                        <div class="creator-reply-date"><%= sdf.format(c.getReplyAt()) %></div>
                                                        <div style="margin-top:8px;">
                                                            <button type="button" class="reply-action-btn primary"
                                                                onclick="toggleForm('editreply-<%= c.getCommentId() %>')">Edit Reply</button>
                                                            <form action="<%= request.getContextPath() %>/guides/comment" method="post" style="display:inline;">
                                                                <input type="hidden" name="guideId" value="<%= c.getGuideId() %>">
                                                                <input type="hidden" name="commentId" value="<%= c.getCommentId() %>">
                                                                <input type="hidden" name="action" value="deleteReply">
                                                                <button type="submit" class="reply-action-btn danger">Delete Reply</button>
                                                            </form>
                                                        </div>
                                                        <div class="inline-reply-form" id="editreply-<%= c.getCommentId() %>">
                                                            <form action="<%= request.getContextPath() %>/guides/comment" method="post">
                                                                <input type="hidden" name="guideId" value="<%= c.getGuideId() %>">
                                                                <input type="hidden" name="commentId" value="<%= c.getCommentId() %>">
                                                                <input type="hidden" name="action" value="editReply">
                                                                <textarea name="reply" required><%= c.getReply() %></textarea>
                                                                <div class="inline-form-actions">
                                                                    <button type="submit" class="btn-primary" style="font-size:0.82rem; padding:6px 14px;">Save</button>
                                                                    <button type="button" class="btn-secondary" style="font-size:0.82rem; padding:6px 14px;"
                                                                        onclick="toggleForm('editreply-<%= c.getCommentId() %>')">Cancel</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                <% } else { %>
                                                    <div style="margin-top:8px;">
                                                        <button type="button" class="reply-action-btn primary"
                                                            onclick="toggleForm('reply-<%= c.getCommentId() %>')">Reply</button>
                                                    </div>
                                                    <div class="inline-reply-form" id="reply-<%= c.getCommentId() %>">
                                                        <form action="<%= request.getContextPath() %>/guides/comment" method="post">
                                                            <input type="hidden" name="guideId" value="<%= c.getGuideId() %>">
                                                            <input type="hidden" name="commentId" value="<%= c.getCommentId() %>">
                                                            <input type="hidden" name="action" value="reply">
                                                            <textarea name="reply" placeholder="Write your reply..." required></textarea>
                                                            <div class="inline-form-actions">
                                                                <button type="submit" class="btn-primary" style="font-size:0.82rem; padding:6px 14px;">Post Reply</button>
                                                                <button type="button" class="btn-secondary" style="font-size:0.82rem; padding:6px 14px;"
                                                                    onclick="toggleForm('reply-<%= c.getCommentId() %>')">Cancel</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <% } %>
                                    </div>
                                    <% } else { %>
                                        <div class="empty-state">
                                            <h3>No comments yet</h3>
                                            <p>When users comment on your guides, they will appear here.</p>
                                        </div>
                                        <% } %>
                            </main>
                            <script>
                                function toggleForm(id) {
                                    var el = document.getElementById(id);
                                    if (el) {
                                        el.style.display = el.style.display === 'block' ? 'none' : 'block';
                                    }
                                }
                            </script>
                        </body>

                        </html>