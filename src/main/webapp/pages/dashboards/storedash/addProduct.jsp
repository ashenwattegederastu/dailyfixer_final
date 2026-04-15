<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="com.dailyfixer.model.User" %>
        <% User user=(User) session.getAttribute("currentUser"); if (user==null || !"store".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp" ); return; } %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Add Product | Daily Fixer</title>
                <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-forms.css">
            </head>

            <body class="dashboard-layout">

                <header class="topbar">
                    <div class="logo">Daily Fixer</div>
                    <div class="panel-name">Store Panel</div>
                    <div style="display: flex; align-items: center; gap: 10px;">
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
                        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
                        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
                    </ul>
                </aside>

                <main class="container form-layout">
                    <div class="form-card">
                        <h2>Add Product</h2>

                        <% if (request.getAttribute("errorMsg") != null) { %>
                        <div class="server-error" style="margin-bottom: 1rem; color: var(--destructive, #b91c1c);">
                            <%= request.getAttribute("errorMsg") %>
                        </div>
                        <% } %>

                        <form id="addProductForm" action="${pageContext.request.contextPath}/AddProductServlet" method="post"
                            enctype="multipart/form-data">

                            <label for="name">Product Name</label>
                            <input type="text" name="name" placeholder="Enter product name" required>

                            <label for="categorySelect">Category</label>
                            <select name="type" id="categorySelect" required>
                                <option value="">-- Select Category --</option>
                                <option value="Cutting Tools">Cutting Tools</option>
                                <option value="Painting Tools">Painting Tools</option>
                                <option value="Tool Storage &amp; Safety Gear">Tool Storage &amp; Safety Gear</option>
                                <option value="Electrical Tools &amp; Accessories">Electrical Tools &amp; Accessories</option>
                                <option value="Power Tools">Power Tools</option>
                                <option value="Cleaning &amp; Maintenance">Cleaning &amp; Maintenance</option>
                                <option value="Vehicle Parts &amp; Accessories">Vehicle Parts &amp; Accessories</option>
                                <option value="Measuring &amp; Marking Tools">Measuring &amp; Marking Tools</option>
                                <option value="Tapes">Tapes</option>
                                <option value="Fasteners &amp; Fittings">Fasteners &amp; Fittings</option>
                                <option value="Plumbing Tools &amp; Supplies">Plumbing Tools &amp; Supplies</option>
                                <option value="Adhesives &amp; Sealants">Adhesives &amp; Sealants</option>
                                <option value="Other">Other</option>
                            </select>

                            <p id="categoryGuidance" class="category-guidance" style="display:none;"></p>

                            <div id="customCategoryWrap" class="custom-category-wrap" style="display:none;">
                                <label for="customCategory">Specify Category</label>
                                <input type="text" id="customCategory" name="customCategory" placeholder="Enter a specific category name">
                            </div>

                            <label for="quantity">Quantity <span id="quantityNote"
                                    class="form-help">(Required if no
                                    variants)</span></label>
                            <input type="number" step="0.01" name="quantity" id="quantityInput"
                                placeholder="Enter quantity" value="0" min="0">

                            <label for="quantityUnit">Unit</label>
                            <select name="quantityUnit" required>
                                <option value="No of items">No of items</option>
                                <option value="Litres">Litres</option>
                                <option value="Kg">Kg</option>
                                <option value="Metres">Metres</option>
                            </select>

                            <label for="price">Price (Rs.) <span id="priceNote"
                                    class="form-help"></span></label>
                            <input type="number" step="0.01" name="price" placeholder="Enter price" required min="0">

                            <label for="description">Description</label>
                            <textarea name="description" id="description" rows="4"
                                placeholder="Enter product description" required></textarea>


                            <label for="warrantyInfo">Warranty Information <span class="form-help">(Optional)</span></label>
                            <textarea name="warrantyInfo" id="warrantyInfo" rows="2"
                                placeholder="e.g. 1 year manufacturer warranty, 6 months for parts"></textarea>

                            <label for="productImageInput">Product Image <span id="mainImageNote" class="form-help">(Required unless at least one variant image is uploaded)</span></label>
                            <input type="file" name="image" id="productImageInput" accept="image/*">
                            <div class="image-preview-wrap" id="imagePreviewWrap" style="display:none;">
                                <img id="productImagePreview" src="" alt="Preview" class="image-preview">
                            </div>

                            <!-- Product Variants Section -->
                            <div class="variants-section">
                                <h3>Product Variants (Optional)</h3>
                                <p class="help-text">If your product has different options (color, size, power), add variants below. Leave empty if product has no variants.</p>
                                <div id="variantsContainer">
                                    <div class="variant-row">
                                        <div class="variant-grid">
                                            <div data-vfield="color">
                                                <label>Color</label>
                                                <input type="text" name="variantColor[]" placeholder="Color">
                                            </div>
                                            <div data-vfield="size">
                                                <label>Size</label>
                                                <input type="text" name="variantSize[]" placeholder="Size">
                                            </div>
                                        </div>
                                        <div class="variant-grid">
                                            <div data-vfield="power">
                                                <label>Power</label>
                                                <input type="text" name="variantPower[]" placeholder="Power">
                                            </div>
                                            <div>
                                                <label>Variant Price (Rs.)</label>
                                                <input type="number" step="0.01" name="variantPrice[]" placeholder="Price" min="0">
                                            </div>
                                        </div>
                                        <div>
                                            <label>Variant Stock</label>
                                            <input type="number" name="variantQuantity[]" placeholder="Stock quantity" min="0">
                                        </div>
                                        <div class="variant-image-wrap">
                                            <label>Variant Image <span class="form-help">(Optional)</span></label>
                                            <input type="file" name="variantImage[]" accept="image/*" class="variant-image-input">
                                            <img src="" alt="Variant preview" class="variant-image-preview" style="display:none;">
                                        </div>
                                        <button type="button" class="remove-variant-btn" onclick="removeVariantRow(this)">Remove</button>
                                    </div>
                                </div>
                                <button type="button" class="add-variant-btn" onclick="addVariantRow()">+ Add Variant</button>
                            </div>

                            <button type="submit">Add Product</button>
                        </form>

                        <a href="${pageContext.request.contextPath}/ListProductsServlet" class="back-btn">Back to
                            Products</a>
                    </div>
                </main>
                <script src="${pageContext.request.contextPath}/assets/js/storedash-product-category.js"></script>
                <script src="${pageContext.request.contextPath}/assets/js/storedash-product-variants.js"></script>
            </body>

            </html>