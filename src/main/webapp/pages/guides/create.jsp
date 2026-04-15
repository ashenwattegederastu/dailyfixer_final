<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || (!"admin".equals(user.getRole())
                && !"volunteer".equals(user.getRole()) && !"technician".equals(user.getRole()))) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Create Guide | Daily Fixer</title>
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                    <style>
                        .page-container {
                            max-width: 900px;
                            margin: 0 auto;
                            padding: 100px 30px 50px;
                        }

                        .page-header {
                            margin-bottom: 30px;
                        }

                        .page-header h1 {
                            font-size: 2rem;
                            color: var(--foreground);
                        }

                        .form-card {
                            background: var(--card);
                            border-radius: var(--radius-lg);
                            padding: 30px;
                            border: 1px solid var(--border);
                            margin-bottom: 25px;
                        }

                        .form-card h2 {
                            font-size: 1.3rem;
                            color: var(--primary);
                            margin-bottom: 20px;
                            padding-bottom: 10px;
                            border-bottom: 2px solid var(--border);
                        }

                        .form-group {
                            margin-bottom: 20px;
                        }

                        .form-group label {
                            display: block;
                            margin-bottom: 8px;
                            font-weight: 600;
                            color: var(--foreground);
                        }

                        .form-group input[type="text"],
                        .form-group input[type="url"],
                        .form-group select,
                        .form-group textarea {
                            width: 100%;
                            padding: 12px 15px;
                            border: 2px solid var(--border);
                            border-radius: var(--radius-md);
                            background: var(--input);
                            color: var(--foreground);
                            font-size: 1rem;
                            font-family: inherit;
                        }

                        .form-group input:focus,
                        .form-group select:focus,
                        .form-group textarea:focus {
                            outline: none;
                            border-color: var(--primary);
                        }

                        .form-group textarea {
                            min-height: 120px;
                            resize: vertical;
                        }

                        .form-group small {
                            color: var(--muted-foreground);
                            font-size: 0.85rem;
                        }

                        .category-row {
                            display: grid;
                            grid-template-columns: 1fr 1fr;
                            gap: 20px;
                        }

                        .dynamic-list {
                            margin-top: 10px;
                        }

                        .dynamic-item {
                            display: flex;
                            gap: 10px;
                            margin-bottom: 10px;
                        }

                        .dynamic-item input {
                            flex: 1;
                        }

                        .add-btn,
                        .remove-btn {
                            padding: 8px 15px;
                            border: none;
                            border-radius: var(--radius-md);
                            cursor: pointer;
                            font-weight: 500;
                        }

                        .add-btn {
                            background: var(--secondary);
                            color: var(--secondary-foreground);
                            border: 1px solid var(--border);
                        }

                        .remove-btn {
                            background: var(--destructive);
                            color: var(--destructive-foreground);
                        }

                        .step-card {
                            background: var(--muted);
                            border-radius: var(--radius-md);
                            padding: 20px;
                            margin-bottom: 20px;
                            position: relative;
                        }

                        .step-card-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 15px;
                        }

                        .step-number {
                            font-weight: 700;
                            color: var(--primary);
                        }

                        .image-preview {
                            max-width: 200px;
                            max-height: 150px;
                            object-fit: cover;
                            border-radius: var(--radius-sm);
                            margin-top: 10px;
                        }

                        .form-actions {
                            display: flex;
                            gap: 15px;
                            justify-content: flex-end;
                            margin-top: 30px;
                        }

                        .error-message {
                            background: var(--destructive);
                            color: var(--destructive-foreground);
                            padding: 15px;
                            border-radius: var(--radius-md);
                            margin-bottom: 20px;
                        }

                        /* Add New Category Styles */
                        .add-new-container {
                            display: none;
                            margin-top: 10px;
                            padding: 15px;
                            background: var(--muted);
                            border-radius: var(--radius-md);
                            border: 1px solid var(--border);
                        }

                        .add-new-container.active {
                            display: block;
                        }

                        .add-new-input-row {
                            display: flex;
                            gap: 10px;
                            align-items: center;
                        }

                        .add-new-input-row input {
                            flex: 1;
                            padding: 10px 12px;
                            border: 2px solid var(--border);
                            border-radius: var(--radius-md);
                            background: var(--input);
                            color: var(--foreground);
                        }

                        .add-new-input-row button {
                            padding: 10px 16px;
                            border: none;
                            border-radius: var(--radius-md);
                            cursor: pointer;
                            font-weight: 500;
                        }

                        .save-new-btn {
                            background: var(--primary);
                            color: var(--primary-foreground);
                        }

                        .cancel-new-btn {
                            background: var(--secondary);
                            color: var(--secondary-foreground);
                            border: 1px solid var(--border);
                        }

                        @media (max-width: 600px) {
                            .category-row {
                                grid-template-columns: 1fr;
                            }
                        }
                    </style>
                </head>

                <body>
                    <!-- Navigation -->
                    <nav id="navbar" class="public-nav">
                        <div class="nav-container">
                            <a href="${pageContext.request.contextPath}/index.jsp" class="logo">Daily Fixer</a>
                            <ul class="nav-links">
                                <li><a href="${pageContext.request.contextPath}/guides">View Repair Guides</a></li>
                            </ul>
                            <div class="nav-buttons">
                                <button id="theme-toggle-btn" class="theme-toggle" onclick="toggleTheme()">🌙
                                    Dark</button>
                                <a href="${pageContext.request.contextPath}/pages/dashboards/${sessionScope.currentUser.role}dash/${sessionScope.currentUser.role}dashmain.jsp"
                                    class="btn-login" style="text-decoration: none; padding: 0.6rem 1.2rem;">
                                    Hi, ${sessionScope.currentUser.firstName}
                                </a>
                                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
                            </div>
                        </div>
                    </nav>

                    <div class="page-container">
                        <div class="page-header">
                            <h1>Create New Guide</h1>
                        </div>

                        <c:if test="${not empty error}">
                            <div class="error-message">${error}</div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/guides/create" method="post"
                            enctype="multipart/form-data" id="guideForm">

                            <!-- Basic Information -->
                            <div class="form-card">
                                <h2>📝 Basic Information</h2>
                                <div class="form-group">
                                    <label for="title">Guide Title *</label>
                                    <input type="text" id="title" name="title" required
                                        placeholder="e.g., How to Fix a Leaking Faucet">
                                </div>
                                <div class="form-group">
                                    <label for="mainImage">Main Image <small
                                            style="color: var(--muted-foreground);">(Max 10 MB)</small></label>
                                    <input type="file" id="mainImage" name="mainImage" accept="image/*"
                                        onchange="validateAndPreviewMainImage(this)">
                                    <div id="mainImageError"
                                        style="color: var(--destructive); font-size: 0.85rem; margin-top: 5px; display: none;">
                                    </div>
                                    <img id="mainImagePreview" class="image-preview" style="display:none;">
                                </div>
                                <div class="category-row">
                                    <div class="form-group">
                                        <label for="mainCategory">Main Category *</label>
                                        <select id="mainCategory" name="mainCategory" required
                                            onchange="handleMainCategoryChange()">
                                            <option value="">Loading categories...</option>
                                        </select>
                                        <div id="addNewMainCategoryContainer" class="add-new-container">
                                            <div class="add-new-input-row">
                                                <input type="text" id="newMainCategoryInput"
                                                    placeholder="Enter new category name">
                                                <button type="button" class="save-new-btn"
                                                    onclick="saveNewMainCategory()">Save</button>
                                                <button type="button" class="cancel-new-btn"
                                                    onclick="cancelNewMainCategory()">Cancel</button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label for="subCategory">Sub-Category *</label>
                                        <select id="subCategory" name="subCategory" required>
                                            <option value="">Select Main Category First</option>
                                        </select>
                                        <div id="addNewSubCategoryContainer" class="add-new-container">
                                            <div class="add-new-input-row">
                                                <input type="text" id="newSubCategoryInput"
                                                    placeholder="Enter new sub-category name">
                                                <button type="button" class="save-new-btn"
                                                    onclick="saveNewSubCategory()">Save</button>
                                                <button type="button" class="cancel-new-btn"
                                                    onclick="cancelNewSubCategory()">Cancel</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="youtubeUrl">YouTube Video URL (Optional)</label>
                                    <input type="url" id="youtubeUrl" name="youtubeUrl"
                                        placeholder="https://www.youtube.com/watch?v=...">
                                    <small>If provided, the video will be embedded in the guide</small>
                                </div>
                            </div>

                            <!-- Requirements -->
                            <div class="form-card">
                                <h2>🔧 Things You Need</h2>
                                <p style="color: var(--muted-foreground); margin-bottom: 15px;">List the tools,
                                    materials, or parts needed to follow this guide.</p>
                                <div id="requirementsList" class="dynamic-list">
                                    <div class="dynamic-item">
                                        <input type="text" name="requirements" placeholder="e.g., Adjustable wrench">
                                        <button type="button" class="remove-btn" onclick="removeItem(this)">✕</button>
                                    </div>
                                </div>
                                <button type="button" class="add-btn" onclick="addRequirement()">+ Add
                                    Requirement</button>
                            </div>

                            <!-- Steps -->
                            <div class="form-card">
                                <h2>📋 Guide Steps</h2>
                                <p style="color: var(--muted-foreground); margin-bottom: 15px;">Add step-by-step
                                    instructions with images.</p>
                                <div id="stepsList">
                                    <div class="step-card" data-step="0">
                                        <div class="step-card-header">
                                            <span class="step-number">Step 1</span>
                                            <button type="button" class="remove-btn" onclick="removeStep(this)">Remove
                                                Step</button>
                                        </div>
                                        <div class="form-group">
                                            <label>Step Title *</label>
                                            <input type="text" name="stepTitle" required
                                                placeholder="e.g., Turn off the water supply">
                                        </div>
                                        <div class="form-group">
                                            <label>Step Images</label>
                                            <input type="file" name="stepImage_0" accept="image/*" multiple>
                                        </div>
                                        <div class="form-group">
                                            <label>Step Description</label>
                                            <textarea name="stepBody"
                                                placeholder="Describe what to do in this step..."></textarea>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="add-btn" onclick="addStep()">+ Add Step</button>
                            </div>

                            <div class="form-actions">
                                <a href="${pageContext.request.contextPath}/guides" class="btn-secondary">Cancel</a>
                                <button type="submit" class="btn-primary">Create Guide</button>
                            </div>
                        </form>
                    </div>
                    <script>
                        // Dynamic category data loaded from server
                        let categoriesData = [];
                        let selectedCategoryId = null;
                        const contextPath = '${pageContext.request.contextPath}';

                        // Load categories on page load
                        document.addEventListener('DOMContentLoaded', function () {
                            loadCategories();
                        });

                        // Fetch categories from the server
                        async function loadCategories() {
                            try {
                                const response = await fetch(contextPath + '/guides/categories');
                                const data = await response.json();
                                categoriesData = data.categories || [];
                                populateMainCategories();
                            } catch (error) {
                                console.error('Failed to load categories:', error);
                                document.getElementById('mainCategory').innerHTML =
                                    '<option value="">Failed to load categories</option>';
                            }
                        }

                        // Populate main category dropdown
                        function populateMainCategories() {
                            const mainSelect = document.getElementById('mainCategory');
                            mainSelect.innerHTML = '<option value="">Select Category</option>';

                            categoriesData.forEach(cat => {
                                const option = document.createElement('option');
                                option.value = cat.name;
                                option.dataset.categoryId = cat.categoryId;
                                option.textContent = cat.name;
                                mainSelect.appendChild(option);
                            });

                            // Add "Add New Category" option
                            const addNewOption = document.createElement('option');
                            addNewOption.value = '__ADD_NEW__';
                            addNewOption.textContent = '➕ Add New Category...';
                            addNewOption.style.fontWeight = 'bold';
                            mainSelect.appendChild(addNewOption);
                        }

                        // Handle main category selection
                        function handleMainCategoryChange() {
                            const mainSelect = document.getElementById('mainCategory');
                            const selectedValue = mainSelect.value;

                            if (selectedValue === '__ADD_NEW__') {
                                // Show add new main category input
                                document.getElementById('addNewMainCategoryContainer').classList.add('active');
                                mainSelect.value = ''; // Reset select
                                return;
                            }

                            // Hide add new containers
                            document.getElementById('addNewMainCategoryContainer').classList.remove('active');
                            document.getElementById('addNewSubCategoryContainer').classList.remove('active');

                            // Find the selected category
                            const selectedOption = mainSelect.options[mainSelect.selectedIndex];
                            const categoryId = selectedOption ? selectedOption.dataset.categoryId : null;
                            selectedCategoryId = categoryId ? parseInt(categoryId) : null;

                            updateSubCategories();
                        }

                        // Update sub-category dropdown based on selected main category
                        function updateSubCategories() {
                            const mainSelect = document.getElementById('mainCategory');
                            const subSelect = document.getElementById('subCategory');
                            subSelect.innerHTML = '<option value="">Select Sub-Category</option>';

                            const selectedOption = mainSelect.options[mainSelect.selectedIndex];
                            if (!selectedOption || !selectedOption.dataset.categoryId) {
                                subSelect.innerHTML = '<option value="">Select Main Category First</option>';
                                return;
                            }

                            const categoryId = parseInt(selectedOption.dataset.categoryId);
                            const category = categoriesData.find(c => c.categoryId === categoryId);

                            if (category && category.subCategories) {
                                category.subCategories.forEach(sub => {
                                    const option = document.createElement('option');
                                    option.value = sub.name;
                                    option.textContent = sub.name;
                                    subSelect.appendChild(option);
                                });
                            }

                            // Add "Add New Sub-Category" option
                            const addNewOption = document.createElement('option');
                            addNewOption.value = '__ADD_NEW__';
                            addNewOption.textContent = '➕ Add New Sub-Category...';
                            addNewOption.style.fontWeight = 'bold';
                            subSelect.appendChild(addNewOption);

                            // Handle sub-category "Add New" selection
                            subSelect.onchange = function () {
                                if (this.value === '__ADD_NEW__') {
                                    document.getElementById('addNewSubCategoryContainer').classList.add('active');
                                    this.value = '';
                                } else {
                                    document.getElementById('addNewSubCategoryContainer').classList.remove('active');
                                }
                            };
                        }

                        // Save new main category
                        async function saveNewMainCategory() {
                            const input = document.getElementById('newMainCategoryInput');
                            const name = input.value.trim();

                            if (!name) {
                                alert('Please enter a category name');
                                return;
                            }

                            try {
                                const response = await fetch(contextPath + '/guides/categories', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/json' },
                                    body: JSON.stringify({ type: 'main', name: name })
                                });

                                const result = await response.json();

                                if (result.success) {
                                    // Add to local data
                                    categoriesData.push({
                                        categoryId: result.categoryId,
                                        name: result.name,
                                        subCategories: []
                                    });

                                    // Refresh dropdown and select the new category
                                    populateMainCategories();
                                    document.getElementById('mainCategory').value = result.name;
                                    selectedCategoryId = result.categoryId;
                                    updateSubCategories();

                                    // Clear and hide input
                                    input.value = '';
                                    document.getElementById('addNewMainCategoryContainer').classList.remove('active');
                                } else {
                                    alert('Error: ' + (result.error || 'Failed to create category'));
                                }
                            } catch (error) {
                                console.error('Error creating category:', error);
                                alert('Failed to create category. Please try again.');
                            }
                        }

                        // Cancel adding new main category
                        function cancelNewMainCategory() {
                            document.getElementById('newMainCategoryInput').value = '';
                            document.getElementById('addNewMainCategoryContainer').classList.remove('active');
                        }

                        // Save new sub-category
                        async function saveNewSubCategory() {
                            const input = document.getElementById('newSubCategoryInput');
                            const name = input.value.trim();

                            if (!name) {
                                alert('Please enter a sub-category name');
                                return;
                            }

                            if (!selectedCategoryId) {
                                alert('Please select a main category first');
                                return;
                            }

                            try {
                                const response = await fetch(contextPath + '/guides/categories', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/json' },
                                    body: JSON.stringify({
                                        type: 'sub',
                                        categoryId: selectedCategoryId,
                                        name: name
                                    })
                                });

                                const result = await response.json();

                                if (result.success) {
                                    // Add to local data
                                    const category = categoriesData.find(c => c.categoryId === selectedCategoryId);
                                    if (category) {
                                        if (!category.subCategories) category.subCategories = [];
                                        category.subCategories.push({
                                            subCategoryId: result.subCategoryId,
                                            name: result.name
                                        });
                                    }

                                    // Refresh sub-category dropdown and select the new one
                                    updateSubCategories();
                                    document.getElementById('subCategory').value = result.name;

                                    // Clear and hide input
                                    input.value = '';
                                    document.getElementById('addNewSubCategoryContainer').classList.remove('active');
                                } else {
                                    alert('Error: ' + (result.error || 'Failed to create sub-category'));
                                }
                            } catch (error) {
                                console.error('Error creating sub-category:', error);
                                alert('Failed to create sub-category. Please try again.');
                            }
                        }

                        // Cancel adding new sub-category
                        function cancelNewSubCategory() {
                            document.getElementById('newSubCategoryInput').value = '';
                            document.getElementById('addNewSubCategoryContainer').classList.remove('active');
                        }

                        const MAX_FILE_SIZE_MB = 10;
                        const MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024;

                        function validateAndPreviewMainImage(input) {
                            const errorDiv = document.getElementById('mainImageError');
                            const preview = document.getElementById('mainImagePreview');

                            // Reset error
                            errorDiv.style.display = 'none';
                            errorDiv.textContent = '';
                            preview.style.display = 'none';

                            if (input.files && input.files[0]) {
                                const file = input.files[0];

                                // Check file size
                                if (file.size > MAX_FILE_SIZE_BYTES) {
                                    const fileSizeMB = (file.size / (1024 * 1024)).toFixed(1);
                                    errorDiv.textContent = '⚠️ File is too large (' + fileSizeMB + ' MB). Maximum size is ' + MAX_FILE_SIZE_MB + ' MB. Please choose a smaller image.';
                                    errorDiv.style.display = 'block';
                                    input.value = ''; // Clear the input
                                    return;
                                }

                                // Preview the image
                                const reader = new FileReader();
                                reader.onload = function (e) {
                                    preview.src = e.target.result;
                                    preview.style.display = 'block';
                                };
                                reader.readAsDataURL(file);
                            }
                        }

                        function previewMainImage(input) {
                            if (input.files && input.files[0]) {
                                const reader = new FileReader();
                                reader.onload = function (e) {
                                    const preview = document.getElementById('mainImagePreview');
                                    preview.src = e.target.result;
                                    preview.style.display = 'block';
                                };
                                reader.readAsDataURL(input.files[0]);
                            }
                        }

                        function addRequirement() {
                            const list = document.getElementById('requirementsList');
                            const div = document.createElement('div');
                            div.className = 'dynamic-item';
                            div.innerHTML = `
            <input type="text" name="requirements" placeholder="e.g., Screwdriver">
            <button type="button" class="remove-btn" onclick="removeItem(this)">✕</button>
        `;
                            list.appendChild(div);
                        }

                        function removeItem(btn) {
                            btn.parentElement.remove();
                        }

                        let stepCount = 1;

                        function addStep() {
                            const list = document.getElementById('stepsList');
                            const div = document.createElement('div');
                            div.className = 'step-card';
                            div.dataset.step = stepCount;
                            div.innerHTML = `
            <div class="step-card-header">
                <span class="step-number">Step ${stepCount + 1}</span>
                <button type="button" class="remove-btn" onclick="removeStep(this)">Remove Step</button>
            </div>
            <div class="form-group">
                <label>Step Title *</label>
                <input type="text" name="stepTitle" required placeholder="e.g., Remove the old part">
            </div>
            <div class="form-group">
                <label>Step Images</label>
                <input type="file" name="stepImage_${stepCount}" accept="image/*" multiple>
            </div>
            <div class="form-group">
                <label>Step Description</label>
                <textarea name="stepBody" placeholder="Describe what to do in this step..."></textarea>
            </div>
        `;
                            list.appendChild(div);
                            stepCount++;
                            renumberSteps();
                        }

                        function removeStep(btn) {
                            const stepCards = document.querySelectorAll('.step-card');
                            if (stepCards.length > 1) {
                                btn.closest('.step-card').remove();
                                renumberSteps();
                            } else {
                                alert('A guide must have at least one step.');
                            }
                        }

                        function renumberSteps() {
                            const stepCards = document.querySelectorAll('.step-card');
                            stepCards.forEach((card, index) => {
                                card.querySelector('.step-number').textContent = 'Step ' + (index + 1);
                                card.dataset.step = index;
                                // Update the file input name to match the new index
                                const fileInput = card.querySelector('input[type="file"]');
                                if (fileInput) {
                                    fileInput.name = 'stepImage_' + index;
                                }
                            });
                        }
                    </script>
                </body>

                </html>