<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Register Store - DailyFixer</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        body {
            display: flex;
            align-items: flex-start;
            justify-content: center;
            min-height: 100vh;
            background-color: var(--background);
            padding: 40px 20px;
        }

        .register-wrapper {
            width: 100%;
            max-width: 1200px;
        }

        .page-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .page-header h2 {
            font-size: 2rem;
            color: var(--primary);
            margin-bottom: 10px;
        }

        .page-header p {
            color: var(--muted-foreground);
        }

        .register-card {
            display: flex;
            gap: 24px;
            align-items: flex-start;
        }

        /* Override form-container centering for side-by-side layout */
        .register-card .form-container {
            max-width: none;
            margin: 0;
        }

        .register-left {
            flex: 1;
        }

        .register-right {
            width: 420px;
            flex-shrink: 0;
        }

        .form-cols {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        /* Extend framework form-group to cover additional input types */
        .form-group input[type="email"],
        .form-group input[type="password"],
        .form-group select {
            width: 100%;
            padding: 10px 15px;
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            background-color: var(--input);
            color: var(--foreground);
            transition: border-color 0.2s, background-color 0.3s ease, color 0.3s ease;
            font-family: var(--font-sans), serif;
        }

        .form-group input[type="email"]:focus,
        .form-group input[type="password"]:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--ring);
        }

        .section-label {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--foreground);
            margin: 20px 0 14px;
            padding-bottom: 6px;
            border-bottom: 2px solid var(--border);
        }

        .section-label:first-of-type {
            margin-top: 4px;
        }

        /* Map panel */
        #store-map {
            width: 100%;
            height: 280px;
            border-radius: var(--radius-md);
            margin-top: 12px;
            border: 2px solid var(--border);
        }

        .location-info {
            background: var(--muted);
            color: var(--muted-foreground);
            padding: 10px 14px;
            border-radius: var(--radius-md);
            margin-top: 10px;
            font-size: 0.85rem;
        }

        .location-info.success {
            background: oklch(0.92 0.05 156);
            color: oklch(0.35 0.12 156);
        }

        .location-info.error {
            background: oklch(0.96 0.03 23);
            color: var(--destructive);
        }

        .location-coords {
            font-weight: 600;
        }

        .map-instructions {
            font-size: 0.8rem;
            color: var(--muted-foreground);
            margin-top: 8px;
            padding: 10px 12px;
            background: var(--muted);
            border-radius: var(--radius-md);
        }

        .login-link {
            text-align: center;
            margin-top: 20px;
            color: var(--muted-foreground);
            font-size: 0.85rem;
        }

        .login-link a {
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        @media (max-width: 900px) {
            .register-card {
                flex-direction: column;
            }

            .register-right {
                width: 100%;
            }

            .form-cols {
                grid-template-columns: 1fr;
            }
        }

        .error-text {
            color: var(--destructive);
            font-size: 0.85rem;
            margin-top: 5px;
            font-weight: 500;
        }

        .server-error {
            background-color: var(--destructive);
            color: white;
            padding: 15px;
            border-radius: var(--radius-md);
            margin-bottom: 20px;
            font-weight: 500;
        }
    </style>
</head>

<body>

    <div class="register-wrapper">
        <div class="page-header">
            <h2>Register Store</h2>
            <p>Join DailyFixer as a Store Partner</p>
        </div>

        <div class="register-card">
            <!-- Left: Form -->
            <div class="register-left form-container">

                <c:if test="${not empty errorMsg}">
                    <div class="server-error">${errorMsg}</div>
                </c:if>

                <div id="formError" class="server-error" style="display:none;"></div>

                <form id="registerForm" method="post" action="${pageContext.request.contextPath}/registerStore"
                    onsubmit="return submitForm(event);">
                    <input type="hidden" name="latitude" id="latitude">
                    <input type="hidden" name="longitude" id="longitude">
                    <input type="hidden" name="storeAddress" id="storeAddress">

                    <div class="section-label">Owner Details</div>

                    <div class="form-cols">
                        <div class="form-group">
                            <label>First name</label>
                            <input type="text" name="firstName" id="firstName" required>
                            <div id="firstNameError" class="error-text"></div>
                        </div>
                        <div class="form-group">
                            <label>Last name</label>
                            <input type="text" name="lastName" id="lastName" required>
                            <div id="lastNameError" class="error-text"></div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" id="username" required>
                        <div id="usernameError" class="error-text"></div>
                    </div>

                    <div class="form-cols">
                        <div class="form-group">
                            <label>Password</label>
                            <input type="password" name="password" id="password" required>
                            <div id="passwordError" class="error-text"></div>
                        </div>
                        <div class="form-group">
                            <label>Confirm Password</label>
                            <input type="password" name="confirmPassword" id="confirmPassword" required>
                            <div id="confirmPasswordError" class="error-text"></div>
                        </div>
                    </div>

                    <div class="form-cols">
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" id="email" required>
                            <div id="emailError" class="error-text"></div>
                        </div>
                        <div class="form-group">
                            <label>Phone number</label>
                            <input type="text" name="phone" id="phone">
                            <div id="phoneError" class="error-text"></div>
                        </div>
                    </div>

                    <div class="section-label">Store Details</div>
                    <% String[] cities = {"Colombo","Kandy","Galle","Jaffna","Kurunegala","Matara","Trincomalee","Batticaloa","Negombo","Anuradhapura","Polonnaruwa","Badulla","Ratnapura","Puttalam","Kilinochchi","Mannar","Hambantota"}; %>

                    <div class="form-group">
                        <label>Store name</label>
                        <input type="text" name="storeName" id="storeName" required>
                        <div id="storeNameError" class="error-text"></div>
                    </div>

                    <div class="form-cols">
                        <div class="form-group">
                            <label>Store city</label>
                            <select name="storeCity" id="storeCity" required>
                                <option value="">-- Select city --</option>
                                <% for (String c : cities) { %>
                                    <option value="<%=c%>"><%=c%></option>
                                <% } %>
                            </select>
                            <div id="storeCityError" class="error-text"></div>
                        </div>
                        <div class="form-group">
                            <label>Store type</label>
                            <select name="storeType" id="storeType" required>
                                <option value="">-- Select type --</option>
                                <option value="electronics">Electronics</option>
                                <option value="hardware">Hardware</option>
                                <option value="vehicle repair">Vehicle Repair</option>
                                <option value="other">Other</option>
                            </select>
                            <div id="storeTypeError" class="error-text"></div>
                        </div>
                    </div>

                    <button type="submit" class="login-btn" id="submitBtn" style="width:100%;margin-top:8px;">Register Store</button>
                </form>
            </div>

            <!-- Right: Map -->
            <div class="register-right form-container">
                <h3 style="color:var(--primary);margin-bottom:6px;">📍 Store Location</h3>
                <p style="font-size:0.85rem;color:var(--muted-foreground);">Set your store location using the search box or by clicking on the map.</p>

                <div class="form-group" style="margin-top:12px;margin-bottom:0;">
                    <label>Search for location:</label>
                    <input type="text" id="map-search-input" placeholder="Type address or place name...">
                </div>

                <div id="store-map"></div>

                <div class="map-instructions">
                    <strong>💡 Tips:</strong><br>
                    • Type an address in the search box above, OR<br>
                    • Click directly on the map to pin your store location
                </div>

                <div id="locationInfo" class="location-info">
                    Location not set. Please select your store location on the map.
                </div>

                <hr style="margin-top:20px;border-color:var(--border);">

                <div class="login-link">
                    <p>Already have an account? <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp">Log in</a></p>
                    <p style="margin-top:6px;">Or go back <a href="${pageContext.request.contextPath}/index.jsp">Home</a></p>
                    <p style="font-size:0.75rem;color:var(--muted-foreground);margin-top:10px;">By registering you agree to our terms and that information you provide is accurate.</p>
                </div>
            </div>
        </div>
    </div>

            <!-- Google Maps API with Places library -->
            <script
                src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCO5jDKuyt8P6aVYy0RfIjanWVbHC--Ox0&libraries=places&callback=initMap"
                async defer></script>

            <script>
                var map;
                var marker;
                var geocoder;
                var autocomplete;
                var selectedLat = null;
                var selectedLng = null;

                // Initialize the map
                function initMap() {
                    // Default center: Sri Lanka
                    var sriLanka = { lat: 7.8731, lng: 80.7718 };

                    map = new google.maps.Map(document.getElementById('store-map'), {
                        center: sriLanka,
                        zoom: 8,
                        mapTypeControl: false,
                        streetViewControl: false,
                        fullscreenControl: true
                    });

                    geocoder = new google.maps.Geocoder();

                    // Create a draggable marker
                    marker = new google.maps.Marker({
                        map: map,
                        draggable: true,
                        visible: false,
                        animation: google.maps.Animation.DROP
                    });

                    // Click on map to set location
                    map.addListener('click', function (e) {
                        setLocation(e.latLng.lat(), e.latLng.lng());
                        reverseGeocode(e.latLng);
                    });

                    // Drag marker to set location
                    marker.addListener('dragend', function (e) {
                        setLocation(e.latLng.lat(), e.latLng.lng());
                        reverseGeocode(e.latLng);
                    });

                    // Initialize Places Autocomplete
                    var searchInput = document.getElementById('map-search-input');
                    autocomplete = new google.maps.places.Autocomplete(searchInput, {
                        componentRestrictions: { country: 'lk' }, // Restrict to Sri Lanka
                        fields: ['geometry', 'formatted_address', 'name']
                    });

                    autocomplete.addListener('place_changed', function () {
                        var place = autocomplete.getPlace();

                        if (place.geometry && place.geometry.location) {
                            var lat = place.geometry.location.lat();
                            var lng = place.geometry.location.lng();

                            setLocation(lat, lng);
                            map.setCenter(place.geometry.location);
                            map.setZoom(15);

                            updateLocationInfo(place.formatted_address || place.name, lat, lng);
                        } else {
                            showLocationError('Could not find that location. Please try again.');
                        }
                    });
                }

                // Set the location coordinates
                function setLocation(lat, lng) {
                    selectedLat = lat;
                    selectedLng = lng;

                    // Update hidden form fields
                    document.getElementById('latitude').value = lat;
                    document.getElementById('longitude').value = lng;

                    // Update marker position
                    var position = new google.maps.LatLng(lat, lng);
                    marker.setPosition(position);
                    marker.setVisible(true);
                }

                // Reverse geocode to get address from coordinates
                function reverseGeocode(latLng) {
                    geocoder.geocode({ location: latLng }, function (results, status) {
                        if (status === 'OK' && results[0]) {
                            updateLocationInfo(results[0].formatted_address, latLng.lat(), latLng.lng());
                        } else {
                            updateLocationInfo('Location selected', latLng.lat(), latLng.lng());
                        }
                    });
                }

                // Update the location info display
                function updateLocationInfo(address, lat, lng) {
                    var infoDiv = document.getElementById('locationInfo');
                    infoDiv.className = 'location-info success';
                    infoDiv.innerHTML = '<strong>✓ Location Set:</strong><br>' +
                        '<span style="font-size:12px;">' + address + '</span><br>' +
                        '<span class="location-coords">Lat: ' + lat.toFixed(6) + ', Lng: ' + lng.toFixed(6) + '</span>';

                    // Auto-fill the hidden store address field
                    document.getElementById('storeAddress').value = address;
                }

                // Show location error
                function showLocationError(message) {
                    var infoDiv = document.getElementById('locationInfo');
                    infoDiv.className = 'location-info error';
                    infoDiv.innerHTML = '<strong>⚠ Error:</strong> ' + message;
                }

                // Client-side validation
                function validateForm() {
                    document.querySelectorAll('.error-text').forEach(el => el.textContent = '');
                    var formError = document.getElementById('formError');
                    formError.style.display = 'none';
                    var f = id => document.getElementById(id).value.trim();
                    var hasError = false;

                    if (!f('firstName'))  { document.getElementById('firstNameError').textContent = 'First name required'; hasError = true; }
                    if (!f('lastName'))   { document.getElementById('lastNameError').textContent = 'Last name required'; hasError = true; }
                    if (!f('username'))   { document.getElementById('usernameError').textContent = 'Username required'; hasError = true; }
                    if (!f('storeName'))  { document.getElementById('storeNameError').textContent = 'Store name required'; hasError = true; }
                    if (!f('storeCity'))  { document.getElementById('storeCityError').textContent = 'Store city required'; hasError = true; }
                    if (!f('storeType'))  { document.getElementById('storeTypeError').textContent = 'Store type required'; hasError = true; }

                    var emailVal = f('email');
                    if (!emailVal) { document.getElementById('emailError').textContent = 'Email required'; hasError = true; }
                    else {
                        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                        if (!emailRegex.test(emailVal)) { document.getElementById('emailError').textContent = 'Invalid email format'; hasError = true; }
                    }

                    var pw  = document.getElementById('password').value;
                    var cpw = document.getElementById('confirmPassword').value;
                    if (!pw || pw.length < 6) { document.getElementById('passwordError').textContent = 'Password required (min 6 chars)'; hasError = true; }
                    if (!cpw) { document.getElementById('confirmPasswordError').textContent = 'Please confirm your password'; hasError = true; }
                    else if (pw !== cpw) { document.getElementById('confirmPasswordError').textContent = 'Passwords do not match'; hasError = true; }

                    var phoneVal = f('phone').replace(/\D/g, '');
                    if (phoneVal && phoneVal.length !== 10) { document.getElementById('phoneError').textContent = 'Phone must be exactly 10 digits'; hasError = true; }

                    var lat = document.getElementById('latitude').value;
                    var lng = document.getElementById('longitude').value;
                    if (!lat || !lng || lat === '' || lng === '') {
                        formError.textContent = 'Please select a store location on the map.';
                        formError.style.display = 'block';
                        hasError = true;
                    }

                    if (hasError) window.scrollTo({ top: 0, behavior: 'smooth' });
                    return !hasError;
                }

                // Submit form - geocode if no map selection, else use selected coords
                function submitForm(event) {
                    event.preventDefault();

                    if (!validateForm()) {
                        return false;
                    }

                    var submitBtn = document.getElementById('submitBtn');
                    submitBtn.disabled = true;
                    submitBtn.textContent = 'Registering...';

                    // Submit the form - validation already checked that location is set
                    document.getElementById('registerForm').submit();
                    return false;
                }
            </script>

        </body>

        </html>