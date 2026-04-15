<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.Vehicle" %>
<%@ page import="com.dailyfixer.dao.VehicleDAO" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    VehicleDAO vehicleDAO = new VehicleDAO();
    Vehicle vehicle = vehicleDAO.getVehicleByDriver(user.getUserId());
    boolean hasVehicle = vehicle != null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Management | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .page-content {
            margin-left: 240px;
            padding: 32px;
            background: var(--background);
            min-height: calc(100vh - 83px);
        }
        .page-header { margin-bottom: 28px; }
        .page-header h1 { font-size: 1.6rem; font-weight: 700; color: var(--foreground); margin: 0 0 4px; }
        .page-header p  { color: var(--muted-foreground); font-size: 0.9rem; margin: 0; }

        /* Empty state */
        .empty-state {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 16px; padding: 72px 32px;
            background: var(--card); border: 1px solid var(--border); border-radius: var(--radius-lg);
            text-align: center;
        }
        .empty-state .empty-icon { font-size: 3rem; color: var(--muted-foreground); }
        .empty-state h3 { font-size: 1.15rem; font-weight: 600; color: var(--foreground); margin: 0; }
        .empty-state p  { color: var(--muted-foreground); font-size: 0.9rem; max-width: 360px; margin: 0; }
        .empty-state a  { text-decoration: none; }

        /* Vehicle layout */
        .vehicle-wrapper { display: flex; flex-direction: column; gap: 24px; }

        /* Photo gallery */
        .photo-gallery { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
        .photo-slot {
            position: relative; background: var(--card); border: 1px solid var(--border);
            border-radius: var(--radius-md); overflow: hidden; aspect-ratio: 4/3; cursor: pointer;
        }
        .photo-slot img { width: 100%; height: 100%; object-fit: cover; display: block; transition: transform 0.2s; }
        .photo-slot:hover img { transform: scale(1.04); }
        .photo-label {
            position: absolute; bottom: 0; left: 0; right: 0;
            background: linear-gradient(transparent, rgba(0,0,0,0.6));
            color: #fff; font-size: 0.75rem; font-weight: 600; padding: 8px 10px 6px;
            text-align: center; letter-spacing: 0.04em; text-transform: uppercase;
        }

        /* Info row */
        .info-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

        /* Detail card */
        .detail-card, .docs-card {
            background: var(--card); border: 1px solid var(--border);
            border-radius: var(--radius-lg); padding: 24px;
        }
        .detail-card h3, .docs-card h3 {
            font-size: 0.8rem; font-weight: 700; color: var(--muted-foreground);
            letter-spacing: 0.08em; text-transform: uppercase; margin: 0 0 18px;
        }
        .category-badge {
            display: inline-block;
            background: color-mix(in srgb, var(--primary) 15%, transparent);
            color: var(--primary); font-size: 0.75rem; font-weight: 600;
            padding: 3px 10px; border-radius: 999px; margin-bottom: 14px;
        }
        .detail-row {
            display: flex; justify-content: space-between; align-items: baseline;
            padding: 10px 0; border-bottom: 1px solid var(--border); gap: 12px;
        }
        .detail-row:last-of-type { border-bottom: none; }
        .detail-label { font-size: 0.82rem; color: var(--muted-foreground); font-weight: 500; white-space: nowrap; }
        .detail-value { font-size: 0.9rem; font-weight: 600; color: var(--foreground); text-align: right; }
        .plate-value  { font-family: 'IBM Plex Mono', monospace; letter-spacing: 0.08em; }

        /* Documents */
        .doc-items { display: flex; flex-direction: column; gap: 12px; }
        .doc-item {
            display: flex; align-items: center; gap: 14px;
            padding: 12px 14px; border-radius: var(--radius-md);
            border: 1px solid var(--border); background: var(--background);
            cursor: pointer; transition: border-color 0.15s;
        }
        .doc-item:hover { border-color: var(--primary); }
        .doc-item.no-link { cursor: default; }
        .doc-item.no-link:hover { border-color: var(--border); }
        .doc-icon { font-size: 1.25rem; flex-shrink: 0; }
        .doc-info { flex: 1; }
        .doc-name { font-size: 0.85rem; font-weight: 600; color: var(--foreground); }
        .doc-sub  { font-size: 0.75rem; color: var(--muted-foreground); margin-top: 2px; }
        .doc-status { display: flex; align-items: center; gap: 5px; font-size: 0.78rem; font-weight: 600; white-space: nowrap; }
        .status-ok   { color: #16a34a; }
        .status-warn { color: #d97706; }

        /* Action row */
        .action-row { display: flex; gap: 12px; }
        .action-row a { text-decoration: none; }

        /* Lightbox */
        .lightbox-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.82); z-index: 1000;
            align-items: center; justify-content: center;
        }
        .lightbox-overlay.open { display: flex; }
        .lightbox-overlay img { max-width: 90vw; max-height: 88vh; border-radius: var(--radius-md); box-shadow: 0 20px 60px rgba(0,0,0,0.5); }
        .lightbox-close { position: fixed; top: 20px; right: 24px; color: #fff; font-size: 2rem; cursor: pointer; line-height: 1; z-index: 1001; }

        /* Delete modal */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.5); z-index: 900;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal-card {
            background: var(--card); border: 1px solid var(--border); border-radius: var(--radius-lg);
            padding: 32px; max-width: 420px; width: 90%; box-shadow: var(--shadow-lg); text-align: center;
        }
        .modal-card .modal-icon { font-size: 2.5rem; color: var(--destructive, #dc2626); margin-bottom: 12px; }
        .modal-card h3 { font-size: 1.1rem; font-weight: 700; color: var(--foreground); margin: 0 0 8px; }
        .modal-card p  { color: var(--muted-foreground); font-size: 0.88rem; margin: 0 0 24px; }
        .modal-actions { display: flex; gap: 12px; justify-content: center; }
        .modal-actions button, .modal-actions input[type=submit] {
            font-family: inherit; font-size: 0.9rem; font-weight: 600;
            padding: 10px 28px; border-radius: var(--radius-md); cursor: pointer; transition: opacity 0.15s;
        }
        .modal-actions .btn-cancel      { background: var(--secondary, #f1f5f9); color: var(--foreground); border: 1px solid var(--border); }
        .modal-actions .btn-confirm-del { background: var(--destructive, #dc2626); color: #fff; border: none; }
        .modal-actions button:hover, .modal-actions input[type=submit]:hover { opacity: 0.85; }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="page-content">
    <div class="page-header">
        <h1>Vehicle Management</h1>
        <p>Manage your registered vehicle and its documents.</p>
    </div>

    <% if (!hasVehicle) { %>
    <!-- STATE A: No vehicle -->
    <div class="empty-state">
        <i class="ph ph-van empty-icon"></i>
        <h3>No Vehicle Registered</h3>
        <p>You haven't added a vehicle yet. Register your vehicle to start accepting delivery requests.</p>
        <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/addVehicle.jsp" class="btn-primary">
            <i class="ph ph-plus"></i> Register My Vehicle
        </a>
    </div>

    <% } else { %>
    <!-- STATE B: Vehicle registered -->
    <div class="vehicle-wrapper">

        <!-- Photo gallery -->
        <div class="photo-gallery">
            <%
                String[] photoTypes  = {"front", "left", "right", "back"};
                String[] photoLabels = {"Front",  "Left",  "Right",  "Back"};
                String[] imgPaths    = { vehicle.getImgFront(), vehicle.getImgLeft(), vehicle.getImgRight(), vehicle.getImgBack() };
                for (int i = 0; i < photoTypes.length; i++) {
                    String imgSrc = (imgPaths[i] != null && !imgPaths[i].isEmpty())
                        ? request.getContextPath() + "/" + imgPaths[i]
                        : "";
            %>
            <div class="photo-slot" onclick="openLightbox('<%= imgSrc %>')">
                <img src="<%= imgSrc %>" alt="<%= photoLabels[i] %> view">
                <div class="photo-label"><%= photoLabels[i] %></div>
            </div>
            <% } %>
        </div>

        <!-- Details + Documents -->
        <div class="info-row">

            <div class="detail-card">
                <h3>Vehicle Details</h3>
                <div class="category-badge"><%= vehicle.getVehicleCategory() %></div>
                <div class="detail-row">
                    <span class="detail-label">Make</span>
                    <span class="detail-value"><%= vehicle.getBrand() %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Model</span>
                    <span class="detail-value"><%= vehicle.getModel() %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Plate Number</span>
                    <span class="detail-value plate-value"><%= vehicle.getPlateNumber() %></span>
                </div>
            </div>

            <div class="docs-card">
                <h3>Documents</h3>
                <div class="doc-items">
                    <%
                        boolean hasReg = vehicle.hasRegistration();
                        boolean hasIns = vehicle.hasInsurance();
                        boolean hasRev = vehicle.hasRevenue();
                        String regSrc = hasReg ? request.getContextPath() + "/" + vehicle.getDocRegistration() : "";
                        String insSrc = hasIns ? request.getContextPath() + "/" + vehicle.getDocInsurance() : "";
                        String revSrc = hasRev ? request.getContextPath() + "/" + vehicle.getDocRevenue() : "";
                    %>
                    <div class="doc-item <%= hasReg ? "" : "no-link" %>" <%= hasReg ? "onclick=\"openLightbox('" + regSrc + "')\"" : "" %>>
                        <i class="ph ph-file-doc doc-icon"></i>
                        <div class="doc-info">
                            <div class="doc-name">Registration Document</div>
                            <div class="doc-sub">Required &middot; <%= hasReg ? "Click to view" : "Not uploaded" %></div>
                        </div>
                        <div class="doc-status <%= hasReg ? "status-ok" : "status-warn" %>">
                            <i class="ph <%= hasReg ? "ph-check-circle" : "ph-warning" %>"></i>
                            <%= hasReg ? "Uploaded" : "Missing" %>
                        </div>
                    </div>
                    <div class="doc-item <%= hasIns ? "" : "no-link" %>" <%= hasIns ? "onclick=\"openLightbox('" + insSrc + "')\"" : "" %>>
                        <i class="ph ph-shield-check doc-icon"></i>
                        <div class="doc-info">
                            <div class="doc-name">Insurance / Commercial Document</div>
                            <div class="doc-sub">Optional &middot; <%= hasIns ? "Click to view" : "Not provided" %></div>
                        </div>
                        <div class="doc-status <%= hasIns ? "status-ok" : "status-warn" %>">
                            <i class="ph <%= hasIns ? "ph-check-circle" : "ph-minus-circle" %>"></i>
                            <%= hasIns ? "Uploaded" : "Not Provided" %>
                        </div>
                    </div>
                    <div class="doc-item <%= hasRev ? "" : "no-link" %>" <%= hasRev ? "onclick=\"openLightbox('" + revSrc + "')\"" : "" %>>
                        <i class="ph ph-receipt doc-icon"></i>
                        <div class="doc-info">
                            <div class="doc-name">Revenue Licence</div>
                            <div class="doc-sub">Required &middot; <%= hasRev ? "Click to view" : "Not uploaded" %></div>
                        </div>
                        <div class="doc-status <%= hasRev ? "status-ok" : "status-warn" %>">
                            <i class="ph <%= hasRev ? "ph-check-circle" : "ph-warning" %>"></i>
                            <%= hasRev ? "Uploaded" : "Missing" %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action buttons -->
        <div class="action-row">
            <a href="${pageContext.request.contextPath}/EditVehicleServlet" class="btn-secondary">
                <i class="ph ph-pencil-simple"></i> Edit Vehicle Details
            </a>
            <button class="btn-danger" onclick="openDeleteModal()">
                <i class="ph ph-trash"></i> Remove My Vehicle
            </button>
        </div>
    </div>
    <% } %>
</main>

<!-- Lightbox -->
<div class="lightbox-overlay" id="lightboxOverlay" onclick="closeLightbox(event)">
    <span class="lightbox-close" onclick="closeLightbox(null)">&times;</span>
    <img id="lightboxImg" src="" alt="Document or photo preview">
</div>

<!-- Delete modal -->
<div class="modal-overlay" id="deleteModal" onclick="closeDeleteModal(event)">
    <div class="modal-card">
        <div class="modal-icon"><i class="ph ph-trash"></i></div>
        <h3>Remove Vehicle</h3>
        <p>Are you sure you want to remove your vehicle and all associated photos and documents? This cannot be undone.</p>
        <div class="modal-actions">
            <button class="btn-cancel" onclick="closeDeleteModal(null)">Cancel</button>
            <form method="post" action="${pageContext.request.contextPath}/DeleteVehicleServlet" style="margin:0">
                <input type="hidden" name="id" value="<%= hasVehicle ? vehicle.getId() : "" %>">
                <input type="submit" class="btn-confirm-del" value="Yes, Remove">
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        var el = document.getElementById('nav-vehicles');
        if (el) el.classList.add('active');
    });

    function openLightbox(src) {
        document.getElementById('lightboxImg').src = src;
        document.getElementById('lightboxOverlay').classList.add('open');
    }
    function closeLightbox(e) {
        if (!e || e.target === document.getElementById('lightboxOverlay') || e.target === document.querySelector('.lightbox-close')) {
            document.getElementById('lightboxOverlay').classList.remove('open');
        }
    }
    function openDeleteModal() {
        document.getElementById('deleteModal').classList.add('open');
    }
    function closeDeleteModal(e) {
        if (!e || e.target === document.getElementById('deleteModal')) {
            document.getElementById('deleteModal').classList.remove('open');
        }
    }
</script>
</body>
</html>
