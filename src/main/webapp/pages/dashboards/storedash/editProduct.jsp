<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    
    int id = Integer.parseInt(request.getParameter("productId"));
    Product product = new ProductDAO().getProductById(id);
    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/ListProductsServlet");
        return;
    }
    
    // Load existing variants
    List<ProductVariant> variants = null;
    try {
        ProductVariantDAO variantDAO = new ProductVariantDAO();
        variants = variantDAO.getVariantsByProductId(id);
    } catch (Exception e) {
        e.printStackTrace();
    }

    String flashError = (String) session.getAttribute("editProductFlashError");
    if (flashError != null) {
        session.removeAttribute("editProductFlashError");
    }
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product | Daily Fixer</title>
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
            <h2>Edit Product</h2>

            <% if (flashError != null) { %>
            <div class="server-error" style="margin-bottom: 1rem; color: var(--destructive, #b91c1c);"><%= flashError %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/EditProductServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" name="productId" value="<%=product.getProductId()%>">

                <label>Product Name</label>
                <input type="text" name="name" value="<%=product.getName()%>" placeholder="Enter product name" required>

                <label>Category</label>
                <%
                    String[] knownCategories = {"Cutting Tools","Painting Tools","Tool Storage & Safety Gear","Electrical Tools & Accessories","Power Tools","Cleaning & Maintenance","Vehicle Parts & Accessories","Measuring & Marking Tools","Tapes","Fasteners & Fittings","Plumbing Tools & Supplies","Adhesives & Sealants"};
                    boolean isKnownCat = false;
                    for (String cat : knownCategories) { if (cat.equals(product.getType())) { isKnownCat = true; break; } }
                    String displayType = isKnownCat ? product.getType() : "Other";
                    String customCatValue = isKnownCat ? "" : product.getType();
                %>
                <select name="type" id="categorySelect" required>
                    <option value="Cutting Tools" <%=displayType.equals("Cutting Tools")?"selected":""%>>Cutting Tools</option>
                    <option value="Painting Tools" <%=displayType.equals("Painting Tools")?"selected":""%>>Painting Tools</option>
                    <option value="Tool Storage &amp; Safety Gear" <%=displayType.equals("Tool Storage & Safety Gear")?"selected":""%>>Tool Storage &amp; Safety Gear</option>
                    <option value="Electrical Tools &amp; Accessories" <%=displayType.equals("Electrical Tools & Accessories")?"selected":""%>>Electrical Tools &amp; Accessories</option>
                    <option value="Power Tools" <%=displayType.equals("Power Tools")?"selected":""%>>Power Tools</option>
                    <option value="Cleaning &amp; Maintenance" <%=displayType.equals("Cleaning & Maintenance")?"selected":""%>>Cleaning &amp; Maintenance</option>
                    <option value="Vehicle Parts &amp; Accessories" <%=displayType.equals("Vehicle Parts & Accessories")?"selected":""%>>Vehicle Parts &amp; Accessories</option>
                    <option value="Measuring &amp; Marking Tools" <%=displayType.equals("Measuring & Marking Tools")?"selected":""%>>Measuring &amp; Marking Tools</option>
                    <option value="Tapes" <%=displayType.equals("Tapes")?"selected":""%>>Tapes</option>
                    <option value="Fasteners &amp; Fittings" <%=displayType.equals("Fasteners & Fittings")?"selected":""%>>Fasteners &amp; Fittings</option>
                    <option value="Plumbing Tools &amp; Supplies" <%=displayType.equals("Plumbing Tools & Supplies")?"selected":""%>>Plumbing Tools &amp; Supplies</option>
                    <option value="Adhesives &amp; Sealants" <%=displayType.equals("Adhesives & Sealants")?"selected":""%>>Adhesives &amp; Sealants</option>
                    <option value="Other" <%=displayType.equals("Other")?"selected":""%>>Other</option>
                </select>

                <p id="categoryGuidance" class="category-guidance" style="display:none;"></p>

                <div id="customCategoryWrap" class="custom-category-wrap" style="<%=!isKnownCat ? "" : "display:none;"%>">
                    <label for="customCategory">Specify Category</label>
                    <input type="text" id="customCategory" name="customCategory" value="<%=customCatValue%>" placeholder="Enter a specific category name" <%=!isKnownCat ? "required" : ""%>>
                </div>

                <label>Quantity <span id="quantityNote" class="form-help">(<%= (variants != null && !variants.isEmpty()) ? "Not required - variants have their own quantities" : "Required if no variants" %>)</span></label>
                <input type="number" step="0.01" name="quantity" id="quantityInput" value="<%=product.getQuantity()%>" placeholder="Enter quantity" min="0" <%=(variants==null || variants.isEmpty()) ? "required" : "" %>>

                <label>Quantity Unit</label>
                <select name="quantityUnit" required>
                    <option value="No of items" <%=product.getQuantityUnit().equals("No of items")?"selected":""%>>No of items</option>
                    <option value="Litres" <%=product.getQuantityUnit().equals("Litres")?"selected":""%>>Litres</option>
                    <option value="Kg" <%=product.getQuantityUnit().equals("Kg")?"selected":""%>>Kg</option>
                    <option value="Metres" <%=product.getQuantityUnit().equals("Metres")?"selected":""%>>Metres</option>
                </select>

                <label>Price (Rs.) <span id="priceNote" class="form-help"></span></label>
                <input type="number" step="0.01" name="price" value="<%=product.getPrice()%>" placeholder="Enter price" required min="0">

                <label>Description</label>
                <textarea name="description" rows="4" placeholder="Enter product description" required><%=product.getDescription()%></textarea>

                <label>Warranty Information <span class="form-help">(Optional)</span></label>
                <textarea name="warrantyInfo" id="warrantyInfo" rows="2"
                    placeholder="e.g. 1 year manufacturer warranty, 6 months for parts"><%=product.getWarrantyInfo() != null ? product.getWarrantyInfo() : ""%></textarea>

                <label>Product Image</label>
                <% String currentImg = product.getImagePath(); if (currentImg != null && !currentImg.isEmpty()) { %>
                <div class="image-current-wrap">
                    <img src="<%=request.getContextPath()%>/<%=currentImg%>" alt="Current image" class="image-current-preview">
                    <p class="form-help">Current image shown. Upload a new file below to replace it.</p>
                </div>
                <% } %>
                <input type="file" name="image" id="productImageInput" accept="image/*">
                <div class="image-preview-wrap" id="imagePreviewWrap" style="display:none;">
                    <img id="productImagePreview" src="" alt="New image preview" class="image-preview">
                </div>

                <!-- Product Variants Section -->
                <div class="variants-section">
                    <h3>Product Variants</h3>
                    <p class="help-text">Manage product variants (color, size, power). Leave empty to remove a variant.</p>

                    <div id="variantsContainer">
                        <% if (variants != null && !variants.isEmpty()) { 
                            for (ProductVariant v : variants) { %>
                            <div class="variant-row">
                                <input type="hidden" name="variantId[]" value="<%=v.getVariantId()%>">
                                <div class="variant-grid">
                                    <div data-vfield="color">
                                        <label>Color</label>
                                        <input type="text" name="variantColor[]" value="<%=v.getColor() != null ? v.getColor() : ""%>" placeholder="Color">
                                    </div>
                                    <div data-vfield="size">
                                        <label>Size</label>
                                        <input type="text" name="variantSize[]" value="<%=v.getSize() != null ? v.getSize() : ""%>" placeholder="Size">
                                    </div>
                                </div>
                                <div class="variant-grid">
                                    <div data-vfield="power">
                                        <label>Power</label>
                                        <input type="text" name="variantPower[]" value="<%=v.getPower() != null ? v.getPower() : ""%>" placeholder="Power">
                                    </div>
                                    <div>
                                        <label>Variant Price (Rs.)</label>
                                        <input type="number" step="0.01" name="variantPrice[]" value="<%=v.getPrice()%>" placeholder="Price" min="0">
                                    </div>
                                </div>
                                <div>
                                    <label>Variant Stock</label>
                                    <input type="number" name="variantQuantity[]" value="<%=v.getQuantity()%>" placeholder="Stock quantity" min="0">
                                </div>
                                <div class="variant-image-wrap">
                                    <label>Variant Image <span class="form-help">(Optional)</span></label>
                                    <% if (v.getImagePath() != null && !v.getImagePath().isEmpty()) { %>
                                    <div class="variant-current-image">
                                        <img src="<%=request.getContextPath()%>/<%=v.getImagePath()%>" alt="Current variant image" class="variant-current-thumb">
                                        <span class="form-help">Upload a new file to replace</span>
                                    </div>
                                    <% } %>
                                    <input type="file" name="variantImage[]" accept="image/*" class="variant-image-input">
                                    <img src="" alt="Variant preview" class="variant-image-preview" style="display:none;">
                                </div>
                                <button type="button" class="remove-variant-btn" onclick="removeVariantRow(this)">Remove</button>
                            </div>
                        <% } } else { %>
                            <!-- Empty variant row if no variants exist -->
                            <div class="variant-row">
                                <input type="hidden" name="variantId[]" value="">
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
                        <% } %>
                    </div>

                    <button type="button" class="add-variant-btn" onclick="addVariantRow()">+ Add Variant</button>
                </div>

                <button type="submit">Update Product</button>
            </form>

            <a href="${pageContext.request.contextPath}/ListProductsServlet" class="back-btn">Back to Products</a>
        </div>
    </main>
    <script src="${pageContext.request.contextPath}/assets/js/storedash-product-category.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/storedash-product-variants.js"></script>
</body>
</html>