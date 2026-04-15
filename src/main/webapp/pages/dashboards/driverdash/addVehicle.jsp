<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.DeliveryRateDAO" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"driver".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    DeliveryRateDAO rateDAO = new DeliveryRateDAO();
    List<String> vehicleCategories = rateDAO.getActiveVehicleTypes();

    String errorMsg = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register Vehicle | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .page-content {
            margin-left: 240px;
            margin-top: 83px;
            padding: 32px;
            background: var(--background);
            min-height: calc(100vh - 83px);
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
        .photo-grid {
            display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px;
        }
        .photo-slot-upload {
            border: 2px dashed var(--border); border-radius: var(--radius-md);
            aspect-ratio: 4/3; position: relative; overflow: hidden;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 8px; cursor: pointer; transition: border-color 0.2s, background 0.2s;
            background: var(--background);
        }
        .photo-slot-upload:hover { border-color: var(--primary); background: color-mix(in srgb, var(--primary) 5%, transparent); }
        .photo-slot-upload input[type=file] {
            position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%;
        }
        .photo-slot-upload .slot-icon { font-size: 1.6rem; color: var(--muted-foreground); pointer-events: none; }
        .photo-slot-upload .slot-label { font-size: 0.78rem; font-weight: 600; color: var(--muted-foreground); pointer-events: none; text-transform: uppercase; letter-spacing: 0.06em; }
        .photo-slot-upload .slot-hint  { font-size: 0.72rem; color: var(--muted-foreground); pointer-events: none; }
        .photo-slot-upload .preview-img { display: none; width: 100%; height: 100%; object-fit: cover; position: absolute; inset: 0; }
        .photo-slot-upload.has-preview .preview-img { display: block; }
        .photo-slot-upload.has-preview .slot-icon,
        .photo-slot-upload.has-preview .slot-label,
        .photo-slot-upload.has-preview .slot-hint  { display: none; }
        .required-dot { color: var(--destructive, #dc2626); margin-left: 2px; }

        /* Form fields */
        .field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group label { font-size: 0.83rem; font-weight: 600; color: var(--foreground); }
        .form-group label .optional { font-weight: 400; color: var(--muted-foreground); margin-left: 4px; font-size: 0.78rem; }
        .form-group select, .form-group input[type=text] {
            padding: 10px 12px; border: 1px solid var(--border); border-radius: var(--radius-md);
            font-family: inherit; font-size: 0.9rem; background: var(--background); color: var(--foreground);
            transition: border-color 0.15s;
        }
        .form-group select:focus, .form-group input[type=text]:focus {
            outline: none; border-color: var(--primary);
            box-shadow: 0 0 0 3px color-mix(in srgb, var(--primary) 15%, transparent);
        }
        .form-group .field-hint { font-size: 0.75rem; color: var(--muted-foreground); }
        .form-group .field-error { font-size: 0.75rem; color: var(--destructive, #dc2626); display: none; }
        .form-group.has-error input, .form-group.has-error select { border-color: var(--destructive, #dc2626); }
        .form-group.has-error .field-error { display: block; }

        #customMakeGroup { display: none; }

        /* Document upload */
        .doc-upload-list { display: flex; flex-direction: column; gap: 14px; }
        .doc-upload-row {
            display: flex; align-items: center; gap: 16px;
            padding: 14px 16px; border: 1px solid var(--border);
            border-radius: var(--radius-md); background: var(--background);
        }
        .doc-icon { font-size: 1.3rem; flex-shrink: 0; color: var(--muted-foreground); }
        .doc-meta { flex: 1; }
        .doc-meta .doc-name { font-size: 0.87rem; font-weight: 600; color: var(--foreground); }
        .doc-meta .doc-hint { font-size: 0.75rem; color: var(--muted-foreground); margin-top: 2px; }
        .doc-optional-badge {
            font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em;
            background: color-mix(in srgb, #f59e0b 15%, transparent);
            color: #b45309; padding: 2px 7px; border-radius: 999px; flex-shrink: 0;
        }
        .doc-upload-row label.upload-btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 7px 14px; border-radius: var(--radius-md);
            background: var(--secondary, #f1f5f9); color: var(--foreground);
            border: 1px solid var(--border); font-size: 0.82rem; font-weight: 600;
            cursor: pointer; white-space: nowrap; transition: border-color 0.15s;
            flex-shrink: 0;
        }
        .doc-upload-row label.upload-btn:hover { border-color: var(--primary); }
        .doc-upload-row input[type=file] { display: none; }
        .doc-filename { font-size: 0.75rem; color: var(--muted-foreground); margin-top: 4px; }

        /* Error banner */
        .error-banner {
            background: color-mix(in srgb, var(--destructive, #dc2626) 12%, transparent);
            border: 1px solid color-mix(in srgb, var(--destructive, #dc2626) 40%, transparent);
            color: var(--destructive, #dc2626);
            border-radius: var(--radius-md); padding: 12px 16px;
            font-size: 0.88rem; font-weight: 500;
        }

        /* Action row */
        .form-actions { display: flex; gap: 12px; align-items: center; }
        .form-actions a { text-decoration: none; }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<main class="page-content">
    <div class="page-header">
        <h1>Register My Vehicle</h1>
        <p>Add your vehicle photos, details, and required documents.</p>
    </div>

    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
    <div class="error-banner" style="max-width:760px;margin-bottom:20px;">
        <i class="ph ph-warning-circle"></i> <%= errorMsg %>
    </div>
    <% } %>

    <form class="form-page" method="post" action="${pageContext.request.contextPath}/AddVehicleServlet" enctype="multipart/form-data" id="addForm" novalidate>

        <!-- SECTION 1: Vehicle photos -->
        <div class="section-card">
            <h2>Vehicle Photos <span class="required-dot">*</span></h2>
            <p style="font-size:0.82rem;color:var(--muted-foreground);margin:0 0 16px;">
                Upload clear photos of your vehicle from all four sides. Images only (JPG, PNG, WEBP). Max 10 MB each.
            </p>
            <div class="photo-grid">
                <div class="photo-slot-upload" id="slotFront">
                    <img class="preview-img" id="prevFront" src="" alt="Front preview">
                    <input type="file" name="imgFront" id="imgFront" accept="image/*" required onchange="previewPhoto(this,'prevFront','slotFront')">
                    <i class="ph ph-camera slot-icon"></i>
                    <span class="slot-label">Front View <span class="required-dot">*</span></span>
                    <span class="slot-hint">Click to upload</span>
                </div>
                <div class="photo-slot-upload" id="slotLeft">
                    <img class="preview-img" id="prevLeft" src="" alt="Left preview">
                    <input type="file" name="imgLeft" id="imgLeft" accept="image/*" required onchange="previewPhoto(this,'prevLeft','slotLeft')">
                    <i class="ph ph-camera slot-icon"></i>
                    <span class="slot-label">Left Side <span class="required-dot">*</span></span>
                    <span class="slot-hint">Click to upload</span>
                </div>
                <div class="photo-slot-upload" id="slotRight">
                    <img class="preview-img" id="prevRight" src="" alt="Right preview">
                    <input type="file" name="imgRight" id="imgRight" accept="image/*" required onchange="previewPhoto(this,'prevRight','slotRight')">
                    <i class="ph ph-camera slot-icon"></i>
                    <span class="slot-label">Right Side <span class="required-dot">*</span></span>
                    <span class="slot-hint">Click to upload</span>
                </div>
                <div class="photo-slot-upload" id="slotBack">
                    <img class="preview-img" id="prevBack" src="" alt="Back preview">
                    <input type="file" name="imgBack" id="imgBack" accept="image/*" required onchange="previewPhoto(this,'prevBack','slotBack')">
                    <i class="ph ph-camera slot-icon"></i>
                    <span class="slot-label">Back View <span class="required-dot">*</span></span>
                    <span class="slot-hint">Click to upload</span>
                </div>
            </div>
        </div>

        <!-- SECTION 2: Vehicle details -->
        <div class="section-card">
            <h2>Vehicle Details</h2>
            <div style="display:flex;flex-direction:column;gap:16px;">
                <div class="field-row">
                    <div class="form-group" id="categoryGroup">
                        <label for="vehicleCategory">Category <span class="required-dot">*</span></label>
                        <select name="vehicleCategory" id="vehicleCategory" required onchange="loadMakes(this.value)">
                            <option value="">-- Select Category --</option>
                            <% for (String cat : vehicleCategories) { %>
                            <option value="<%= cat %>"><%= cat %></option>
                            <% } %>
                        </select>
                        <span class="field-error" id="categoryError">Please select a category.</span>
                    </div>
                    <div class="form-group" id="makeGroup">
                        <label for="brand">Make <span class="required-dot">*</span></label>
                        <select name="brand" id="brand" required onchange="toggleCustomMake(this.value)">
                            <option value="">-- Select Category First --</option>
                        </select>
                        <span class="field-error" id="makeError">Please select a make.</span>
                    </div>
                </div>
                <div class="form-group" id="customMakeGroup">
                    <label for="customMake">Enter Make Name <span class="required-dot">*</span></label>
                    <input type="text" name="customMake" id="customMake" placeholder="e.g. Bajaj, TVS, Force" maxlength="100">
                    <span class="field-hint">This make will be added to the system for future use.</span>
                </div>
                <div class="field-row">
                    <div class="form-group">
                        <label for="vehicleModel">Model <span class="required-dot">*</span></label>
                        <input type="text" name="model" id="vehicleModel" placeholder="e.g. CB125, Tuk 4s" required maxlength="100">
                    </div>
                    <div class="form-group" id="plateGroup">
                        <label for="plateNumber">Plate Number <span class="required-dot">*</span></label>
                        <input type="text" name="plateNumber" id="plateNumber" placeholder="AB AB-1234 or AAA-0001"
                               required maxlength="12" oninput="validatePlate(this)">
                        <span class="field-hint">Format: <code>AB AB-1234</code> or <code>AAA-0001</code> (uppercase letters &amp; digits only)</span>
                        <span class="field-error" id="plateError">Invalid format. Use AB AB-1234 or AAA-0001.</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- SECTION 3: Documents -->
        <div class="section-card">
            <h2>Documents</h2>
            <p style="font-size:0.82rem;color:var(--muted-foreground);margin:0 0 16px;">
                Upload document images only (JPG, PNG, WEBP). Max 10 MB each.
                Registration and Revenue Licence are required.
            </p>
            <div class="doc-upload-list">
                <!-- Registration -->
                <div class="doc-upload-row">
                    <i class="ph ph-file-doc doc-icon"></i>
                    <div class="doc-meta">
                        <div class="doc-name">Registration Document <span class="required-dot">*</span></div>
                        <div class="doc-hint">Vehicle registration certificate &mdash; images only</div>
                        <div class="doc-filename" id="nameReg">No file chosen</div>
                    </div>
                    <label class="upload-btn" for="docRegistration">
                        <i class="ph ph-upload-simple"></i> Choose Image
                    </label>
                    <input type="file" name="docRegistration" id="docRegistration" accept="image/*" required
                           onchange="showFilename(this,'nameReg')">
                </div>
                <!-- Insurance (optional) -->
                <div class="doc-upload-row">
                    <i class="ph ph-shield-check doc-icon"></i>
                    <div class="doc-meta">
                        <div class="doc-name">Insurance / Commercial Document</div>
                        <div class="doc-hint">Vehicle insurance or commercial permit &mdash; images only</div>
                        <div class="doc-filename" id="nameIns">No file chosen</div>
                    </div>
                    <span class="doc-optional-badge">Optional</span>
                    <label class="upload-btn" for="docInsurance">
                        <i class="ph ph-upload-simple"></i> Choose Image
                    </label>
                    <input type="file" name="docInsurance" id="docInsurance" accept="image/*"
                           onchange="showFilename(this,'nameIns')">
                </div>
                <!-- Revenue -->
                <div class="doc-upload-row">
                    <i class="ph ph-receipt doc-icon"></i>
                    <div class="doc-meta">
                        <div class="doc-name">Revenue Licence <span class="required-dot">*</span></div>
                        <div class="doc-hint">Annual revenue licence &mdash; images only</div>
                        <div class="doc-filename" id="nameRev">No file chosen</div>
                    </div>
                    <label class="upload-btn" for="docRevenue">
                        <i class="ph ph-upload-simple"></i> Choose Image
                    </label>
                    <input type="file" name="docRevenue" id="docRevenue" accept="image/*" required
                           onchange="showFilename(this,'nameRev')">
                </div>
            </div>
        </div>

        <!-- Actions -->
        <div class="form-actions">
            <button type="submit" class="btn-primary" id="submitBtn">
                <i class="ph ph-check"></i> Register Vehicle
            </button>
            <a href="${pageContext.request.contextPath}/pages/dashboards/driverdash/vehicleManagement.jsp" class="btn-secondary">
                Cancel
            </a>
        </div>

    </form>
</main>

<script>
    var MAKES_URL = '${pageContext.request.contextPath}/GetVehicleMakesServlet';
    var PLATE_RE  = /^[A-Z]{2}\s[A-Z]{2}-\d{4}$|^[A-Z]{3}-\d{4}$/;

    document.addEventListener('DOMContentLoaded', function () {
        var el = document.getElementById('nav-vehicles');
        if (el) el.classList.add('active');
    });

    function previewPhoto(input, previewId, slotId) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById(previewId).src = e.target.result;
                document.getElementById(slotId).classList.add('has-preview');
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    function loadMakes(category) {
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
                    sel.appendChild(opt);
                });
                var other = document.createElement('option');
                other.value = 'Other'; other.textContent = 'Other (specify)';
                sel.appendChild(other);
            })
            .catch(function() {
                sel.innerHTML = '<option value="">-- Error loading makes --</option>';
            });
    }

    function toggleCustomMake(val) {
        document.getElementById('customMakeGroup').style.display = val === 'Other' ? 'flex' : 'none';
        var cm = document.getElementById('customMake');
        cm.required = val === 'Other';
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
        el.textContent = input.files.length > 0 ? input.files[0].name : 'No file chosen';
    }

    document.getElementById('addForm').addEventListener('submit', function(e) {
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
