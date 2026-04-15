<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.model.Store" %>
<%@ page import="com.dailyfixer.util.ProductDisplayUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.LinkedHashSet" %>

<%!
    // Helper method to convert color name to hex code
    private String getColorCode(String colorName) {
        if (colorName == null) return "#cccccc";
        String color = colorName.toLowerCase().trim();
        switch (color) {
            case "red": return "#ff0000";
            case "blue": return "#0000ff";
            case "green": return "#00ff00";
            case "yellow": return "#ffff00";
            case "black": return "#000000";
            case "white": return "#ffffff";
            case "gray": case "grey": return "#808080";
            case "orange": return "#ffa500";
            case "purple": return "#800080";
            case "pink": return "#ffc0cb";
            case "brown": return "#a52a2a";
            case "navy": return "#000080";
            case "teal": return "#008080";
            case "cyan": return "#00ffff";
            case "magenta": return "#ff00ff";
            case "lime": return "#00ff00";
            case "maroon": return "#800000";
            case "olive": return "#808000";
            case "silver": return "#c0c0c0";
            case "gold": return "#ffd700";
            default: 
                // Try to parse as hex color if it starts with #
                if (color.startsWith("#") && color.length() == 7) {
                    return color;
                }
                // Default gray for unknown colors
                return "#cccccc";
        }
    }
%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = Boolean.TRUE.equals(request.getAttribute("isLoggedIn")) || currentUser != null;

    Product product = (Product) request.getAttribute("product");
    List<ProductVariant> variants = (List<ProductVariant>) request.getAttribute("variants");
    boolean hasVariants = Boolean.TRUE.equals(request.getAttribute("hasVariants"));
    boolean outOfStock = Boolean.TRUE.equals(request.getAttribute("outOfStock"));
    Set<String> colors = (Set<String>) request.getAttribute("colors");
    Set<String> sizes = (Set<String>) request.getAttribute("sizes");
    Set<String> powers = (Set<String>) request.getAttribute("powers");
    Discount activeDiscount = (Discount) request.getAttribute("activeDiscount");
    Number displayPriceNum = (Number) request.getAttribute("displayPrice");
    Number originalPriceNum = (Number) request.getAttribute("originalPrice");
    double displayPrice = displayPriceNum != null ? displayPriceNum.doubleValue() : 0.0;
    double originalPrice = originalPriceNum != null ? originalPriceNum.doubleValue() : 0.0;
    String loginUrl = (String) request.getAttribute("loginUrl");
    boolean canPurchase = Boolean.TRUE.equals(request.getAttribute("canPurchase"));
    String purchaseLockMessage = (String) request.getAttribute("purchaseLockMessage");
    Number currentCartTotalNum = (Number) request.getAttribute("currentCartTotal");
    Number purchaseLimitNum = (Number) request.getAttribute("purchaseLimit");
    String variantDataJson = (String) request.getAttribute("variantDataJson");
    String baseDiscountJson = (String) request.getAttribute("baseDiscountJson");
    double currentCartTotal = currentCartTotalNum != null ? currentCartTotalNum.doubleValue() : 0.0;
    double purchaseLimit = purchaseLimitNum != null ? purchaseLimitNum.doubleValue() : 10000.0;
    Store store = (Store) request.getAttribute("store");
    String storePhone = (String) request.getAttribute("storePhone");

    if (variants == null) variants = java.util.Collections.emptyList();
    if (colors == null) colors = new LinkedHashSet<>();
    if (sizes == null) sizes = new LinkedHashSet<>();
    if (powers == null) powers = new LinkedHashSet<>();
    if (variantDataJson == null || variantDataJson.isEmpty()) variantDataJson = "[]";
    if (baseDiscountJson == null || baseDiscountJson.isEmpty()) baseDiscountJson = "null";

    if (loginUrl == null) {
        loginUrl = request.getContextPath() + "/pages/authentication/login.jsp";
    }

    if (product == null) {
        String productIdParam = request.getParameter("productId");
        if (productIdParam != null && !productIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/product_details?productId=" + productIdParam);
            return;
        }
%>
<p>Product not found</p>
<a href="store_main.jsp">Back</a>
<%
        return;
    }
%>



<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title><%= product.getName() %> | Daily Fixer Store</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/product_details.css" />
</head>
<body>

<jsp:include page="/pages/shared/header.jsp"/>

<div class="page-container">
    <a href="javascript:history.back()" class="back-link">
        <i class="ph ph-arrow-left"></i> Back to Products
    </a>

    <!-- ===== PRODUCT HERO ===== -->
    <div class="product-layout">

        <!-- Left: Image Gallery -->
        <div class="image-gallery">
            <div class="main-image">
                <% String pdImg = product.getImagePath();
                   String mainDisplayRel = ProductDisplayUtil.getDisplayImagePath(product, variants);
                   boolean hasMainProductUpload = (pdImg != null && !pdImg.isEmpty());
                %>
                <img id="mainProductImage"
                     src="<%= mainDisplayRel != null && !mainDisplayRel.isEmpty() ? request.getContextPath() + "/" + mainDisplayRel : request.getContextPath() + "/assets/images/tools.png" %>"
                     alt="<%= product.getName() %>"
                     style="transition: opacity 0.15s ease;">
            </div>

            <!-- Thumbnail Strip -->
            <%
                boolean hasGalleryImages = (mainDisplayRel != null && !mainDisplayRel.isEmpty());
            %>
            <% if (hasGalleryImages) { %>
            <div class="thumbnail-strip">
                <% if (hasMainProductUpload) { %>
                <div class="thumbnail-item active"
                     data-src="<%= request.getContextPath() + "/" + pdImg %>">
                    <img src="<%= request.getContextPath() + "/" + pdImg %>" alt="Main">
                </div>
                <% } %>
                <% boolean markFirstVariantActive = !hasMainProductUpload;
                   for (ProductVariant pv : variants) {
                       if (pv.getImagePath() == null || pv.getImagePath().isEmpty()) continue;
                       boolean isActive = markFirstVariantActive;
                       markFirstVariantActive = false;
                %>
                    <div class="thumbnail-item<%= isActive ? " active" : "" %>"
                         data-src="<%= request.getContextPath() + "/" + pv.getImagePath() %>"
                         data-variant-id="<%= pv.getVariantId() %>"
                         title="<% if (pv.getColor() != null && !pv.getColor().isEmpty()) { %><%= pv.getColor() %><% } %><% if (pv.getSize() != null && !pv.getSize().isEmpty()) { %> <%= pv.getSize() %><% } %><% if (pv.getPower() != null && !pv.getPower().isEmpty()) { %> <%= pv.getPower() %><% } %>">
                        <img src="<%= request.getContextPath() + "/" + pv.getImagePath() %>" alt="Variant">
                    </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- Right: Product Info -->
        <div class="product-info-panel">

            <div class="badge <%= outOfStock ? "badge-out-stock" : "badge-in-stock" %>" style="display: flex; gap: 5px; align-items: center;">
                <% if (outOfStock) { %>
                    <i class="ph ph-x-circle"></i>
                <% } else { %>
                    <i class="ph ph-check-circle"></i>
                <% } %>
                <span id="stockStatus">
                    <%= outOfStock ? "Out of Stock" : "In Stock" + (hasVariants ? "" : ": " + product.getQuantity()) %>
                </span>
            </div>

            <h1 class="product-title"><%= product.getName() %></h1>

            <div class="price-container">
                <div class="current-price">
                    Rs <span id="priceValue"><%= String.format("%.2f", displayPrice) %></span>
                </div>
                <div class="price-details" id="priceDetails" style="<%= (activeDiscount != null && activeDiscount.isValid()) ? "" : "display: none;" %>">
                    <span class="original-price" id="originalPrice">Rs <%= String.format("%.2f", originalPrice) %></span>
                    <span class="discount-badge" id="discountBadge">
                        <% if (activeDiscount != null && activeDiscount.isValid()) { %>
                            <% if ("PERCENTAGE".equalsIgnoreCase(activeDiscount.getDiscountType())) { %>
                                <i class="ph ph-tag"></i> <%= activeDiscount.getDiscountValue() %>% OFF
                            <% } else { %>
                                <i class="ph ph-tag"></i> Rs <%= activeDiscount.getDiscountValue() %> OFF
                            <% } %>
                        <% } %>
                    </span>
                </div>
            </div>

            <!-- Variant Selection -->
            <% if (hasVariants) { %>
            <div class="variant-section">
                <% if (!colors.isEmpty()) { %>
                <div class="variant-option">
                    <span class="variant-label">Color</span>
                    <div class="variant-buttons" id="colorButtons">
                        <% for (String color : colors) { %>
                        <button type="button"
                                class="variant-btn color-btn"
                                data-value="<%= color %>"
                                data-option="color">
                            <span class="color-indicator" style="background-color: <%= getColorCode(color) %>;"></span>
                            <%= color %>
                        </button>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <% if (!sizes.isEmpty()) { %>
                <div class="variant-option">
                    <span class="variant-label">Size</span>
                    <div class="variant-buttons" id="sizeButtons">
                        <% for (String size : sizes) { %>
                        <button type="button"
                                class="variant-btn size-btn"
                                data-value="<%= size %>"
                                data-option="size">
                            <%= size %>
                        </button>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <% if (!powers.isEmpty()) { %>
                <div class="variant-option">
                    <span class="variant-label">Power</span>
                    <div class="variant-buttons" id="powerButtons">
                        <% for (String power : powers) { %>
                        <button type="button"
                                class="variant-btn power-btn"
                                data-value="<%= power %>"
                                data-option="power">
                            <%= power %>
                        </button>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <input type="hidden" id="selectedVariantId" value="">
                <input type="hidden" id="selectedColor" value="">
                <input type="hidden" id="selectedSize" value="">
                <input type="hidden" id="selectedPower" value="">
            </div>
            <div class="variant-stock-line" id="variantStockLine"></div>
            <% } %>

            <!-- Quantity + Buttons -->
            <div class="action-controls">
                <div class="qty-wrapper">
                    <button class="qty-btn" id="minusBtn" <%= outOfStock ? "disabled" : "" %>>
                        <i class="ph ph-minus"></i>
                    </button>
                    <input type="number"
                           id="qty"
                           class="qty-input"
                           value="1"
                           min="1"
                           max="<%= hasVariants ? "" : product.getQuantity() %>"
                        <%= outOfStock ? "disabled" : "" %>>
                    <button class="qty-btn" id="plusBtn" <%= outOfStock ? "disabled" : "" %>>
                        <i class="ph ph-plus"></i>
                    </button>
                </div>

                <div class="buy-actions">
                    <button class="btn-add-cart"
                            id="addBtn"
                            data-product-id="<%= product.getProductId() %>"
                            <%= (!isLoggedIn || outOfStock || !canPurchase) ? "disabled" : "" %>>
                        <i class="ph ph-shopping-cart"></i> Add to Cart
                    </button>
                    <button class="btn-buy-now"
                            id="buyNowBtn"
                            data-product-id="<%= product.getProductId() %>"
                            <%= (!isLoggedIn || outOfStock || !canPurchase) ? "disabled" : "" %>>
                        <i class="ph ph-bag-check"></i> Buy Now
                    </button>
                </div>
            </div>

            <div class="alerts-container">
                <% if (!isLoggedIn) { %>
                    <div class="login-banner">
                        <i class="ph ph-info"></i>
                        <p>Please <a href="<%= loginUrl %>">login</a> to purchase products or write reviews.</p>
                    </div>
                <% } else if (!canPurchase) { %>
                    <div class="login-banner">
                        <i class="ph ph-map-pin"></i>
                        <p><%= (purchaseLockMessage != null && !purchaseLockMessage.isEmpty()) ? purchaseLockMessage : "Set your location to enable purchases." %></p>
                    </div>
                <% } %>
                <div class="login-banner" id="priceLimitBanner" style="display: none;">
                    <i class="ph ph-currency-circle-dollar"></i>
                    <p id="priceLimitMessage"></p>
                </div>
            </div>

        </div>
    </div>

    <!-- ===== INFO GRID: Description + Warranty ===== -->
    <div class="info-grid">

        <!-- Description Card -->
        <div class="info-card">
            <div class="info-card-header">
                <i class="ph ph-text-align-left"></i> Product Description
            </div>
            <div class="description-text"><%= product.getDescription() != null ? product.getDescription() : "" %></div>
        </div>

        <!-- Warranty Card -->
        <div class="info-card">
            <div class="info-card-header">
                <i class="ph ph-shield-check"></i> Warranty Information
            </div>
            <% String warrantyInfo = product.getWarrantyInfo(); %>
            <% if (warrantyInfo != null && !warrantyInfo.trim().isEmpty()) { %>
                <div class="warranty-text"><%= warrantyInfo %></div>
            <% } else { %>
                <div class="warranty-text empty">No warranty information provided.</div>
            <% } %>
            <div class="warranty-disclaimer">
                <i class="ph ph-info"></i>
                <span>Warranty is handled directly between the store and the customer. Daily Fixer is not responsible for warranty claims.</span>
            </div>
        </div>

    </div>

    <!-- ===== STORE ROW: Contact + Map ===== -->
    <% if (store != null) { %>
    <div class="store-row">

        <!-- Store Contact Card -->
        <div class="info-card">
            <div class="info-card-header">
                <i class="ph ph-storefront"></i> Sold by <%= store.getStoreName() %>
            </div>

            <div class="store-contact-row">
                <i class="ph ph-map-pin"></i>
                <div>
                    <span><%= store.getStoreAddress() != null ? store.getStoreAddress() : "Address not available" %></span>
                    <% if (store.getStoreCity() != null && !store.getStoreCity().isEmpty()) { %>
                        <span class="store-contact-text"><%= store.getStoreCity() %></span>
                    <% } %>
                </div>
            </div>

            <% if (storePhone != null && !storePhone.trim().isEmpty()) { %>
            <div class="store-contact-row">
                <i class="ph ph-phone"></i>
                <span><%= storePhone %></span>
            </div>
            <% } %>

            <div class="store-contact-row">
                <i class="ph ph-tag"></i>
                <span><%= store.getStoreType() != null ? store.getStoreType() : "General Store" %></span>
            </div>
        </div>

        <!-- Store Map Card -->
        <div class="info-card">
            <div class="info-card-header">
                <i class="ph ph-map-trifold"></i> Store Location
            </div>
            <%
                boolean hasStoreMapCoords = store.getLatitude() != 0.0 && store.getLongitude() != 0.0;
            %>
            <% if (hasStoreMapCoords) { %>
                <div id="storeMapDiv" class="store-mini-map"></div>
                <a href="https://maps.google.com/maps?daddr=<%= store.getLatitude() %>,<%= store.getLongitude() %>"
                   target="_blank"
                   rel="noopener noreferrer"
                   class="navigate-btn">
                    <i class="ph ph-navigation-arrow"></i> Get Directions
                </a>
            <% } else { %>
                <div class="no-map-placeholder">
                    <i class="ph ph-map-pin-simple-slash"></i>
                    <span>Store location not configured</span>
                </div>
            <% } %>
        </div>

    </div>
    <% } %>

    <!-- ===== REVIEWS SECTION ===== -->
    <div class="reviews-section">
        <h3 class="reviews-header"><i class="ph ph-star-half"></i> Customer Reviews</h3>

        <div class="rating-summary-card">
            <div class="avg-rating-big" id="avgRatingDisplay">0.0</div>
            <div>
                <div class="avg-rating-stars" id="avgStarsDisplay">☆☆☆☆☆</div>
                <div class="review-count-text" id="reviewCountDisplay">0 reviews</div>
            </div>
        </div>

        <div id="reviewsList">
            <h4 style="font-size: 1.2rem; font-weight: 600; margin-bottom: 20px;">All Reviews</h4>
            <div id="reviewsContainer" style="border: 1px solid var(--border); border-radius: var(--radius-lg); overflow: hidden;">
                <p style="text-align: center; padding: 40px; color: var(--muted-foreground);">Loading reviews...</p>
            </div>
        </div>
    </div>
</div>

<script>
    window.PRODUCT_DETAILS_DATA = {
        contextPath: "<%=request.getContextPath()%>",
        productId: <%= product.getProductId() %>,
        hasVariants: <%= hasVariants %>,
        baseStock: <%= product.getQuantity() %>,
        basePrice: <%= originalPrice %>,
        baseDisplayPrice: <%= displayPrice %>,
        isLoggedIn: <%= isLoggedIn %>,
        canPurchase: <%= canPurchase %>,
        currentCartTotal: <%= currentCartTotal %>,
        priceLimit: <%= purchaseLimit %>,
        loginUrl: "<%= loginUrl.replace("\\", "\\\\").replace("\"", "\\\"") %>",
        variants: <%= variantDataJson %>,
        baseDiscount: <%= baseDiscountJson %>
    };
<% if (store != null && store.getLatitude() != 0.0 && store.getLongitude() != 0.0) { %>
    window.STORE_MAP_DATA = {
        lat: <%= store.getLatitude() %>,
        lng: <%= store.getLongitude() %>,
        name: "<%= store.getStoreName() != null ? store.getStoreName().replace("\\", "\\\\").replace("\"", "\\\"") : "" %>"
    };
    function initStoreMap() {
        var d = window.STORE_MAP_DATA;
        if (!d || !window.google) return;
        var pos = { lat: d.lat, lng: d.lng };
        var map = new google.maps.Map(document.getElementById("storeMapDiv"), {
            center: pos,
            zoom: 15,
            disableDefaultUI: true,
            gestureHandling: "none"
        });
        new google.maps.Marker({ position: pos, map: map, title: d.name });
    }
<% } %>
</script>

<% if (store != null && store.getLatitude() != 0.0 && store.getLongitude() != 0.0) { %>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&callback=initStoreMap" async defer></script>
<% } %>
<script src="${pageContext.request.contextPath}/assets/js/product_details.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/product_reviews.js"></script>

</body>
</html>
