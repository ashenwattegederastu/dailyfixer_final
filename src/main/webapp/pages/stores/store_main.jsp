<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Fixer - Store</title>
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

        .category-section, .suggested-section {
            margin-top: 50px;
        }

        .section-title {
            font-size: 1.5rem;
            color: var(--foreground);
            margin-bottom: 25px;
        }

        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 20px;
        }

        .category-card {
            background: var(--card);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            padding: 25px 15px;
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: var(--foreground);
        }

        .category-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-xl);
        }

        .category-card img {
            width: 60px;
            height: 60px;
            margin-bottom: 15px;
            object-fit: contain;
        }

        .category-card span {
            font-size: 0.95rem;
            font-weight: 500;
            line-height: 1.3;
        }

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
            display: block;
        }

        .product-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-xl);
        }

        .product-card-image {
            width: 100%;
            height: 200px;
            object-fit: contain;
            background: var(--muted);
            padding: 20px;
        }

        .product-card-body {
            padding: 20px;
        }

        .product-card-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--foreground);
            margin-bottom: 8px;
        }

        .product-card-price {
            font-size: 1rem;
            color: var(--primary);
            font-weight: 600;
            margin-bottom: 12px;
        }

        .product-card-desc {
            color: var(--muted-foreground);
            font-size: 0.85rem;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

    </style>
</head>

<body>
<jsp:include page="/pages/shared/header.jsp" />

<div class="page-container">
    <div class="page-header">
        <h1>Parts & Tools Store</h1>
        <p>Find the right parts and tools for your daily fixes</p>
    </div>

    <!-- Search Section -->
    <div class="filters-section">
        <form class="filters-form" action="${pageContext.request.contextPath}/search" method="get">
            <div class="filter-group">
                <label for="search-input"><i class="ph ph-magnifying-glass"></i> Search</label>
                <input type="text" name="q" id="search-input" placeholder="Search for a part/item or category" required>
            </div>
            <div class="filter-buttons">
                <button type="submit" class="btn-primary"><i class="ph ph-magnifying-glass"></i> Search</button>
            </div>
        </form>
    </div>

    <!-- Category Section -->
    <section class="category-section">
        <h2 class="section-title">Browse by Category</h2>
        <div class="category-grid">
            <a href="${pageContext.request.contextPath}/products?category=Cutting Tools" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/saw-machine.png" alt="Cutting Tools">
                <span>Cutting Tools</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Painting Tools" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/paint-roller.png" alt="Painting Tools">
                <span>Painting Tools</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Tool Storage %26 Safety Gear" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/safety-gear.png" alt="Tool Storage & Safety Gear">
                <span>Tool Storage<br>& Safety Gear</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Electrical Tools %26 Accessories" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/power-cable.png" alt="Electrical Tools & Accessories">
                <span>Electrical Tools<br>& Accessories</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Power Tools" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/power-drill.png" alt="Power Tools">
                <span>Power Tools</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Cleaning %26 Maintenance" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/cleaning.png" alt="Cleaning & Maintenance">
                <span>Cleaning &<br>Maintenance</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Vehicle Parts %26 Accessories" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/tyre.png" alt="Vehicle Parts & Accessories">
                <span>Vehicle Parts<br>& Accessories</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Measuring %26 Marking Tools" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/tape-measure.png" alt="Measuring & Marking Tools">
                <span>Measuring &<br>Marking Tools</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Tapes" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/masking-tape.png" alt="Tapes">
                <span>Tapes</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Fasteners %26 Fittings" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/tools.png" alt="Fasteners & Fittings">
                <span>Fasteners &<br>Fittings</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Plumbing Tools %26 Supplies" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/pipe.png" alt="Plumbing Tools & Supplies">
                <span>Plumbing Tools<br>& Supplies</span>
            </a>

            <a href="${pageContext.request.contextPath}/products?category=Adhesives %26 Sealants" class="category-card">
                <img src="${pageContext.request.contextPath}/assets/images/glue.png" alt="Adhesives & Sealants">
                <span>Adhesives &<br>Sealants</span>
            </a>
        </div>
    </section>
</div>
</body>
</html>
