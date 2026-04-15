<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Register Technician - DailyFixer</title>
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

        .server-error {
            background-color: var(--destructive);
            color: white;
            padding: 15px;
            border-radius: var(--radius-md);
            margin-bottom: 20px;
            font-weight: 500;
            line-height: 1.6;
        }

        .error-text {
            color: var(--destructive);
            font-size: 0.85rem;
            font-weight: 500;
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

        .form-cols {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        @media (max-width: 600px) {
            .form-cols { grid-template-columns: 1fr; gap: 0; }
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

        .login-link a:hover { text-decoration: underline; }

        .required-star { color: var(--destructive); }

        /* File upload */
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

        .file-hint {
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

        .file-upload-group input[type="file"]:hover { border-color: var(--primary); }

        .file-preview {
            margin-top: 8px;
            max-width: 200px;
            max-height: 120px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            display: none;
            object-fit: cover;
        }

        /* Professional background notice box */
        .notice-box {
            background: var(--muted);
            border-left: 4px solid var(--primary);
            border-radius: var(--radius-md);
            padding: 14px 16px;
            margin-bottom: 20px;
            font-size: 0.9rem;
            color: var(--foreground);
            line-height: 1.6;
        }

        .notice-box strong { color: var(--primary); }

        /* OR divider between qualifications and experience */
        .or-divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 20px 0;
            color: var(--muted-foreground);
            font-weight: 600;
            font-size: 0.85rem;
        }

        .or-divider::before,
        .or-divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        /* Dynamic multi-file rows */
        .multi-file-list { display: flex; flex-direction: column; gap: 10px; }

        .multi-file-row {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .multi-file-row input[type="file"] {
            flex: 1;
            padding: 8px;
            border: 2px dashed var(--border);
            border-radius: var(--radius-md);
            background: var(--muted);
            cursor: pointer;
            font-size: 0.85rem;
        }

        .multi-file-row input[type="file"]:hover { border-color: var(--primary); }

        .btn-remove-file {
            background: var(--destructive);
            color: white;
            border: none;
            border-radius: 6px;
            width: 32px;
            height: 32px;
            cursor: pointer;
            font-size: 1rem;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-add-file {
            background: var(--secondary);
            border: 1px dashed var(--primary);
            color: var(--primary);
            border-radius: var(--radius-md);
            padding: 8px 14px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: 8px;
        }

        .btn-add-file:hover { background: var(--accent); }

        .subsection-title {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--primary);
            text-transform: uppercase;
            letter-spacing: 0.4px;
            margin-bottom: 12px;
        }

        .experience-block {
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 16px;
            background: var(--card);
        }
    </style>
</head>

<body>

    <div class="register-container">
        <div class="form-container">
            <div class="page-header">
                <h2>Technician Account</h2>
                <p>Register to start accepting jobs</p>
            </div>

            <%
                String error = request.getParameter("error");
                if (error != null && !error.isEmpty()) {
            %>
            <div class="server-error"><%= error %></div>
            <% } %>

            <div id="clientError" class="server-error" style="display:none;"></div>

            <form method="post" action="${pageContext.request.contextPath}/registerTechnician"
                  enctype="multipart/form-data" id="registerForm">

                <!-- Personal Details -->
                <div class="section-title">Personal Details</div>

                <div class="form-cols">
                    <div class="form-group">
                        <label for="firstName">First Name <span class="required-star">*</span></label>
                        <input type="text" name="firstName" id="firstName" placeholder="First Name" required>
                        <div id="firstNameError" class="error-text"></div>
                    </div>
                    <div class="form-group">
                        <label for="lastName">Last Name <span class="required-star">*</span></label>
                        <input type="text" name="lastName" id="lastName" placeholder="Last Name" required>
                        <div id="lastNameError" class="error-text"></div>
                    </div>
                </div>

                <div class="form-cols">
                    <div class="form-group">
                        <label for="username">Username <span class="required-star">*</span></label>
                        <input type="text" name="username" id="username" placeholder="Username" required>
                        <div id="usernameError" class="error-text"></div>
                    </div>
                    <div class="form-group">
                        <label for="email">Email <span class="required-star">*</span></label>
                        <input type="email" name="email" id="email" placeholder="Email" required>
                        <div id="emailError" class="error-text"></div>
                    </div>
                </div>

                <div class="form-cols">
                    <div class="form-group">
                        <label for="password">Password <span class="required-star">*</span></label>
                        <input type="password" name="password" id="password" placeholder="Min 6 characters" required>
                        <div id="passwordError" class="error-text"></div>
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword">Confirm Password <span class="required-star">*</span></label>
                        <input type="password" name="confirmPassword" id="confirmPassword" placeholder="Confirm Password" required>
                        <div id="confirmPasswordError" class="error-text"></div>
                    </div>
                </div>

                <!-- Contact Information -->
                <div class="section-title">Contact Information</div>

                <div class="form-cols">
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="text" name="phone" id="phone" placeholder="Phone Number">
                        <div id="phoneError" class="error-text"></div>
                    </div>
                    <div class="form-group">
                        <label for="city">City <span class="required-star">*</span></label>
                        <select name="city" id="city" class="filter-select" style="width: 100%;" required>
                            <option value="">-- Select city --</option>
                            <% String[] cities = {"Colombo","Kandy","Galle","Jaffna","Kurunegala","Matara",
                               "Trincomalee","Batticaloa","Negombo","Anuradhapura","Polonnaruwa","Badulla",
                               "Ratnapura","Puttalam","Kilinochchi","Mannar","Hambantota"};
                               for (String c : cities) { %>
                            <option value="<%= c %>"><%= c %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- Profile Picture -->
                <div class="section-title">Profile Picture</div>

                <div class="file-upload-group">
                    <label>Technician Photo <span class="required-star">*</span></label>
                    <div class="file-hint">This will be used as your profile picture on the platform (max 5MB, image only)</div>
                    <input type="file" name="profile_picture" id="profile_picture" accept="image/*" required
                           onchange="previewImage(this, 'profilePreview')">
                    <img id="profilePreview" class="file-preview" alt="Profile Preview">
                </div>

                <!-- Professional Background -->
                <div class="section-title">Professional Background <span class="required-star">*</span></div>

                <div class="notice-box">
                    <strong>Please provide your professional background to register as a technician.</strong><br>
                    You must submit <strong>at least one</strong> of the following:
                    <ul style="margin: 8px 0 0 18px; padding: 0;">
                        <li>Your <strong>qualifications or certifications</strong> (e.g., training certificates) — up to 3 files (PDF or image)</li>
                        <li>Your <strong>workplace experience</strong> (company name, role, years, Employee ID card — name on card must match your registered name)</li>
                    </ul>
                    Providing both is recommended for better verification.
                </div>

                <!-- Qualifications -->
                <div class="subsection-title">Qualifications / Certifications</div>
                <div class="file-hint">Upload training certificates, diplomas, or other credentials. PDF or image, max 5MB each, up to 3 files.</div>

                <div class="multi-file-list" id="qualList">
                    <div class="multi-file-row">
                        <input type="file" name="qualifications[]" accept="image/*,.pdf">
                        <button type="button" class="btn-remove-file" onclick="removeFileRow(this, 'qualList', 3)" title="Remove">✕</button>
                    </div>
                </div>
                <button type="button" class="btn-add-file" onclick="addFileRow('qualList', 3, 'qualifications[]', 'image/*,.pdf')">+ Add qualification</button>

                <div class="or-divider">OR</div>

                <!-- Workplace Experience -->
                <div class="subsection-title">Workplace Experience</div>
                <div class="experience-block">
                    <div class="form-cols">
                        <div class="form-group">
                            <label for="experience_company">Company / Employer Name</label>
                            <input type="text" name="experience_company" id="experience_company" placeholder="e.g. ABC Repairs Ltd">
                        </div>
                        <div class="form-group">
                            <label for="experience_role">Role / Job Title</label>
                            <input type="text" name="experience_role" id="experience_role" placeholder="e.g. Senior Technician">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="experience_years">Years of Experience</label>
                        <input type="number" name="experience_years" id="experience_years" placeholder="e.g. 3" min="0" max="50">
                    </div>

                    <div class="file-upload-group">
                        <label>Employee ID Card Photo
                            <span style="font-size:0.8rem; color:var(--muted-foreground); font-weight:400;">
                                (required if filling experience)
                            </span>
                        </label>
                        <div class="file-hint">Image only, max 5MB</div>
                        <input type="file" name="emp_id_card" id="emp_id_card" accept="image/*"
                               onchange="previewImage(this, 'empIdPreview')">
                        <img id="empIdPreview" class="file-preview" alt="Employee ID Preview">
                    </div>

                    <div class="form-group">
                        <label for="emp_id_card_name">Name on Employee ID Card <span class="required-star">*</span>
                            <span style="font-size:0.8rem; color:var(--muted-foreground); font-weight:400;">
                                (must match your registered name)
                            </span>
                        </label>
                        <input type="text" name="emp_id_card_name" id="emp_id_card_name"
                               placeholder="Name exactly as it appears on card">
                    </div>
                </div>

                <!-- Optional Work Proof -->
                <div class="section-title">Work Proof <span style="font-size:0.85rem; color:var(--muted-foreground); font-weight:400;">(Optional)</span></div>
                <div class="file-hint">Upload up to 5 images of completed repairs or projects (images only, max 5MB each).</div>

                <div class="multi-file-list" id="proofList">
                    <div class="multi-file-row">
                        <input type="file" name="work_proofs[]" accept="image/*">
                        <button type="button" class="btn-remove-file" onclick="removeFileRow(this, 'proofList', 5)" title="Remove">✕</button>
                    </div>
                </div>
                <button type="button" class="btn-add-file" onclick="addFileRow('proofList', 5, 'work_proofs[]', 'image/*')">+ Add work proof</button>

                <button type="submit" class="btn-primary" style="width: 100%; margin-top: 28px;">
                    Submit Technician Application
                </button>
            </form>

            <p class="login-link">Already have an account?
                <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp">Login here</a>
            </p>
        </div>
    </div>

    <script>
        function previewImage(input, previewId) {
            var preview = document.getElementById(previewId);
            if (input.files && input.files[0]) {
                var file = input.files[0];
                if (!file.type.startsWith('image/')) {
                    alert('Please select an image file.');
                    input.value = '';
                    preview.style.display = 'none';
                    return;
                }
                if (file.size > 5 * 1024 * 1024) {
                    alert('File size must be less than 5MB.');
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

        function addFileRow(listId, max, inputName, acceptAttr) {
            var list = document.getElementById(listId);
            var rows = list.querySelectorAll('.multi-file-row');
            if (rows.length >= max) {
                alert('Maximum ' + max + ' files allowed.');
                return;
            }
            var row = document.createElement('div');
            row.className = 'multi-file-row';
            row.innerHTML =
                '<input type="file" name="' + inputName + '" accept="' + acceptAttr + '">' +
                '<button type="button" class="btn-remove-file" onclick="removeFileRow(this, \'' + listId + '\', ' + max + ')" title="Remove">✕</button>';
            list.appendChild(row);
        }

        function removeFileRow(btn, listId, max) {
            var list = document.getElementById(listId);
            var rows = list.querySelectorAll('.multi-file-row');
            if (rows.length <= 1) {
                // Keep at least one row, just clear its value
                var input = btn.parentElement.querySelector('input[type="file"]');
                if (input) input.value = '';
                return;
            }
            btn.parentElement.remove();
        }

        document.getElementById('registerForm').addEventListener('submit', function(e) {
            document.querySelectorAll('.error-text').forEach(el => el.textContent = '');
            document.getElementById('clientError').style.display = 'none';
            var errors = [];
            var hasFieldError = false;
            var f = id => document.getElementById(id).value.trim();

            if (!f('firstName')) { document.getElementById('firstNameError').textContent = 'First name required'; hasFieldError = true; }
            if (!f('lastName'))  { document.getElementById('lastNameError').textContent = 'Last name required'; hasFieldError = true; }
            if (!f('username'))  { document.getElementById('usernameError').textContent = 'Username required'; hasFieldError = true; }
            if (!f('email'))     { document.getElementById('emailError').textContent = 'Email required'; hasFieldError = true; }
            else {
                var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(f('email'))) { document.getElementById('emailError').textContent = 'Invalid email format'; hasFieldError = true; }
            }

            var pw  = document.getElementById('password').value;
            var cpw = document.getElementById('confirmPassword').value;

            if (pw.length < 6) { document.getElementById('passwordError').textContent = 'Min 6 characters'; hasFieldError = true; }
            if (pw !== cpw)    { document.getElementById('confirmPasswordError').textContent = 'Passwords do not match'; hasFieldError = true; }

            var phoneVal = f('phone').replace(/\D/g, '');
            if (phoneVal && phoneVal.length !== 10) { document.getElementById('phoneError').textContent = 'Phone must be exactly 10 digits'; hasFieldError = true; }

            // Profile picture required
            var profileFiles = document.getElementById('profile_picture').files;
            if (!profileFiles || profileFiles.length === 0) {
                errors.push('A profile picture is required.');
            }

            // At least one qualification file OR experience company must be provided
            var qualInputs = document.querySelectorAll('#qualList input[type="file"]');
            var hasQual = false;
            for (var i = 0; i < qualInputs.length; i++) {
                if (qualInputs[i].files && qualInputs[i].files.length > 0) { hasQual = true; break; }
            }

            var expCompany = document.getElementById('experience_company').value.trim();
            var hasExp = expCompany.length > 0;

            if (!hasQual && !hasExp) {
                errors.push('Please provide at least one qualification file or workplace experience details.');
            }

            // If experience is filled, require emp_id_card and emp_id_card_name
            if (hasExp) {
                var empIdFiles = document.getElementById('emp_id_card').files;
                if (!empIdFiles || empIdFiles.length === 0) {
                    errors.push('Employee ID card photo is required when providing work experience.');
                }
                var empIdName = document.getElementById('emp_id_card_name').value.trim();
                if (!empIdName) {
                    errors.push('Please enter the name on your Employee ID card.');
                }
                // Client-side name check
                if (empIdName) {
                    var firstName = document.getElementById('firstName').value.trim().toLowerCase();
                    var lastName  = document.getElementById('lastName').value.trim().toLowerCase();
                    var fullName  = (firstName + ' ' + lastName).trim();
                    if (empIdName.toLowerCase() !== fullName) {
                        errors.push('The name on your Employee ID card must match your registered name (' + document.getElementById('firstName').value.trim() + ' ' + document.getElementById('lastName').value.trim() + ').');
                    }
                }
            }

            if (errors.length > 0 || hasFieldError) {
                if (errors.length > 0) {
                    var div = document.getElementById('clientError');
                    div.innerHTML = errors.join('<br>');
                    div.style.display = 'block';
                }
                e.preventDefault();
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>

</body>
</html>