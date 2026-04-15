<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Requests - Technician Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
</head>
<body>
    <jsp:include page="sidebar.jsp" />
    
    <div class="dashboard-container">
        <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; color: var(--foreground);">Booking Requests</h1>
        
        <c:if test="${param.accepted}">
            <div style="background: #10b981; color: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                Booking accepted successfully! Chat has been created.
            </div>
        </c:if>
        
        <c:if test="${param.rejected}">
            <div style="background: #f59e0b; color: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                Booking rejected.
            </div>
        </c:if>

        <c:if test="${param.limitReached}">
            <div style="background: #ef4444; color: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                &#9888; You have reached your daily booking limit for <strong>${param.date}</strong>.
                You cannot accept more bookings on that day. Try a different date or increase your daily limit in your profile settings.
            </div>
        </c:if>
        
        <c:if test="${empty bookingRequests}">
            <div style="text-align: center; padding: 3rem; background: var(--card); border-radius: var(--radius);">
                <p style="font-size: 1.125rem; color: var(--muted-foreground);">No pending booking requests.</p>
            </div>
        </c:if>
        
        <div style="display: grid; gap: 1.5rem;">
            <c:forEach var="booking" items="${bookingRequests}">
                <div style="background: var(--card); border-radius: var(--radius); padding: 1.5rem; box-shadow: var(--shadow-sm); border: 1px solid var(--border);">
                    <div style="display: grid; grid-template-columns: 1fr auto; gap: 1rem; margin-bottom: 1rem;">
                        <div>
                            <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 0.5rem;">
                                ${booking.serviceName}
                                <c:if test="${not empty booking.recurringContractId}">
                                    <span style="display: inline-block; background: #dbeafe; color: #1e40af; border-radius: 4px; padding: 2px 8px; font-size: 0.75rem; font-weight: 700; margin-left: 6px; vertical-align: middle;">
                                        &#8635; Recurring
                                    </span>
                                </c:if>
                            </h3>
                            <p style="color: var(--muted-foreground); margin-bottom: 0.25rem;">  
                                <strong>Customer:</strong> ${booking.userName}
                                <c:set var="clientRating" value="${userAvgRatings[booking.userId]}"/>
                                <c:choose>
                                    <c:when test="${clientRating > 0}">
                                        <span style="display: inline-flex; align-items: center; gap: 3px; background: #fef3c7; color: #92400e; border-radius: 4px; padding: 1px 7px; font-size: 0.78rem; margin-left: 6px; font-weight: 600;">
                                            ★ <fmt:formatNumber value="${clientRating}" maxFractionDigits="1" minFractionDigits="1"/>
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="display: inline-block; background: var(--accent); color: var(--accent-foreground); border-radius: 4px; padding: 1px 7px; font-size: 0.78rem; margin-left: 6px;">New Client</span>
                                    </c:otherwise>
                                </c:choose>
                            </p>
                            <p style="color: var(--muted-foreground); margin-bottom: 0.25rem;"><strong>Phone:</strong> ${booking.phoneNumber}</p>
                            <p style="color: var(--muted-foreground); margin-bottom: 0.25rem;"><strong>Date:</strong> ${booking.bookingDate} at ${booking.bookingTime}</p>
                        </div>
                        <div>
                            <span style="display: inline-block; background: var(--accent); color: var(--accent-foreground); padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.875rem; font-weight: 600;">
                                PENDING
                            </span>
                        </div>
                    </div>
                    
                    <div style="background: var(--muted); padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                        <p style="font-weight: 600; margin-bottom: 0.5rem;">Problem Description:</p>
                        <p style="color: var(--muted-foreground);">${booking.problemDescription}</p>
                    </div>
                    
                    <div style="background: var(--muted); padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                        <p style="font-weight: 600; margin-bottom: 0.5rem;">Location:</p>
                        <p style="color: var(--muted-foreground); margin-bottom: 0.5rem;">${booking.locationAddress}</p>
                        <c:if test="${not empty booking.locationLatitude && not empty booking.locationLongitude}">
                            <a href="https://www.google.com/maps?q=${booking.locationLatitude},${booking.locationLongitude}" target="_blank"
                               style="color: var(--primary); text-decoration: underline;">View on Google Maps</a>
                        </c:if>
                    </div>
                    
                    <c:if test="${booking.recurringSequence == 1}">
                    <div style="background: #fef3c7; border: 1px solid #fcd34d; border-radius: 0.5rem; padding: 0.75rem 1rem; margin-bottom: 1rem;">
                        <p style="color: #92400e; font-size: 0.875rem; margin: 0; font-weight: 600;">
                            &#9888; Recurring Contract: Accepting this booking will activate a <strong>1-year recurring contract</strong>.
                            Months 2–12 will be automatically scheduled on the same day each month.
                        </p>
                    </div>
                    </c:if>

                    <div style="display: flex; gap: 1rem;">
                        <form method="post" action="${pageContext.request.contextPath}/bookings/accept" style="flex: 1;">
                            <input type="hidden" name="bookingId" value="${booking.bookingId}">
                            <button type="submit" style="width: 100%; background: #10b981; color: white; padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                                Accept
                            </button>
                        </form>
                        <button onclick="showRejectModal(${booking.bookingId})" 
                                style="flex: 1; background: var(--destructive); color: var(--destructive-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                            Reject
                        </button>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    
    <!-- Reject Modal -->
    <div id="rejectModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
        <div style="background: var(--card); padding: 2rem; border-radius: var(--radius); max-width: 500px; width: 90%;">
            <h3 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 1rem;">Reject Booking</h3>
            <form id="rejectForm" method="post" action="${pageContext.request.contextPath}/bookings/reject">
                <input type="hidden" name="bookingId" id="rejectBookingId">
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Reason for Rejection *</label>
                    <textarea name="rejectionReason" required rows="4" placeholder="Please provide a reason..."
                              style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input); resize: vertical;"></textarea>
                </div>
                <div style="display: flex; gap: 1rem;">
                    <button type="submit" style="flex: 1; background: var(--destructive); color: var(--destructive-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                        Reject Booking
                    </button>
                    <button type="button" onclick="closeRejectModal()" style="flex: 1; background: var(--secondary); color: var(--secondary-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function showRejectModal(bookingId) {
            document.getElementById('rejectBookingId').value = bookingId;
            document.getElementById('rejectModal').style.display = 'flex';
        }
        
        function closeRejectModal() {
            document.getElementById('rejectModal').style.display = 'none';
        }
    </script>
</body>
</html>
