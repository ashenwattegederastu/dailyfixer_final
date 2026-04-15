<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
  User user = (User) session.getAttribute("currentUser");
  if (user == null || user.getRole() == null || !"driver".equalsIgnoreCase(user.getRole().trim())) {
    response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
    return;
  }
  Double savedLat = user.getLatitude();
  Double savedLng = user.getLongitude();
  boolean hasLocation = savedLat != null && savedLng != null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
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

/* Profile Card */
.profile-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
    overflow: hidden;
    margin-bottom: 20px;
}
.profile-image {
    background: var(--muted);
    padding: 30px;
    text-align: center;
    border-bottom: 1px solid var(--border);
}
.profile-image img {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    object-fit: cover;
    border: 4px solid var(--primary);
    margin-bottom: 15px;
}
.profile-image h2 {
    font-size: 1.4em;
    margin-bottom: 5px;
    color: var(--foreground);
}
.profile-image .role {
    color: var(--primary);
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.9em;
}

/* Profile Details */
.profile-details {
    padding: 30px;
}
.profile-details table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 25px;
}
.profile-details th, .profile-details td {
    padding: 12px 15px;
    text-align: left;
    border-bottom: 1px solid var(--border);
}
.profile-details th {
    background: var(--muted);
    font-weight: 600;
    color: var(--foreground);
    width: 30%;
}
.profile-details td {
    color: var(--muted-foreground);
    font-weight: 500;
}

/* Profile Buttons */
.profile-buttons {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
}
.profile-buttons .btn {
    padding: 12px 24px;
    border: none;
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    text-decoration: none;
    display: inline-block;
    transition: all 0.2s;
    box-shadow: var(--shadow-sm);
}
.profile-buttons .btn.reset {
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: #fff;
}
.profile-buttons .btn.edit {
    background: var(--primary);
    color: var(--primary-foreground);
}
.profile-buttons .btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}

/* Location Card */
.location-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
    overflow: hidden;
    margin-top: 20px;
}
.location-card .location-header {
    background: var(--muted);
    padding: 20px 30px;
    border-bottom: 1px solid var(--border);
}
.location-card .location-header h3 {
    font-size: 1.1em;
    font-weight: 700;
    color: var(--foreground);
    margin-bottom: 4px;
}
.location-card .location-header p {
    font-size: 0.85em;
    color: var(--muted-foreground);
}
.location-card .location-body {
    padding: 24px 30px;
}
#profile-map-search {
    width: 100%;
    padding: 10px 14px;
    border: 2px solid var(--border);
    border-radius: var(--radius-md);
    background: var(--input, #fff);
    color: var(--foreground);
    font-family: var(--font-sans), sans-serif;
    font-size: 0.9rem;
    transition: all 0.2s ease;
    margin-bottom: 12px;
}
#profile-map-search:focus {
    outline: none;
    border-color: var(--ring, var(--primary));
}
#locationMap {
    width: 100%;
    height: 320px;
    border-radius: var(--radius-md);
    border: 1px solid var(--border);
    margin-bottom: 16px;
}
.location-card .location-instructions {
    font-size: 0.85em;
    color: var(--muted-foreground);
    margin-bottom: 14px;
}
.location-card .save-location-btn {
    padding: 11px 28px;
    background: var(--primary);
    color: var(--primary-foreground);
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.9rem;
    cursor: pointer;
    box-shadow: var(--shadow-sm);
    transition: all 0.2s;
}
.location-card .save-location-btn:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    opacity: 0.9;
}
.location-card .save-location-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
}
#locationStatus {
    margin-top: 10px;
    font-size: 0.9em;
    font-weight: 600;
}
#locationStatus.success { color: #28a745; }
#locationStatus.error   { color: #dc3545; }
.no-location-warning {
    margin-bottom: 14px;
    font-size: 0.9em;
    color: #c0392b;
    font-weight: 600;
}

.section-title {
    font-size: 1.2em;
    font-weight: 700;
    color: var(--foreground);
    margin: 28px 0 16px;
}

/* Bank status card */
.bank-status-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    box-shadow: var(--shadow-sm);
    padding: 22px 28px;
    display: flex;
    align-items: center;
    gap: 20px;
}
.bank-icon, .bank-icon-none {
    width: 50px; height: 50px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.bank-icon      { background: oklch(0.9 0.12 145); color: oklch(0.35 0.15 145); }
.bank-icon-none { background: var(--muted); color: var(--muted-foreground); }
.bank-name   { font-size: 1em; font-weight: 700; color: var(--foreground); margin-bottom: 4px; }
.bank-detail { font-size: 0.87em; color: var(--muted-foreground); font-family: 'IBM Plex Mono', monospace; }
.bank-empty  { color: var(--muted-foreground); font-size: 0.95em; }

/* Modal */
.modal-overlay {
    position: fixed; inset: 0; background: rgba(0,0,0,0.5);
    z-index: 1000; display: flex; align-items: center; justify-content: center;
}
.modal-box {
    background: var(--card); border-radius: var(--radius-lg);
    border: 1px solid var(--border); box-shadow: var(--shadow-xl);
    padding: 32px; width: 520px; max-width: 95vw;
    max-height: 90vh; overflow-y: auto;
}
.modal-box h3 { font-size: 1.1em; font-weight: 700; color: var(--foreground); margin: 0 0 22px; }
.field-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 18px; }
.form-group { display: flex; flex-direction: column; }
.form-group label { font-weight: 600; font-size: 0.84rem; color: var(--foreground); margin-bottom: 6px; }
.form-group input {
    padding: 10px 14px; border: 1px solid var(--border);
    border-radius: var(--radius-md); font-size: 0.9rem;
    background: var(--background); color: var(--foreground);
    font-family: 'Plus Jakarta Sans', sans-serif; transition: border-color 0.2s;
}
.form-group input:focus { outline: none; border-color: var(--primary); }
.modal-actions { display: flex; gap: 12px; justify-content: flex-end; }
.btn-primary {
    padding: 9px 22px;
    background: linear-gradient(135deg, var(--primary), oklch(0.6 0.2 280));
    color: #fff; border: none; border-radius: var(--radius-md);
    font-weight: 600; font-size: 0.88em; cursor: pointer; transition: all 0.2s;
    font-family: 'Plus Jakarta Sans', sans-serif;
}
.btn-primary:hover { opacity: 0.9; transform: translateY(-1px); }
.btn-outline {
    padding: 9px 22px; background: transparent; color: var(--foreground);
    border: 1px solid var(--border); border-radius: var(--radius-md);
    font-weight: 600; font-size: 0.88em; cursor: pointer; transition: all 0.2s;
    font-family: 'Plus Jakarta Sans', sans-serif;
}
.btn-outline:hover { border-color: var(--primary); color: var(--primary); background: var(--muted); }

/* Toast */
#toast {
    position: fixed; bottom: 24px; right: 24px;
    padding: 14px 22px; border-radius: var(--radius-md);
    font-weight: 600; font-size: 0.95em; z-index: 9999;
    display: none; box-shadow: var(--shadow-lg);
}
#toast.success { background: #28a745; color: #fff; }
#toast.error   { background: #dc3545; color: #fff; }
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>My Profile</h2>

    <div class="profile-card">
        <div class="profile-image">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser.profilePicturePath}">
                    <img src="${pageContext.request.contextPath}/${sessionScope.currentUser.profilePicturePath}" 
                         alt="Profile Picture" 
                         onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/default-profile.png';">
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/assets/images/default-profile.png" alt="Profile Picture">
                </c:otherwise>
            </c:choose>
            <h2>${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</h2>
            <p class="role">(${sessionScope.currentUser.role})</p>
        </div>

        <div class="profile-details">
            <table>
                <tr><th>Driver ID:</th><td>${sessionScope.currentUser.userId}</td></tr>
                <tr><th>Name:</th><td>${sessionScope.currentUser.firstName}</td></tr>
                <tr><th>Username:</th><td>${sessionScope.currentUser.username}</td></tr>
                <tr><th>Email:</th><td>${sessionScope.currentUser.email}</td></tr>
                <tr><th>Phone:</th><td>${sessionScope.currentUser.phoneNumber}</td></tr>
                <tr><th>City:</th><td>${sessionScope.currentUser.city}</td></tr>
            </table>

            <div class="profile-buttons">
                <form action="${pageContext.request.contextPath}/pages/authentication/resetPassword.jsp" method="get">
                    <button type="submit" class="btn reset">Reset Password</button>
                </form>
                <form action="${pageContext.request.contextPath}/pages/authentication/editProfile.jsp" method="get">
                    <button type="submit" class="btn edit">Edit Account Info</button>
                </form>
                <form action="${pageContext.request.contextPath}/SoftDeleteUserServlet" method="post"
                      onsubmit="return confirm('Are you sure you want to delete your account? This action cannot be undone.');">
                    <button type="submit" class="btn reset">Delete Account</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Home Base Location Card -->
    <div class="location-card">
        <div class="location-header">
            <h3>Home Base Location</h3>
            <p>Your home location is used to find nearby delivery requests within 10 km.</p>
        </div>
        <div class="location-body">
            <% if (!hasLocation) { %>
            <p class="no-location-warning">
                No location set. Please pin your home base to receive delivery requests.
            </p>
            <% } %>

            <p class="location-instructions">Search for a location or click anywhere on the map to pin your home base.</p>
            <input type="text" id="profile-map-search" placeholder="Search for location (e.g., Colombo, Kandy)...">
            <div id="locationMap"></div>

            <button class="save-location-btn" id="saveLocationBtn" onclick="saveLocation()" disabled>
                Save Location
            </button>
            <p id="locationStatus"></p>
        </div>
    </div>

    <!-- Bank Details -->
    <h3 class="section-title">Bank Details</h3>
    <div id="bankStatusContainer">
        <div class="bank-status-card">
            <div class="bank-icon-none">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5z"/>
                </svg>
            </div>
            <div class="bank-empty">Loading...</div>
        </div>
    </div>
</main>

<!-- Bank Details Modal -->
<div id="bankModal" class="modal-overlay" style="display:none">
    <div class="modal-box">
        <h3 id="bankModalTitle">Add Bank Details</h3>
        <form id="bankForm" onsubmit="saveBank(event)">
            <div class="field-grid">
                <div class="form-group">
                    <label for="bankName">Bank Name *</label>
                    <input type="text" id="bankName" name="bankName" required placeholder="e.g. Bank of Ceylon">
                </div>
                <div class="form-group">
                    <label for="branch">Branch</label>
                    <input type="text" id="branch" name="branch" placeholder="e.g. Colombo Fort">
                </div>
                <div class="form-group">
                    <label for="accountNumber">Account Number *</label>
                    <input type="text" id="accountNumber" name="accountNumber" required placeholder="e.g. 0012345678">
                </div>
                <div class="form-group">
                    <label for="accountHolderName">Account Holder Name *</label>
                    <input type="text" id="accountHolderName" name="accountHolderName" required placeholder="As it appears on the account">
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-outline" onclick="closeBankModal()">Cancel</button>
                <button type="submit" class="btn-primary">Save Details</button>
            </div>
        </form>
    </div>
</div>

<div id="toast"></div>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    const HAS_SAVED_LOC = <%= hasLocation %>;
    const SAVED_LAT = <%= hasLocation ? savedLat : "6.9271" %>;
    const SAVED_LNG = <%= hasLocation ? savedLng : "79.8612" %>;

    let map, marker;
    let pendingLat = null, pendingLng = null;

    function initDriverProfileMap() {
        const center = { lat: SAVED_LAT, lng: SAVED_LNG };

        map = new google.maps.Map(document.getElementById('locationMap'), {
            center: center,
            zoom: HAS_SAVED_LOC ? 14 : 12,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: false
        });

        if (HAS_SAVED_LOC) {
            marker = new google.maps.Marker({
                position: center,
                map: map,
                title: 'Home Base',
                animation: google.maps.Animation.DROP
            });
        }

        map.addListener('click', function(e) {
            pendingLat = e.latLng.lat();
            pendingLng = e.latLng.lng();

            if (marker) {
                marker.setPosition(e.latLng);
            } else {
                marker = new google.maps.Marker({
                    position: e.latLng,
                    map: map,
                    title: 'Home Base',
                    animation: google.maps.Animation.DROP
                });
            }

            document.getElementById('saveLocationBtn').disabled = false;
            document.getElementById('locationStatus').textContent = '';
        });

        // Initialize Places Autocomplete
        const searchInput = document.getElementById('profile-map-search');
        if (searchInput) {
            const autocomplete = new google.maps.places.Autocomplete(searchInput, {
                componentRestrictions: { country: 'lk' }, // Restrict to Sri Lanka
                fields: ['geometry', 'name']
            });

            autocomplete.addListener('place_changed', function () {
                const place = autocomplete.getPlace();

                if (place.geometry && place.geometry.location) {
                    pendingLat = place.geometry.location.lat();
                    pendingLng = place.geometry.location.lng();

                    if (marker) {
                        marker.setPosition(place.geometry.location);
                    } else {
                        marker = new google.maps.Marker({
                            position: place.geometry.location,
                            map: map,
                            title: 'Home Base',
                            animation: google.maps.Animation.DROP
                        });
                    }

                    map.setCenter(place.geometry.location);
                    map.setZoom(15);

                    document.getElementById('saveLocationBtn').disabled = false;
                    document.getElementById('locationStatus').textContent = '';
                }
            });
        }
    }

    function saveLocation() {
        if (pendingLat === null || pendingLng === null) return;

        const btn = document.getElementById('saveLocationBtn');
        const status = document.getElementById('locationStatus');
        btn.disabled = true;
        btn.textContent = 'Saving...';
        status.textContent = '';
        status.className = '';

        fetch(CONTEXT_PATH + '/driver/updateLocation', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'latitude=' + pendingLat + '&longitude=' + pendingLng
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                status.textContent = 'Location saved successfully!';
                status.className = 'success';
                pendingLat = null;
                pendingLng = null;
            } else {
                status.textContent = 'Failed to save: ' + (data.message || 'Unknown error');
                status.className = 'error';
            }
            btn.textContent = 'Save Location';
            btn.disabled = pendingLat === null;
        })
        .catch(err => {
            status.textContent = 'Error: ' + err.message;
            status.className = 'error';
            btn.textContent = 'Save Location';
            btn.disabled = false;
        });
    }

    // ── Bank Details ─────────────────────────────────────────
    function loadBankDetails() {
        fetch(CONTEXT_PATH + '/bank-details')
            .then(r => r.json())
            .then(data => renderBankStatus(data.success ? data.bank : null))
            .catch(() => renderBankStatus(null));
    }

    function renderBankStatus(bank) {
        const c = document.getElementById('bankStatusContainer');
        const cardIcon = '<svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">'
            + '<path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5z"/>'
            + '</svg>';
        if (bank) {
            const accountNumber = (bank.accountNumber || '').toString();
            const masked = accountNumber.length > 4
                ? '\u2022\u2022\u2022\u2022 ' + accountNumber.slice(-4)
                : accountNumber;
            c.innerHTML =
                '<div class="bank-status-card">'
                + '<div class="bank-icon">' + cardIcon + '</div>'
                + '<div style="flex:1">'
                + '<div class="bank-name">' + htmlEsc(bank.bankName) + (bank.branch ? ' \u2014 ' + htmlEsc(bank.branch) : '') + '</div>'
                + '<div class="bank-detail">Account: ' + htmlEsc(masked) + ' &nbsp;|&nbsp; ' + htmlEsc(bank.accountHolderName) + '</div>'
                + '</div>'
                + '<button class="btn-outline" id="editBankBtn">Edit</button>'
                + '</div>';
            document.getElementById('editBankBtn').addEventListener('click', function() {
                openBankModal(bank);
            });
        } else {
            c.innerHTML =
                '<div class="bank-status-card">'
                + '<div class="bank-icon-none">' + cardIcon + '</div>'
                + '<div class="bank-empty" style="flex:1">No bank account linked yet.</div>'
                + '<button class="btn-primary" onclick="openBankModal(null)">Add Bank Details</button>'
                + '</div>';
        }
    }

    function openBankModal(bank) {
        document.getElementById('bankModalTitle').textContent = bank ? 'Edit Bank Details' : 'Add Bank Details';
        document.getElementById('bankName').value          = bank ? (bank.bankName || '')         : '';
        document.getElementById('branch').value            = bank ? (bank.branch || '')            : '';
        document.getElementById('accountNumber').value     = bank ? (bank.accountNumber || '')     : '';
        document.getElementById('accountHolderName').value = bank ? (bank.accountHolderName || '') : '';
        document.getElementById('bankModal').style.display = 'flex';
    }

    function closeBankModal() {
        document.getElementById('bankModal').style.display = 'none';
    }

    function saveBank(e) {
        e.preventDefault();
        fetch(CONTEXT_PATH + '/bank-details', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(document.getElementById('bankForm')))
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                closeBankModal();
                loadBankDetails();
                showToast('Bank details saved.', 'success');
            } else {
                showToast(data.message || 'Failed to save.', 'error');
            }
        })
        .catch(err => showToast('Error: ' + err.message, 'error'));
    }

    document.getElementById('bankModal').addEventListener('click', function(e) {
        if (e.target === this) closeBankModal();
    });

    function htmlEsc(str) {
        const d = document.createElement('div');
        d.textContent = str || '';
        return d.innerHTML;
    }

    function showToast(msg, type) {
        const t = document.getElementById('toast');
        t.textContent = msg; t.className = type; t.style.display = 'block';
        setTimeout(() => { t.style.display = 'none'; }, 3500);
    }

    document.addEventListener('DOMContentLoaded', function() {
        loadBankDetails();
    });
</script>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&libraries=places&callback=initDriverProfileMap" async defer></script>

</body>
</html>
