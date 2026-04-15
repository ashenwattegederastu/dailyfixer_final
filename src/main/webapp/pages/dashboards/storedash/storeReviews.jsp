<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Review" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.util.ProductDisplayUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Get the currently logged-in user from session
    User user = (User) session.getAttribute("currentUser");

    // Redirect to login if no user or role is set
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    // Check role: allow only admin or store
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    // Get reviews from request attribute (set by servlet)
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    
    if (reviews == null) {
        reviews = new java.util.ArrayList<>();
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    
    // Calculate statistics
    int totalReviews = reviews.size();
    double avgRating = 0.0;
    int[] ratingCounts = new int[6]; // 0-5 stars
    
    if (totalReviews > 0) {
        int totalRating = 0;
        for (Review review : reviews) {
            int rating = review.getRating();
            totalRating += rating;
            if (rating >= 0 && rating <= 5) {
                ratingCounts[rating]++;
            }
        }
        avgRating = (double) totalRating / totalReviews;
    }
    
    // Load product data for modal (get unique product IDs from reviews)
    Set<Integer> productIds = new HashSet<>();
    for (Review review : reviews) {
        productIds.add(review.getProductId());
    }
    
    ProductDAO productDAO = new ProductDAO();
    ProductVariantDAO variantDAO = new ProductVariantDAO();
    DiscountDAO discountDAO = new DiscountDAO();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Customer Reviews | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-tables.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-reviews.css">
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
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet" class="active">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <div class="top-bar">
        <h2>Customer Reviews</h2>
    </div>

    <!-- Statistics Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <h3>Total Reviews</h3>
            <div class="stat-value"><%= totalReviews %></div>
        </div>
        <div class="stat-card">
            <h3>Average Rating</h3>
            <div class="stat-value"><%= totalReviews > 0 ? String.format("%.1f", avgRating) : "N/A" %></div>
        </div>
        <div class="stat-card">
            <h3>5 Star Reviews</h3>
            <div class="stat-value"><%= ratingCounts[5] %></div>
        </div>
        <div class="stat-card">
            <h3>4 Star Reviews</h3>
            <div class="stat-value"><%= ratingCounts[4] %></div>
        </div>
    </div>

    <!-- Reviews Table -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Customer</th>
                    <th>Rating</th>
                    <th>Comment</th>
                    <th>Date</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (reviews == null || reviews.isEmpty()) { %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: var(--muted-foreground);">
                        No reviews yet. Reviews will appear here once customers submit them.
                    </td>
                </tr>
                <% } else { 
                    for (Review review : reviews) {
                        String productName = review.getProductName() != null ? review.getProductName() : "Product #" + review.getProductId();
                        String customerName = review.getUsername() != null ? review.getUsername() : "Anonymous";
                        int rating = review.getRating();
                        String ratingClass = "star-" + rating;
                        String comment = review.getComment() != null && !review.getComment().trim().isEmpty() 
                            ? review.getComment() : "No comment provided";
                %>
                <tr>
                    <td>
                        <strong><%= productName %></strong>
                    </td>
                    <td>
                        <span class="customer-name"><%= customerName %></span>
                    </td>
                    <td>
                        <div class="rating-stars">
                            <% 
                                for (int i = 1; i <= 5; i++) {
                                    if (i <= rating) {
                            %>
                                <span class="star">★</span>
                            <% } else { %>
                                <span class="star empty">★</span>
                            <% } 
                                } %>
                        </div>
                    </td>
                    <td class="comment-cell">
                        <%= comment.length() > 100 ? comment.substring(0, 100) + "..." : comment %>
                    </td>
                    <td>
                        <%= review.getCreatedAt() != null ? dateFormat.format(review.getCreatedAt()) : "N/A" %>
                    </td>
                    <td>
                        <button class="btn-view" onclick="viewProductDetails(<%= review.getProductId() %>)">
                            View Product
                        </button>
                    </td>
                </tr>
                <% } 
                } %>
            </tbody>
        </table>
    </div>
</main>

<!-- Product Details Modal -->
<div id="productDetailsModal" class="product-details-modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalProductName">Product Details</h3>
            <button class="close-btn" onclick="closeProductDetailsModal()">&times;</button>
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
                        <span class="info-value highlight" id="modalBasePrice"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Total Stock:</span>
                        <span class="info-value highlight" id="modalBaseStock"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Unit:</span>
                        <span class="info-value" id="modalUnit"></span>
                    </div>
                </div>
            </div>
            <div class="review-variants-section">
                <h4>Product Variants</h4>
                <div id="modalVariantsContainer"></div>
            </div>
        </div>
    </div>
</div>
<script>
let productData = {};

// Load product data for all products in reviews
<% 
    for (Integer productId : productIds) {
        try {
            Product product = productDAO.getProductById(productId);
            if (product != null) {
                List<ProductVariant> variants = variantDAO.getVariantsByProductId(productId);
                String modalImgRel = ProductDisplayUtil.getDisplayImagePathVariantFirst(product, variants);
%>
productData[<%=productId%>] = {
    id: <%=product.getProductId()%>,
    name: "<%=product.getName() != null ? product.getName().replace("\"", "\\\"").replace("\n", "\\n") : ""%>",
    type: "<%=product.getType() != null ? product.getType() : ""%>",
    description: "<%=product.getDescription() != null ? product.getDescription().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r") : ""%>",
    price: <%=product.getPrice()%>,
    quantity: <%=product.getQuantity()%>,
    unit: "<%=product.getQuantityUnit() != null ? product.getQuantityUnit() : ""%>",
    image: "<%=modalImgRel != null && !modalImgRel.isEmpty() ? request.getContextPath() + "/" + modalImgRel : ""%>",
    variants: [
        <% if (variants != null && !variants.isEmpty()) {
            for (int i = 0; i < variants.size(); i++) {
                ProductVariant v = variants.get(i);
                Discount variantDiscount = null;
                Discount productDiscount = null;
                try {
                    variantDiscount = discountDAO.getActiveDiscountForVariant(v.getVariantId());
                    if (variantDiscount == null || !variantDiscount.isValid()) {
                        productDiscount = discountDAO.getActiveDiscountForProduct(productId);
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
<%          }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

function viewProductDetails(productId) {
    const product = productData[productId];
    if (!product) {
        alert('Product data not available');
        return;
    }
    
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

// Close modal on outside click
document.getElementById('productDetailsModal').addEventListener('click', e => {
    if(e.target.id === 'productDetailsModal') {
        closeProductDetailsModal();
    }
});
</script>

</body>
</html>
