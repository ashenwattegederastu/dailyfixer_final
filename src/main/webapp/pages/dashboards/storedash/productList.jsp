<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.util.ProductDisplayUtil" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    List<Product> products = (List<Product>) request.getAttribute("products");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Product Catalogue | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-tables.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-reviews.css">

<style>
/* Page-specific: category filter */
.top-bar-left {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.category-filter {
  display: flex;
  align-items: center;
  gap: 10px;
}

.category-filter label {
  font-weight: 600;
  color: var(--foreground);
  font-size: 0.95em;
}

.category-filter select {
  padding: 10px 15px;
  border: 2px solid var(--border);
  border-radius: var(--radius-md);
  background: var(--input);
  font-size: 0.95em;
  color: var(--foreground);
  cursor: pointer;
  transition: all 0.2s;
  min-width: 220px;
  font-weight: 500;
}

.category-filter select:hover {
  border-color: var(--ring);
}

.category-filter select:focus {
  outline: none;
  border-color: var(--ring);
  box-shadow: 0 0 0 3px var(--ring) / 0.1;
}

.product-count {
  font-size: 0.9em;
  color: var(--muted-foreground);
  font-weight: 500;
  padding: 8px 12px;
  background: var(--muted);
  border-radius: var(--radius-md);
}

.product-count strong {
  color: var(--primary);
  font-weight: 600;
}

/* Page-specific: table layout and column widths */
table {
  table-layout: fixed;
}

table th,
table td {
  word-wrap: break-word;
  overflow-wrap: break-word;
  vertical-align: top;
}

th:nth-child(1), td:nth-child(1) { width: 40px; }
th:nth-child(2), td:nth-child(2) { width: 120px; }
th:nth-child(3), td:nth-child(3) { width: 200px; max-width: 200px; }
th:nth-child(4), td:nth-child(4) { width: 100px; }
th:nth-child(5), td:nth-child(5) { width: 120px; }
th:nth-child(6), td:nth-child(6) { width: 120px; }
th:nth-child(7), td:nth-child(7) { width: 100px; }
th:nth-child(8), td:nth-child(8) { width: 220px; }
td:nth-child(8) {
  white-space: nowrap;
}

td:nth-child(8) .btn {
  margin-bottom: 0;
  vertical-align: middle;
}

td:nth-child(3) {
  max-width: 200px;
}

td:nth-child(3) strong {
  word-wrap: break-word;
}

img.service-thumb {
  width: 100px;
  height: 80px;
  border-radius: var(--radius-md);
  object-fit: cover;
}

/* Page-specific: delete confirmation modal */
.confirm-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.6);
  justify-content: center;
  align-items: center;
  z-index: 500;
}

.confirm-modal .modal-content {
  background: var(--card);
  color: var(--card-foreground);
  padding: 30px;
  border-radius: var(--radius-lg);
  max-width: 400px;
  width: 90%;
  text-align: center;
  box-shadow: var(--shadow-xl);
  border: 1px solid var(--border);
  position: relative;
}

.confirm-modal h3 {
  color: var(--primary);
  margin-bottom: 15px;
}

.confirm-modal p {
  color: var(--muted-foreground);
  margin-bottom: 25px;
}

.confirm-modal .modal-buttons {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.confirm-modal .modal-btn {
  padding: 10px 20px;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.confirm-modal .confirm-btn {
  background: var(--destructive);
  color: var(--destructive-foreground);
}

.confirm-modal .confirm-btn:hover {
  opacity: 0.8;
}

.confirm-modal .cancel-btn {
  background: var(--secondary);
  color: var(--secondary-foreground);
  border: 1px solid var(--border);
}

.confirm-modal .cancel-btn:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.confirm-modal .close-btn {
  position: absolute;
  top: 15px;
  right: 20px;
  font-size: 1.5em;
  font-weight: bold;
  cursor: pointer;
  color: var(--muted-foreground);
  transition: color 0.2s ease;
}

.confirm-modal .close-btn:hover {
  color: var(--foreground);
}

/* Page-specific: variants section in modal */
.variants-section {
  margin-top: 30px;
  padding: 25px;
  background: var(--card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  border: 1px solid var(--border);
}

.variants-section h4 {
  color: var(--primary);
  margin-top: 0;
  margin-bottom: 20px;
  font-size: 1.3em;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--border);
}

/* Page-specific: expand/collapse variants in table */
.toggle-variants-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 5px;
  font-size: 0.9em;
  color: var(--primary);
  transition: transform 0.2s;
}

.toggle-variants-btn:hover {
  transform: scale(1.2);
}

.toggle-variants-btn[data-expanded="true"] .toggle-icon {
  transform: rotate(90deg);
}

.toggle-icon {
  display: inline-block;
  transition: transform 0.2s;
}

/* Page-specific: inline variant details row */
.variant-details-row {
  background-color: var(--muted);
}

.variant-details-row td {
  padding: 20px;
  border-top: 2px solid var(--primary);
}

.variants-container {
  padding: 15px;
  background: var(--card);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border);
}

.variants-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
  box-shadow: none;
  border: 1px solid var(--border);
  background: var(--card);
}

.variants-table thead {
  background-color: var(--muted);
}

.variants-table th,
.variants-table td {
  padding: 10px;
  text-align: left;
  border-bottom: 1px solid var(--border);
  font-size: 0.9em;
}

.variants-table tbody tr:hover {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

.variant-badge {
  display: inline-block;
  background: var(--primary);
  color: var(--primary-foreground);
  padding: 4px 10px;
  border-radius: var(--radius-md);
  font-size: 0.85em;
  font-weight: 600;
}

/* Page-specific: responsive container */
@media (max-width: 768px) {
  .container {
    margin-left: 0;
    padding: 20px;
  }
}
</style>
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
        <li><a href="${pageContext.request.contextPath}/ListProductsServlet" class="active">Catalogue</a></li>
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <!-- Top Bar -->
    <div class="top-bar">
        <div class="top-bar-left">
            <h2 style="margin: 0;">Product Catalogue</h2>
            <div class="category-filter">
                <label for="categoryFilter">Filter by Category:</label>
                <select id="categoryFilter" onchange="filterByCategory()">
                    <option value="">All Categories</option>
                    <option value="Cutting Tools">Cutting Tools</option>
                    <option value="Painting Tools">Painting Tools</option>
                    <option value="Tool Storage & Safety Gear">Tool Storage & Safety Gear</option>
                    <option value="Electrical Tools & Accessories">Electrical Tools & Accessories</option>
                    <option value="Power Tools">Power Tools</option>
                    <option value="Cleaning & Maintenance">Cleaning & Maintenance</option>
                    <option value="Vehicle Parts & Accessories">Vehicle Parts & Accessories</option>
                    <option value="Measuring & Marking Tools">Measuring & Marking Tools</option>
                    <option value="Tapes">Tapes</option>
                    <option value="Fasteners & Fittings">Fasteners & Fittings</option>
                    <option value="Plumbing Tools & Supplies">Plumbing Tools & Supplies</option>
                    <option value="Adhesives & Sealants">Adhesives & Sealants</option>
                </select>
                <span class="product-count" id="productCount">
                    <strong id="visibleCount"><%=products != null ? products.size() : 0%></strong> product(s) shown
                </span>
            </div>
        </div>
        <a class="btn-add" href="${pageContext.request.contextPath}/pages/dashboards/storedash/addProduct.jsp">+ Add Product</a>
    </div>

    <!-- Products Table -->
    <table>
        <thead>
            <tr>
                <th style="width: 50px;"></th>
                <th>Image</th>
                <th>Name</th>
                <th>Type</th>
                <th>Stock</th>
                <th>Price</th>
                <th>Variants</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if(products != null && !products.isEmpty()){
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                for(Product p : products){ 
                    // Get variants for this product
                    List<ProductVariant> variants = null;
                    boolean hasVariants = false;
                    int totalVariantStock = 0;
                    double minPrice = p.getPrice();
                    double maxPrice = p.getPrice();
                    
                    try {
                        variants = variantDAO.getVariantsByProductId(p.getProductId());
                        hasVariants = (variants != null && !variants.isEmpty());
                        
                        if (hasVariants) {
                            // Calculate total stock and price range
                            for (ProductVariant v : variants) {
                                totalVariantStock += v.getQuantity();
                                if (v.getPrice() != null) {
                                    double vPrice = v.getPrice().doubleValue();
                                    if (minPrice == 0.00 || vPrice < minPrice) minPrice = vPrice;
                                    if (vPrice > maxPrice) maxPrice = vPrice;
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    // Get display price
                    double displayPrice = p.getPrice();
                    if (hasVariants && p.getPrice() == 0.00 && variants.get(0).getPrice() != null) {
                        displayPrice = variants.get(0).getPrice().doubleValue();
                    }
                    
                    int totalStock = hasVariants ? totalVariantStock : p.getQuantity();
                    String catalogueImg = ProductDisplayUtil.getDisplayImagePath(p, variants);
                %>
            <tr class="product-row" data-product-id="<%=p.getProductId()%>" data-category="<%=p.getType() != null ? p.getType() : ""%>">
                <td>
                    <% if (hasVariants) { %>
                    <button class="toggle-variants-btn" onclick="toggleVariants(<%=p.getProductId()%>)" data-expanded="false">
                        <span class="toggle-icon">▶</span>
                    </button>
                    <% } else { %>
                    <span style="color: #ccc;">—</span>
                    <% } %>
                </td>
                <td>
                    <% if(catalogueImg != null && !catalogueImg.isEmpty()){ %>
                    <img class="service-thumb" src="<%=request.getContextPath()%>/<%=catalogueImg%>">
                    <% } else { %>
                    <img class="service-thumb" src="${pageContext.request.contextPath}/assets/images/tools.png" alt="No Image">
                    <% } %>
                </td>
                <td>
                    <strong><%=p.getName()%></strong>
                </td>
                <td><%=p.getType()%></td>
                <td>
                    <% if (hasVariants) { %>
                    <strong><%=totalStock%></strong> <%=p.getQuantityUnit() != null ? p.getQuantityUnit() : "units"%>
                    <br><small style="color: #666;">(<%=variants.size()%> variants)</small>
                    <% } else { %>
                    <strong><%=p.getQuantity()%></strong> <%=p.getQuantityUnit() != null ? p.getQuantityUnit() : "units"%>
                    <% } %>
                </td>
                <td>
                    <% if (hasVariants) { %>
                    <% if (minPrice == maxPrice) { %>
                    Rs. <%=String.format("%.2f", minPrice)%>
                    <% } else { %>
                    Rs. <%=String.format("%.2f", minPrice)%> - Rs. <%=String.format("%.2f", maxPrice)%>
                    <% } %>
                    <% } else { %>
                    Rs. <%=String.format("%.2f", displayPrice)%>
                    <% } %>
                </td>
                <td>
                    <% if (hasVariants) { %>
                    <span class="variant-badge"><%=variants.size()%> variant<%=variants.size() > 1 ? "s" : ""%></span>
                    <% } else { %>
                    <span style="color: #999;">No variants</span>
                    <% } %>
                </td>
                <td>
                    <button class="btn view-btn" onclick="viewProductDetails(<%=p.getProductId()%>)">View Details</button>
                    <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/editProduct.jsp?productId=<%=p.getProductId()%>" class="btn edit-btn">Edit</a>
                    <button class="btn delete-btn" onclick="confirmDelete('<%=p.getProductId()%>', '<%=p.getName()%>')">Delete</button>
                </td>
            </tr>
            <% if (hasVariants) { %>
            <tr class="variant-details-row" id="variants-<%=p.getProductId()%>" style="display: none;" data-product-id="<%=p.getProductId()%>" data-category="<%=p.getType() != null ? p.getType() : ""%>">
                <td colspan="8">
                    <div class="variants-container">
                        <h4 style="margin-bottom: 15px; color: var(--accent);">Variant Details</h4>
                        <table class="variants-table">
                            <thead>
                                <tr>
                                    <th>Color</th>
                                    <th>Size</th>
                                    <th>Power</th>
                                    <th>Price</th>
                                    <th>Stock</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (ProductVariant v : variants) { %>
                                <tr>
                                    <td><%=v.getColor() != null && !v.getColor().isEmpty() ? v.getColor() : "—"%></td>
                                    <td><%=v.getSize() != null && !v.getSize().isEmpty() ? v.getSize() : "—"%></td>
                                    <td><%=v.getPower() != null && !v.getPower().isEmpty() ? v.getPower() : "—"%></td>
                                    <td><strong>Rs. <%=v.getPrice() != null ? String.format("%.2f", v.getPrice().doubleValue()) : "0.00"%></strong></td>
                                    <td><strong><%=v.getQuantity()%></strong> <%=p.getQuantityUnit() != null ? p.getQuantityUnit() : "units"%></td>
                                    <td>
                                        <% if (v.getQuantity() > 0) { %>
                                        <span class="status-badge in-stock">In Stock</span>
                                        <% } else { %>
                                        <span class="status-badge out-of-stock">Out of Stock</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </td>
            </tr>
            <% } %>
            <% }} else { %>
            <tr><td colspan="8" style="text-align:center; color:#777;">No products found.</td></tr>
            <% } %>
        </tbody>
    </table>
</main>

<!-- Product Details Modal -->
<div id="productDetailsModal" class="product-details-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalProductName">Product Details</h3>
            <span class="close-btn" onclick="closeProductDetailsModal()">&times;</span>
        </div>
        <div class="modal-body">
            <div class="product-details-grid">
                <div class="product-image-section">
                    <img id="modalProductImage" src="" alt="Product Image">
                </div>
                <div class="product-info-section">
                    <h4>Product Information</h4>
                    <div class="info-row">
                        <span class="info-label">Name:</span>
                        <span class="info-value" id="modalName"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Type:</span>
                        <span class="info-value" id="modalType"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Description:</span>
                        <span class="info-value" id="modalDescription"></span>
                    </div>
                <div class="info-row">
                    <span class="info-label">Price Range:</span>
                    <span class="info-value" id="modalBasePrice" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462);"></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Total Stock:</span>
                    <span class="info-value" id="modalBaseStock" style="font-weight: 600; color: oklch(0.5393 0.2713 286.7462);"></span>
                </div>
                    <div class="info-row">
                        <span class="info-label">Unit:</span>
                        <span class="info-value" id="modalUnit"></span>
                    </div>
                </div>
            </div>
            <div class="variants-section">
                <h4>Product Variants</h4>
                <div id="modalVariantsContainer"></div>
            </div>
        </div>
    </div>
</div>

<!-- Confirmation Modal -->
<div id="confirmModal" class="confirm-modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeConfirmModal()">&times;</span>
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to delete the product "<span id="productName"></span>"?</p>
        <p style="color: #e74c3c; font-size: 0.9em;">This action cannot be undone.</p>
        
        <div class="modal-buttons">
            <button class="modal-btn confirm-btn" onclick="deleteProduct()">Yes, Delete</button>
            <button class="modal-btn cancel-btn" onclick="closeConfirmModal()">Cancel</button>
        </div>
    </div>
</div>
<script>
let productToDelete = '';
let productData = {};

// Store product data for modal
<% if(products != null && !products.isEmpty()){
    ProductVariantDAO variantDAO = new ProductVariantDAO();
    DiscountDAO discountDAO = new DiscountDAO();
    for(Product p : products){ 
        List<ProductVariant> variants = null;
        try {
            variants = variantDAO.getVariantsByProductId(p.getProductId());
        } catch (Exception e) {
            e.printStackTrace();
        }
        String modalDisplayImg = ProductDisplayUtil.getDisplayImagePath(p, variants);
%>
productData[<%=p.getProductId()%>] = {
    id: <%=p.getProductId()%>,
    name: "<%=p.getName() != null ? p.getName().replace("\"", "\\\"").replace("\n", "\\n") : ""%>",
    type: "<%=p.getType() != null ? p.getType() : ""%>",
    description: "<%=p.getDescription() != null ? p.getDescription().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r") : ""%>",
    price: <%=p.getPrice()%>,
    quantity: <%=p.getQuantity()%>,
    unit: "<%=p.getQuantityUnit() != null ? p.getQuantityUnit() : ""%>",
    image: "<%=modalDisplayImg != null && !modalDisplayImg.isEmpty() ? request.getContextPath() + "/" + modalDisplayImg : ""%>",
    variants: [
        <% if (variants != null && !variants.isEmpty()) {
            for (int i = 0; i < variants.size(); i++) {
                ProductVariant v = variants.get(i);
                Discount variantDiscount = null;
                Discount productDiscount = null;
                try {
                    variantDiscount = discountDAO.getActiveDiscountForVariant(v.getVariantId());
                    if (variantDiscount == null || !variantDiscount.isValid()) {
                        productDiscount = discountDAO.getActiveDiscountForProduct(p.getProductId());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Discount activeDiscount = (variantDiscount != null && variantDiscount.isValid()) ? variantDiscount : 
                                        ((productDiscount != null && productDiscount.isValid()) ? productDiscount : null);
                double variantPrice = v.getPrice() != null ? v.getPrice().doubleValue() : 0.0;
                double variantDisplayPrice = variantPrice;
                if (activeDiscount != null && activeDiscount.isValid()) {
                    variantDisplayPrice = activeDiscount.calculateDiscountedPrice(variantPrice);
                }
        %>{
            id: <%=v.getVariantId()%>,
            color: "<%=v.getColor() != null ? v.getColor().replace("\"", "\\\"") : ""%>",
            size: "<%=v.getSize() != null ? v.getSize().replace("\"", "\\\"") : ""%>",
            power: "<%=v.getPower() != null ? v.getPower().replace("\"", "\\\"") : ""%>",
            price: <%=variantPrice%>,
            displayPrice: <%=variantDisplayPrice%>,
            quantity: <%=v.getQuantity()%>,
            discount: <% if (activeDiscount != null && activeDiscount.isValid()) { %>{
                name: "<%=activeDiscount.getDiscountName() != null ? activeDiscount.getDiscountName().replace("\"", "\\\"").replace("\n", "\\n") : ""%>",
                type: "<%=activeDiscount.getDiscountType() != null ? activeDiscount.getDiscountType() : ""%>",
                value: <%=activeDiscount.getDiscountValue() != null ? activeDiscount.getDiscountValue() : 0%>
            }<% } else { %>null<% } %>
        }<%= (i < variants.size() - 1) ? "," : "" %>
        <%   }
           } %>
    ]
};
<%   }
   } %>

function viewProductDetails(productId) {
    const product = productData[productId];
    if (!product) return;
    
    // Calculate price range and total quantity from variants
    let priceRange = '';
    let totalQuantity = product.quantity;
    
    if (product.variants && product.variants.length > 0) {
        // Calculate price range from variants
        const prices = product.variants.map(v => v.price).filter(p => p > 0);
        const displayPrices = product.variants.map(v => v.displayPrice).filter(p => p > 0);
        
        if (prices.length > 0) {
            const minPrice = Math.min(...prices);
            const maxPrice = Math.max(...prices);
            const minDisplayPrice = Math.min(...displayPrices);
            const maxDisplayPrice = Math.max(...displayPrices);
            
            if (minPrice === maxPrice) {
                priceRange = 'Rs. ' + minPrice.toFixed(2);
            } else {
                priceRange = 'Rs. ' + minPrice.toFixed(2) + ' - Rs. ' + maxPrice.toFixed(2);
            }
        } else {
            priceRange = 'Rs. ' + product.price.toFixed(2);
        }
        
        // Calculate total quantity from all variants
        totalQuantity = product.variants.reduce((sum, v) => sum + (v.quantity || 0), 0);
    } else {
        priceRange = 'Rs. ' + product.price.toFixed(2);
    }
    
    // Populate basic info
    document.getElementById('modalProductName').textContent = product.name;
    document.getElementById('modalName').textContent = product.name;
    document.getElementById('modalType').textContent = product.type || 'N/A';
    document.getElementById('modalDescription').textContent = product.description || 'No description';
    document.getElementById('modalBasePrice').textContent = priceRange;
    document.getElementById('modalBaseStock').textContent = totalQuantity;
    document.getElementById('modalUnit').textContent = product.unit || 'units';
    
    // Set image
    const imgEl = document.getElementById('modalProductImage');
    if (product.image) {
        imgEl.src = product.image;
        imgEl.style.display = 'block';
    } else {
        imgEl.src = '${pageContext.request.contextPath}/assets/images/tools.png';
        imgEl.style.display = 'block';
    }
    
    // Populate variants
    const variantsContainer = document.getElementById('modalVariantsContainer');
    if (product.variants && product.variants.length > 0) {
        let html = '<table class="variants-table"><thead><tr>';
        html += '<th>Color</th><th>Size</th><th>Power</th><th>Price</th><th>Discount</th><th>Stock</th><th>Status</th>';
        html += '</tr></thead><tbody>';
        
        product.variants.forEach(variant => {
            html += '<tr>';
            
            // Color column
            html += '<td>';
            if (variant.color && variant.color.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.color + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Size column
            html += '<td>';
            if (variant.size && variant.size.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.size + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Power column
            html += '<td>';
            if (variant.power && variant.power.trim() !== '') {
                html += '<span class="variant-attribute">' + variant.power + '</span>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Price column
            html += '<td>';
            if (variant.discount && variant.displayPrice < variant.price) {
                html += '<span class="variant-price original">Rs. ' + variant.price.toFixed(2) + '</span>';
                html += '<br><span class="variant-price discounted">Rs. ' + variant.displayPrice.toFixed(2) + '</span>';
            } else {
                html += '<span class="variant-price">Rs. ' + variant.price.toFixed(2) + '</span>';
            }
            html += '</td>';
            
            // Discount column
            html += '<td>';
            if (variant.discount && variant.displayPrice < variant.price) {
                html += '<span class="discount-badge">';
                if (variant.discount.type === 'PERCENTAGE') {
                    html += variant.discount.value + '% OFF';
                } else {
                    html += 'Rs. ' + variant.discount.value + ' OFF';
                }
                html += '</span>';
                html += '<br><small style="color: #666; margin-top: 4px; display: block; font-size: 0.8em;">' + variant.discount.name + '</small>';
            } else {
                html += '<span style="color: #999;">-</span>';
            }
            html += '</td>';
            
            // Stock column
            html += '<td><strong style="font-size: 1.05em;">' + variant.quantity + '</strong></td>';
            
            // Status column
            html += '<td>';
            if (variant.quantity > 0) {
                html += '<span class="status-badge in-stock">In Stock</span>';
            } else {
                html += '<span class="status-badge out-of-stock">Out of Stock</span>';
            }
            html += '</td>';
            
            html += '</tr>';
        });
        
        html += '</tbody></table>';
        variantsContainer.innerHTML = html;
    } else {
        variantsContainer.innerHTML = '<p class="no-variants">No variants available for this product.</p>';
    }
    
    // Show modal
    document.getElementById('productDetailsModal').style.display = 'flex';
}

function closeProductDetailsModal() {
    document.getElementById('productDetailsModal').style.display = 'none';
}

function confirmDelete(productId, productName) {
    productToDelete = productId;
    document.getElementById('productName').textContent = productName;
    document.getElementById('confirmModal').style.display = 'flex';
}

function closeConfirmModal() {
    document.getElementById('confirmModal').style.display = 'none';
    productToDelete = '';
}

function deleteProduct() {
    if (productToDelete) {
        window.location.href = '${pageContext.request.contextPath}/DeleteProductServlet?productId=' + productToDelete;
    }
}

// Close modals on outside click
document.getElementById('confirmModal').addEventListener('click', e => {
    if(e.target.id === 'confirmModal') {
        closeConfirmModal();
    }
});

document.getElementById('productDetailsModal').addEventListener('click', e => {
    if(e.target.id === 'productDetailsModal') {
        closeProductDetailsModal();
    }
});

// Category filter function
function filterByCategory() {
    const selectedCategory = document.getElementById('categoryFilter').value;
    const productRows = document.querySelectorAll('.product-row');
    let visibleCount = 0;
    
    productRows.forEach(row => {
        const rowCategory = row.getAttribute('data-category');
        const shouldShow = selectedCategory === '' || rowCategory === selectedCategory;
        
        if (shouldShow) {
            row.style.display = '';
            visibleCount++;
            
            // Keep variant rows in their current state (expanded/collapsed) but ensure they're not hidden by filter
            const productId = row.getAttribute('data-product-id');
            const relatedVariantRows = document.querySelectorAll(`.variant-details-row[data-product-id="${productId}"]`);
            relatedVariantRows.forEach(vr => {
                // Only show variant row if it was already visible (expanded)
                if (vr.style.display !== 'none' && vr.style.display !== '') {
                    // Keep it visible
                } else if (vr.style.display === 'none') {
                    // Keep it hidden (was collapsed)
                }
            });
        } else {
            row.style.display = 'none';
            
            // Hide variant rows for hidden products
            const productId = row.getAttribute('data-product-id');
            const relatedVariantRows = document.querySelectorAll(`.variant-details-row[data-product-id="${productId}"]`);
            relatedVariantRows.forEach(vr => {
                vr.style.display = 'none';
            });
        }
    });
    
    // Update product count
    const visibleCountEl = document.getElementById('visibleCount');
    if (visibleCountEl) {
        visibleCountEl.textContent = visibleCount;
    }
    
    // Show message if no products match
    const tbody = document.querySelector('table tbody');
    let noResultsRow = tbody.querySelector('.no-results-row');
    
    if (visibleCount === 0 && selectedCategory !== '') {
        if (!noResultsRow) {
            noResultsRow = document.createElement('tr');
            noResultsRow.className = 'no-results-row';
            noResultsRow.innerHTML = '<td colspan="8" style="text-align:center; color:#777; padding: 40px;">No products found in this category.</td>';
            tbody.appendChild(noResultsRow);
        }
        noResultsRow.style.display = '';
    } else {
        if (noResultsRow) {
            noResultsRow.style.display = 'none';
        }
    }
}

// Add data-category to variant detail rows as well
document.addEventListener('DOMContentLoaded', function() {
    const variantRows = document.querySelectorAll('.variant-details-row');
    variantRows.forEach(vr => {
        const productRow = vr.previousElementSibling;
        if (productRow && productRow.classList.contains('product-row')) {
            const category = productRow.getAttribute('data-category');
            vr.setAttribute('data-category', category);
            vr.setAttribute('data-product-id', productRow.getAttribute('data-product-id'));
        }
    });
});
</script>

</body>
</html>
