<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <title>Driver Signup | DailyFixer</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background-color: var(--background);
            padding: 40px 20px;
        }

        .register-container {
            width: 100%;
            max-width: 700px;
        }

        .form-container {
            margin: 0 auto;
        }

        .page-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .page-header h2 {
            font-size: 2rem;
            color: var(--primary);
            margin-bottom: 10px;
        }

        .page-header p {
            color: var(--muted-foreground);
        }

        .error-text {
            color: var(--destructive);
            font-size: 0.85rem;
            margin-top: 5px;
            font-weight: 500;
        }

        .server-error {
            background-color: var(--destructive);
            color: white;
            padding: 15px;
            border-radius: var(--radius-md);
            margin-bottom: 20px;
            font-weight: 500;
        }

        .form-cols {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        @media (max-width: 600px) {
            .form-cols {
                grid-template-columns: 1fr;
                gap: 0;
            }
        }

        .login-link {
            text-align: center;
            margin-top: 20px;
            color: var(--muted-foreground);
        }

        .login-link a {
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        .section-title {
            font-size: 1rem;
            font-weight: 700;
            color: var(--foreground);
            margin-top: 28px;
            margin-bottom: 14px;
            padding-bottom: 8px;
            border-bottom: 2px solid var(--border);
        }

        .file-upload-group {
            margin-bottom: 16px;
        }

        .file-upload-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 6px;
            color: var(--foreground);
            font-size: 0.9rem;
        }

        .file-upload-group .file-hint {
            font-size: 0.8rem;
            color: var(--muted-foreground);
            margin-bottom: 6px;
        }

        .file-upload-group input[type="file"] {
            width: 100%;
            padding: 10px;
            border: 2px dashed var(--border);
            border-radius: var(--radius-md);
            background: var(--muted);
            cursor: pointer;
            font-size: 0.9rem;
        }

        .file-upload-group input[type="file"]:hover {
            border-color: var(--primary);
        }

        .file-preview {
            margin-top: 8px;
            max-width: 200px;
            max-height: 120px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            display: none;
            object-fit: cover;
        }

        .policy-group {
            margin-top: 24px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }

        .policy-group input[type="checkbox"] {
            margin-top: 3px;
            width: 18px;
            height: 18px;
            accent-color: var(--primary);
        }

        .policy-group label {
            font-size: 0.9rem;
            color: var(--foreground);
        }

        .policy-group label a {
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
        }

        .policy-group label a:hover {
            text-decoration: underline;
        }

        .required-star {
            color: var(--destructive);
        }
    </style>
</head>

<body>

    <div class="register-container">
        <div class="form-container">
            <div class="page-header">
                <h2>Driver Signup</h2>
                <p>Join DailyFixer as a Delivery Driver</p>
            </div>

            <%
                String error = request.getParameter("error");
                if (error != null && !error.isEmpty()) {
            %>
            <div class="server-error"><%= error %></div>
            <% } %>

            <div id="error" class="error-text" style="margin-bottom: 15px; text-align: center;"></div>

            <form action="${pageContext.request.contextPath}/RegisterDriverServlet" method="post" enctype="multipart/form-data" id="registerForm">

                <!-- Personal Information -->
                <div class="section-title">Personal Information</div>

                <div class="form-cols">
                    <div class="form-group">
                        <label for="first_name">First Name <span class="required-star">*</span></label>
                        <input type="text" name="first_name" id="first_name" placeholder="First Name" required>
                        <div id="firstNameError" class="error-text"></div>
                    </div>

                    <div class="form-group">
                        <label for="last_name">Last Name <span class="required-star">*</span></label>
                        <input type="text" name="last_name" id="last_name" placeholder="Last Name" required>
                        <div id="lastNameError" class="error-text"></div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="username">Username <span class="required-star">*</span></label>
                    <input type="text" name="username" id="username" placeholder="Username" required>
                    <div id="usernameError" class="error-text"></div>
                </div>

                <div class="form-cols">
                    <div class="form-group">
                        <label for="email">Email <span class="required-star">*</span></label>
                        <input type="email" name="email" id="email" placeholder="Email" required>
                        <div id="emailError" class="error-text"></div>
                    </div>

                    <div class="form-group">
                        <label for="phone_number">Phone Number <span class="required-star">*</span></label>
                        <input type="tel" name="phone_number" id="phone_number" placeholder="Phone Number" required>
                        <div id="phoneError" class="error-text"></div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="city">City <span class="required-star">*</span></label>
                    <input type="text" name="city" id="city" placeholder="City" required>
                    <div id="cityError" class="error-text"></div>
                </div>

                <!-- Identification Documents -->
                <div class="section-title">Identification Documents</div>

                <div class="form-group">
                    <label for="nic_number">NIC Number <span class="required-star">*</span></label>
                    <input type="text" name="nic_number" id="nic_number"
                           placeholder="e.g. 200012345678 or 901234567V" required>
                    <div id="nicError" class="error-text"></div>
                </div>

                <div class="form-cols">
                    <div class="file-upload-group">
                        <label>NIC Front Photo <span class="required-star">*</span></label>
                        <div class="file-hint">Upload photo of the front of your NIC (max 5MB)</div>
                        <input type="file" name="nic_front" id="nic_front" accept="image/*" required
                               onchange="previewFile(this, 'nicFrontPreview')">
                        <img id="nicFrontPreview" class="file-preview" alt="NIC Front Preview">
                    </div>

                    <div class="file-upload-group">
                        <label>NIC Back Photo <span class="required-star">*</span></label>
                        <div class="file-hint">Upload photo of the back of your NIC (max 5MB)</div>
                        <input type="file" name="nic_back" id="nic_back" accept="image/*" required
                               onchange="previewFile(this, 'nicBackPreview')">
                        <img id="nicBackPreview" class="file-preview" alt="NIC Back Preview">
                    </div>
                </div>

                <!-- Profile Picture -->
                <div class="section-title">Profile Picture</div>

                <div class="file-upload-group">
                    <label>Driver Photo <span class="required-star">*</span></label>
                    <div class="file-hint">This will be used as your profile picture on the platform (max 5MB)</div>
                    <input type="file" name="profile_picture" id="profile_picture" accept="image/*" required
                           onchange="previewFile(this, 'profilePreview')">
                    <img id="profilePreview" class="file-preview" alt="Profile Preview">
                </div>

                <!-- Driving License -->
                <div class="section-title">Driving License</div>

                <div class="form-cols">
                    <div class="file-upload-group">
                        <label>License Front Photo <span class="required-star">*</span></label>
                        <div class="file-hint">Upload photo of the front of your license (max 5MB)</div>
                        <input type="file" name="license_front" id="license_front" accept="image/*" required
                               onchange="previewFile(this, 'licenseFrontPreview')">
                        <img id="licenseFrontPreview" class="file-preview" alt="License Front Preview">
                    </div>

                    <div class="file-upload-group">
                        <label>License Back Photo</label>
                        <div class="file-hint">Optional — upload if your license has info on the back</div>
                        <input type="file" name="license_back" id="license_back" accept="image/*"
                               onchange="previewFile(this, 'licenseBackPreview')">
                        <img id="licenseBackPreview" class="file-preview" alt="License Back Preview">
                    </div>
                </div>

                <!-- Password -->
                <div class="section-title">Account Security</div>

                <div class="form-cols">
                    <div class="form-group">
                        <label for="password">Password <span class="required-star">*</span></label>
                        <input type="password" name="password" id="password" placeholder="Min 6 characters" required>
                        <div id="passwordError" class="error-text"></div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Confirm Password <span class="required-star">*</span></label>
                        <input type="password" name="confirmPassword" id="confirmPassword"
                               placeholder="Confirm Password" required>
                        <div id="confirmPasswordError" class="error-text"></div>
                    </div>
                </div>

                <!-- Policy Acceptance -->
                <div class="policy-group">
                    <input type="checkbox" name="policy_accepted" id="policy_accepted" required>
                    <label for="policy_accepted">
                        I have read and agree to the
                        <a href="javascript:void(0);" onclick="openPolicyModal(event)">Driver Policies</a>
                        <span class="required-star">*</span>
                    </label>
                </div>

                <button type="submit" class="btn-primary" style="width: 100%; margin-top: 24px;">
                    Submit Driver Application
                </button>
            </form>
            <p class="login-link">Already have an account? <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp">Login here</a></p>
        </div>
    </div>

    <!-- Driver Policies Modal -->
    <div id="policyModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); align-items:center; justify-content:center; z-index:1000; padding:20px; backdrop-filter: blur(2px);">
        <div style="background:var(--background); max-width:600px; width:100%; border-radius:var(--radius-md); padding:30px; position:relative; box-shadow:0 10px 25px rgba(0,0,0,0.2); max-height:85vh; overflow-y:auto; border: 1px solid var(--border);">
            <button type="button" onclick="closePolicyModal()" style="position:absolute; top:15px; right:20px; background:none; border:none; font-size:1.5rem; cursor:pointer; color:var(--muted-foreground);">&times;</button>
            <h2 style="margin-top:0; font-size:1.2rem; color:var(--foreground); margin-bottom:15px;">Driver Policies & Terms of Service</h2>
            <div style="font-size:0.9rem; color:var(--muted-foreground); line-height:1.6;">
                <p style="margin-bottom:12px;">By registering as a driver on Daily Fixer, you agree to abide by the following policies and guidelines.</p>
                <ul style="padding-left:20px; color:var(--foreground);">
                    <li style="margin-bottom:8px;">Daily Fixer currently uses a <strong>one-attempt delivery policy</strong>. Re-delivery scheduling is out of scope.</li>
                    <li style="margin-bottom:8px;">If the buyer is unavailable but answers the call, the package may be handed to a nearby neighbor or family member only after PIN verification.</li>
                    <li style="margin-bottom:8px;">If the buyer is unreachable, doorstep-drop completion is allowed only for orders where buyer consent exists.</li>
                    <li style="margin-bottom:8px;">For doorstep-drop completion, the driver must upload <strong>two proof photos</strong>: package close-up and package with door/house context.</li>
                    <li style="margin-bottom:8px;">Drivers must not mark an order delivered unless either PIN handover or required photo proof has been completed.</li>
                    <li style="margin-bottom:8px;">All delivery disputes are handled by support through the official website email channel.</li>
                </ul>
                <div style="background:var(--muted); border:1px dashed var(--border); border-radius:8px; padding:15px; margin-top:20px; text-align:center;">
                    <p style="font-weight:600; margin-bottom:5px; color:var(--foreground);">Policy Scope</p>
                    <p style="margin:0; font-size:0.85rem;">Advanced call logging, in-app calling, GPS tracking, and automated logistics rerouting are currently out of scope for this release.</p>
                </div>
            </div>
            <button type="button" onclick="acceptPolicies()" style="width:100%; margin-top:20px; padding:12px; background:var(--primary); color:white; border:none; border-radius:var(--radius-md); font-size:0.95rem; font-weight:600; cursor:pointer;">I Agree & Understand</button>
        </div>
    </div>

    <script>
        function openPolicyModal(e) {
            if(e) e.preventDefault();
            document.getElementById('policyModal').style.display = 'flex';
        }
        function closePolicyModal() {
            document.getElementById('policyModal').style.display = 'none';
        }
        function acceptPolicies() {
            closePolicyModal();
            document.getElementById('policy_accepted').checked = true;
        }

        function previewFile(input, previewId) {
            var preview = document.getElementById(previewId);
            if (input.files && input.files[0]) {
                var file = input.files[0];

                // Validate file type
                if (!file.type.startsWith('image/')) {
                    alert('Please select an image file (JPG, PNG, etc.)');
                    input.value = '';
                    preview.style.display = 'none';
                    return;
                }

                // Validate file size (5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert('File size must be less than 5MB');
                    input.value = '';
                    preview.style.display = 'none';
                    return;
                }

                var reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                };
                reader.readAsDataURL(file);
            } else {
                preview.style.display = 'none';
            }
        }

        document.getElementById('registerForm').addEventListener('submit', function(e) {
            document.querySelectorAll('.error-text').forEach(el => el.textContent = '');
            var hasFieldError = false;
            var fileErrors = "";
            var f = id => document.getElementById(id).value.trim();

            if (!f('first_name')) { document.getElementById('firstNameError').textContent = 'First name required'; hasFieldError = true; }
            if (!f('last_name'))  { document.getElementById('lastNameError').textContent = 'Last name required'; hasFieldError = true; }
            if (!f('username'))   { document.getElementById('usernameError').textContent = 'Username required'; hasFieldError = true; }
            if (!f('city'))       { document.getElementById('cityError').textContent = 'City required'; hasFieldError = true; }

            var emailVal = f('email');
            if (!emailVal) { document.getElementById('emailError').textContent = 'Email required'; hasFieldError = true; }
            else {
                var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(emailVal)) { document.getElementById('emailError').textContent = 'Invalid email format'; hasFieldError = true; }
            }

            var phoneVal = f('phone_number').replace(/\D/g, '');
            if (!phoneVal) { document.getElementById('phoneError').textContent = 'Phone number required'; hasFieldError = true; }
            else if (phoneVal.length !== 10) { document.getElementById('phoneError').textContent = 'Phone must be exactly 10 digits'; hasFieldError = true; }

            var pw  = document.getElementById("password").value;
            var cpw = document.getElementById("confirmPassword").value;
            if (pw.length < 6) { document.getElementById('passwordError').textContent = 'Min 6 characters'; hasFieldError = true; }
            if (pw !== cpw)    { document.getElementById('confirmPasswordError').textContent = 'Passwords do not match'; hasFieldError = true; }

            var nic    = document.getElementById("nic_number").value.trim();
            var policy = document.getElementById("policy_accepted").checked;

            // NIC validation: 9 digits + V/X or 12 digits
            var nicRegex = /^\d{9}[VvXx]$|^\d{12}$/;
            if (!nicRegex.test(nic)) {
                fileErrors += "Invalid NIC format. Use 9 digits + V/X or 12 digits.<br>";
                document.getElementById("nicError").textContent = "Invalid NIC format";
            } else {
                document.getElementById("nicError").textContent = "";
            }

            // Validate required files
            var nicFront = document.getElementById("nic_front").files.length;
            var nicBack  = document.getElementById("nic_back").files.length;
            var profile  = document.getElementById("profile_picture").files.length;
            var licFront = document.getElementById("license_front").files.length;

            if (nicFront === 0) fileErrors += "NIC front photo is required.<br>";
            if (nicBack === 0)  fileErrors += "NIC back photo is required.<br>";
            if (profile === 0)  fileErrors += "Profile picture is required.<br>";
            if (licFront === 0) fileErrors += "License front photo is required.<br>";

            if (!policy) fileErrors += "You must accept the driver policies.<br>";

            var errorDiv = document.getElementById("error");
            errorDiv.innerHTML = fileErrors;

            if (fileErrors !== "" || hasFieldError) {
                e.preventDefault();
                window.scrollTo({top: 0, behavior: 'smooth'});
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>
</body>

</html>