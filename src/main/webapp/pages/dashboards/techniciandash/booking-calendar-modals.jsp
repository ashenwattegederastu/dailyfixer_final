<%-- booking-calendar-modals.jsp: All modal overlays for booking-calendar.jsp --%>

<%-- ═══ Cancel Booking Modal ══════════════════════════════════════════════ --%>
<div id="cancelModal" class="modal-overlay">
    <div class="modal-content">
        <h3>Cancel Booking</h3>
        <form id="cancelForm" method="post" action="${pageContext.request.contextPath}/bookings/cancel">
            <input type="hidden" name="bookingId" id="cancelBookingId">
            <div class="form-group">
                <label class="form-label">Reason for Cancellation *</label>
                <textarea name="cancellationReason" required rows="4"
                          placeholder="Please provide a reason..."
                          class="form-input"></textarea>
            </div>
            <div class="modal-actions">
                <button type="submit" class="btn-cancel-booking">Cancel Booking</button>
                <button type="button" class="btn-secondary" onclick="closeCancelModal()">Close</button>
            </div>
        </form>
    </div>
</div>

<%-- ═══ Reschedule Request Modal ══════════════════════════════════════════ --%>
<div id="rescheduleModal" class="modal-overlay">
    <div class="modal-content">
        <h3>Request Reschedule</h3>
        <form id="rescheduleForm" method="post"
              action="${pageContext.request.contextPath}/bookings/reschedule/request">
            <input type="hidden" name="bookingId" id="rescheduleBookingId">
            <div class="form-group">
                <label class="form-label">New Date *</label>
                <input type="date" name="newDate" id="rescheduleNewDate" required class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label">New Time *</label>
                <input type="time" name="newTime" id="rescheduleNewTime" required class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label">Reason (optional)</label>
                <textarea name="reason" rows="3" placeholder="Provide a reason for rescheduling..."
                          class="form-input"></textarea>
            </div>
            <div class="modal-actions">
                <button type="submit" class="btn-complete">Submit Request</button>
                <button type="button" class="btn-secondary" onclick="closeRescheduleModal()">Close</button>
            </div>
        </form>
    </div>
</div>

<%-- ═══ Client Not Home Modal ═════════════════════════════════════════════ --%>
<div id="clientNoShowModal" class="modal-overlay">
    <div class="modal-content" style="max-width: 460px;">
        <h3 style="color: #9d174d;">&#9888; Mark Client Not Home</h3>
        <p class="modal-subtitle">
            You are about to record that the client was not available at the scheduled location.
            A <strong>Rs. 2,500 no-show penalty</strong> will be applied to the client's account.
            This action cannot be undone.
        </p>
        <form id="clientNoShowForm" method="post"
              action="${pageContext.request.contextPath}/bookings/client-no-show"
              enctype="multipart/form-data">
            <input type="hidden" name="bookingId" id="clientNoShowBookingId">
            <div class="form-group">
                <label class="form-label">Arrival Proof Photo (JPG or PNG, max 5 MB) *</label>
                <p class="modal-subtitle" style="margin-top: -0.75rem; margin-bottom: 0.5rem;">
                    Upload a photo showing the client's door / location to confirm you arrived.
                </p>
                <input type="file" name="techProofFile" id="techProofFileInput"
                       accept="image/jpeg,image/png" required class="form-input">
                <div id="techProofFileError"
                     style="color: var(--destructive); font-size: 0.8em; margin-top: 0.3rem; display: none;"></div>
            </div>
            <div class="modal-actions">
                <button type="submit" class="btn-client-no-show">Confirm &#8211; Client Not Home</button>
                <button type="button" class="btn-secondary" onclick="closeClientNoShowModal()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<%-- ═══ Booking Detail Modal (calendar click) ════════════════════════════ --%>
<div id="detailModal" class="modal-overlay">
    <div class="modal-content">
        <h3 id="detailServiceName"></h3>
        <div class="info-block" style="margin-bottom: 0.75rem;">
            <p><strong>Customer:</strong> <span id="detailCustomer"></span></p>
            <p><strong>Phone:</strong>    <span id="detailPhone"></span></p>
            <p><strong>Date:</strong>     <span id="detailDate"></span></p>
            <p><strong>Status:</strong>   <span id="detailStatusBadge"></span></p>
        </div>
        <div class="info-block" style="margin-bottom: 0.75rem;">
            <p class="label">Problem Description:</p>
            <p id="detailProblem"></p>
        </div>
        <div class="info-block" style="margin-bottom: 1rem;">
            <p class="label">Location:</p>
            <p id="detailAddress"></p>
            <a id="detailMapLink" href="#" target="_blank"
               style="color: var(--primary); text-decoration: underline; display: none; margin-top: 0.25rem;">
                View on Google Maps
            </a>
        </div>
        <div id="detailActions" class="booking-actions"></div>
        <div style="margin-top: 1rem; text-align: right;">
            <button onclick="closeDetailModal()" class="btn-secondary">Close</button>
        </div>
    </div>
</div>
