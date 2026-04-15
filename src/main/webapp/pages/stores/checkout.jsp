<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.dailyfixer.model.CartItem" %>
<%@ page import="com.dailyfixer.dao.ProductDAO" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.util.ProductDisplayUtil" %>

<% 
    // Check if user is logged in
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        // Store the intended destination for redirect after login
        String redirectUrl = request.getRequestURL().toString();
        if (request.getQueryString() != null) {
            redirectUrl += "?" + request.getQueryString();
        }
        session.setAttribute("redirectAfterLogin", redirectUrl);
        response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
        return;
    }
    
    // Session "itemsToCheckout" can be stale (e.g. Buy Now qty 1) while cart has updated quantities.
    // fromCart=1: always re-copy current cart. Buy-now query params: build that line item and replace session.
@SuppressWarnings("unchecked")
Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
@SuppressWarnings("unchecked")
Map<String, CartItem> itemsToCheckout = (Map<String, CartItem>) session.getAttribute("itemsToCheckout");

String fromCartParam = request.getParameter("fromCart");
String productIdParam = request.getParameter("productId");
String quantityParam = request.getParameter("quantity");
String variantIdParam = request.getParameter("variantId");

boolean syncFromCart = "1".equals(fromCartParam) || "true".equalsIgnoreCase(fromCartParam != null ? fromCartParam : "");
boolean buyNowRequest = productIdParam != null && quantityParam != null && !productIdParam.trim().isEmpty();

if (syncFromCart) {
    itemsToCheckout = new HashMap<>();
    if (cart != null && !cart.isEmpty()) {
        itemsToCheckout.putAll(cart);
    }
} else if (buyNowRequest) {
    itemsToCheckout = new HashMap<>();
    try {
        int productId = Integer.parseInt(productIdParam.trim());
        int quantity = Integer.parseInt(quantityParam.trim());
        Integer variantId = null;
        if (variantIdParam != null && !variantIdParam.isBlank()) {
            variantId = Integer.parseInt(variantIdParam.trim());
        }

        ProductDAO dao = new ProductDAO();
        Product product = dao.getProductById(productId);
        if (product != null) {
            double price = product.getPrice();
            double originalPrice = product.getPrice();
            String variantColor = null;
            String variantSize = null;
            String variantPower = null;
            ProductVariant buyNowVariant = null;

            if (variantId != null) {
                try {
                    ProductVariantDAO variantDAO = new ProductVariantDAO();
                    buyNowVariant = variantDAO.getVariantById(variantId);
                    if (buyNowVariant != null && buyNowVariant.getProductId() == productId) {
                        price = buyNowVariant.getPrice().doubleValue();
                        originalPrice = price;
                        variantColor = buyNowVariant.getColor();
                        variantSize = buyNowVariant.getSize();
                        variantPower = buyNowVariant.getPower();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            String buyNowImagePath = ProductDisplayUtil.resolveCartThumbnailPath(product, buyNowVariant);

            double discountAmount = 0;
            String discountName = null;
            String discountType = null;
            double discountedPrice = price;

            try {
                DiscountDAO discountDAO = new DiscountDAO();
                Discount discount = null;

                if (variantId != null) {
                    discount = discountDAO.getActiveDiscountForVariant(variantId);
                    if (discount == null || !discount.isValid()) {
                        discount = discountDAO.getActiveDiscountForProduct(productId);
                    }
                } else {
                    discount = discountDAO.getActiveDiscountForProduct(productId);
                }

                if (discount != null && discount.isValid()) {
                    originalPrice = price;
                    discountedPrice = discount.calculateDiscountedPrice(price);
                    discountAmount = originalPrice - discountedPrice;
                    discountName = discount.getDiscountName();
                    discountType = discount.getDiscountType();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            CartItem item = new CartItem(
                product.getProductId(),
                product.getName(),
                discountedPrice,
                originalPrice,
                quantity,
                buyNowImagePath,
                variantId,
                variantColor,
                variantSize,
                variantPower,
                discountAmount,
                discountName,
                discountType
            );
            item.setStoreUsername(product.getStoreUsername());
            item.setStoreId(product.getStoreId());
            String cartKey = variantId != null ? "V-" + variantId : "P-" + productId;
            itemsToCheckout.put(cartKey, item);
        }
    } catch (NumberFormatException nfe) {
        nfe.printStackTrace();
    }
} else if (itemsToCheckout == null || itemsToCheckout.isEmpty()) {
    itemsToCheckout = new HashMap<>();
    if (cart != null && !cart.isEmpty()) {
        itemsToCheckout.putAll(cart);
    }
}

if (itemsToCheckout == null) {
    itemsToCheckout = new HashMap<>();
}

// If no items, show message and return
if (itemsToCheckout == null || itemsToCheckout.isEmpty()) {
    String error = request.getParameter("error");
    String errorMessage = "";
    if ("empty_cart".equals(error)) {
        errorMessage = "Your cart is empty. Please add products to cart first.";
    } else if ("missing_fields".equals(error)) {
        errorMessage = "Please fill all required fields.";
    } else if ("location_required".equals(error)) {
        errorMessage = "Set your location before checkout. Purchases are only allowed within 10km.";
    } else if ("outside_purchase_radius".equals(error)) {
        errorMessage = "One or more selected stores are outside your 10km purchase radius.";
    } else if ("store_location_unavailable".equals(error)) {
        errorMessage = "A store in your checkout does not have location data configured.";
    } else if ("database_error".equals(error)) {
        errorMessage = "Database error occurred. Please try again.";
    } else if ("server_error".equals(error)) {
        errorMessage = "Server error occurred. Please try again.";
    } else {
        errorMessage = "No products to checkout.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Checkout - Daily Fixer</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        .error-message { color: var(--destructive, #e74c3c); margin: 20px 0; }
        a { color: var(--primary, #3498db); text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h2>Checkout Error</h2>
    <p class="error-message"><%= errorMessage %></p>
    <a href="store_main.jsp">Back to Store</a>
</body>
</html>
<% 
    return; 
} 

// Store cart items in session for post-payment order
session.setAttribute("itemsToCheckout", itemsToCheckout); 
double total = 0; // Initialize total for order
double purchaseLimit = 10000.0;
double payableItemsTotal = 0;
boolean itemPriceLimitExceeded = false;

for (CartItem item : itemsToCheckout.values()) {
    double lineTotal = item.getPrice() * item.getQuantity();
    payableItemsTotal += lineTotal;
    if (lineTotal > purchaseLimit) {
        itemPriceLimitExceeded = true;
    }
}

boolean orderPriceLimitExceeded = payableItemsTotal > purchaseLimit;
boolean checkoutBlockedByPriceLimit = itemPriceLimitExceeded || orderPriceLimitExceeded;

// Get form data from session for repopulation (if redirected back with error)
String checkoutName = (String) session.getAttribute("checkout_name");
String checkoutPhone = (String) session.getAttribute("checkout_phone");
String checkoutEmail = (String) session.getAttribute("checkout_email");
String checkoutAddress = (String) session.getAttribute("checkout_address");
String checkoutCity = (String) session.getAttribute("checkout_city");
String checkoutProvince = (String) session.getAttribute("checkout_province");
String checkoutDistrict = (String) session.getAttribute("checkout_district");
Boolean checkoutDoorstepConsent = (Boolean) session.getAttribute("checkout_doorstep_consent");

// Clear session attributes after retrieving (so they don't persist)
if (checkoutName != null) session.removeAttribute("checkout_name");
if (checkoutPhone != null) session.removeAttribute("checkout_phone");
if (checkoutEmail != null) session.removeAttribute("checkout_email");
if (checkoutAddress != null) session.removeAttribute("checkout_address");
if (checkoutCity != null) session.removeAttribute("checkout_city");
if (checkoutProvince != null) session.removeAttribute("checkout_province");
if (checkoutDistrict != null) session.removeAttribute("checkout_district");
if (checkoutDoorstepConsent != null) session.removeAttribute("checkout_doorstep_consent");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - Daily Fixer</title>
    <!-- framework.css, fonts, and icons are loaded by header.jsp -->
    <style>
        /* ===== CHECKOUT CONTAINER ===== */
        .checkout-container {
            display: flex;
            gap: 30px;
            max-width: 1200px;
            margin: auto;
            flex-wrap: wrap;
            padding: 40px;
            margin-top: 100px;
        }

        .shipping, .order-summary {
            background: var(--card);
            padding: 20px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border);
        }

        .shipping { flex: 3; min-width: 400px; }
        .order-summary { flex: 1; min-width: 250px; position: sticky; top: 100px; }

        .checkout-title {
            margin-bottom: 15px;
            color: var(--primary);
            text-align: center;
        }

        .address-row {
            display: flex;
            gap: 15px;
        }

        .address-row > div { flex: 1; }

        /* ===== ORDER SUMMARY ===== */
        .order-summary-title {
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--primary);
            color: var(--primary);
            font-size: 1.3rem;
            text-align: center;
        }

        .checkout-item {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
            background: var(--secondary);
            padding: 10px;
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            border: 1px solid var(--border);
        }

        .checkout-item:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .checkout-item img {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
        }

        .item-details p {
            margin-bottom: 5px;
            font-size: 0.95rem;
        }

        .totals {
            margin-top: 15px;
            padding-top: 10px;
            border-top: 2px solid var(--primary);
        }

        .totals div {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 1rem;
        }

        .totals .total {
            font-weight: bold;
            font-size: 1.15rem;
            color: var(--primary);
        }
    </style>
</head>

<body>

    <jsp:include page="/pages/shared/header.jsp"/>

    <!-- Entire form wraps shipping + order summary -->
    <form method="post" action="${pageContext.request.contextPath}/redirectToPayment">

        <div class="checkout-container">
            <!-- Left: Shipping Details -->
            <div class="shipping">
                <h2 class="checkout-title">Shipping Details</h2>
                <% String error = request.getParameter("error"); 
                   if (error != null) { %>
                    <div class="alert alert-error">
                        <% if ("missing_fields".equals(error)) { %>
                            Please fill all required fields.
                        <% } else if ("empty_cart".equals(error)) { %>
                            Your cart is empty. Please add products to cart first.
                        <% } else if ("database_error".equals(error)) { %>
                            Database error occurred. Please try again. If the problem persists, contact support.
                        <% } else if ("server_error".equals(error)) { %>
                            Server error occurred. Please try again.
                        <% } else if ("invalid_email".equals(error)) { %>
                            Please enter a valid email address.
                        <% } else if ("terms_not_accepted".equals(error)) { %>
                            You must accept the one-attempt delivery policy to place this order.
                        <% } else if ("item_price_limit_exceeded".equals(error)) { %>
                            One or more items exceed the Rs 10,000 purchase limit.
                        <% } else if ("order_price_limit_exceeded".equals(error)) { %>
                            Your item subtotal exceeds the Rs 10,000 purchase limit.
                        <% } else if ("location_required".equals(error)) { %>
                            Set your location before checkout. Purchases are only allowed within 10km.
                        <% } else if ("outside_purchase_radius".equals(error)) { %>
                            One or more selected stores are outside your 10km purchase radius.
                        <% } else if ("store_location_unavailable".equals(error)) { %>
                            A store in your checkout does not have location data configured.
                        <% } else { %>
                            An error occurred. Please try again.
                        <% } %>
                    </div>
                <% } %>
                <% if (checkoutBlockedByPriceLimit) { %>
                    <div class="alert" style="background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba;">
                        <% if (itemPriceLimitExceeded) { %>
                            One or more items exceed the Rs 10,000 purchase limit.
                        <% } else { %>
                            Your item subtotal exceeds the Rs 10,000 purchase limit.
                        <% } %>
                    </div>
                <% } %>
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="name" value="<%= checkoutName != null ? checkoutName : "" %>" required>
                </div>

                <div class="form-group">
                    <label>Phone</label>
                    <input type="text" name="phone" value="<%= checkoutPhone != null ? checkoutPhone : "" %>" required>
                </div>

                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" value="<%= (String) session.getAttribute("checkout_email") != null ? (String) session.getAttribute("checkout_email") : "" %>" required>
                </div>

                <!-- Location selection: type address or pick on map -->
                <div class="form-group">
                    <label>Delivery Location</label>
                    <input type="text" id="map-search-input" placeholder="Type your location or select on map">

                    <!-- Map where user can click to set location -->
                    <div id="checkout-map" style="width: 100%; height: 260px; margin: 10px 0; border-radius: var(--radius-md); overflow: hidden; border: 1px solid var(--border);"></div>

                    <p style="font-size: 12px; color: var(--muted-foreground); margin-top: 4px;">
                        You can <strong>type your address</strong> to search, or <strong>click on the map</strong> to set your exact location.
                    </p>
                </div>

                <!-- Hidden fields to submit coordinates with the order -->
                <input type="hidden" id="latitude" name="latitude">
                <input type="hidden" id="longitude" name="longitude">

                <div class="form-group">
                    <label>Address</label>
                    <input type="text" id="address-input" name="address" value="<%= checkoutAddress != null ? checkoutAddress : "" %>" required>
                </div>

                <div class="address-row">
                    <div class="form-group">
                        <label>Province</label>
                        <select name="province" required>
                            <option value="">Select Province</option>
                            <option value="Western" <%= "Western".equals(checkoutProvince) ? "selected" : "" %>>Western</option>
                            <option value="Central" <%= "Central".equals(checkoutProvince) ? "selected" : "" %>>Central</option>
                            <option value="Southern" <%= "Southern".equals(checkoutProvince) ? "selected" : "" %>>Southern</option>
                            <option value="Eastern" <%= "Eastern".equals(checkoutProvince) ? "selected" : "" %>>Eastern</option>
                            <option value="Northern" <%= "Northern".equals(checkoutProvince) ? "selected" : "" %>>Northern</option>
                            <option value="North-Western" <%= "North-Western".equals(checkoutProvince) ? "selected" : "" %>>North-Western</option>
                            <option value="North-Central" <%= "North-Central".equals(checkoutProvince) ? "selected" : "" %>>North-Central</option>
                            <option value="Sabaragamuwa" <%= "Sabaragamuwa".equals(checkoutProvince) ? "selected" : "" %>>Sabaragamuwa</option>
                            <option value="Uva" <%= "Uva".equals(checkoutProvince) ? "selected" : "" %>>Uva</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>District</label>
                        <select name="district" required>
                            <option value="">Select District</option>
                            <option value="Colombo" <%= "Colombo".equals(checkoutDistrict) ? "selected" : "" %>>Colombo</option>
                            <option value="Gampaha" <%= "Gampaha".equals(checkoutDistrict) ? "selected" : "" %>>Gampaha</option>
                            <option value="Kalutara" <%= "Kalutara".equals(checkoutDistrict) ? "selected" : "" %>>Kalutara</option>
                            <option value="Kandy" <%= "Kandy".equals(checkoutDistrict) ? "selected" : "" %>>Kandy</option>
                            <option value="Matale" <%= "Matale".equals(checkoutDistrict) ? "selected" : "" %>>Matale</option>
                            <option value="Nuwara Eliya" <%= "Nuwara Eliya".equals(checkoutProvince) ? "selected" : "" %>>Nuwara Eliya</option>
                            <option value="Galle" <%= "Galle".equals(checkoutDistrict) ? "selected" : "" %>>Galle</option>
                            <option value="Matara" <%= "Matara".equals(checkoutDistrict) ? "selected" : "" %>>Matara</option>
                            <option value="Hambantota" <%= "Hambantota".equals(checkoutDistrict) ? "selected" : "" %>>Hambantota</option>
                            <option value="Jaffna" <%= "Jaffna".equals(checkoutDistrict) ? "selected" : "" %>>Jaffna</option>
                            <option value="Kilinochchi" <%= "Kilinochchi".equals(checkoutDistrict) ? "selected" : "" %>>Kilinochchi</option>
                            <option value="Mannar" <%= "Mannar".equals(checkoutDistrict) ? "selected" : "" %>>Mannar</option>
                            <option value="Mullaitivu" <%= "Mullaitivu".equals(checkoutDistrict) ? "selected" : "" %>>Mullaitivu</option>
                            <option value="Vavuniya" <%= "Vavuniya".equals(checkoutDistrict) ? "selected" : "" %>>Vavuniya</option>
                            <option value="Trincomalee" <%= "Trincomalee".equals(checkoutDistrict) ? "selected" : "" %>>Trincomalee</option>
                            <option value="Batticaloa" <%= "Batticaloa".equals(checkoutDistrict) ? "selected" : "" %>>Batticaloa</option>
                            <option value="Ampara" <%= "Ampara".equals(checkoutDistrict) ? "selected" : "" %>>Ampara</option>
                            <option value="Kurunegala" <%= "Kurunegala".equals(checkoutDistrict) ? "selected" : "" %>>Kurunegala</option>
                            <option value="Puttalam" <%= "Puttalam".equals(checkoutDistrict) ? "selected" : "" %>>Puttalam</option>
                            <option value="Anuradhapura" <%= "Anuradhapura".equals(checkoutDistrict) ? "selected" : "" %>>Anuradhapura</option>
                            <option value="Polonnaruwa" <%= "Polonnaruwa".equals(checkoutDistrict) ? "selected" : "" %>>Polonnaruwa</option>
                            <option value="Badulla" <%= "Badulla".equals(checkoutDistrict) ? "selected" : "" %>>Badulla</option>
                            <option value="Monaragala" <%= "Monaragala".equals(checkoutDistrict) ? "selected" : "" %>>Monaragala</option>
                            <option value="Ratnapura" <%= "Ratnapura".equals(checkoutDistrict) ? "selected" : "" %>>Ratnapura</option>
                            <option value="Kegalle" <%= "Kegalle".equals(checkoutDistrict) ? "selected" : "" %>>Kegalle</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>City</label>
                        <input type="text" name="city" value="<%= checkoutCity != null ? checkoutCity : "" %>" required>
                    </div>
                </div>

                <div style="margin-top: 16px; padding: 12px; border: 1px solid var(--border); border-radius: var(--radius-md); background: var(--muted);">
                    <label style="display: flex; align-items: flex-start; gap: 10px; font-size: 0.9em; color: var(--foreground); line-height: 1.45;">
                        <input type="checkbox" name="doorstepDropConsent" required
                               <%= (checkoutDoorstepConsent != null && checkoutDoorstepConsent) ? "checked" : "" %>
                               style="margin-top: 3px;">
                        <span>
                            I understand this order has <strong>one delivery attempt only</strong>. If I am unreachable,
                            the driver may complete delivery by leaving the package at my door with two proof photos.
                            After completion, responsibility transfers to me.
                        </span>
                    </label>
                </div>
            </div>

            <!-- Right: Order Summary -->
            <div class="order-summary">
                <h2 class="order-summary-title">Order Summary</h2>

                <% 
                double totalDiscount = 0; 
                for (CartItem item : itemsToCheckout.values()) { 
                    double itemSubtotal = item.getQuantity() * item.getPrice(); 
                    double itemOriginalSubtotal = item.getQuantity() * item.getOriginalPrice(); 
                    if (item.getDiscountAmount() > 0) {
                        totalDiscount += item.getTotalDiscount();
                    }
                    total += itemOriginalSubtotal;
                %>
                    <div class="checkout-item">
                        <% String ciImg = item.getImagePath(); %>
                        <img src="<%=ciImg != null && !ciImg.isEmpty() ? request.getContextPath() + "/" + ciImg : request.getContextPath() + "/assets/images/tools.png"%>" alt="<%=item.getName()%>" width="100">
                        <div class="item-details">
                            <p><strong><%=item.getName()%></strong></p>
                            <% if (item.getVariantId() != null) { %>
                                <p style="font-size: 0.9em; color: var(--muted-foreground);">
                                    <% if (item.getVariantColor() != null && !item.getVariantColor().isEmpty()) { %>
                                        Color: <%=item.getVariantColor()%>
                                    <% } %>
                                    <% if (item.getVariantSize() != null && !item.getVariantSize().isEmpty()) { %>
                                        <% if (item.getVariantColor() != null && !item.getVariantColor().isEmpty()) { %> | <% } %>
                                        Size: <%=item.getVariantSize()%>
                                    <% } %>
                                    <% if (item.getVariantPower() != null && !item.getVariantPower().isEmpty()) { %>
                                        <% if ((item.getVariantColor() != null && !item.getVariantColor().isEmpty()) || 
                                              (item.getVariantSize() != null && !item.getVariantSize().isEmpty())) { %> | <% } %>
                                        Power: <%=item.getVariantPower()%>
                                    <% } %>
                                </p>
                            <% } %>
                            <p>Qty: <%=item.getQuantity()%></p>
                            <p>
                                <% if (item.getOriginalPrice() > item.getPrice() && item.getDiscountAmount() > 0) { %>
                                    <span style="text-decoration: line-through; color: var(--muted-foreground); margin-right: 10px;">
                                        Price: Rs <%=String.format("%.2f", item.getOriginalPrice())%>
                                    </span>
                                    <span style="color: var(--chart-1); font-weight: 600;">
                                        Price: Rs <%=String.format("%.2f", item.getPrice())%>
                                    </span>
                                <% } else { %>
                                    Price: Rs <%=String.format("%.2f", item.getPrice())%>
                                <% } %>
                            </p>
                            <p>
                                Subtotal: Rs <%=String.format("%.2f", itemSubtotal)%>
                                <% if (item.getDiscountAmount() > 0) { %>
                                    <br><span style="color: var(--chart-1); font-size: 0.9em;">
                                        Discount: -Rs <%=String.format("%.2f", item.getTotalDiscount())%>
                                        <% if (item.getDiscountName() != null) { %>
                                            (<%=item.getDiscountName()%>)
                                        <% } %>
                                    </span>
                                <% } %>
                            </p>
                        </div>
                    </div>
                <% } %>

                <div class="totals">
                    <div>Subtotal <span>Rs <%=String.format("%.2f", total)%></span></div>
                    <div<%= totalDiscount > 0 ? " style=\"color: var(--chart-1);\"" : "" %>>
                        Discount
                        <span<%= totalDiscount > 0 ? " style=\"color: var(--chart-1);\"" : "" %>>
                            <% if (totalDiscount > 0) { %>-<% } %>Rs <%=String.format("%.2f", totalDiscount)%>
                        </span>
                    </div>
                    <div id="delivery-fee-row">Delivery <span id="delivery-total">Rs 0.00</span></div>
                    <div id="delivery-breakdown" style="display:none; font-size:0.82em; color:var(--muted-foreground); flex-direction:column; gap:2px; padding:0; margin-top:-6px;"></div>
                    <div class="total">Total <span id="grand-total">Rs <%=String.format("%.2f", total - totalDiscount)%></span></div>
                </div>

                <!-- Place Order button -->
                <button type="submit" class="btn-primary" style="width: 100%; margin-top: 20px;" <%= checkoutBlockedByPriceLimit ? "disabled title=\"Orders above Rs 10,000 are view only\"" : "" %>>Place Order</button>
            </div>
        </div>
    </form>

    <!-- Google Maps for checkout location selection -->
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&libraries=places&callback=initCheckoutMap" async defer></script>

    <script>
        let checkoutMap;
        let checkoutMarker;
        let checkoutGeocoder;
        let checkoutAutocomplete;
        let selectedLat = null;
        let selectedLng = null;

        function initCheckoutMap() {
            const mapDiv = document.getElementById('checkout-map');
            if (!mapDiv) return;

            const sriLanka = { lat: 7.8731, lng: 80.7718 };

            checkoutMap = new google.maps.Map(mapDiv, {
                center: sriLanka,
                zoom: 8,
                mapTypeControl: false,
                streetViewControl: false,
                fullscreenControl: true
            });

            checkoutGeocoder = new google.maps.Geocoder();

            checkoutMarker = new google.maps.Marker({
                map: checkoutMap,
                draggable: true,
                visible: false,
                animation: google.maps.Animation.DROP
            });

            checkoutMap.addListener('click', (e) => {
                setCheckoutLocation(e.latLng.lat(), e.latLng.lng());
                reverseGeocodeCheckout(e.latLng);
            });

            checkoutMarker.addListener('dragend', (e) => {
                setCheckoutLocation(e.latLng.lat(), e.latLng.lng());
                reverseGeocodeCheckout(e.latLng);
            });

            const searchInput = document.getElementById('map-search-input');
            if (searchInput) {
                checkoutAutocomplete = new google.maps.places.Autocomplete(searchInput, {
                    componentRestrictions: { country: 'lk' },
                    fields: ['geometry', 'formatted_address', 'name']
                });

                checkoutAutocomplete.addListener('place_changed', () => {
                    const place = checkoutAutocomplete.getPlace();
                    if (place.geometry && place.geometry.location) {
                        const lat = place.geometry.location.lat();
                        const lng = place.geometry.location.lng();
                        setCheckoutLocation(lat, lng);
                        checkoutMap.setCenter(place.geometry.location);
                        checkoutMap.setZoom(15);

                        const addressInput = document.getElementById('address-input');
                        if (addressInput) {
                            addressInput.value = place.formatted_address || place.name || addressInput.value;
                        }
                    } else {
                        alert('Please select a valid location from the suggestions.');
                    }
                });
            }
        }

        const itemsSubtotal = <%=total - totalDiscount%>;

        function setCheckoutLocation(lat, lng) {
            selectedLat = lat;
            selectedLng = lng;

            const latInput = document.getElementById('latitude');
            const lngInput = document.getElementById('longitude');
            if (latInput) latInput.value = lat;
            if (lngInput) lngInput.value = lng;

            const pos = new google.maps.LatLng(lat, lng);
            checkoutMarker.setPosition(pos);
            checkoutMarker.setVisible(true);

            fetchDeliveryFees(lat, lng);
        }

        function fetchDeliveryFees(lat, lng) {
            const deliveryTotal = document.getElementById('delivery-total');
            const breakdown = document.getElementById('delivery-breakdown');
            if (deliveryTotal) deliveryTotal.textContent = 'Calculating...';

            fetch('<%=request.getContextPath()%>/calculateDeliveryFee?customerLat=' + lat + '&customerLng=' + lng)
                .then(r => {
                    if (!r.ok) {
                        console.error('Delivery fee endpoint returned', r.status, r.statusText);
                        throw new Error('HTTP ' + r.status);
                    }
                    return r.json();
                })
                .then(data => {
                    // Handle error object returned by servlet
                    if (data && data.error) {
                        console.error('Delivery fee error:', data.error);
                        if (deliveryTotal) deliveryTotal.textContent = 'Rs 0.00';
                        return;
                    }
                    const stores = Array.isArray(data) ? data : [];
                    let total = 0;
                    breakdown.innerHTML = '';

                    if (stores.length > 1) {
                        stores.forEach(s => {
                            total += s.deliveryFee;
                            const row = document.createElement('div');
                            row.style.cssText = 'display:flex;justify-content:space-between;padding:2px 0;';
                            row.innerHTML = '<span style="padding-left:10px;">↳ ' + (s.storeName || s.storeUsername) + ' (' + s.distanceKm.toFixed(1) + ' km)</span>'
                                          + '<span>Rs ' + s.deliveryFee.toFixed(2) + '</span>';
                            breakdown.appendChild(row);
                        });
                        breakdown.style.display = 'flex';
                    } else if (stores.length === 1) {
                        total = stores[0].deliveryFee;
                        breakdown.style.display = 'none';
                    } else {
                        console.warn('No stores found in cart for delivery fee calculation.');
                    }

                    if (deliveryTotal) deliveryTotal.textContent = 'Rs ' + total.toFixed(2);
                    const grandTotal = document.getElementById('grand-total');
                    if (grandTotal) grandTotal.textContent = 'Rs ' + (itemsSubtotal + total).toFixed(2);
                })
                .catch(err => {
                    console.error('fetchDeliveryFees failed:', err);
                    if (deliveryTotal) deliveryTotal.textContent = 'Rs 0.00';
                });
        }

        function reverseGeocodeCheckout(latLng) {
            if (!checkoutGeocoder) return;
            checkoutGeocoder.geocode({ location: latLng }, (results, status) => {
                if (status === 'OK' && results[0]) {
                    const addressInput = document.getElementById('address-input');
                    if (addressInput) {
                        addressInput.value = results[0].formatted_address;
                    }
                }
            });
        }

        document.querySelector('form[action*="redirectToPayment"]')
            .addEventListener('submit', function(e) {
                if (!selectedLat || !selectedLng) {
                    e.preventDefault();
                    alert('Please select your delivery location on the map before placing your order.');
                    document.getElementById('map-search-input').focus();
                }
            });
    </script>

</body>

</html>
