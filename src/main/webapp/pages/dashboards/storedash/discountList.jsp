<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"store".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    List<Discount> discounts = (List<Discount>) request.getAttribute("discounts");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Discount Management | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-tables.css">
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
    <div class="top-bar">
        <h2>Discount Management</h2>
        <a class="btn-add" href="${pageContext.request.contextPath}/pages/dashboards/storedash/addDiscount.jsp">+ Create Discount</a>
    </div>

    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Type</th>
                <th>Value</th>
                <th>Applied To</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if (discounts == null || discounts.isEmpty()) { %>
            <tr>
                <td colspan="8" class="empty-state">
                    No discounts created yet. <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/addDiscount.jsp">Create one now</a>
                </td>
            </tr>
            <% } else { 
                DiscountDAO discountDAO = new DiscountDAO();
                ProductDAO productDAO = new ProductDAO();
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                
                for (Discount discount : discounts) {
                    long currentTime = System.currentTimeMillis();
                    boolean isExpired = discount.getEndDate() != null && currentTime > discount.getEndDate().getTime();
                    boolean isActive = discount.isActive() && !isExpired;
                    boolean isValid = discount.isValid();
                    
                    // Get linked products and variants
                    List<Integer> productIds = null;
                    List<Integer> variantIds = null;
                    List<String> productNames = new java.util.ArrayList<>();
                    List<String> variantNames = new java.util.ArrayList<>();
                    
                    try {
                        productIds = discountDAO.getProductIdsForDiscount(discount.getDiscountId());
                        variantIds = discountDAO.getVariantIdsForDiscount(discount.getDiscountId());
                        
                        // Get product names
                        for (Integer productId : productIds) {
                            try {
                                Product product = productDAO.getProductById(productId);
                                if (product != null) {
                                    productNames.add(product.getName());
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                        
                        // Get variant details
                        for (Integer variantId : variantIds) {
                            try {
                                ProductVariant variant = variantDAO.getVariantById(variantId);
                                if (variant != null) {
                                    Product parentProduct = productDAO.getProductById(variant.getProductId());
                                    String variantInfo = (parentProduct != null ? parentProduct.getName() : "Product") + " - ";
                                    if (variant.getColor() != null && !variant.getColor().isEmpty()) {
                                        variantInfo += "Color: " + variant.getColor();
                                    }
                                    if (variant.getSize() != null && !variant.getSize().isEmpty()) {
                                        variantInfo += (variantInfo.endsWith(" - ") ? "" : ", ") + "Size: " + variant.getSize();
                                    }
                                    if (variant.getPower() != null && !variant.getPower().isEmpty()) {
                                        variantInfo += (variantInfo.endsWith(" - ") ? "" : ", ") + "Power: " + variant.getPower();
                                    }
                                    variantNames.add(variantInfo);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
                <tr>
                    <td><strong><%= discount.getDiscountName() %></strong></td>
                    <td><%= discount.getDiscountType() %></td>
                    <td class="value-display">
                        <% if ("PERCENTAGE".equalsIgnoreCase(discount.getDiscountType())) { %>
                            <%= discount.getDiscountValue() %>%
                        <% } else { %>
                            Rs <%= discount.getDiscountValue() %>
                        <% } %>
                    </td>
                    <td class="applied-to-cell">
                        <% if (productNames.isEmpty() && variantNames.isEmpty()) { %>
                            <span class="text-muted-italic">No products/variants assigned</span>
                        <% } else { %>
                            <div class="tag-container">
                                <% for (int i = 0; i < productNames.size(); i++) { %>
                                    <span class="product-tag"><%= productNames.get(i) %></span>
                                <% } %>
                                <% for (int i = 0; i < variantNames.size(); i++) { %>
                                    <span class="variant-tag"><%= variantNames.get(i) %></span>
                                <% } %>
                            </div>
                        <% } %>
                    </td>
                    <td><%= discount.getStartDate() != null ? dateFormat.format(discount.getStartDate()) : "Immediate" %></td>
                    <td><%= discount.getEndDate() != null ? dateFormat.format(discount.getEndDate()) : "No expiry" %></td>
                    <td>
                        <% if (isExpired) { %>
                            <span class="badge badge-expired">Expired</span>
                        <% } else if (isValid) { %>
                            <span class="badge badge-active">Active</span>
                        <% } else { %>
                            <span class="badge badge-inactive">Inactive</span>
                        <% } %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/pages/dashboards/storedash/editDiscount.jsp?discountId=<%= discount.getDiscountId() %>" 
                           class="btn-edit">
                            Edit
                        </a>
                        <form method="post" action="${pageContext.request.contextPath}/DeleteDiscountServlet" style="display: inline;">
                            <input type="hidden" name="discountId" value="<%= discount.getDiscountId() %>">
                            <button type="submit" class="btn-delete" onclick="return confirm('Are you sure you want to delete this discount?');">Delete</button>
                        </form>
                    </td>
                </tr>
                <% } %>
            <% } %>
        </tbody>
    </table>
</main>
</body>
</html>
