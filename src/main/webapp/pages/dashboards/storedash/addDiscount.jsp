<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    String storeUsername = user.getUsername();
    List<Product> products = null;
    try {
        ProductDAO productDAO = new ProductDAO();
        products = productDAO.getAllProducts(storeUsername);
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Create Discount | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
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
        <li><a href="${pageContext.request.contextPath}/ListDiscountsServlet" class="active">Discounts</a></li>
        <li><a href="${pageContext.request.contextPath}/StoreReviewsServlet">Customer Reviews</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/finances.jsp">Finances</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myStore.jsp">My Store</a></li>
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/myProfile.jsp">Profile</a></li>
    </ul>
</aside>

<main class="container">
    <div class="form-card">
        <h2>Create Discount</h2>
        
        <% if (request.getAttribute("error") != null) { %>
        <div class="error-msg"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/CreateDiscountServlet" method="post">

            <label for="discountName">Discount Name *</label>
            <input type="text" name="discountName" placeholder="e.g., Summer Sale, 20% Off" required>

            <label for="discountType">Discount Type *</label>
            <select name="discountType" id="discountType" required onchange="updateDiscountValueLabel()">
                <option value="">-- Select Type --</option>
                <option value="PERCENTAGE">Percentage (%)</option>
                <option value="FIXED">Fixed Amount (Rs)</option>
            </select>

            <label for="discountValue">Discount Value *</label>
            <div class="discount-value-container">
                <input type="number" name="discountValue" id="discountValue" step="0.01" min="0" placeholder="Enter value" required>
                <span id="discountValueLabel">-</span>
            </div>

            <label for="startDate">Start Date (Optional)</label>
            <input type="datetime-local" name="startDate" id="startDate">

            <label for="endDate">End Date (Optional)</label>
            <input type="datetime-local" name="endDate" id="endDate">

            <label>Select Products to Apply Discount *</label>
            <div class="product-selection">
                <% if (products == null || products.isEmpty()) { %>
                    <p style="color: var(--muted-foreground); padding: 10px;">No products available. Please add products first.</p>
                <% } else { 
                    ProductVariantDAO variantDAO = new ProductVariantDAO();
                    for (Product product : products) {
                        String priceDisplay = "";
                        try {
                            List<ProductVariant> variants = variantDAO.getVariantsByProductId(product.getProductId());
                            if (variants != null && !variants.isEmpty() && product.getPrice() == 0.00) {
                                // Calculate price range from variants
                                double minPrice = Double.MAX_VALUE;
                                double maxPrice = 0.0;
                                boolean hasValidPrice = false;
                                
                                for (ProductVariant v : variants) {
                                    if (v.getPrice() != null) {
                                        double vPrice = v.getPrice().doubleValue();
                                        if (vPrice > 0) {
                                            hasValidPrice = true;
                                            if (vPrice < minPrice) minPrice = vPrice;
                                            if (vPrice > maxPrice) maxPrice = vPrice;
                                        }
                                    }
                                }
                                
                                if (hasValidPrice) {
                                    if (minPrice == maxPrice) {
                                        priceDisplay = String.format("Rs %.2f", minPrice);
                                    } else {
                                        priceDisplay = String.format("Rs %.2f - Rs %.2f", minPrice, maxPrice);
                                    }
                                } else {
                                    priceDisplay = "Rs 0.00";
                                }
                            } else {
                                priceDisplay = String.format("Rs %.2f", product.getPrice());
                            }
                        } catch (Exception e) {
                            priceDisplay = String.format("Rs %.2f", product.getPrice());
                        }
                %>
                    <div class="product-checkbox">
                        <input type="checkbox" name="productIds" value="<%= product.getProductId() %>" id="product_<%= product.getProductId() %>">
                        <label for="product_<%= product.getProductId() %>" style="margin: 0; font-weight: normal; cursor: pointer;">
                            <%= product.getName() %> - <%= priceDisplay %>
                        </label>
                    </div>
                    <% } %>
                <% } %>
            </div>
            <small class="selection-hint">
                Select at least one product to apply the discount
            </small>

            <button type="submit">Create Discount</button>
            <a href="${pageContext.request.contextPath}/ListDiscountsServlet" class="back-btn" style="width: 100%; text-align: center; display: block;">Cancel</a>
        </form>
    </div>
</main>
<script src="${pageContext.request.contextPath}/assets/js/storedash-discount-form.js"></script>

</body>
</html>
