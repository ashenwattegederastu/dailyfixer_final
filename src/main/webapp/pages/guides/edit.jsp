<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); return; } %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Edit Guide | Daily Fixer</title>
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

                        .current-image {
                            max-width: 300px;
                            max-height: 200px;
                            object-fit: cover;
                            border-radius: var(--radius-md);
                            margin-bottom: 10px;
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

                        .info-message {
                            background: var(--accent);
                            color: var(--accent-foreground);
                            padding: 15px;
                            border-radius: var(--radius-md);
                            margin-bottom: 20px;
                        }

                        @media (max-width: 600px) {
                            .category-row {
                                grid-template-columns: 1fr;
                            }
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

                        .existing-images-container {
                            display: flex;
                            gap: 15px;
                            flex-wrap: wrap;
                            margin-top: 10px;
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
                            <h1>Edit Guide</h1>
                        </div>

                        <c:if test="${not empty error}">
                            <div class="error-message">${error}</div>
                        </c:if>



                        <form action="${pageContext.request.contextPath}/guides/edit" method="post"
                            enctype="multipart/form-data">
                            <input type="hidden" name="guideId" value="${guide.guideId}">

                            <!-- Basic Information -->
                            <div class="form-card">
                                <h2>📝 Basic Information</h2>
                                <div class="form-group">
                                    <label for="title">Guide Title *</label>
                                    <input type="text" id="title" name="title" required value="${guide.title}">
                                </div>
                                <div class="form-group">
                                    <label>Current Main Image</label>
                                    <c:if test="${not empty guide.mainImagePath}">
                                        <br><img src="${pageContext.request.contextPath}/${guide.mainImagePath}"
                                            class="current-image" alt="Current image">
                                    </c:if>
                                    <c:if test="${empty guide.mainImagePath}">
                                        <p style="color: var(--muted-foreground);">No image uploaded</p>
                                    </c:if>
                                </div>
                                <div class="form-group">
                                    <label for="mainImage">Upload New Image (optional)</label>
                                    <input type="file" id="mainImage" name="mainImage" accept="image/*">
                                </div>
                                <div class="category-row">
                                    <div class="form-group">
                                        <label for="mainCategory">Main Category *</label>
                                        <select id="mainCategory" name="mainCategory" required
                                            onchange="updateSubCategories()">
                                            <option value="">Select Category</option>
                                            <option value="Home Repair" ${guide.mainCategory=='Home Repair' ? 'selected'
                                                : '' }>Home Repair</option>
                                            <option value="Home Electronics / Appliance Repair"
                                                ${guide.mainCategory=='Home Electronics / Appliance Repair' ? 'selected'
                                                : '' }>Home Electronics / Appliances</option>
                                            <option value="Vehicle Repair" ${guide.mainCategory=='Vehicle Repair'
                                                ? 'selected' : '' }>Vehicle Repair</option>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label for="subCategory">Sub-Category *</label>
                                        <select id="subCategory" name="subCategory" required>
                                            <option value="">Select Sub-Category</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="youtubeUrl">YouTube Video URL (Optional)</label>
                                    <input type="url" id="youtubeUrl" name="youtubeUrl" value="${guide.youtubeUrl}"
                                        placeholder="https://www.youtube.com/watch?v=...">
                                </div>
                            </div>

                            <!-- Requirements -->
                            <div class="form-card">
                                <h2>🔧 Things You Need</h2>
                                <div id="requirementsList" class="dynamic-list">
                                    <c:forEach var="req" items="${guide.requirements}">
                                        <div class="dynamic-item">
                                            <input type="text" name="requirements" value="${req}">
                                            <button type="button" class="remove-btn"
                                                onclick="removeItem(this)">✕</button>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${empty guide.requirements}">
                                        <div class="dynamic-item">
                                            <input type="text" name="requirements"
                                                placeholder="e.g., Adjustable wrench">
                                            <button type="button" class="remove-btn"
                                                onclick="removeItem(this)">✕</button>
                                        </div>
                                    </c:if>
                                </div>
                                <button type="button" class="add-btn" onclick="addRequirement()">+ Add
                                    Requirement</button>
                            </div>

                            <!-- Steps -->
                            <div class="form-card">
                                <h2>📋 Guide Steps</h2>
                                <p style="color: var(--muted-foreground); margin-bottom: 15px;">Add, edit, or remove
                                    step-by-step instructions. rearrange steps or images as needed.</p>
                                <div id="stepsList">
                                    <c:forEach var="step" items="${guide.steps}" varStatus="status">
                                        <div class="step-card" data-step="${status.index}">
                                            <div class="step-card-header">
                                                <span class="step-number">Step ${status.index + 1}</span>
                                                <button type="button" class="remove-btn"
                                                    onclick="removeStep(this)">Remove Step</button>
                                            </div>
                                            <div class="form-group">
                                                <label>Step Title *</label>
                                                <input type="text" name="stepTitle" required value="${step.stepTitle}"
                                                    placeholder="e.g., Turn off the water supply">
                                            </div>

                                            <!-- Existing Images -->
                                            <c:if test="${not empty step.imagePaths}">
                                                <div class="form-group">
                                                    <label>Current Images</label>
                                                    <div class="existing-images-container"
                                                        style="display: flex; gap: 10px; flex-wrap: wrap;">
                                                        <c:forEach var="imgPath" items="${step.imagePaths}">
                                                            <div class="existing-image-wrapper"
                                                                style="position: relative;">
                                                                <img src="${pageContext.request.contextPath}/${imgPath}"
                                                                    class="image-preview" alt="Step image">
                                                                <input type="hidden"
                                                                    name="existingImages_${status.index}"
                                                                    value="${imgPath}">
                                                                <button type="button" class="remove-btn"
                                                                    style="position: absolute; top: 5px; right: 5px; padding: 2px 6px; font-size: 0.8rem;"
                                                                    onclick="removeExistingImage(this)">✕</button>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <div class="form-group">
                                                <label>Add New Images</label>
                                                <input type="file" name="stepImage_${status.index}" accept="image/*"
                                                    multiple>
                                            </div>
                                            <div class="form-group">
                                                <label>Step Description</label>
                                                <textarea name="stepBody"
                                                    placeholder="Describe what to do in this step...">${step.stepBody}</textarea>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                                <button type="button" class="add-btn" onclick="addStep()">+ Add Step</button>
                            </div>

                            <div class="form-actions">
                                <a href="${pageContext.request.contextPath}/guides/view?id=${guide.guideId}"
                                    class="btn-secondary">Cancel</a>
                                <button type="submit" class="btn-primary">Update Guide</button>
                            </div>
                        </form>
                    </div>
                    <script>
                        const subCategories = {
                            'Home Repair': ['Plumbing', 'Electrical', 'Masonry', 'Painting & Finishing', 'Carpentry', 'Roofing',
                                'Flooring & Tiling', 'Doors & Windows', 'Ceiling & False Ceiling', 'Waterproofing',
                                'Glass & Mirrors', 'Locks & Hardware'],
                            'Home Electronics / Appliance Repair': ['Refrigerator', 'Washing Machine', 'Microwave Oven', 'Electric Kettle',
                                'Rice Cooker', 'Mixer / Blender', 'Air Conditioner', 'Water Heater',
                                'Fans', 'Television', 'Home Theatre / Speakers', 'Inverter / UPS',
                                'Voltage Stabilizer'],
                            'Vehicle Repair': ['Engine System', 'Fuel System', 'Electrical System', 'Battery & Charging', 'Transmission',
                                'Clutch System', 'Brake System', 'Steering System', 'Suspension System', 'Tyres & Wheels',
                                'Cooling System', 'Exhaust System', 'Body & Interior']
                        };

                        const currentSubCategory = '${guide.subCategory}';

                        function updateSubCategories() {
                            const mainCat = document.getElementById('mainCategory').value;
                            const subSelect = document.getElementById('subCategory');
                            subSelect.innerHTML = '<option value="">Select Sub-Category</option>';

                            if (mainCat && subCategories[mainCat]) {
                                subCategories[mainCat].forEach(sub => {
                                    const option = document.createElement('option');
                                    option.value = sub;
                                    option.textContent = sub;
                                    if (sub === currentSubCategory) option.selected = true;
                                    subSelect.appendChild(option);
                                });
                            }
                        }

                        // Initialize on page load
                        updateSubCategories();

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

                        function removeExistingImage(btn) {
                            btn.parentElement.remove();
                        }

                        let stepCount = ${ guide.steps != null ? guide.steps.size() : 0};

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
                            btn.closest('.step-card').remove();
                            renumberSteps();
                        }

                        function renumberSteps() {
                            const stepCards = document.querySelectorAll('.step-card');
                            stepCards.forEach((card, index) => {
                                card.querySelector('.step-number').textContent = 'Step ' + (index + 1);
                                card.dataset.step = index;

                                // Update file input name
                                const fileInput = card.querySelector('input[type="file"]');
                                if (fileInput) {
                                    fileInput.name = 'stepImage_' + index;
                                }

                                // Update existing images hidden inputs
                                const hiddenInputs = card.querySelectorAll('input[type="hidden"][name^="existingImages_"]');
                                hiddenInputs.forEach(input => {
                                    input.name = 'existingImages_' + index;
                                });
                            });
                            stepCount = stepCards.length;
                        }
                    </script>
                </body>

                </html>