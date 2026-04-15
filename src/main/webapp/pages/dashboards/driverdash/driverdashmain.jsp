<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.model.Vehicle" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="com.dailyfixer.dao.VehicleDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Calendar" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    VehicleDAO vehicleDAO = new VehicleDAO();

    List<DeliveryAssignment> completedAll  = assignmentDAO.getByDriver(user.getUserId(), "DELIVERED");
    List<DeliveryAssignment> activeOrders  = assignmentDAO.getByDriver(user.getUserId(), "ACCEPTED");
    List<Vehicle>            vehicles      = vehicleDAO.getVehiclesByDriver(user.getUserId());

    // Total earnings + this-month earnings & count
    BigDecimal totalEarnings = BigDecimal.ZERO;
    BigDecimal monthEarnings = BigDecimal.ZERO;
    int monthCount = 0;

    Calendar now = Calendar.getInstance();
    int thisYear  = now.get(Calendar.YEAR);
    int thisMonth = now.get(Calendar.MONTH);

    for (DeliveryAssignment a : completedAll) {
        if (a.getDeliveryFeeEarned() != null) {
            totalEarnings = totalEarnings.add(a.getDeliveryFeeEarned());
            if (a.getCompletedAt() != null) {
                Calendar c = Calendar.getInstance();
                c.setTime(a.getCompletedAt());
                if (c.get(Calendar.YEAR) == thisYear && c.get(Calendar.MONTH) == thisMonth) {
                    monthEarnings = monthEarnings.add(a.getDeliveryFeeEarned());
                    monthCount++;
                }
            }
        }
    }

    int totalCompleted = completedAll.size();
    int activeCount    = activeOrders.size();
    int vehicleCount   = vehicles.size();

    Double savedLat = user.getLatitude();
    Double savedLng = user.getLongitude();
    boolean hasLocation = savedLat != null && savedLng != null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Driver Dashboard | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<style>
.container {
    flex: 1;
    margin-left: 240px;
    padding: 30px;
    background-color: var(--background);
}
.container > h2 {
    font-size: 1.6em;
    margin-bottom: 6px;
    color: var(--foreground);
}
.container > .welcome-sub {
    color: var(--muted-foreground);
    margin-bottom: 28px;
    font-size: 0.95em;
}

/* Stat cards */
.stats-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 20px;
    margin-bottom: 28px;
}
.stat-card {
    background: var(--card);
    padding: 22px 20px;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.stat-card .stat-icon {
    font-size: 1.6em;
    margin-bottom: 4px;
}
.stat-card .number {
    font-size: 1.9em;
    font-weight: 700;
    color: var(--primary);
    line-height: 1;
}
.stat-card .label {
    color: var(--muted-foreground);
    font-weight: 500;
    font-size: 0.88em;
}
.stat-card.highlight { border-left: 4px solid var(--primary); }
.stat-card.active-card .number { color: #f59e0b; }
.stat-card.active-card { border-left: 4px solid #f59e0b; }

/* Two-column layout */
.dash-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    margin-bottom: 24px;
}
@media (max-width: 900px) { .dash-grid { grid-template-columns: 1fr; } }

/* Section cards */
.section-card {
    background: var(--card);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
    overflow: hidden;
}
.section-card .section-header {
    background: var(--muted);
    padding: 16px 22px;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    gap: 10px;
}
.section-card .section-header h3 {
    font-size: 1em;
    font-weight: 700;
    color: var(--foreground);
    margin: 0;
}
.section-card .section-header i { font-size: 1.2em; color: var(--primary); }
.section-card .section-body { padding: 20px 22px; }

/* Info rows */
.info-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid var(--border);
    font-size: 0.9em;
}
.info-row:last-child { border-bottom: none; }
.info-row .info-label { color: var(--muted-foreground); font-weight: 500; }
.info-row .info-value { color: var(--foreground); font-weight: 600; }

/* Home base alert */
.location-alert {
    background: #fff3cd;
    border: 1px solid #ffc107;
    border-radius: var(--radius-md);
    padding: 12px 16px;
    margin-bottom: 16px;
    color: #856404;
    font-size: 0.88em;
    font-weight: 600;
}
.location-alert a { color: #856404; }

/* Map */
#dashMap {
    width: 100%;
    height: 260px;
    border-radius: var(--radius-md);
    border: 1px solid var(--border);
    margin-bottom: 14px;
}
.save-loc-btn {
    padding: 10px 22px;
    background: var(--primary);
    color: var(--primary-foreground);
    border: none;
    border-radius: var(--radius-md);
    font-weight: 600;
    font-size: 0.9rem;
    cursor: pointer;
    transition: all 0.2s;
}
.save-loc-btn:hover { opacity: 0.9; transform: translateY(-1px); }
.save-loc-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
#locStatus { margin-top: 8px; font-size: 0.88em; font-weight: 600; }
#locStatus.success { color: #28a745; }
#locStatus.error   { color: #dc3545; }

/* Map Search */
#map-search-input {
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
#map-search-input:focus {
    outline: none;
    border-color: var(--ring, var(--primary));
}

/* Quick links */
.quick-links {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}
.quick-link {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 14px 16px;
    background: var(--muted);
    border-radius: var(--radius-md);
    text-decoration: none;
    color: var(--foreground);
    font-weight: 600;
    font-size: 0.9em;
    border: 1px solid var(--border);
    transition: all 0.2s;
}
.quick-link:hover {
    background: var(--border);
    transform: translateY(-1px);
    box-shadow: var(--shadow-sm);
}
.quick-link i { font-size: 1.2em; color: var(--primary); }
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Welcome back, <%= user.getFirstName() %>!</h2>
    <p class="welcome-sub">Here's an overview of your driver activity.</p>

    <!-- Top Stats -->
    <div class="stats-container">
        <div class="stat-card highlight">
            <i class="ph ph-check-circle stat-icon" style="color: var(--primary);"></i>
            <div class="number"><%= totalCompleted %></div>
            <div class="label">Total Deliveries</div>
        </div>
        <div class="stat-card active-card">
            <i class="ph ph-package stat-icon" style="color: #f59e0b;"></i>
            <div class="number"><%= activeCount %></div>
            <div class="label">Active Deliveries</div>
        </div>
        <div class="stat-card highlight">
            <i class="ph ph-currency-circle-dollar stat-icon" style="color: var(--primary);"></i>
            <div class="number" style="font-size: 1.3em;">LKR <%= String.format("%,.0f", totalEarnings) %></div>
            <div class="label">Total Earned</div>
        </div>

    </div>

    <!-- Middle Row -->
    <div class="dash-grid">

        <!-- This Month + Quick Links -->
        <div style="display: flex; flex-direction: column; gap: 24px;">
            <div class="section-card">
                <div class="section-header">
                    <i class="ph ph-calendar-check"></i>
                    <h3>This Month</h3>
                </div>
                <div class="section-body">
                    <div class="info-row">
                        <span class="info-label">Deliveries Completed</span>
                        <span class="info-value"><%= monthCount %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Earnings</span>
                        <span class="info-value">LKR <%= String.format("%,.2f", monthEarnings) %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Home Base</span>
                        <span class="info-value" style="color: <%= hasLocation ? "#28a745" : "#dc3545" %>;">
                            <%= hasLocation ? "Set ✓" : "Not set" %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Status</span>
                        <span class="info-value" style="color: <%= activeCount > 0 ? "#f59e0b" : "#28a745" %>;">
                            <%= activeCount > 0 ? activeCount + " delivery in progress" : "Available" %>
                        </span>
                    </div>
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <i class="ph ph-lightning"></i>
                    <h3>Quick Links</h3>
                </div>
                <div class="section-body">
                    <div class="quick-links">
                        <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/deliveryrequests.jsp" class="quick-link">
                            <i class="ph ph-map-pin-area"></i> Delivery Requests
                        </a>
                        <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/acceptedOrders.jsp" class="quick-link">
                            <i class="ph ph-package"></i> Active Orders
                        </a>
                        <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/completedOrders.jsp" class="quick-link">
                            <i class="ph ph-check-square-offset"></i> Completed
                        </a>
                        <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp" class="quick-link">
                            <i class="ph ph-van"></i> My Vehicle
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Home Base Location Picker -->
        <div class="section-card">
            <div class="section-header">
                <i class="ph ph-map-pin"></i>
                <h3>Set Current Location</h3>
            </div>
            <div class="section-body">
                <% if (!hasLocation) { %>
                <div class="location-alert">
                    No location set — you won't appear in delivery request searches. Click on the map to pin your home base.
                </div>
                <% } %>
                <input type="text" id="map-search-input" placeholder="Search for location (e.g., Colombo, Kandy)...">
                <div id="dashMap"></div>
                <button class="save-loc-btn" id="saveLocBtn" onclick="saveLocation()" disabled>Save Location</button>
                <p id="locStatus"></p>
            </div>
        </div>

    </div>
</main>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    const HAS_LOC   = <%= hasLocation %>;
    const SAVED_LAT = <%= hasLocation ? savedLat : "6.9271" %>;
    const SAVED_LNG = <%= hasLocation ? savedLng : "79.8612" %>;

    let map, marker;
    let pendingLat = null, pendingLng = null;

    function initDashMap() {
        const center = { lat: SAVED_LAT, lng: SAVED_LNG };
        map = new google.maps.Map(document.getElementById('dashMap'), {
            center: center,
            zoom: HAS_LOC ? 14 : 12,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: false
        });

        if (HAS_LOC) {
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

            document.getElementById('saveLocBtn').disabled = false;
            document.getElementById('locStatus').textContent = '';
        });

        // Initialize Places Autocomplete
        const searchInput = document.getElementById('map-search-input');
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

                document.getElementById('saveLocBtn').disabled = false;
                document.getElementById('locStatus').textContent = '';
            }
        });
    }

    function saveLocation() {
        if (pendingLat === null || pendingLng === null) return;
        const btn = document.getElementById('saveLocBtn');
        const status = document.getElementById('locStatus');
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
                status.textContent = 'Location saved!';
                status.className = 'success';
                pendingLat = null;
                pendingLng = null;
            } else {
                status.textContent = 'Failed: ' + (data.message || 'Unknown error');
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
</script>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&libraries=places&callback=initDashMap" async defer></script>

</body>
</html>
