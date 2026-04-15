<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.dao.OrderDAO" %>
<%@ page import="com.dailyfixer.dao.StoreDAO" %>
<%@ page import="com.dailyfixer.dao.UserDAO" %>
<%@ page import="com.dailyfixer.model.Order" %>
<%@ page import="com.dailyfixer.model.OrderItem" %>
<%@ page import="com.dailyfixer.model.Store" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.math.BigDecimal" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
%>

<%
    // Get order_id from URL parameter
    String orderIdParam = request.getParameter("order_id");
    Order order = null;
    List<Order> allRelatedOrders = new ArrayList<>(); // Store all related orders for multi-store purchases
    OrderDAO orderDAO = new OrderDAO(); // Declare orderDAO outside if block for use in JSP rendering
    
    if (orderIdParam != null && !orderIdParam.isEmpty()) {
        order = orderDAO.findOrderById(orderIdParam);
        
        // Update order status to PAID if it's still PENDING
        // This is a fallback in case NotifyServlet wasn't called (common in sandbox/development)
        if (order != null) {
            String currentStatus = order.getStatus() != null ? order.getStatus().trim() : "";
            // Atomic PENDING→PAID only — avoids double stock deduction vs PayHere / duplicate loads
            if (!"PAID".equalsIgnoreCase(currentStatus)) {
                boolean claimed = orderDAO.claimOrderPaidFromPending(orderIdParam, null);
                if (claimed) {
                    System.out.println("Order claimed PAID on success page: " + orderIdParam);
                    order = orderDAO.findOrderById(orderIdParam);
                    try {
                        boolean stockReduced = orderDAO.reduceStockForOrder(orderIdParam);
                        if (stockReduced) {
                            System.out.println("Stock reduced successfully for order: " + orderIdParam);
                        } else {
                            System.err.println("Warning: Stock reduction failed or incomplete for order: " + orderIdParam);
                        }
                    } catch (Exception e) {
                        System.err.println("Error reducing stock for order " + orderIdParam + ": " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            // If already PAID (e.g. notify ran first), claim does nothing — no second stock reduction
            
            // Get all related orders from session (stored during checkout)
            @SuppressWarnings("unchecked")
            List<String> allOrderIds = (List<String>) session.getAttribute("allOrderIds");
            
            if (allOrderIds != null && !allOrderIds.isEmpty()) {
                // Fetch all orders by their IDs
                for (String orderId : allOrderIds) {
                    try {
                        Order relatedOrder = orderDAO.findOrderById(orderId);
                        if (relatedOrder != null) {
                            allRelatedOrders.add(relatedOrder);
                        }
                    } catch (Exception e) {
                        System.err.println("Error fetching order " + orderId + ": " + e.getMessage());
                    }
                }
            }
            
            // Fallback: If no orders from session, find by email and time
            if (allRelatedOrders.isEmpty() && order.getEmail() != null) {
                try {
                    List<Order> allOrders = orderDAO.getOrdersByStatus("PAID");
                    for (Order relatedOrder : allOrders) {
                        if (relatedOrder.getEmail() != null && 
                            relatedOrder.getEmail().equals(order.getEmail()) &&
                            relatedOrder.getCreatedAt() != null && order.getCreatedAt() != null) {
                            long timeDiff = Math.abs(relatedOrder.getCreatedAt().getTime() - order.getCreatedAt().getTime());
                            if (timeDiff < 300000) { // 5 minutes in milliseconds
                                allRelatedOrders.add(relatedOrder);
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Warning: Could not get related orders: " + e.getMessage());
                }
            }
            
            // If still no related orders, just use the main order
            if (allRelatedOrders.isEmpty()) {
                allRelatedOrders.add(order);
            }

            // Clear the cart now that the order is confirmed
            session.removeAttribute("cart");
            session.removeAttribute("itemsToCheckout");
            session.removeAttribute("allOrderIds");
            session.removeAttribute("currentOrder");
        } else {
            System.err.println("Order not found for order_id: " + orderIdParam);
        }
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    
    // Helper function to update related orders (for multi-store orders)
    if (order != null && order.getEmail() != null) {
        try {
            OrderDAO tempOrderDAO = new OrderDAO();
            // Update all orders with same email and PENDING status created recently
            List<Order> relatedOrders = tempOrderDAO.getOrdersByStatus("PENDING");
            for (Order relatedOrder : relatedOrders) {
                if (relatedOrder.getEmail() != null && 
                    relatedOrder.getEmail().equals(order.getEmail()) &&
                    !relatedOrder.getOrderId().equals(order.getOrderId())) {
                    // Check if created within last 5 minutes (related order)
                    if (relatedOrder.getCreatedAt() != null && order.getCreatedAt() != null) {
                        long timeDiff = Math.abs(relatedOrder.getCreatedAt().getTime() - order.getCreatedAt().getTime());
                        if (timeDiff < 300000) { // 5 minutes in milliseconds
                            String relatedStatus = relatedOrder.getStatus() != null ? relatedOrder.getStatus().trim() : "";
                            if (!"PAID".equalsIgnoreCase(relatedStatus)) {
                                boolean relClaimed = tempOrderDAO.claimOrderPaidFromPending(relatedOrder.getOrderId(), null);
                                if (relClaimed) {
                                    System.out.println("Updated related order to PAID: " + relatedOrder.getOrderId());
                                    try {
                                        boolean stockReduced = tempOrderDAO.reduceStockForOrder(relatedOrder.getOrderId());
                                        if (stockReduced) {
                                            System.out.println("Stock reduced successfully for related order: " + relatedOrder.getOrderId());
                                        } else {
                                            System.err.println("Warning: Stock reduction failed for related order: " + relatedOrder.getOrderId());
                                        }
                                    } catch (Exception e) {
                                        System.err.println("Error reducing stock for related order " + relatedOrder.getOrderId() + ": " + e.getMessage());
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Warning: Could not update related orders: " + e.getMessage());
        }
    }
    
    // Prepare order data for receipt
    String customerName = "";
    String orderDate = "";
    String totalAmount = "";
    List<OrderItem> allOrderItems = new ArrayList<>();
    BigDecimal combinedTotal = BigDecimal.ZERO;
    
    // Store information map (storeId -> Store info with User details)
    Map<Integer, Map<String, String>> storeInfoMap = new HashMap<>();
    StoreDAO storeDAO = new StoreDAO();
    UserDAO userDAO = new UserDAO();
    
    if (order != null) {
        customerName = order.getFirstName() + (order.getLastName() != null && !order.getLastName().isEmpty() ? " " + order.getLastName() : "");
        orderDate = order.getCreatedAt() != null ? dateFormat.format(order.getCreatedAt()) : "N/A";
        totalAmount = String.format("LKR %.2f", order.getAmount());
        
        // Get all order items from all related orders
        for (Order relatedOrder : allRelatedOrders) {
            List<OrderItem> items = orderDAO.getOrderItemsByOrderId(relatedOrder.getOrderId());
            if (items != null) {
                allOrderItems.addAll(items);
                
                // Collect unique store information
                for (OrderItem item : items) {
                    int storeId = item.getStoreId();
                    if (!storeInfoMap.containsKey(storeId)) {
                        try {
                            Store store = storeDAO.getStoreById(storeId);
                            if (store != null) {
                                Map<String, String> storeInfo = new HashMap<>();
                                storeInfo.put("storeName", store.getStoreName() != null ? store.getStoreName() : "N/A");
                                storeInfo.put("storeAddress", store.getStoreAddress() != null ? store.getStoreAddress() : "N/A");
                                storeInfo.put("storeCity", store.getStoreCity() != null ? store.getStoreCity() : "N/A");
                                
                                // Get user (store owner) information for contact and email
                                try {
                                    User storeOwner = userDAO.getUserById(store.getUserId());
                                    if (storeOwner != null) {
                                        storeInfo.put("contact", storeOwner.getPhoneNumber() != null ? storeOwner.getPhoneNumber() : "N/A");
                                        storeInfo.put("email", storeOwner.getEmail() != null ? storeOwner.getEmail() : "N/A");
                                    } else {
                                        storeInfo.put("contact", "N/A");
                                        storeInfo.put("email", "N/A");
                                    }
                                } catch (Exception e) {
                                    System.err.println("Error getting store owner info: " + e.getMessage());
                                    storeInfo.put("contact", "N/A");
                                    storeInfo.put("email", "N/A");
                                }
                                
                                storeInfoMap.put(storeId, storeInfo);
                            }
                        } catch (Exception e) {
                            System.err.println("Error getting store info for storeId " + storeId + ": " + e.getMessage());
                        }
                    }
                }
            }
            if (relatedOrder.getAmount() != null) {
                combinedTotal = combinedTotal.add(relatedOrder.getAmount());
            }
        }
        
        if (combinedTotal.compareTo(BigDecimal.ZERO) > 0) {
            totalAmount = String.format("LKR %.2f", combinedTotal);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Payment Successful - DailyFixer">
    <title>Payment Successful - Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/payment-status.css">
</head>

<body>
    <!-- Navigation -->
    <nav class="public-nav">
        <div class="nav-container">
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">Daily Fixer</a>
            <div class="nav-buttons">
                <% if (isLoggedIn) { %>
                    <form action="<%=request.getContextPath()%>/logout" method="post" style="margin: 0; display: inline;">
                        <button type="submit" class="btn-logout">Logout</button>
                    </form>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
        <div class="result-card success">
            <div class="result-icon success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <circle cx="12" cy="12" r="10"></circle>
                    <path d="M9 12l2 2 4-4"></path>
                </svg>
            </div>

            <h1 class="success-title">Payment Successful!</h1>
            <p class="subtitle">
                Thank you for your purchase. Your order has been confirmed and will be processed shortly.
            </p>

            <% if (order != null) { %>
                <div class="order-details" id="orderDetails">
                    <!-- Order Information -->
                    <div class="order-section">
                        <div class="section-title">Order Information</div>
                        <div class="detail-row">
                            <span class="detail-label">Order ID</span>
                            <span class="detail-value"><%= order.getOrderId() %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Order Date</span>
                            <span class="detail-value"><%= orderDate %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Payment Status</span>
                            <span class="status-paid">PAID</span>
                        </div>
                    </div>

                    <!-- Customer Information -->
                    <div class="order-section">
                        <div class="section-title">Customer Information</div>
                        <div class="detail-row">
                            <span class="detail-label">Name</span>
                            <span class="detail-value"><%= customerName %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Email</span>
                            <span class="detail-value"><%= order.getEmail() != null ? order.getEmail() : "N/A" %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Phone</span>
                            <span class="detail-value"><%= order.getPhone() != null ? order.getPhone() : "N/A" %></span>
                        </div>
                    </div>

                    <!-- Delivery Information -->
                    <div class="order-section">
                        <div class="section-title">Delivery Information</div>
                        <div class="detail-row">
                            <span class="detail-label">Address</span>
                            <span class="detail-value"><%= order.getAddress() != null ? order.getAddress() : "N/A" %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">City</span>
                            <span class="detail-value"><%= order.getCity() != null ? order.getCity() : "N/A" %></span>
                        </div>
                    </div>

                    <!-- Store Information -->
                    <% if (!storeInfoMap.isEmpty()) { %>
                        <div class="order-section">
                            <div class="section-title">Store Information</div>
                            <% 
                                int storeIndex = 0;
                                for (Map.Entry<Integer, Map<String, String>> storeEntry : storeInfoMap.entrySet()) {
                                    Map<String, String> storeInfo = storeEntry.getValue();
                                    storeIndex++;
                            %>
                                <% if (storeInfoMap.size() > 1) { %>
                                    <div style="margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid var(--border);">
                                        <div style="font-weight: 600; color: var(--primary); margin-bottom: 0.5rem;">Store <%= storeIndex %></div>
                                <% } %>
                                <div class="detail-row">
                                    <span class="detail-label">Store Name</span>
                                    <span class="detail-value"><%= storeInfo.get("storeName") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Store Address</span>
                                    <span class="detail-value"><%= storeInfo.get("storeAddress") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Store City</span>
                                    <span class="detail-value"><%= storeInfo.get("storeCity") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Contact</span>
                                    <span class="detail-value"><%= storeInfo.get("contact") %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Email</span>
                                    <span class="detail-value"><%= storeInfo.get("email") %></span>
                                </div>
                                <% if (storeInfoMap.size() > 1 && storeIndex < storeInfoMap.size()) { %>
                                    </div>
                                <% } %>
                            <% } %>
                        </div>
                    <% } %>

                    <!-- Order Summary -->
                    <div class="order-section">
                        <div class="section-title">Order Summary</div>
                        <div class="detail-row" style="flex-direction: column; align-items: flex-start;">
                            <span class="detail-label" style="margin-bottom: 10px;">Products</span>
                            <div style="width: 100%;">
                                <% 
                                    if (allOrderItems.isEmpty()) {
                                        // Fallback to product_name if order_items not available
                                        StringBuilder allProducts = new StringBuilder();
                                        for (int i = 0; i < allRelatedOrders.size(); i++) {
                                            Order relatedOrder = allRelatedOrders.get(i);
                                            if (relatedOrder.getProductName() != null && !relatedOrder.getProductName().isEmpty()) {
                                                if (i > 0) {
                                                    allProducts.append(", ");
                                                }
                                                allProducts.append(relatedOrder.getProductName());
                                            }
                                        }
                                        String displayProducts = allProducts.length() > 0 ? allProducts.toString() : "N/A";
                                %>
                                    <span class="detail-value"><%= displayProducts %></span>
                                <% } else { %>
                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                        <% for (OrderItem item : allOrderItems) { %>
                                            <div class="product-item">
                                                <div class="product-item-name"><%= item.getProductName() %></div>
                                                <div class="product-item-details">
                                                    Quantity: <%= item.getQuantity() %> × LKR <%= String.format("%.2f", item.getUnitPrice()) %> = LKR <%= String.format("%.2f", item.getTotalPrice()) %>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Total Amount</span>
                            <span class="detail-value amount-highlight"><%= totalAmount %></span>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="order-details">
                    <div class="detail-row">
                        <span class="detail-label">Order ID</span>
                        <span class="detail-value" id="order-id">Loading...</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Payment Status</span>
                        <span class="status-paid">PAID</span>
                    </div>
                </div>
            <% } %>

            <div class="action-buttons">
                <button onclick="downloadReceipt()" class="btn-primary btn-download">
                    📄 Download Receipt
                </button>
                <a href="store_main.jsp" class="btn-primary">
                    🛒 Continue Shopping
                </a>
                <a href="<%=request.getContextPath()%>/index.jsp" class="btn-secondary">
                    🏠 Back to Home
                </a>
            </div>

            <div class="success-message">
                <p>✅ Your payment has been successfully processed.</p>
                <p>📧 A confirmation email has been sent to your email address.</p>
                <p>📦 Your order will be prepared and shipped soon.</p>
                <p>📞 Our team will contact you if there are any updates regarding your order.</p>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <p>&copy; 2026 DailyFixer. All rights reserved.</p>
    </footer>

    <script>
        // Get order info from URL params if order not found in database
        document.addEventListener('DOMContentLoaded', function () {
            <% if (order == null) { %>
                const urlParams = new URLSearchParams(window.location.search);
                const orderId = urlParams.get('order_id');
                if (orderId) {
                    const orderIdElement = document.getElementById('order-id');
                    if (orderIdElement) {
                        orderIdElement.textContent = orderId;
                    }
                }
            <% } %>
        });

        // Download Receipt Function
        function downloadReceipt() {
            const orderDetails = document.getElementById('orderDetails');
            if (!orderDetails) {
                alert('Order details not available');
                return;
            }

            // Create a new window for printing
            const printWindow = window.open('', '_blank');
            
            // Get all order data
            <%
                // Escape JavaScript strings properly
                String safeOrderId = order != null ? order.getOrderId().replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") : "N/A";
                String safeOrderDate = orderDate.replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeCustomerName = customerName.replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeEmail = (order != null && order.getEmail() != null ? order.getEmail() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safePhone = (order != null && order.getPhone() != null ? order.getPhone() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeAddress = (order != null && order.getAddress() != null ? order.getAddress() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeCity = (order != null && order.getCity() != null ? order.getCity() : "N/A").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                String safeTotalAmount = totalAmount.replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
            %>
            const orderData = {
                orderId: '<%= safeOrderId %>',
                orderDate: '<%= safeOrderDate %>',
                customerName: '<%= safeCustomerName %>',
                email: '<%= safeEmail %>',
                phone: '<%= safePhone %>',
                address: '<%= safeAddress %>',
                city: '<%= safeCity %>',
                totalAmount: '<%= safeTotalAmount %>',
                stores: [
                    <% if (!storeInfoMap.isEmpty()) { %>
                        <% 
                            int storeIdx = 0;
                            for (Map.Entry<Integer, Map<String, String>> storeEntry : storeInfoMap.entrySet()) {
                                Map<String, String> storeInfo = storeEntry.getValue();
                                String safeStoreName = storeInfo.get("storeName").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeStoreAddress = storeInfo.get("storeAddress").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeStoreCity = storeInfo.get("storeCity").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeContact = storeInfo.get("contact").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                                String safeStoreEmail = storeInfo.get("email").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                        %>
                            {
                                name: '<%= safeStoreName %>',
                                address: '<%= safeStoreAddress %>',
                                city: '<%= safeStoreCity %>',
                                contact: '<%= safeContact %>',
                                email: '<%= safeStoreEmail %>'
                            }<%= storeIdx < storeInfoMap.size() - 1 ? "," : "" %>
                        <% 
                                storeIdx++;
                            }
                        %>
                    <% } %>
                ],
                items: [
                    <% if (!allOrderItems.isEmpty()) { %>
                        <% for (int i = 0; i < allOrderItems.size(); i++) { 
                            OrderItem item = allOrderItems.get(i);
                            String itemName = item.getProductName().replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
                        %>
                            {
                                name: '<%= itemName %>',
                                quantity: <%= item.getQuantity() %>,
                                unitPrice: <%= item.getUnitPrice() %>,
                                totalPrice: <%= item.getTotalPrice() %>
                            }<%= i < allOrderItems.size() - 1 ? "," : "" %>
                        <% } %>
                    <% } %>
                ]
            };

            // Build receipt HTML using string concatenation
            let receiptHTML = '<!DOCTYPE html><html><head>';
            receiptHTML += '<meta charset="UTF-8">';
            receiptHTML += '<title>Receipt - Order ' + orderData.orderId + '</title>';
            receiptHTML += '<style>';
            receiptHTML += '* { margin: 0; padding: 0; box-sizing: border-box; }';
            receiptHTML += 'body { font-family: Arial, sans-serif; padding: 40px; max-width: 800px; margin: 0 auto; background: white; color: #000; }';
            receiptHTML += '.receipt-header { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 3px solid #8b7dd8; }';
            receiptHTML += '.receipt-header h1 { color: #8b7dd8; font-size: 2rem; margin-bottom: 10px; }';
            receiptHTML += '.receipt-header p { color: #666; font-size: 0.9rem; }';
            receiptHTML += '.receipt-section { margin-bottom: 25px; }';
            receiptHTML += '.receipt-section h2 { color: #8b7dd8; font-size: 1.2rem; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 2px solid #e0e0e0; }';
            receiptHTML += '.receipt-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }';
            receiptHTML += '.receipt-row:last-child { border-bottom: none; }';
            receiptHTML += '.receipt-label { font-weight: 600; color: #333; }';
            receiptHTML += '.receipt-value { color: #666; text-align: right; }';
            receiptHTML += '.receipt-items { margin-top: 10px; }';
            receiptHTML += '.receipt-item { padding: 12px; background: #f9f9f9; border-left: 3px solid #8b7dd8; margin-bottom: 10px; border-radius: 4px; }';
            receiptHTML += '.receipt-item-name { font-weight: 600; color: #333; margin-bottom: 5px; }';
            receiptHTML += '.receipt-item-details { font-size: 0.9em; color: #666; }';
            receiptHTML += '.receipt-total { margin-top: 20px; padding-top: 15px; border-top: 2px solid #8b7dd8; }';
            receiptHTML += '.receipt-total .receipt-row { font-size: 1.2rem; font-weight: 700; color: #8b7dd8; }';
            receiptHTML += '.receipt-footer { margin-top: 40px; padding-top: 20px; border-top: 2px solid #e0e0e0; text-align: center; color: #666; font-size: 0.9rem; }';
            receiptHTML += '@media print { body { padding: 20px; } }';
            receiptHTML += '</style></head><body>';
            
            // Header
            receiptHTML += '<div class="receipt-header">';
            receiptHTML += '<h1>Daily Fixer</h1>';
            receiptHTML += '<p>Order Receipt</p>';
            receiptHTML += '</div>';
            
            // Order Information
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Order Information</h2>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Order ID:</span><span class="receipt-value">' + orderData.orderId + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Order Date:</span><span class="receipt-value">' + orderData.orderDate + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Payment Status:</span><span class="receipt-value" style="color: #27ae60; font-weight: 600;">PAID</span></div>';
            receiptHTML += '</div>';
            
            // Customer Information
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Customer Information</h2>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Name:</span><span class="receipt-value">' + orderData.customerName + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Email:</span><span class="receipt-value">' + orderData.email + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Phone:</span><span class="receipt-value">' + orderData.phone + '</span></div>';
            receiptHTML += '</div>';
            
            // Delivery Information
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Delivery Information</h2>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Address:</span><span class="receipt-value">' + orderData.address + '</span></div>';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">City:</span><span class="receipt-value">' + orderData.city + '</span></div>';
            receiptHTML += '</div>';
            
            // Store Information
            if (orderData.stores && orderData.stores.length > 0) {
                receiptHTML += '<div class="receipt-section">';
                receiptHTML += '<h2>Store Information</h2>';
                for (let i = 0; i < orderData.stores.length; i++) {
                    const store = orderData.stores[i];
                    if (orderData.stores.length > 1) {
                        receiptHTML += '<div style="margin-bottom: 15px; padding-bottom: 15px; border-bottom: 1px solid #e0e0e0;">';
                        receiptHTML += '<div style="font-weight: 600; color: #8b7dd8; margin-bottom: 8px;">Store ' + (i + 1) + '</div>';
                    }
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Store Name:</span><span class="receipt-value">' + store.name + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Store Address:</span><span class="receipt-value">' + store.address + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Store City:</span><span class="receipt-value">' + store.city + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Contact:</span><span class="receipt-value">' + store.contact + '</span></div>';
                    receiptHTML += '<div class="receipt-row"><span class="receipt-label">Email:</span><span class="receipt-value">' + store.email + '</span></div>';
                    if (orderData.stores.length > 1 && i < orderData.stores.length - 1) {
                        receiptHTML += '</div>';
                    }
                }
                receiptHTML += '</div>';
            }
            
            // Order Summary
            receiptHTML += '<div class="receipt-section">';
            receiptHTML += '<h2>Order Summary</h2>';
            receiptHTML += '<div class="receipt-items">';
            
            // Build items HTML
            for (let i = 0; i < orderData.items.length; i++) {
                const item = orderData.items[i];
                receiptHTML += '<div class="receipt-item">';
                receiptHTML += '<div class="receipt-item-name">' + item.name + '</div>';
                receiptHTML += '<div class="receipt-item-details">';
                receiptHTML += 'Quantity: ' + item.quantity + ' × LKR ' + item.unitPrice.toFixed(2) + ' = LKR ' + item.totalPrice.toFixed(2);
                receiptHTML += '</div>';
                receiptHTML += '</div>';
            }
            
            receiptHTML += '</div>';
            receiptHTML += '<div class="receipt-total">';
            receiptHTML += '<div class="receipt-row"><span class="receipt-label">Total Amount:</span><span class="receipt-value">' + orderData.totalAmount + '</span></div>';
            receiptHTML += '</div>';
            receiptHTML += '</div>';
            
            // Footer
            receiptHTML += '<div class="receipt-footer">';
            receiptHTML += '<p>Thank you for your purchase!</p>';
            receiptHTML += '<p>Daily Fixer - Fix, Learn, Restore</p>';
            receiptHTML += '<p>This is a computer-generated receipt.</p>';
            receiptHTML += '</div>';
            
            receiptHTML += '</body></html>';

            // Write receipt to new window
            printWindow.document.write(receiptHTML);
            printWindow.document.close();

            // Wait for content to load, then print
            setTimeout(() => {
                printWindow.print();
            }, 250);
        }
    </script>
</body>

</html>
