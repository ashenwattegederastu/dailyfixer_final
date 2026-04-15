<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Fixer</title>
    <!-- Link to external stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/store.css">
</head>
<body>
<header>

    <!-- Main Navbar -->
    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="logo">Daily Fixer</a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/index.jsp" class="active">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/login">Log in</a></li>
        </ul>
    </nav>

    <!-- Rounded Subnav -->
    <div class="subnav">
        <a href="${pageContext.request.contextPath}/diagnostic.jsp">Diagnose Now</a>
        <a href="#">Find a Technician</a>
        <a href="${pageContext.request.contextPath}/listguides.jsp">View Repair Guides</a>
        <a href="${pageContext.request.contextPath}/pages/stores/store.jsp" class="active">Stores</a>
    </div>
</header>

<div class="container">
    <nav class="sub-nav">
        <h2 class="page-title">Stores</h2>
        <button class="cart-button">
            <img src="project icons/shopping-cart.png" alt="Cart Icon" class="cart-icon-img">
        </button>
    </nav>

    <section class="search-section">
        <h3 class="search-title">What are you looking for?</h3>
        <div class="search-box">
            <input type="text" placeholder="search for a part/item">
            <button>
                <img src="images/search.png" alt="Search">
            </button>
        </div>

        <section class="category-section">
            <h4 class="category-header">Browse Items by Category</h4>
            <div class="category-grid">
                <a href="cutting-tools.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/saw-machine.png" alt="Cutting Tools">
                    <p class="category-label">Cutting Tools</p>
                </a>
                <a href="painting-tools.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/paint-roller.png" alt="Painting Tools">
                    <p class="category-label">Painting Tools</p>
                </a>
                <a href="tool-storage.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/safety-gear.png" alt="Tool Storage & Safety Gear">
                    <p class="category-label">Tool Storage <br>& Safety Gear</p>
                </a>
                <a href="electrical-tools.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/power-cable.png" alt="Electrical Tools & Accessories">
                    <p class="category-label">Electrical Tools <br>& Accessories</p>
                </a>
                <a href="power-tools.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/power-drill.png" alt="Power Tools">
                    <p class="category-label">Power Tools</p>
                </a>
                <a href="cleaning-maintenance.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/cleaning.png" alt="Cleaning & Maintenance">
                    <p class="category-label">Cleaning & Maintenance</p>
                </a>
                <a href="vehicle-parts.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/tyre.png" alt="Vehicle Parts & Accessories">
                    <p class="category-label">Vehicle Parts <br>& Accessories</p>
                </a>
                <a href="measuring-tools.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/tape-measure.png" alt="Measuring & Marking Tools">
                    <p class="category-label">Measuring & <br>Marking Tools</p>
                </a>
                <a href="tapes.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/masking-tape.png" alt="Tapes">
                    <p class="category-label">Tapes</p>
                </a>
                <a href="fasteners-fittings.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/tools.png" alt="Fasteners & Fittings">
                    <p class="category-label">Fasteners & <br>Fittings</p>
                </a>
                <a href="plumbing-supplies.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/pipe.png" alt="Plumbing Tools & Supplies">
                    <p class="category-label">Plumbing Tools <br>& Supplies</p>
                </a>
                <a href="adhesives-sealants.html" class="category-item">
                    <img src="${pageContext.request.contextPath}/assets/images/icons/glue.png" alt="Adhesives & Sealants">
                    <p class="category-label">Adhesives & <br>Sealants</p>
                </a>
            </div>
        </section>
    </section>
</div>

</body>
</html>