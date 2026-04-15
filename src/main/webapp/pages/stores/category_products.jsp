<%@ page import="java.util.List" %>
<%@ page import="com.dailyfixer.model.Product" %>
<%@ page import="com.dailyfixer.model.ProductVariant" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page import="com.dailyfixer.dao.ProductVariantDAO" %>
<%@ page import="com.dailyfixer.dao.DiscountDAO" %>
<%@ page import="com.dailyfixer.model.Discount" %>
<%@ page import="com.dailyfixer.util.ProductDisplayUtil" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<%
    boolean hasLocationFilter = false;
    String sessionLat = null;
    String sessionLng = null;
    List<Product> products = (List<Product>) request.getAttribute("products");
    String categoryName = (String) request.getAttribute("category");
    String searchTerm = (String) request.getAttribute("searchTerm");
    String searchType = (String) request.getAttribute("searchType");
    boolean isSearch = (searchTerm != null && !searchTerm.isEmpty());

    // Set display title based on search or category
    String displayTitle = categoryName;
    if (isSearch && "product".equals(searchType)) {
        displayTitle = "Search Results for \"" + searchTerm + "\"";
    } else if (isSearch && "category".equals(searchType)) {
        displayTitle = categoryName + " (Category)";
    }

    String requestLat = request.getParameter("lat");
    String requestLng = request.getParameter("lng");
    Object sessionLatObj = session.getAttribute("userLat");
    Object sessionLngObj = session.getAttribute("userLng");
    if (sessionLatObj != null && sessionLngObj != null) {
        sessionLat = String.valueOf(sessionLatObj);
        sessionLng = String.valueOf(sessionLngObj);
    }

    // Track whether location is set for purchase-radius checks.
    if (requestLat != null && requestLng != null) {
        hasLocationFilter = true;
    } else if (sessionLat != null && sessionLng != null) {
        hasLocationFilter = true;
    }

    boolean purchaseRadiusFilteredEmpty = Boolean.TRUE.equals(request.getAttribute("purchaseRadiusFilteredEmpty"));
    boolean showNearbyProductsLine = hasLocationFilter && !purchaseRadiusFilteredEmpty
            && products != null && !products.isEmpty();

    String encSearchQ = "";
    if (searchTerm != null && !searchTerm.isEmpty()) {
        encSearchQ = URLEncoder.encode(searchTerm, StandardCharsets.UTF_8);
    }

    // Check if user is logged in
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Fixer - <%= categoryName %></title>
    <!-- Importing Phosphor Icon Library Locally from assets-->
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
    <style>
        .page-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 100px 30px 50px;
        }

        .page-header {
            margin-bottom: 30px;
        }

        .page-header h1 {
            font-size: 2.2rem;
            color: var(--foreground);
            margin-bottom: 10px;
        }

        .page-header p {
            color: var(--muted-foreground);
        }

        /* Search / Filter Section (top) */
        .filters-section {
            background: var(--card);
            padding: 20px;
            border-radius: var(--radius-lg);
            margin-bottom: 30px;
            border: 1px solid var(--border);
        }

        .filters-form {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: flex-end;
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
        }

        .filter-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--foreground);
            font-size: 0.9rem;
        }

        .filter-group input,
        .filter-group select {
            width: 100%;
            padding: 10px 12px;
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            background: var(--input);
            color: var(--foreground);
            font-size: 0.95rem;
        }
        
        .filter-group input:focus,
        .filter-group select:focus {
            outline: none;
            border-color: var(--ring);
        }

        .filter-buttons {
            display: flex;
            gap: 10px;
        }

        /* Two-Column Layout */
        .content-layout {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 30px;
            align-items: start;
        }

        @media (max-width: 900px) {
            .content-layout {
                grid-template-columns: 1fr;
            }
        }

        /* Sidebar Filter Card */
        .sidebar-filter {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 25px;
        }

        .sidebar-filter h3 {
            font-size: 1.2rem;
            color: var(--foreground);
            margin-bottom: 15px;
        }

        .sidebar-filter .filter-item {
            margin-bottom: 25px;
        }
        
        .sidebar-filter label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--foreground);
            font-size: 0.9rem;
        }

        .sidebar-filter input[type="text"],
        .sidebar-filter select {
            width: 100%;
            padding: 10px 12px;
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            background: var(--input);
            color: var(--foreground);
            font-size: 0.95rem;
            margin-bottom: 10px;
        }
        
        .sidebar-filter input[type="text"]:focus,
        .sidebar-filter select:focus {
            outline: none;
            border-color: var(--ring);
        }

        .sidebar-filter .btn-block {
            display: block;
            width: 100%;
            text-align: center;
            margin-bottom: 10px;
        }

        /* Map & Location */
        #location-map {
            width: 100%;
            height: 200px;
            border-radius: var(--radius-md);
            margin-bottom: 10px;
            border: 1px solid var(--border);
        }

        .map-hint {
            font-size: 0.8rem;
            color: var(--muted-foreground);
            margin-bottom: 15px;
            padding: 8px;
            background: var(--secondary);
            border-radius: var(--radius-md);
        }

        .location-status {
            background: var(--muted);
            color: var(--muted-foreground);
            padding: 12px;
            border-radius: var(--radius-md);
            font-size: 0.85rem;
            margin-top: 15px;
            border: 1px solid var(--border);
        }

        .location-status.active {
            background: rgba(var(--primary), 0.1);
            color: var(--primary);
            border-color: var(--primary);
        }

        /* Product Grid Layout */
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
        }

        .product-card {
            background: var(--card);
            border-radius: var(--radius-lg);
            overflow: hidden;
            border: 1px solid var(--border);
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .product-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-xl);
        }

        .product-card-image-wrap {
            position: relative;
            background: var(--muted);
        }

        .product-discount-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 2;
            background: var(--destructive, #dc2626);
            color: var(--destructive-foreground, #fff);
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.02em;
            padding: 5px 9px;
            border-radius: var(--radius-md, 6px);
            line-height: 1.2;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
            max-width: calc(100% - 20px);
            text-align: center;
        }

        .product-card-image {
            width: 100%;
            height: 200px;
            object-fit: contain;
            background: var(--muted);
            padding: 20px;
            display: block;
        }

        .product-card-body {
            padding: 20px;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        .product-card-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--foreground);
            margin-bottom: 8px;
        }

        .product-card-price {
            font-size: 1.05rem;
            color: var(--primary);
            font-weight: 600;
            margin-bottom: 12px;
        }

        .product-price-old {
            text-decoration: line-through;
            color: var(--muted-foreground);
            font-weight: 500;
            font-size: 0.92em;
            margin-right: 8px;
        }

        .product-price-sale {
            color: var(--primary);
            font-weight: 700;
        }

        .product-card-desc {
            color: var(--muted-foreground);
            font-size: 0.85rem;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            flex-grow: 1;
            margin-bottom: 15px;
        }
        
        .no-results {
            grid-column: 1 / -1;
            text-align: center;
            padding: 60px 20px;
            background: var(--card);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            color: var(--muted-foreground);
        }
    </style>
</head>

<body>
<jsp:include page="/pages/shared/header.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1>
            <% if (isSearch) { %>
                <%= displayTitle %>
            <% } else { %>
                <%= categoryName %>
            <% } %>
        </h1>
        <p>Browse products and tools near you</p>
        <% if (showNearbyProductsLine) { %>
        <p style="color: var(--muted-foreground); font-size: 0.95rem; margin-top: 8px;">Showing products from stores within 10 km of your saved map location.</p>
        <% } %>
    </div>

    <!-- Search Top Bar -->
    <div class="filters-section">
        <form class="filters-form" action="${pageContext.request.contextPath}/search" method="get">
            <div class="filter-group">
                <label for="search-input"><i class="ph ph-magnifying-glass"></i> Search Products</label>
                <input id="search-input" type="text" name="q"
                    placeholder="Search for a tool or category..."
                    value="<%= searchTerm != null ? searchTerm : "" %>">
            </div>
            <div class="filter-buttons">
                <button type="submit" class="btn-primary"><i class="ph ph-magnifying-glass"></i> Search</button>
            </div>
        </form>
    </div>

    <!-- Main Content Layout -->
    <div class="content-layout">
        
        <!-- Sidebar Filter Map Panel -->
        <div class="sidebar-filter" data-page-url="<%= request.getRequestURI() %>">
            <input type="hidden" id="nav-is-search" value="<%= isSearch ? "1" : "0" %>">
            <input type="hidden" id="nav-enc-search-q" value="<%= encSearchQ %>">
            <input type="hidden" id="nav-category" value="<c:out value='${requestScope.category}'/>">
            
            <div class="filter-item">
                <h3><i class="ph ph-funnel"></i> Sort Products</h3>
                <select id="sort-products">
                    <option value="default">Default</option>
                    <option value="price-asc">Price: Low to High</option>
                    <option value="price-desc">Price: High to Low</option>
                </select>
            </div>

            <div class="filter-item">
                <h3><i class="ph ph-map-pin"></i> Filter by location</h3>
                <input id="location-input" type="text" placeholder="Search for your address...">
                <div id="location-map"></div>
                <div class="map-hint">Click the map or drag the pin to choose where you are, then press <strong>Save Location</strong> to show only products from stores within 10 km.</div>
                
                <button id="btn-set-location" class="btn-primary btn-block" style="margin-bottom: 8px;">Save Location</button>
                <button id="btn-clear-location" class="btn-danger btn-block"><i class="ph ph-x-circle"></i> Clear Location</button>
                
                <div id="location-status" class="location-status<%= hasLocationFilter ? " active" : "" %>">
                    <% if (hasLocationFilter) { %>
                        <i class="ph ph-check-circle"></i> Location saved. Purchases are enabled for stores within 10km.
                    <% } else { %>
                        No location set. You can browse all products, but purchases are locked.
                    <% } %>
                </div>
            </div>

            <div class="filter-item" style="margin-top: 30px;">
                <button id="btn-clear-filters" class="btn-secondary btn-block"><i class="ph ph-broom"></i> Clear All Filters</button>
            </div>
        </div>

        <!-- Products Grid Panel -->
        <div class="products-panel">
            <div class="product-grid" id="product-grid">
                <% if (products != null && !products.isEmpty()) {
                    DiscountDAO discountDAO = new DiscountDAO();
                    for (Product item : products) {
                        double listPrice = item.getPrice();
                        List<ProductVariant> itemVariants = null;
                        try {
                            ProductVariantDAO variantDAO = new ProductVariantDAO();
                            itemVariants = variantDAO.getVariantsByProductId(item.getProductId());
                            if (item.getPrice() == 0.00 && itemVariants != null && !itemVariants.isEmpty()
                                    && itemVariants.get(0).getPrice() != null) {
                                listPrice = itemVariants.get(0).getPrice().doubleValue();
                            }
                        } catch (Exception e) {
                            // If error getting variants, use main price
                        }

                        Discount activeDiscount = null;
                        try {
                            boolean useFirstVariant = item.getPrice() == 0.00 && itemVariants != null && !itemVariants.isEmpty();
                            if (useFirstVariant) {
                                activeDiscount = discountDAO.getActiveDiscountForVariant(itemVariants.get(0).getVariantId());
                                if (activeDiscount == null || !activeDiscount.isValid()) {
                                    activeDiscount = discountDAO.getActiveDiscountForProduct(item.getProductId());
                                }
                            } else {
                                activeDiscount = discountDAO.getActiveDiscountForProduct(item.getProductId());
                            }
                        } catch (Exception e) {
                            activeDiscount = null;
                        }

                        double originalPrice = listPrice;
                        double finalPrice = listPrice;
                        boolean showDiscount = false;
                        if (activeDiscount != null && activeDiscount.isValid() && originalPrice > 0) {
                            double discounted = activeDiscount.calculateDiscountedPrice(originalPrice);
                            if (discounted + 1e-6 < originalPrice) {
                                finalPrice = discounted;
                                showDiscount = true;
                            }
                        }

                        String discountBadgeText = "";
                        String discountTitle = "";
                        if (showDiscount && activeDiscount != null) {
                            discountTitle = activeDiscount.getDiscountName() != null
                                    ? activeDiscount.getDiscountName().replace("\"", "&quot;") : "";
                            if ("PERCENTAGE".equalsIgnoreCase(activeDiscount.getDiscountType())) {
                                double pct = activeDiscount.getDiscountValue().doubleValue();
                                discountBadgeText = (pct == Math.floor(pct))
                                        ? String.format("%.0f", pct) + "% OFF"
                                        : String.format("%.1f", pct) + "% OFF";
                            } else {
                                double fixed = activeDiscount.getDiscountValue().doubleValue();
                                discountBadgeText = "Rs. " + (fixed == Math.floor(fixed)
                                        ? String.format("%.0f", fixed) : String.format("%.2f", fixed)) + " OFF";
                            }
                        }

                        String cpiImg = ProductDisplayUtil.getDisplayImagePath(item, itemVariants);
                %>
                <div class="product-card" data-name="<%= item.getName().toLowerCase() %>" data-price="<%= finalPrice %>">
                    <div class="product-card-image-wrap">
                        <% if (showDiscount && !discountBadgeText.isEmpty()) { %>
                        <span class="product-discount-badge" title="<%= discountTitle %>"><%= discountBadgeText %></span>
                        <% } %>
                        <img src="<%=cpiImg != null && !cpiImg.isEmpty() ? request.getContextPath() + "/" + cpiImg : request.getContextPath() + "/assets/images/tools.png"%>" alt="<%= item.getName() %>" class="product-card-image">
                    </div>
                    <div class="product-card-body">
                        <h3 class="product-card-title"><%= item.getName() %></h3>
                        <p class="product-card-price">
                            <% if (showDiscount) { %>
                            <span class="product-price-old">Rs. <%= String.format("%.2f", originalPrice) %></span>
                            <span class="product-price-sale">Rs. <%= String.format("%.2f", finalPrice) %></span>
                            <% } else { %>
                            Rs. <%= String.format("%.2f", finalPrice) %>
                            <% } %>
                        </p>
                        <p class="product-card-desc"><%= item.getDescription() %></p>
                        <a href="${pageContext.request.contextPath}/product_details?productId=<%= item.getProductId() %>" class="btn-primary btn-block" style="text-align: center;">View Details</a>
                    </div>
                </div>
                <% } } else { %>
                    <div class="no-results" id="no-products">
                        <% if (purchaseRadiusFilteredEmpty) { %>
                        <h3>No products in your area</h3>
                        <p>No stores with products in this list within 10 km of your saved location. Pick another point on the map and save again, or clear location to see all products.</p>
                        <% } else { %>
                        <h3>No Products Found</h3>
                        <p>No products available in this category or matching your search criteria.</p>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>
        
    </div>
</div>

<!-- Google Maps API with Places -->
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&libraries=places&callback=initLocationMap" async defer></script>

<script>
    var map;
    var marker;
    var geocoder;
    var autocomplete;
    var selectedLat = null;
    var selectedLng = null;

    var urlParams = new URLSearchParams(window.location.search);
    var currentLat = urlParams.get('lat') || '<%= sessionLat != null ? sessionLat : "" %>';
    var currentLng = urlParams.get('lng') || '<%= sessionLng != null ? sessionLng : "" %>';

    var ctxPath = '${pageContext.request.contextPath}';

    function getNavCategory() {
        var el = document.getElementById('nav-category');
        return el ? el.value : '';
    }

    function isSearchPage() {
        var el = document.getElementById('nav-is-search');
        return el && el.value === '1';
    }

    function getEncSearchQ() {
        var el = document.getElementById('nav-enc-search-q');
        return el ? el.value : '';
    }

    function applyFilterNavigate() {
        if (selectedLat === null || selectedLng === null) {
            return;
        }
        if (isSearchPage()) {
            window.location.href = ctxPath + '/search?q=' + getEncSearchQ()
                + '&lat=' + selectedLat + '&lng=' + selectedLng;
        } else {
            window.location.href = ctxPath + '/products?category=' + encodeURIComponent(getNavCategory())
                + '&lat=' + selectedLat + '&lng=' + selectedLng;
        }
    }

    function clearLocationNavigate() {
        if (isSearchPage()) {
            window.location.href = ctxPath + '/search?q=' + getEncSearchQ() + '&clearLocation=true';
        } else {
            window.location.href = ctxPath + '/products?category=' + encodeURIComponent(getNavCategory()) + '&clearLocation=true';
        }
    }

    function initLocationMap() {
        var defaultCenter = { lat: 7.8731, lng: 80.7718 };
        var defaultZoom = 8;

        if (currentLat && currentLng) {
            defaultCenter = { lat: parseFloat(currentLat), lng: parseFloat(currentLng) };
            defaultZoom = 13;
            selectedLat = parseFloat(currentLat);
            selectedLng = parseFloat(currentLng);
        }

        map = new google.maps.Map(document.getElementById('location-map'), {
            center: defaultCenter,
            zoom: defaultZoom,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: false
        });

        geocoder = new google.maps.Geocoder();

        marker = new google.maps.Marker({
            map: map,
            draggable: true,
            visible: currentLat && currentLng ? true : false,
            position: defaultCenter,
            animation: google.maps.Animation.DROP
        });

        map.addListener('click', function (e) {
            setLocation(e.latLng.lat(), e.latLng.lng());
            reverseGeocode(e.latLng);
        });

        marker.addListener('dragend', function (e) {
            setLocation(e.latLng.lat(), e.latLng.lng());
            reverseGeocode(e.latLng);
        });

        var input = document.getElementById('location-input');
        autocomplete = new google.maps.places.Autocomplete(input, {
            componentRestrictions: { country: 'lk' },
            fields: ['geometry', 'formatted_address']
        });

        autocomplete.addListener('place_changed', function () {
            var place = autocomplete.getPlace();
            if (place.geometry) {
                var lat = place.geometry.location.lat();
                var lng = place.geometry.location.lng();
                setLocation(lat, lng);
                map.setCenter(place.geometry.location);
                map.setZoom(14);
            }
        });
    }

    function setLocation(lat, lng) {
        selectedLat = lat;
        selectedLng = lng;
        var pos = new google.maps.LatLng(lat, lng);
        marker.setPosition(pos);
        marker.setVisible(true);
        updateStatus('Location selected. Click <strong>Save Location</strong> below to filter products by nearby stores.', true);
    }

    function reverseGeocode(latLng) {
        geocoder.geocode({ location: latLng }, function (results, status) {
            if (status === 'OK' && results[0]) {
                document.getElementById('location-input').value = results[0].formatted_address;
            }
        });
    }

    function updateStatus(message, isActive) {
        var statusDiv = document.getElementById('location-status');
        if (isActive) {
            statusDiv.innerHTML = '<i class="ph ph-check-circle"></i> ' + message;
        } else {
            statusDiv.textContent = message;
        }
        statusDiv.className = 'location-status' + (isActive ? ' active' : '');
    }

    window.addEventListener('load', function () {
        var searchInput = document.getElementById('search-input');
        var sortSelect = document.getElementById('sort-products');
        var clearFiltersBtn = document.getElementById('btn-clear-filters');
        var clearLocationBtn = document.getElementById('btn-clear-location');
        var setLocationBtn = document.getElementById('btn-set-location');
        var productGrid = document.getElementById('product-grid');
        var productCards = Array.from(productGrid.getElementsByClassName('product-card'));

        function applySort() {
            var sortVal = sortSelect ? sortSelect.value : 'default';
            var sortedCards = Array.from(productCards);

            if (sortVal === 'price-asc') {
                sortedCards.sort(function (a, b) {
                    return parseFloat(a.dataset.price) - parseFloat(b.dataset.price);
                });
            } else if (sortVal === 'price-desc') {
                sortedCards.sort(function (a, b) {
                    return parseFloat(b.dataset.price) - parseFloat(a.dataset.price);
                });
            }

            // Remove existing cards, keep only the no-results div if it's there
            var elementsToKeep = [];
            Array.from(productGrid.children).forEach(function(child) {
                if(child.id === 'no-products') elementsToKeep.push(child);
            });
            productGrid.innerHTML = '';
            elementsToKeep.forEach(function(child) { productGrid.appendChild(child); });
            
            // Add sorted cards back
            sortedCards.forEach(function (card) {
                productGrid.appendChild(card);
            });
        }

        if (sortSelect) {
            sortSelect.addEventListener('change', applySort);
        }

        if (setLocationBtn) {
            setLocationBtn.addEventListener('click', function () {
                if (selectedLat !== null && selectedLng !== null) {
                    applyFilterNavigate();
                } else {
                    alert('Please select a location on the map first (click the map or search for an address).');
                }
            });
        }

        if (clearFiltersBtn) {
            clearFiltersBtn.addEventListener('click', function () {
                if (searchInput) searchInput.value = '';
                if (sortSelect) sortSelect.value = 'default';
                
                // Only rewrite grid with original cards list
                var elementsToKeep = [];
                Array.from(productGrid.children).forEach(function(child) {
                    if(child.id === 'no-products') elementsToKeep.push(child);
                });
                productGrid.innerHTML = '';
                elementsToKeep.forEach(function(child) { productGrid.appendChild(child); });
                
                productCards.forEach(function (card) { productGrid.appendChild(card); });
            });
        }

        if (clearLocationBtn) {
            clearLocationBtn.addEventListener('click', function () {
                clearLocationNavigate();
            });
        }
    });
</script>

</body>

</html>
