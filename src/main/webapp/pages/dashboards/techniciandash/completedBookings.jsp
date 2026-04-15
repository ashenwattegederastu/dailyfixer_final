<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ page import="com.dailyfixer.model.User" %>
<% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null || !"technician".equalsIgnoreCase(user.getRole().trim())) {
    response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); return;
} %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Completed Bookings | Technician | Daily Fixer</title>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                            rel="stylesheet">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    </head>

                    <body class="dashboard-layout">
                        <jsp:include page="sidebar.jsp" />

                        <main class="dashboard-container">
                            <header class="dashboard-header">
                                <h1>Completed Bookings</h1>
                                <p>View your past completed service jobs</p>
                            </header>

                            <c:if test="${param.confirmed}">
                                <div
                                    style="padding: 1rem; border-radius: 8px; margin-bottom: 1rem; background: #d1fae5; color: #065f46; font-weight: 500;">
                                    Booking confirmed by the customer!
                                </div>
                            </c:if>

                            <c:if test="${param.rated}">
                                <div style="padding:1rem; border-radius:8px; margin-bottom:1rem; background:#d1fae5; color:#065f46; font-weight:500;">
                                    Client rated successfully!
                                </div>
                            </c:if>

                            <c:if test="${param.penaltyConfirmed}">
                                <div style="padding:1rem; border-radius:8px; margin-bottom:1rem; background:#d1fae5; color:#065f46; font-weight:500;">
                                    Payment confirmed — the no-show penalty is resolved and the booking is now marked completed.
                                </div>
                            </c:if>

                            <c:if test="${param.penaltyDisputed}">
                                <div style="padding:1rem; border-radius:8px; margin-bottom:1rem; background:#fef3c7; color:#92400e; font-weight:500;">
                                    Payment disputed — the case has been escalated to an admin for review.
                                </div>
                            </c:if>

                            <div class="section">
                                <div class="table-container">
                                    <c:choose>
                                        <c:when test="${empty completedBookings}">
                                            <div class="empty-state">
                                                <h3>No Completed Bookings</h3>
                                                <p>Your finished jobs will appear here once they are completed.</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <table>
                                                <thead>
                                                    <tr>
                                                        <th>Service</th>
                                                        <th>Customer</th>
                                                        <th>Date &amp; Time</th>
                                                        <th>Status</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="b" items="${completedBookings}">
                                                        <tr>
                                                            <td>
                                                                <strong>${b.serviceName}</strong><br>
                                                                <small>${b.problemDescription}</small>
                                                            </td>
                                                            <td>${b.userName}</td>
                                                            <td>
                                                                <fmt:formatDate value="${b.bookingDate}"
                                                                    pattern="MMM dd, yyyy" /><br>
                                                                <fmt:formatDate value="${b.bookingTime}"
                                                                    pattern="hh:mm a" type="time" />
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${b.status eq 'FULLY_COMPLETED'}">
                                                                        <span class="status-badge"
                                                                            style="background: #d1fae5; color: #065f46;">Fully
                                                                            Completed</span>
                                                                    </c:when>
                                                                    <c:when
                                                                        test="${b.status eq 'TECHNICIAN_COMPLETED'}">
                                                                        <span class="status-badge"
                                                                            style="background: #e0e7ff; color: #3730a3;">Awaiting
                                                                            User Confirm</span>
                                                                    </c:when>
                                                                    <c:when test="${b.status eq 'NO_SHOW'}">
                                                                        <span class="status-badge" style="background:#fef3c7;color:#92400e;">No Show</span>
                                                                    </c:when>
                                                                    <c:when test="${b.status eq 'CLIENT_NO_SHOW'}">
                                                                        <c:set var="cp" value="${clientNoShowPenalties[b.bookingId]}"/>
                                                                        <span class="status-badge" style="background:#fce7f3;color:#9d174d;">Client Not Home</span>
                                                                        <c:if test="${not empty cp}">
                                                                            <div style="margin-top:0.4rem;font-size:0.8rem;color:var(--muted-foreground);">
                                                                                Penalty:
                                                                                <c:choose>
                                                                                    <c:when test="${cp.status eq 'PENDING'}"><strong style="color:#92400e;">Awaiting client payment</strong></c:when>
                                                                                    <c:when test="${cp.status eq 'PROOF_UPLOADED'}"><strong style="color:#1d4ed8;">Receipt uploaded — action required</strong></c:when>
                                                                                    <c:when test="${cp.status eq 'CONFIRMED_PAID'}"><strong style="color:#065f46;">Confirmed paid &#10003;</strong></c:when>
                                                                                    <c:when test="${cp.status eq 'ADMIN_REVIEW'}"><strong style="color:#7c3aed;">Disputed — under admin review</strong></c:when>
                                                                                    <c:when test="${cp.status eq 'RESOLVED'}"><strong style="color:#065f46;">Resolved by admin &#10003;</strong></c:when>
                                                                                    <c:when test="${cp.status eq 'FRAUD_SUSPENDED'}"><strong style="color:#7f1d1d;">Fraud — client suspended</strong></c:when>
                                                                                </c:choose>
                                                                            </div>
                                                                        </c:if>
                                                                    </c:when>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${b.status eq 'FULLY_COMPLETED' and !ratedBookingIds.contains(b.bookingId)}">
                                                                        <button onclick="openRateModal(${b.bookingId})"
                                                                            style="background:#f59e0b; color:white; border:none; padding:0.35rem 0.8rem; border-radius:4px; font-size:0.8rem; cursor:pointer; font-weight:600;">
                                                                            &#9733; Rate Client
                                                                        </button>
                                                                    </c:when>
                                                                    <c:when test="${b.status eq 'FULLY_COMPLETED'}">
                                                                        <span style="font-size:0.8rem; color:var(--muted-foreground);">Rated &#10003;</span>
                                                                    </c:when>
                                                                    <c:when test="${b.status eq 'NO_SHOW'}">
                                                                        <span style="font-size:0.8rem;color:var(--muted-foreground);">—</span>
                                                                    </c:when>
                                                                    <c:when test="${b.status eq 'CLIENT_NO_SHOW'}">
                                                                        <c:set var="cp" value="${clientNoShowPenalties[b.bookingId]}"/>
                                                                        <c:choose>
                                                                            <c:when test="${not empty cp and cp.status eq 'PROOF_UPLOADED'}">
                                                                                <%-- Technician can view receipt and take action --%>
                                                                                <div style="display:flex;flex-direction:column;gap:0.5rem;">
                                                                                    <a href="${pageContext.request.contextPath}/${cp.proofPath}" target="_blank"
                                                                                       style="background:#4f46e5;color:white;padding:0.35rem 0.8rem;border-radius:4px;font-size:0.8rem;font-weight:600;text-decoration:none;text-align:center;">View Receipt</a>
                                                                                    <div style="display:flex;gap:0.4rem;">
                                                                                        <form method="post" action="${pageContext.request.contextPath}/technician/client-penalty/review" style="flex:1;">
                                                                                            <input type="hidden" name="penaltyId" value="${cp.penaltyId}">
                                                                                            <input type="hidden" name="action" value="confirm">
                                                                                            <button type="submit" style="width:100%;background:#10b981;color:white;border:none;padding:0.35rem 0.5rem;border-radius:4px;font-size:0.78rem;font-weight:600;cursor:pointer;">Confirm Paid</button>
                                                                                        </form>
                                                                                        <form method="post" action="${pageContext.request.contextPath}/technician/client-penalty/review" style="flex:1;">
                                                                                            <input type="hidden" name="penaltyId" value="${cp.penaltyId}">
                                                                                            <input type="hidden" name="action" value="dispute">
                                                                                            <button type="submit" style="width:100%;background:#ef4444;color:white;border:none;padding:0.35rem 0.5rem;border-radius:4px;font-size:0.78rem;font-weight:600;cursor:pointer;">Not Paid</button>
                                                                                        </form>
                                                                                    </div>
                                                                                </div>
                                                                            </c:when>
                                                                            <c:when test="${not empty cp and cp.status eq 'PENDING'}">
                                                                                <span style="font-size:0.8rem;color:var(--muted-foreground);">Awaiting client payment</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span style="font-size:0.8rem;color:var(--muted-foreground);">—</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </c:when>
                                                                    <c:otherwise>&mdash;</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </main>

                        <!-- Rate Client Modal -->
                        <div id="rateClientModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; align-items:center; justify-content:center;">
                            <div style="background:var(--card); padding:2rem; border-radius:var(--radius); max-width:440px; width:90%; box-shadow:0 10px 40px rgba(0,0,0,0.25);">
                                <h3 style="font-size:1.3rem; font-weight:700; margin-bottom:1rem;">Rate This Client</h3>
                                <form method="post" action="${pageContext.request.contextPath}/bookings/rate">
                                    <input type="hidden" name="bookingId" id="rateBookingId">
                                    <input type="hidden" name="ratingType" value="CLIENT_RATING">
                                    <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/technician/bookings/completed">
                                    <div style="margin-bottom:1rem;">
                                        <label style="display:block; font-weight:600; margin-bottom:0.5rem;">Star Rating *</label>
                                        <div style="display:flex; gap:0.5rem; font-size:2rem;">
                                            <c:forEach var="s" begin="1" end="5">
                                                <label style="cursor:pointer; color:#d1d5db;">
                                                    <input type="radio" name="rating" value="${s}" required style="display:none;" onclick="highlightStars(this, ${s})">
                                                    <span class="star-label" data-val="${s}">&#9733;</span>
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <div style="margin-bottom:1.2rem;">
                                        <label style="display:block; font-weight:600; margin-bottom:0.5rem;">Comment (optional)</label>
                                        <textarea name="review" rows="3" placeholder="Leave a comment about this client..."
                                            style="width:100%; padding:0.75rem; border:1px solid var(--border); border-radius:4px; background:var(--input); resize:vertical;"></textarea>
                                    </div>
                                    <div style="display:flex; gap:1rem;">
                                        <button type="submit" style="flex:1; background:#10b981; color:white; padding:0.75rem; border:none; border-radius:4px; font-weight:600; cursor:pointer;">Submit Rating</button>
                                        <button type="button" onclick="closeRateModal()" style="flex:1; background:var(--secondary); color:var(--secondary-foreground); padding:0.75rem; border:none; border-radius:4px; font-weight:600; cursor:pointer;">Cancel</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <script>
                            function openRateModal(bookingId) {
                                document.getElementById('rateBookingId').value = bookingId;
                                document.getElementById('rateClientModal').style.display = 'flex';
                            }
                            function closeRateModal() {
                                document.getElementById('rateClientModal').style.display = 'none';
                            }
                            function highlightStars(radio, val) {
                                document.querySelectorAll('.star-label').forEach(function(s) {
                                    s.style.color = parseInt(s.dataset.val) <= val ? '#f59e0b' : '#d1d5db';
                                });
                            }
                        </script>
                    </body>
                    </html>