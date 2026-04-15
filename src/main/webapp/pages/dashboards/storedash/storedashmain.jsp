<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.ProductSales" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

<%
    // Get the current user from session
    User user = (User) session.getAttribute("currentUser");

    // If user is not logged in, redirect to login
    if (user == null || user.getRole() == null) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    // Check if role is admin or store; otherwise redirect
    String role = user.getRole().trim().toLowerCase();
    if (!("admin".equals(role) || "store".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }

    // Fetch data for dashboard
    String storeUsername = user.getUsername();
    ProductDAO productDAO = new ProductDAO();
    OrderDAO orderDAO = new OrderDAO();
    ProductVariantDAO variantDAO = new ProductVariantDAO();
    
    // Get all products for this store
    List<Product> allProducts = new ArrayList<>();
    try {
        allProducts = productDAO.getAllProducts(storeUsername);
    } catch (Exception e) {
        System.err.println("Error fetching products: " + e.getMessage());
        e.printStackTrace();
    }
    
    // Filter low stock items (quantity < 5)
    List<Product> lowStockProducts = new ArrayList<>();
    for (Product product : allProducts) {
        int totalStock = product.getQuantity();
        
        // Check if product has variants - if so, sum variant quantities
        try {
            List<ProductVariant> variants = variantDAO.getVariantsByProductId(product.getProductId());
            if (variants != null && !variants.isEmpty()) {
                totalStock = 0;
                for (ProductVariant variant : variants) {
                    totalStock += variant.getQuantity();
                }
            }
        } catch (Exception e) {
            // If variant check fails, use product quantity
        }
        
        if (totalStock < 5) {
            lowStockProducts.add(product);
        }
    }
    
    // Get order statistics
    List<com.dailyfixer.model.Order> allStoreOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> pendingOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> completedOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> processingOrders = new ArrayList<>();
    List<com.dailyfixer.model.Order> outForDeliveryOrders = new ArrayList<>();
    BigDecimal totalRevenue = BigDecimal.ZERO;
    
    try {
        // Fetch all active orders in one query (includes STORE_ACCEPTED after dispatch)
        allStoreOrders = orderDAO.getAllOrdersByStore(storeUsername);

        if (allStoreOrders != null) {
            for (com.dailyfixer.model.Order order : allStoreOrders) {
                String status = order.getStatus() != null ? order.getStatus().trim().toUpperCase() : "";
                switch (status) {
                    case "DELIVERED":
                        completedOrders.add(order);
                        break;
                    case "PROCESSING":
                        processingOrders.add(order);
                        break;
                    case "OUT_FOR_DELIVERY":
                    case "STORE_ACCEPTED":
                        outForDeliveryOrders.add(order);
                        break;
                    default:
                        pendingOrders.add(order);
                        break;
                }
                // Revenue for store should exclude delivery fee
                if (order.getAmount() != null) {
                    BigDecimal netRevenue = order.getAmount();
                    if (order.getDeliveryFee() != null) {
                        netRevenue = netRevenue.subtract(order.getDeliveryFee());
                    }
                    if (netRevenue.compareTo(BigDecimal.ZERO) < 0) {
                        netRevenue = BigDecimal.ZERO;
                    }
                    totalRevenue = totalRevenue.add(netRevenue);
                }
            }
        }
    } catch (Exception e) {
        System.err.println("Error fetching orders: " + e.getMessage());
        e.printStackTrace();
    }
    
    // Format revenue for display
    NumberFormat currencyFormat = NumberFormat.getNumberInstance(Locale.US);
    String formattedRevenue = currencyFormat.format(totalRevenue.doubleValue());
    
    // --- Data for charts ---
    int pendingCount = pendingOrders != null ? pendingOrders.size() : 0;
    int processingCount = processingOrders != null ? processingOrders.size() : 0;
    int outForDeliveryCount = outForDeliveryOrders != null ? outForDeliveryOrders.size() : 0;
    int deliveredCount = completedOrders != null ? completedOrders.size() : 0;
    
    // Last 7 days: order count and revenue per day
    String[] dayLabels = new String[7];
    int[] orderCounts = new int[7];
    double[] revenueByDay = new double[7];
    Map<String, Integer> keyToIndex = new HashMap<>();
    SimpleDateFormat keyFmt = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat labelFmt = new SimpleDateFormat("d MMM");
    Calendar cal = Calendar.getInstance();
    cal.set(Calendar.HOUR_OF_DAY, 0);
    cal.set(Calendar.MINUTE, 0);
    cal.set(Calendar.SECOND, 0);
    cal.set(Calendar.MILLISECOND, 0);
    for (int i = 0; i < 7; i++) {
        Calendar d = (Calendar) cal.clone();
        d.add(Calendar.DATE, -(6 - i));
        String key = keyFmt.format(d.getTime());
        keyToIndex.put(key, i);
        dayLabels[i] = labelFmt.format(d.getTime());
    }
    List<com.dailyfixer.model.Order> allOrdersForCharts = new ArrayList<>();
    try {
        allOrdersForCharts = orderDAO.getAllOrdersByStore(storeUsername);
    } catch (Exception e) { }
    if (allOrdersForCharts != null) {
        for (com.dailyfixer.model.Order o : allOrdersForCharts) {
            if (o.getCreatedAt() == null) continue;
            String k = keyFmt.format(o.getCreatedAt());
            if (keyToIndex.containsKey(k)) {
                int idx = keyToIndex.get(k);
                orderCounts[idx]++;
                if (o.getAmount() != null) {
                    BigDecimal netRevenue = o.getAmount();
                    if (o.getDeliveryFee() != null) {
                        netRevenue = netRevenue.subtract(o.getDeliveryFee());
                    }
                    if (netRevenue.compareTo(BigDecimal.ZERO) < 0) {
                        netRevenue = BigDecimal.ZERO;
                    }
                    revenueByDay[idx] += netRevenue.doubleValue();
                }
            }
        }
    }
    
    // Most selling items for chart and for Most Selling Item card
    StringBuilder mostSellingJson = new StringBuilder("[");
    List<ProductSales> productSales = new ArrayList<>();
    try {
        productSales = orderDAO.getProductSalesByStore(storeUsername);
    } catch (Exception e) {
        System.err.println("Error fetching product sales: " + e.getMessage());
    }
    if (productSales != null) {
        for (int i = 0; i < productSales.size(); i++) {
            ProductSales ps = productSales.get(i);
            if (i > 0) mostSellingJson.append(",");
            String nm = ps.getProductName() != null ? ps.getProductName().replace("\"", "\\\"") : "";
            mostSellingJson.append("{\"name\":\"").append(nm).append("\",\"qty\":").append(ps.getQuantitySold()).append("}");
        }
    }
    mostSellingJson.append("]");
    
    // Top-selling product for the Most Selling Item card (with image)
    ProductSales topSales = (productSales != null && !productSales.isEmpty()) ? productSales.get(0) : null;
    Product mostSellingProduct = null;
    if (topSales != null && topSales.getProductId() > 0) {
        try {
            mostSellingProduct = productDAO.getProductById(topSales.getProductId());
        } catch (Exception e) { }
    }
    
    // JS arrays for charts
    StringBuilder orderCountsJs = new StringBuilder();
    StringBuilder revenueByDayJs = new StringBuilder();
    for (int i = 0; i < 7; i++) {
        if (i > 0) { orderCountsJs.append(','); revenueByDayJs.append(','); }
        orderCountsJs.append(orderCounts[i]);
        revenueByDayJs.append(String.format(Locale.US, "%.2f", revenueByDay[i]));
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Store Dashboard | Daily Fixer</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/storedash-dashboard.css">
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
        <li><a href="${pageContext.request.contextPath}/pages/dashboards/storedash/storedashmain.jsp" class="active">Dashboard</a></li>
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

<main class="container">
    <h2>Store Dashboard</h2>
    <p class="dashboard-subtitle">Welcome back! Here's an overview of your store performance.</p>
    
    <!-- Key Performance Cards -->
    <div class="cards-grid">
        <div class="card">
            <div class="card-header">
                <h3>Store Revenue</h3>
            </div>
            <div class="number" style="font-size: 1.8em;">LKR <%= formattedRevenue %></div>
            <div class="label">Order revenue excluding delivery fees</div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h3>Low Stock Items</h3>
            </div>
            <div class="low-stock-list">
                <% if (lowStockProducts != null && !lowStockProducts.isEmpty()) { 
                    int displayCount = 0;
                    for (Product product : lowStockProducts) {
                        if (displayCount >= 5) break; // Show max 5 items
                        
                        int totalStock = product.getQuantity();
                        // Check variants if exists
                        try {
                            List<ProductVariant> variants = variantDAO.getVariantsByProductId(product.getProductId());
                            if (variants != null && !variants.isEmpty()) {
                                totalStock = 0;
                                for (ProductVariant variant : variants) {
                                    totalStock += variant.getQuantity();
                                }
                            }
                        } catch (Exception e) {
                            // Use product quantity if variant check fails
                        }
                %>
                    <a class="low-stock-item" href="${pageContext.request.contextPath}/pages/dashboards/storedash/editProduct.jsp?productId=<%= product.getProductId() %>">
                        <span class="item-name"><%= product.getName() %></span>
                        <span class="stock-count"><%= totalStock %> left</span>
                    </a>
                <% 
                        displayCount++;
                    } 
                } else { %>
                    <div class="low-stock-empty">
                        <p style="font-weight: 500; margin-bottom: 4px;">All stocked!</p>
                        <p style="font-size: 0.9em;">No low stock items to display</p>
                    </div>
                <% } %>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h3>Total Products</h3>
            </div>
            <div class="number"><%= allProducts != null ? allProducts.size() : 0 %></div>
            <div class="label">Products in your store</div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h3>Most Selling Item</h3>
            </div>
            <% if (mostSellingProduct != null && topSales != null) { 
                String imgPath = mostSellingProduct.getImagePath();
                boolean hasImg = imgPath != null && !imgPath.isEmpty();
            %>
                <div class="most-selling-item">
                    <% if (hasImg) { %>
                    <img src="<%= request.getContextPath() + "/" + imgPath %>" alt="<%= mostSellingProduct.getName() %>">
                    <% } %>
                    <div class="info">
                        <h4><%= mostSellingProduct.getName() %></h4>
                        <p><%= topSales.getQuantitySold() %> units sold</p>
                    </div>
                </div>
            <% } else { %>
                <div class="most-selling-empty">
                    <p>No sales data yet</p>
                    <span>Your top-selling product will show here once orders come in.</span>
                </div>
            <% } %>
        </div>
    </div>

    <!-- General Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="number"><%= allStoreOrders != null ? allStoreOrders.size() + (completedOrders != null ? completedOrders.size() : 0) : 0 %></div>
            <p>Total Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= completedOrders != null ? completedOrders.size() : 0 %></div>
            <p>Completed Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= pendingOrders != null ? pendingOrders.size() : 0 %></div>
            <p>Pending Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= processingOrders != null ? processingOrders.size() : 0 %></div>
            <p>Processing Orders</p>
        </div>
        <div class="stat-card">
            <div class="number"><%= outForDeliveryOrders != null ? outForDeliveryOrders.size() : 0 %></div>
            <p>Up for Delivery</p>
        </div>
    </div>

    <!-- Charts -->
    <section class="charts-section">
        <h3>Analytics</h3>
        <div class="charts-grid">
            <div class="chart-card">
                <h4>Order Status</h4>
                <div class="chart-container chart-sm">
                    <canvas id="chartOrderStatus"></canvas>
                </div>
            </div>
            <div class="chart-card">
                <h4>Orders & Revenue (Last 7 Days)</h4>
                <div class="chart-container">
                    <canvas id="chartOrdersOverTime"></canvas>
                </div>
            </div>
            <div class="chart-card">
                <h4>Most Selling Items</h4>
                <div class="chart-container chart-sm">
                    <canvas id="chartMostSelling"></canvas>
                </div>
            </div>
        </div>
    </section>
</main>
<script>
window.storeDashData = {
    statusLabels: ['Pending', 'Processing', 'Out for Delivery', 'Delivered'],
    statusValues: [<%= pendingCount %>, <%= processingCount %>, <%= outForDeliveryCount %>, <%= deliveredCount %>],
    dayLabels: [<%= "\"" + String.join("\",\"", dayLabels) + "\"" %>],
    orderCounts: [<%= orderCountsJs.toString() %>],
    revenueByDay: [<%= revenueByDayJs.toString() %>],
    mostSelling: <%= mostSellingJson.toString() %>
};
</script>
<script src="${pageContext.request.contextPath}/assets/js/storedash-charts.js"></script>
</body>
</html>

