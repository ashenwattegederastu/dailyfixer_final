<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.DeliveryAssignment" %>
<%@ page import="com.dailyfixer.model.Vehicle" %>
<%@ page import="com.dailyfixer.dao.DeliveryAssignmentDAO" %>
<%@ page import="com.dailyfixer.dao.VehicleDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="java.util.Set" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    Double driverLat = user.getLatitude();
    Double driverLng = user.getLongitude();
    boolean hasLocation = driverLat != null && driverLng != null;

    List<DeliveryAssignment> nearbyAssignments = new ArrayList<>();
    List<String> vehicleCategories = new ArrayList<>();

    if (hasLocation) {
        VehicleDAO vehicleDAO = new VehicleDAO();
        List<Vehicle> driverVehicles = vehicleDAO.getVehiclesByDriver(user.getUserId());
        Set<String> catSet = new LinkedHashSet<>();
        for (Vehicle v : driverVehicles) {
            if (v.getVehicleCategory() != null && !v.getVehicleCategory().isBlank()) {
                catSet.add(v.getVehicleCategory());
            }
        }
        vehicleCategories.addAll(catSet);

        if (!vehicleCategories.isEmpty()) {
            DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
            nearbyAssignments = assignmentDAO.getPendingNearby(driverLat, driverLng, vehicleCategories, 10.0);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Delivery Requests | Daily Fixer</title>
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

.content-wrapper {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 450px;
    gap: 30px;
    align-items: start;
}
.map-column {
    position: sticky;
    top: 100px;
}
#deliveryMap {
    width: 100%;
    height: calc(100vh - 130px);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    box-shadow: var(--shadow-sm);
}
@media (max-width: 1100px) {
    .content-wrapper {
        display: flex;
        flex-direction: column-reverse;
    }
    #deliveryMap {
        height: 350px;
        margin-bottom: 20px;
    }
    .map-column {
        position: static;
        width: 100%;
    }
}

.warn-banner {
    background: #fff3cd;
    border: 1px solid #ffc107;
    border-radius: var(--radius-md);
    padding: 16px 20px;
    margin-bottom: 20px;
    color: #856404;
    font-weight: 600;
    font-size: 0.95em;
}
.warn-banner a { color: #856404; }

.card {
    background: var(--card);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border);
    padding: 22px 25px;
    margin-bottom: 16px;
    transition: all 0.2s;
}
.card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}
.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
    border-bottom: 2px solid var(--border);
    padding-bottom: 10px;
}
.card-header h3 { font-size: 1.1em; color: var(--primary); margin: 0; }
.card-header .fee-badge {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: #fff;
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 0.85em;
    font-weight: 700;
}

.details-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 10px;
    margin-bottom: 16px;
}
.details-grid p {
    margin: 0;
    color: var(--muted-foreground);
    font-weight: 500;
    font-size: 0.9em;
}
.details-grid strong { color: var(--foreground); font-weight: 600; }

.accept-btn {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
    border: none;
    padding: 11px 24px;
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    font-size: 0.9rem;
    box-shadow: var(--shadow-sm);
    transition: all 0.2s;
    width: 100%;
}
.accept-btn:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); opacity: 0.9; }
.accept-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

.toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
}
.refresh-btn {
    padding: 8px 18px;
    background: var(--muted);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    font-size: 0.85rem;
    color: var(--foreground);
    transition: all 0.2s;
}
.refresh-btn:hover { background: var(--border); }
</style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="container">
    <h2>Delivery Requests</h2>

    <% if (!hasLocation) { %>
    <div class="warn-banner">
        Your home base location is not set. Please
        <a href="<%= request.getContextPath() %>/pages/dashboards/driverdash/myProfile.jsp">set your location</a>
        in My Profile to see nearby delivery requests.
    </div>
    <% } else if (vehicleCategories.isEmpty()) { %>
    <div class="warn-banner">
        You have no registered vehicles. Please
        <a href="<%= request.getContextPath() %>/pages/dashboards/driverdash/vehicleManagement.jsp">add a vehicle</a>
        with a vehicle category to receive delivery requests.
    </div>
    <% } else { %>

    <div class="content-wrapper">
        <div class="requests-column">
            <div class="toolbar">
                <span style="font-size: 0.9em; color: var(--muted-foreground);">
                    Showing <strong><%= nearbyAssignments.size() %></strong>
                    delivery request<%= nearbyAssignments.size() != 1 ? "s" : "" %> within 10 km
                </span>
                <button class="refresh-btn" onclick="window.location.reload()">↻ Refresh</button>
            </div>

            <% if (nearbyAssignments.isEmpty()) { %>
            <div class="card" style="text-align: center; color: var(--muted-foreground); padding: 40px;">
                <p style="font-size: 1.1em; font-weight: 600; margin-bottom: 8px;">No delivery requests nearby</p>
                <p style="font-size: 0.9em;">Check back soon or refresh the page.</p>
            </div>
            <% } else {
                for (DeliveryAssignment a : nearbyAssignments) {
                    String customerName = a.getCustomerName() != null ? a.getCustomerName() : "—";
                    String pickupAddr   = a.getPickupAddress() != null ? a.getPickupAddress() : a.getStoreName();
                    String dropoffAddr  = a.getDeliveryAddress() != null ? a.getDeliveryAddress() : "—";
                    String feeStr       = a.getDeliveryFeeEarned() != null
                                          ? String.format("LKR %.2f", a.getDeliveryFeeEarned()) : "LKR 0.00";
                    String distStr      = String.format("%.1f km", a.getDistanceKm());
            %>
            <div class="card" id="card-<%= a.getAssignmentId() %>">
                <div class="card-header">
                    <h3><%= a.getStoreName() %> → <%= customerName %></h3>
                    <span class="fee-badge"><%= feeStr %></span>
                </div>
                <div class="details-grid">
                    <p><strong>Order ID:</strong> <%= a.getOrderId() %></p>
                    <p><strong>Vehicle Required:</strong> <%= a.getRequiredVehicleType() %></p>
                    <p><strong>Distance to Store:</strong> <%= distStr %></p>
                    <p><strong>Pickup:</strong> <%= pickupAddr %></p>
                    <p><strong>Dropoff:</strong> <%= dropoffAddr %></p>
                </div>
                <button class="accept-btn" id="btn-<%= a.getAssignmentId() %>"
                        onclick="acceptDelivery(<%= a.getAssignmentId() %>, this)">
                    Accept Delivery
                </button>
            </div>
            <% } } %>
        </div>

        <div class="map-column">
            <div id="deliveryMap"></div>
        </div>
    </div>

    <% } // end hasLocation %>
</main>

<script>
    const CONTEXT_PATH = '<%= request.getContextPath() %>';
    const HAS_LOC = <%= hasLocation %>;
    const DRIVER_LAT = <%= hasLocation ? driverLat : 6.9271 %>;
    const DRIVER_LNG = <%= hasLocation ? driverLng : 79.8612 %>;

    const assignments = [
        <% for (int i = 0; i < nearbyAssignments.size(); i++) {
            DeliveryAssignment a = nearbyAssignments.get(i);
            if (a.getStoreLat() == 0 && a.getStoreLng() == 0) continue;
            String storeName = (a.getStoreName() != null ? a.getStoreName() : "Store")
                                .replace("'", "\\'");
            String pickupAddr = (a.getPickupAddress() != null ? a.getPickupAddress() : "")
                                .replace("'", "\\'");
        %>
        { id: <%= a.getAssignmentId() %>, lat: <%= a.getStoreLat() %>, lng: <%= a.getStoreLng() %>,
          label: '<%= storeName %>', address: '<%= pickupAddr %>' },
        <% } %>
    ];

    function initDeliveryMap() {
        if (!HAS_LOC) return;

        const driverPos = { lat: DRIVER_LAT, lng: DRIVER_LNG };
        const map = new google.maps.Map(document.getElementById('deliveryMap'), {
            center: driverPos,
            zoom: 12,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: false
        });

        new google.maps.Marker({
            position: driverPos,
            map: map,
            title: 'Your Home Base',
            icon: {
                path: google.maps.SymbolPath.CIRCLE,
                scale: 10,
                fillColor: '#8b95ff',
                fillOpacity: 1,
                strokeColor: '#fff',
                strokeWeight: 2
            }
        });

        new google.maps.Circle({
            map: map,
            center: driverPos,
            radius: 10000,
            fillColor: '#8b95ff',
            fillOpacity: 0.08,
            strokeColor: '#8b95ff',
            strokeOpacity: 0.4,
            strokeWeight: 2
        });

        assignments.forEach(function(a) {
            const marker = new google.maps.Marker({
                position: { lat: a.lat, lng: a.lng },
                map: map,
                title: a.label,
                icon: {
                    path: google.maps.SymbolPath.BACKWARD_CLOSED_ARROW,
                    scale: 7,
                    fillColor: '#28a745',
                    fillOpacity: 1,
                    strokeColor: '#fff',
                    strokeWeight: 2
                }
            });

            const infoWindow = new google.maps.InfoWindow({
                content: '<div style="font-family:Inter,sans-serif;padding:4px 2px;">' +
                         '<strong>' + a.label + '</strong><br>' +
                         '<span style="font-size:0.85em;color:#555;">' + a.address + '</span>' +
                         '</div>'
            });
            marker.addListener('click', function() {
                infoWindow.open(map, marker);
                const card = document.getElementById('card-' + a.id);
                if (card) card.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            });
        });
    }

    function acceptDelivery(assignmentId, btn) {
        if (!confirm('Accept this delivery?')) return;
        btn.disabled = true;
        btn.textContent = 'Accepting...';

        fetch(CONTEXT_PATH + '/driver/acceptDelivery', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'assignmentId=' + assignmentId
        })
        .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(data => {
            if (data.success) {
                btn.textContent = 'Accepted!';
                btn.style.background = '#6c757d';
                setTimeout(() => {
                    const card = document.getElementById('card-' + assignmentId);
                    if (card) card.remove();
                }, 800);
            } else {
                alert(data.message || 'Failed to accept delivery.');
                btn.disabled = false;
                btn.textContent = 'Accept Delivery';
            }
        })
        .catch(err => {
            alert('Error: ' + err.message);
            btn.disabled = false;
            btn.textContent = 'Accept Delivery';
        });
    }
</script>
<% if (hasLocation) { %>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&callback=initDeliveryMap" async defer></script>
<% } %>

</body>
</html>
