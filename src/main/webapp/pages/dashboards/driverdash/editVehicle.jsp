<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Vehicle" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    Vehicle vehicle = (Vehicle) request.getAttribute("vehicle");
    if (vehicle == null) {
        response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<String> vehicleCategories = (List<String>) request.getAttribute("vehicleCategories");
    @SuppressWarnings("unchecked")
    List<String> makesForCategory  = (List<String>) request.getAttribute("makesForCategory");

    String errorMsg = (String) request.getAttribute("error");

    String ctxPath     = request.getContextPath();
    String[] imgPaths   = { vehicle.getImgFront(), vehicle.getImgLeft(), vehicle.getImgRight(), vehicle.getImgBack() };
    boolean hasReg = vehicle.hasRegistration();
    boolean hasIns = vehicle.hasInsurance();
    boolean hasRev = vehicle.hasRevenue();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Vehicle | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .page-content {
            margin-left: 240px; margin-top: 83px; padding: 32px;
            background: var(--background); min-height: calc(100vh - 83px);
        }
        .page-header { margin-bottom: 28px; }
        .page-header h1 { font-size: 1.5rem; font-weight: 700; color: var(--foreground); margin: 0 0 4px; }
        .page-header p  { color: var(--muted-foreground); font-size: 0.9rem; margin: 0; }

        .form-page { max-width: 760px; display: flex; flex-direction: column; gap: 28px; }

        .section-card {
            background: var(--card); border: 1px solid var(--border);
            border-radius: var(--radius-lg); padding: 28px;
        }
        .section-card h2 {
            font-size: 0.82rem; font-weight: 700; color: var(--muted-foreground);
            letter-spacing: 0.08em; text-transform: uppercase; margin: 0 0 20px;
            padding-bottom: 12px; border-bottom: 1px solid var(--border);
        }

        /* Photo grid */
        .photo-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
        .photo-slot-upload {
            border: 2px dashed var(--border); border-radius: var(--radius-md);
            aspect-ratio: 4/3; position: relative; overflow: hidden;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 8px; cursor: pointer; transition: border-color 0.2s, background 0.2s;
            background: var(--background);
        }
        .photo-slot-upload:hover  { border-color: var(--primary); }
        .photo-slot-upload.loaded { border-style: solid; }
        .photo-slot-upload input[type=file] {
            position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%; z-index: 2;
        }
        .photo-slot-upload .slot-icon  { font-size: 1.6rem; color: var(--muted-foreground); pointer-events: none; }
        .photo-slot-upload .slot-label { font-size: 0.78rem; font-weight: 600; color: var(--muted-foreground); pointer-events: none; text-transform: uppercase; letter-spacing: 0.06em; }
        .photo-slot-upload .slot-hint  { font-size: 0.72rem; color: var(--muted-foreground); pointer-events: none; }
        .photo-slot-upload .preview-img { width: 100%; height: 100%; object-fit: cover; position: absolute; inset: 0; z-index: 1; }
        .change-overlay {
            position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
            background: rgba(0,0,0,0.45); color: #fff; font-size: 0.8rem; font-weight: 600;
            opacity: 0; transition: opacity 0.2s; z-index: 3; pointer-events: none;
            gap: 6px;
        }
        .photo-slot-upload.loaded:hover .change-overlay { opacity: 1; }
        .required-dot { color: var(--destructive, #dc2626); margin-left: 2px; }

        /* Form fields */
        .field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group label { font-size: 0.83rem; font-weight: 600; color: var(--foreground); }
        .form-group select, .form-group input[type=text] {
            padding: 10px 12px; border: 1px solid var(--border); border-radius: var(--radius-md);
            font-family: inherit; font-size: 0.9rem; background: var(--background); color: var(--foreground);
            transition: border-color 0.15s;
        }
        .form-group select:focus, .form-group input[type=text]:focus {
            outline: none; border-color: var(--primary);
            box-shadow: 0 0 0 3px color-mix(in srgb, var(--primary) 15%, transparent);
        }
        .form-group .field-hint  { font-size: 0.75rem; color: var(--muted-foreground); }
        .form-group .field-error { font-size: 0.75rem; color: var(--destructive, #dc2626); display: none; }
        .form-group.has-error input, .form-group.has-error select { border-color: var(--destructive, #dc2626); }
        .form-group.has-error .field-error { display: block; }
        #customMakeGroup { display: none; }

        /* Document upload */
        .doc-upload-list { display: flex; flex-direction: column; gap: 14px; }
        .doc-upload-row {
            display: flex; align-items: center; gap: 16px; padding: 14px 16px;
            border: 1px solid var(--border); border-radius: var(--radius-md); background: var(--background);
        }
        .doc-icon { font-size: 1.3rem; flex-shrink: 0; color: var(--muted-foreground); }
        .doc-meta { flex: 1; }
        .doc-meta .doc-name { font-size: 0.87rem; font-weight: 600; color: var(--foreground); }
        .doc-meta .doc-hint { font-size: 0.75rem; color: var(--muted-foreground); margin-top: 2px; }
        .doc-meta .doc-filename { font-size: 0.75rem; color: var(--muted-foreground); margin-top: 4px; }
        .doc-status-chip {
            font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em;
            padding: 2px 8px; border-radius: 999px; flex-shrink: 0;
        }
        .chip-ok   { background: color-mix(in srgb, #16a34a 12%, transparent); color: #15803d; }
        .chip-miss { background: color-mix(in srgb, #dc2626 12%, transparent); color: #dc2626; }
        .chip-opt  { background: color-mix(in srgb, #f59e0b 12%, transparent); color: #b45309; }
        .doc-upload-row label.upload-btn {
            display: inline-flex; align-items: center; gap: 6px; padding: 7px 14px;
            border-radius: var(--radius-md); background: var(--secondary, #f1f5f9); color: var(--foreground);
            border: 1px solid var(--border); font-size: 0.82rem; font-weight: 600; cursor: pointer;
            white-space: nowrap; transition: border-color 0.15s; flex-shrink: 0;
        }
        .doc-upload-row label.upload-btn:hover { border-color: var(--primary); }
        .doc-upload-row input[type=file] { display: none; }

        /* Error banner */
        .error-banner {
            background: color-mix(in srgb, var(--destructive, #dc2626) 12%, transparent);
            border: 1px solid color-mix(in srgb, var(--destructive, #dc2626) 40%, transparent);
            color: var(--destructive, #dc2626);
            border-radius: var(--radius-md); padding: 12px 16px; font-size: 0.88rem; font-weight: 500;
        }

        .form-actions { display: flex; gap: 12px; align-items: center; }
        .form-actions a { text-decoration: none; }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="page-content">
    <div class="page-header">
        <h1>Edit Vehicle Details</h1>
        <p>Update your vehicle information, photos, or documents. Only fields you change will be updated.</p>
    </div>

    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
    <div class="error-banner" style="max-width:760px;margin-bottom:20px;">
        <i class="ph ph-warning-circle"></i> <%= errorMsg %>
    </div>
    <% } %>

    <form class="form-page" method="post" action="${pageContext.request.contextPath}/EditVehicleServlet"
          enctype="multipart/form-data" id="editForm" novalidate>
        <input type="hidden" name="id" value="<%= vehicle.getId() %>">

        <!-- SECTION 1: Photos -->
        <div class="section-card">
            <h2>Vehicle Photos</h2>
            <p style="font-size:0.82rem;color:var(--muted-foreground);margin:0 0 16px;">
                Current photos are shown. Click a slot to replace it. Images only (JPG, PNG, WEBP). Max 10 MB each.
            </p>
            <div class="photo-grid">
                <%
                    String[] photoTypes  = {"front",   "left",   "right",   "back"};
                    String[] photoLabels = {"Front View", "Left Side", "Right Side", "Back View"};
                    String[] photoNames  = {"imgFront", "imgLeft",  "imgRight",  "imgBack"};
                    String[] slotIds     = {"slotFront","slotLeft", "slotRight", "slotBack"};
                    String[] prevIds     = {"prevFront","prevLeft", "prevRight", "prevBack"};
                    for (int i = 0; i < photoTypes.length; i++) {
                        String imgSrc = (imgPaths[i] != null && !imgPaths[i].isEmpty())
                            ? ctxPath + "/" + imgPaths[i] : "";
                %>
                <div class="photo-slot-upload loaded" id="<%= slotIds[i] %>">
                    <img class="preview-img" id="<%= prevIds[i] %>" src="<%= imgSrc %>" alt="<%= photoLabels[i] %>">
                    <div class="change-overlay"><i class="ph ph-camera"></i> Replace</div>
                    <input type="file" name="<%= photoNames[i] %>" id="<%= photoNames[i] %>" accept="image/*"
                           onchange="previewPhoto(this,'<%= prevIds[i] %>')">
                </div>
                <% } %>
            </div>
        </div>

        <!-- SECTION 2: Vehicle details -->
        <div class="section-card">
            <h2>Vehicle Details</h2>
            <div style="display:flex;flex-direction:column;gap:16px;">
                <div class="field-row">
                    <div class="form-group" id="categoryGroup">
                        <label for="vehicleCategory">Category <span class="required-dot">*</span></label>
                        <select name="vehicleCategory" id="vehicleCategory" required
                                onchange="loadMakes(this.value, null)">
                            <option value="">-- Select Category --</option>
                            <% if (vehicleCategories != null) { for (String cat : vehicleCategories) { %>
                            <option value="<%= cat %>" <%= cat.equals(vehicle.getVehicleCategory()) ? "selected" : "" %>><%= cat %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="form-group" id="makeGroup">
                        <label for="brand">Make <span class="required-dot">*</span></label>
                        <select name="brand" id="brand" required onchange="toggleCustomMake(this.value)">
                            <option value="">-- Loading --</option>
                        </select>
                        <span class="field-error" id="makeError">Please select a make.</span>
                    </div>
                </div>
                <div class="form-group" id="customMakeGroup">
                    <label for="customMake">Enter Make Name <span class="required-dot">*</span></label>
                    <input type="text" name="customMake" id="customMake" placeholder="e.g. Bajaj, TVS" maxlength="100">
                    <span class="field-hint">This make will be added to the system for future use.</span>
                </div>
                <div class="field-row">
                    <div class="form-group">
                        <label for="vehicleModel">Model <span class="required-dot">*</span></label>
                        <input type="text" name="model" id="vehicleModel"
                               value="<%= vehicle.getModel() != null ? vehicle.getModel() : "" %>"
                               required maxlength="100">
                    </div>
                    <div class="form-group" id="plateGroup">
                        <label for="plateNumber">Plate Number <span class="required-dot">*</span></label>
                        <input type="text" name="plateNumber" id="plateNumber"
                               value="<%= vehicle.getPlateNumber() != null ? vehicle.getPlateNumber() : "" %>"
                               required maxlength="12" oninput="validatePlate(this)">
                        <span class="field-hint">Format: <code>AB AB-1234</code> or <code>AAA-0001</code></span>
                        <span class="field-error" id="plateError">Invalid format. Use AB AB-1234 or AAA-0001.</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- SECTION 3: Documents -->
        <div class="section-card">
            <h2>Documents</h2>
            <p style="font-size:0.82rem;color:var(--muted-foreground);margin:0 0 16px;">
                Current documents are shown below. Upload a new image to replace one. Images only (JPG, PNG, WEBP). Max 10 MB each.
            </p>
            <div class="doc-upload-list">
                <!-- Registration -->
                <div class="doc-upload-row">
                    <i class="ph ph-file-doc doc-icon"></i>
                    <div class="doc-meta">
                        <div class="doc-name">Registration Document <span class="required-dot">*</span></div>
                        <div class="doc-hint">Leave empty to keep current file</div>
                        <div class="doc-filename" id="nameReg">
                            <%= hasReg ? "Current: uploaded" : "Not uploaded yet" %>
                        </div>
                    </div>
                    <span class="doc-status-chip <%= hasReg ? "chip-ok" : "chip-miss" %>">
                        <%= hasReg ? "Uploaded" : "Missing" %>
                    </span>
                    <label class="upload-btn" for="docRegistration">
                        <i class="ph ph-upload-simple"></i> <%= hasReg ? "Replace" : "Upload" %>
                    </label>
                    <input type="file" name="docRegistration" id="docRegistration" accept="image/*"
                           onchange="showFilename(this,'nameReg')">
                </div>
                <!-- Insurance -->
                <div class="doc-upload-row">
                    <i class="ph ph-shield-check doc-icon"></i>
                    <div class="doc-meta">
                        <div class="doc-name">Insurance / Commercial Document</div>
                        <div class="doc-hint">Optional &mdash; leave empty to keep current or skip</div>
                        <div class="doc-filename" id="nameIns">
                            <%= hasIns ? "Current: uploaded" : "Not provided" %>
                        </div>
                    </div>
                    <span class="doc-status-chip <%= hasIns ? "chip-ok" : "chip-opt" %>">
                        <%= hasIns ? "Uploaded" : "Optional" %>
                    </span>
                    <label class="upload-btn" for="docInsurance">
                        <i class="ph ph-upload-simple"></i> <%= hasIns ? "Replace" : "Upload" %>
                    </label>
                    <input type="file" name="docInsurance" id="docInsurance" accept="image/*"
                           onchange="showFilename(this,'nameIns')">
                </div>
                <!-- Revenue -->
                <div class="doc-upload-row">
                    <i class="ph ph-receipt doc-icon"></i>
                    <div class="doc-meta">
                        <div class="doc-name">Revenue Licence <span class="required-dot">*</span></div>
                        <div class="doc-hint">Leave empty to keep current file</div>
                        <div class="doc-filename" id="nameRev">
                            <%= hasRev ? "Current: uploaded" : "Not uploaded yet" %>
                        </div>
                    </div>
                    <span class="doc-status-chip <%= hasRev ? "chip-ok" : "chip-miss" %>">
                        <%= hasRev ? "Uploaded" : "Missing" %>
                    </span>
                    <label class="upload-btn" for="docRevenue">
                        <i class="ph ph-upload-simple"></i> <%= hasRev ? "Replace" : "Upload" %>
                    </label>
                    <input type="file" name="docRevenue" id="docRevenue" accept="image/*"
                           onchange="showFilename(this,'nameRev')">
                </div>
            </div>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn-primary">
                <i class="ph ph-check"></i> Save Changes
            </button>
            <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp" class="btn-secondary">
                Cancel
            </a>
        </div>
    </form>
</main>

<script>
    var MAKES_URL      = '${pageContext.request.contextPath}/GetVehicleMakesServlet';
    var PLATE_RE       = /^[A-Z]{2}\s[A-Z]{2}-\d{4}$|^[A-Z]{3}-\d{4}$/;
    var CURRENT_BRAND  = '<%= vehicle.getBrand() != null ? vehicle.getBrand().replace("'", "\\'") : "" %>';
    var CURRENT_CAT    = '<%= vehicle.getVehicleCategory() != null ? vehicle.getVehicleCategory().replace("'", "\\'") : "" %>';

    document.addEventListener('DOMContentLoaded', function () {
        var el = document.getElementById('nav-vehicles');
        if (el) el.classList.add('active');
        // Load makes for the pre-selected category
        if (CURRENT_CAT) loadMakes(CURRENT_CAT, CURRENT_BRAND);
    });

    function previewPhoto(input, previewId) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById(previewId).src = e.target.result;
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    function loadMakes(category, preselect) {
        var sel = document.getElementById('brand');
        sel.innerHTML = '<option value="">Loading...</option>';
        document.getElementById('customMakeGroup').style.display = 'none';
        if (!category) { sel.innerHTML = '<option value="">-- Select Category First --</option>'; return; }
        fetch(MAKES_URL + '?category=' + encodeURIComponent(category))
            .then(function(r){ return r.json(); })
            .then(function(makes) {
                sel.innerHTML = '<option value="">-- Select Make --</option>';
                makes.forEach(function(m) {
                    var opt = document.createElement('option');
                    opt.value = m; opt.textContent = m;
                    if (preselect && m === preselect) opt.selected = true;
                    sel.appendChild(opt);
                });
                var other = document.createElement('option');
                other.value = 'Other'; other.textContent = 'Other (specify)';
                if (preselect === 'Other') other.selected = true;
                sel.appendChild(other);
                if (preselect === 'Other') toggleCustomMake('Other');
            })
            .catch(function() {
                sel.innerHTML = '<option value="">-- Error loading makes --</option>';
            });
    }

    function toggleCustomMake(val) {
        var grp = document.getElementById('customMakeGroup');
        grp.style.display = val === 'Other' ? 'flex' : 'none';
        document.getElementById('customMake').required = val === 'Other';
    }

    function validatePlate(input) {
        var val = input.value.toUpperCase();
        input.value = val;
        var fg = document.getElementById('plateGroup');
        if (val && !PLATE_RE.test(val)) {
            fg.classList.add('has-error');
        } else {
            fg.classList.remove('has-error');
        }
    }

    function showFilename(input, targetId) {
        var el = document.getElementById(targetId);
        el.textContent = input.files.length > 0 ? input.files[0].name : el.textContent;
    }

    document.getElementById('editForm').addEventListener('submit', function(e) {
        var plate = document.getElementById('plateNumber').value.toUpperCase();
        if (!PLATE_RE.test(plate)) {
            e.preventDefault();
            document.getElementById('plateGroup').classList.add('has-error');
            document.getElementById('plateNumber').focus();
        }
    });
</script>
</body>
</html>
