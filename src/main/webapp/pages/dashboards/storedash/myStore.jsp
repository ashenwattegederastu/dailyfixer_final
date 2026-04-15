<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Store" %>
<%@ page import="com.dailyfixer.dao.StoreDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    private static String he(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    StoreDAO storeDAO = new StoreDAO();
    Store store = storeDAO.getStoreByUserId(user.getUserId());
    if (store == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    double storeLat = store.getLatitude();
    double storeLng = store.getLongitude();
    boolean hasCoords = storeLat != 0.0 && storeLng != 0.0
        && Math.abs(storeLat) <= 90.0 && Math.abs(storeLng) <= 180.0;
    String memberSince = store.getCreatedAt() != null
        ? new SimpleDateFormat("MMMM yyyy").format(store.getCreatedAt()) : "";
    String initial = (store.getStoreName() != null && !store.getStoreName().isEmpty())
        ? String.valueOf(store.getStoreName().charAt(0)).toUpperCase() : "S";
    String typeRaw = store.getStoreType() != null ? store.getStoreType().toLowerCase().trim() : "other";
    String typeCss;
    switch (typeRaw) {
        case "electronics":    typeCss = "type-electronics"; break;
        case "hardware":       typeCss = "type-hardware";    break;
        case "vehicle repair": typeCss = "type-vehicle";     break;
        default:               typeCss = "type-other";       break;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Store | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-dashboard.css">
<style>
/* ── Two-column grid ───────────────────────────────── */
.store-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    margin-bottom: 32px;
}
@media (max-width: 900px) { .store-grid { grid-template-columns: 1fr; } }

/* ── Hero card ─────────────────────────────────────── */
.store-hero {
    background: var(--card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    box-shadow: var(--shadow-sm);
    padding: 28px 32px;
    display: flex;
    align-items: center;
    gap: 24px;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.store-hero::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 4px;
    background: linear-gradient(90deg, var(--primary), oklch(0.6 0.2 280));
}
.store-initial {
    width: 72px; height: 72px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary), oklch(0.6 0.2 280));
    display: flex; align-items: center; justify-content: center;
    font-size: 2em; font-weight: 700; color: #fff; flex-shrink: 0;
}
.hero-name  { font-size: 1.6em; font-weight: 700; color: var(--foreground); margin: 0 0 6px; }
.hero-meta  { color: var(--muted-foreground); font-size: 0.9em; margin-top: 5px; }
.hero-actions { margin-left: auto; }

/* ── Section card ──────────────────────────────────── */
.section-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    box-shadow: var(--shadow-sm);
    padding: 24px;
}
.section-card h4 {
    font-size: 0.82em; font-weight: 700; color: var(--muted-foreground);
    text-transform: uppercase; letter-spacing: 0.5px;
    margin: 0 0 18px; padding-bottom: 12px;
    border-bottom: 1px solid var(--border);
}
.section-title {
    font-size: 1.2em; font-weight: 700; color: var(--foreground);
    margin: 32px 0 16px;
}

/* ── Info rows ─────────────────────────────────────── */
.info-rows { display: flex; flex-direction: column; gap: 14px; }
.info-row  { display: flex; align-items: flex-start; }
.info-label {
    min-width: 140px; font-weight: 600; font-size: 0.84em;
    color: var(--muted-foreground); text-transform: uppercase;
    letter-spacing: 0.3px; flex-shrink: 0; padding-top: 2px;
}
.info-value      { font-size: 0.95em; color: var(--foreground); font-weight: 500; }
.info-value.mono { font-family: 'IBM Plex Mono', monospace; font-size: 0.88em; }

/* ── Store-type badges ─────────────────────────────── */
.type-badge {
    padding: 3px 11px; border-radius: 999px;
    font-weight: 600; font-size: 0.8rem;
    display: inline-block; text-transform: capitalize;
}
.type-electronics { background: oklch(0.9 0.1 240);  color: oklch(0.35 0.15 240); }
.type-hardware    { background: oklch(0.9 0.12 55);   color: oklch(0.4 0.12 55); }
.type-vehicle     { background: oklch(0.9 0.12 145);  color: oklch(0.35 0.12 145); }
.type-other       { background: var(--muted);         color: var(--muted-foreground); }

/* ── Map ───────────────────────────────────────────── */
#store-map { height: 310px; border-radius: var(--radius-md); overflow: hidden; }
.map-placeholder {
    height: 310px; display: flex; flex-direction: column;
    align-items: center; justify-content: center; gap: 10px;
    background: var(--muted); border-radius: var(--radius-md);
    color: var(--muted-foreground); font-size: 0.9em; text-align: center;
}
.map-placeholder svg { opacity: 0.35; }

/* ── Bank status card ──────────────────────────────── */
.bank-status-card {
    background: var(--card); border-radius: var(--radius-lg);
    border: 1px solid var(--border); box-shadow: var(--shadow-sm);
    padding: 22px 28px; display: flex; align-items: center; gap: 20px;
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

/* ── Buttons ───────────────────────────────────────── */
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

/* ── Modals ────────────────────────────────────────── */
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
.field-grid .full { grid-column: 1 / -1; }
.form-group { display: flex; flex-direction: column; }
.form-group label { font-weight: 600; font-size: 0.84rem; color: var(--foreground); margin-bottom: 6px; }
.form-group input,
.form-group select {
    padding: 10px 14px; border: 1px solid var(--border);
    border-radius: var(--radius-md); font-size: 0.9rem;
    background: var(--background); color: var(--foreground);
    font-family: 'Plus Jakarta Sans', sans-serif; transition: border-color 0.2s;
}
.form-group input:focus,
.form-group select:focus { outline: none; border-color: var(--primary); }
.form-group input[readonly] { opacity: 0.6; cursor: not-allowed; }
.readonly-note { font-size: 0.78em; color: var(--muted-foreground); margin-top: 4px; }
.modal-actions { display: flex; gap: 12px; justify-content: flex-end; }

/* ── Toast ─────────────────────────────────────────── */
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
<body class="dashboard-layout">

<header class="topbar">
    <div class="logo">Daily Fixer</div>
    <div class="panel-name">Store Panel</div>
    <div style="display:flex;align-items:center;gap:10px;">
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Log Out</a>
    </div>
</header>

<aside class="sidebar">
    <h3>Navigation</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp">Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/orders.jsp">Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/upfordelivery.jsp">Up for Delivery</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/completedorders.jsp">Completed Orders</a></li>
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp" class="active">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <h2>My Store</h2>
    <p class="dashboard-subtitle">View and manage your store details, location, and bank account.</p>

    <!-- Hero card -->
    <div class="store-hero">
        <div class="store-initial" id="hero-initial"><%= initial %></div>
        <div>
            <div class="hero-name" id="hero-name"><%= he(store.getStoreName()) %></div>
            <span class="type-badge <%= typeCss %>" id="hero-badge"><%= he(typeRaw) %></span>
            <div class="hero-meta">
                <span id="hero-address"><%= he(store.getStoreAddress()) %>, <%= he(store.getStoreCity()) %></span>
                <% if (!memberSince.isEmpty()) { %>&nbsp;&bull;&nbsp;Member since <%= memberSince %><% } %>
            </div>
        </div>
        <div class="hero-actions">
            <button class="btn-primary" onclick="openEditModal()">Edit Store</button>
        </div>
    </div>

    <!-- Info + Map two-column grid -->
    <div class="store-grid">
        <div class="section-card">
            <h4>Store Information</h4>
            <div class="info-rows">
                <div class="info-row">
                    <span class="info-label">Store Name</span>
                    <span class="info-value" id="info-name"><%= he(store.getStoreName()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Store Type</span>
                    <span class="info-value">
                        <span class="type-badge <%= typeCss %>" id="info-badge"><%= he(typeRaw) %></span>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Address</span>
                    <span class="info-value" id="info-address"><%= he(store.getStoreAddress()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">City</span>
                    <span class="info-value" id="info-city"><%= he(store.getStoreCity()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Username</span>
                    <span class="info-value mono"><%= he(user.getUsername()) %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email</span>
                    <span class="info-value"><%= user.getEmail() != null ? he(user.getEmail()) : "—" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Phone</span>
                    <span class="info-value"><%= user.getPhoneNumber() != null ? he(user.getPhoneNumber()) : "—" %></span>
                </div>
            </div>
        </div>

        <div class="section-card">
            <h4>Store Location</h4>
            <% if (hasCoords) { %>
            <div id="store-map"
                  data-lat="<%= storeLat %>"
                  data-lng="<%= storeLng %>"
                 data-name="<%= he(store.getStoreName()) %>"
                 data-address="<%= he(store.getStoreAddress()) %>, <%= he(store.getStoreCity()) %>">
            </div>
            <% } else { %>
            <div class="map-placeholder">
                <svg width="52" height="52" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z"/>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z"/>
                </svg>
                <span style="font-weight:600;">Location not set</span>
                <span style="font-size:0.82em;">Coordinates were not recorded at registration.</span>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Bank Account -->
    <h3 class="section-title">Bank Account</h3>
    <div id="bankStatusContainer">
        <div class="bank-status-card">
            <div class="bank-icon-none bank-icon">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5z"/>
                </svg>
            </div>
            <div class="bank-empty">Loading...</div>
        </div>
    </div>
</main>

<!-- Edit Store Modal -->
<div id="editModal" class="modal-overlay" style="display:none">
    <div class="modal-box">
        <h3>Edit Store Details</h3>
        <form id="editStoreForm" onsubmit="saveStore(event)">
            <div class="field-grid">
                <div class="form-group full">
                    <label for="edit-name">Store Name *</label>
                    <input type="text" id="edit-name" name="storeName" required
                           value="<%= he(store.getStoreName()) %>">
                </div>
                <div class="form-group">
                    <label for="edit-type">Store Type</label>
                    <select id="edit-type" name="storeType">
                        <option value="electronics"   <% if ("electronics".equals(typeRaw))    { %>selected<% } %>>Electronics</option>
                        <option value="hardware"      <% if ("hardware".equals(typeRaw))       { %>selected<% } %>>Hardware</option>
                        <option value="vehicle repair"<% if ("vehicle repair".equals(typeRaw)) { %>selected<% } %>>Vehicle Repair</option>
                        <option value="other"         <% if ("other".equals(typeRaw))          { %>selected<% } %>>Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="edit-city">City *</label>
                    <input type="text" id="edit-city" name="storeCity" required
                           value="<%= he(store.getStoreCity()) %>">
                </div>
                <div class="form-group full">
                    <label for="edit-address">Address *</label>
                    <input type="text" id="edit-address" name="storeAddress" required
                           value="<%= he(store.getStoreAddress()) %>">
                </div>
                <div class="form-group full">
                    <label>Username (owner)</label>
                    <input type="text" value="<%= he(user.getUsername()) %>" readonly>
                    <span class="readonly-note">Username cannot be changed.</span>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-outline" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

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
                <button type="submit" class="btn-primary">Save Bank Details</button>
            </div>
        </form>
    </div>
</div>

<div id="toast"></div>

<script>
    const CTX = '<%= request.getContextPath() %>';

    // ── Map ──────────────────────────────────────────────────
    function showMapFallback(message) {
        const mapEl = document.getElementById('store-map');
        if (!mapEl) return;
        mapEl.className = 'map-placeholder';
        mapEl.innerHTML =
            '<svg width="52" height="52" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">' +
            '<path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z"/>' +
            '<path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z"/>' +
            '</svg>' +
            '<span style="font-weight:600;">Map unavailable</span>' +
            '<span style="font-size:0.82em;">' + htmlEsc(message || 'Could not load map right now.') + '</span>';
    }

    function initStoreMap() {
        const mapEl = document.getElementById('store-map');
        if (!mapEl) return;

        if (!window.google || !google.maps) {
            showMapFallback('Google Maps failed to initialize.');
            return;
        }

        const lat = Number(mapEl.dataset.lat);
        const lng = Number(mapEl.dataset.lng);
        if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
            showMapFallback('Invalid coordinates for this store location.');
            return;
        }

        const pos = { lat: lat, lng: lng };
        const map = new google.maps.Map(mapEl, {
            center: pos,
            zoom: 15,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: false
        });

        const marker = new google.maps.Marker({
            position: pos,
            map: map,
            title: mapEl.dataset.name || 'Store location'
        });

        const infoWindow = new google.maps.InfoWindow({
            content:
                '<div style="font-family:Inter,sans-serif;padding:4px 2px;">' +
                '<strong>' + htmlEsc(mapEl.dataset.name) + '</strong><br>' +
                '<span style="font-size:0.85em;color:#555;">' + htmlEsc(mapEl.dataset.address) + '</span>' +
                '</div>'
        });

        marker.addListener('click', function() {
            infoWindow.open(map, marker);
        });
        infoWindow.open(map, marker);
    }

    function handleStoreMapLoadError() {
        showMapFallback('Google Maps could not be loaded. Check your network or API configuration.');
    }

    window.initStoreMap = initStoreMap;
    window.handleStoreMapLoadError = handleStoreMapLoadError;

    // ── Bank details ─────────────────────────────────────────
    function loadBankDetails() {
        fetch(CTX + '/bank-details')
            .then(r => r.json())
            .then(data => renderBankStatus(data.success ? data.bank : null))
            .catch(() => renderBankStatus(null));
    }

    function renderBankStatus(bank) {
        const c = document.getElementById('bankStatusContainer');
        const cardIcon = `<svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5z"/>
        </svg>`;
        if (bank) {
            const accountNumber = (bank.accountNumber || '').toString();
            const masked = accountNumber.length > 4
                ? '&bull;&bull;&bull;&bull;&thinsp;' + accountNumber.slice(-4)
                : accountNumber;
            c.innerHTML =
                '<div class="bank-status-card">' +
                    '<div class="bank-icon">' + cardIcon + '</div>' +
                    '<div style="flex:1;">' +
                        '<div class="bank-name">' +
                            htmlEsc(bank.bankName) +
                            (bank.branch ? ' &mdash; ' + htmlEsc(bank.branch) : '') +
                        '</div>' +
                        '<div class="bank-detail">' + masked + ' &nbsp;&bull;&nbsp; ' + htmlEsc(bank.accountHolderName) + '</div>' +
                    '</div>' +
                    '<button class="btn-outline" id="editBankBtn">Edit</button>' +
                '</div>';
            const editBankBtn = document.getElementById('editBankBtn');
            if (editBankBtn) {
                editBankBtn.addEventListener('click', function() {
                    openBankModal(bank);
                });
            }
        } else {
            c.innerHTML =
                '<div class="bank-status-card">' +
                    '<div class="bank-icon-none bank-icon">' + cardIcon + '</div>' +
                    '<div style="flex:1;">' +
                        '<div class="bank-empty">No bank account linked yet. Add your bank details to receive payouts.</div>' +
                    '</div>' +
                    '<button class="btn-primary" onclick="openBankModal(null)">Add Bank Details</button>' +
                '</div>';
        }
    }

    function openBankModal(bank) {
        document.getElementById('bankModalTitle').textContent = bank ? 'Edit Bank Details' : 'Add Bank Details';
        document.getElementById('bankName').value          = bank ? bank.bankName          : '';
        document.getElementById('branch').value            = bank ? (bank.branch || '')    : '';
        document.getElementById('accountNumber').value     = bank ? bank.accountNumber     : '';
        document.getElementById('accountHolderName').value = bank ? bank.accountHolderName : '';
        document.getElementById('bankModal').style.display = 'flex';
    }
    function closeBankModal() { document.getElementById('bankModal').style.display = 'none'; }

    function saveBank(e) {
        e.preventDefault();
        fetch(CTX + '/bank-details', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(document.getElementById('bankForm')))
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) { closeBankModal(); loadBankDetails(); showToast('Bank details saved.', 'success'); }
            else showToast(data.message || 'Failed to save.', 'error');
        })
        .catch(err => showToast('Error: ' + err.message, 'error'));
    }

    // ── Edit Store ───────────────────────────────────────────
    function openEditModal() { document.getElementById('editModal').style.display = 'flex'; }
    function closeEditModal() { document.getElementById('editModal').style.display = 'none'; }

    function saveStore(e) {
        e.preventDefault();
        fetch(CTX + '/store-profile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(document.getElementById('editStoreForm')))
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                closeEditModal();
                const name    = document.getElementById('edit-name').value.trim();
                const type    = document.getElementById('edit-type').value;
                const address = document.getElementById('edit-address').value.trim();
                const city    = document.getElementById('edit-city').value.trim();

                // Update info panel
                document.getElementById('info-name').textContent    = name;
                document.getElementById('info-address').textContent = address;
                document.getElementById('info-city').textContent    = city;

                // Update type badges
                const typeCssMap = {
                    'electronics': 'type-electronics',
                    'hardware':    'type-hardware',
                    'vehicle repair': 'type-vehicle',
                    'other':       'type-other'
                };
                const newCss = typeCssMap[type] || 'type-other';
                ['info-badge', 'hero-badge'].forEach(id => {
                    const el = document.getElementById(id);
                    el.textContent = type;
                    el.className = 'type-badge ' + newCss;
                });

                // Update hero
                document.getElementById('hero-name').textContent    = name;
                document.getElementById('hero-address').textContent = address + ', ' + city;
                document.getElementById('hero-initial').textContent = name.charAt(0).toUpperCase();

                showToast('Store details updated.', 'success');
            } else {
                showToast(data.message || 'Failed to update.', 'error');
            }
        })
        .catch(err => showToast('Error: ' + err.message, 'error'));
    }

    // ── Close modals on overlay click ────────────────────────
    ['editModal', 'bankModal'].forEach(id => {
        document.getElementById(id).addEventListener('click', function(e) {
            if (e.target === this) this.style.display = 'none';
        });
    });

    // ── Utilities ────────────────────────────────────────────
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

    loadBankDetails();
</script>
<% if (hasCoords) { %>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&callback=initStoreMap" async defer onerror="handleStoreMapLoadError()"></script>
<% } %>
</body>
</html>
