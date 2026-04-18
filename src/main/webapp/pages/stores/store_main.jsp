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
        body {
            background-image: url('<%= request.getContextPath() %>/assets/images/backgrounds/guides.jpg'); /* your image path */
            background-size: cover;       /* fill entire screen */
            background-repeat: no-repeat; /* no tiling */
            background-position: center;  /* center the image */
        }
        .page-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 30px 30px 50px;
        }

        .store-hero {
            position: relative;
            min-height: 350px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 130px 30px 30px;
        }

        .store-hero-content {
            position: relative;
            z-index: 1;
            width: 100%;
        }

        .store-hero-content h1 {
            font-size: 3rem;
            font-weight: 800;
            color: var(--foreground);
            margin-bottom: 12px;
            letter-spacing: -0.02em;
        }

        .store-slogan {
            font-size: 1.5rem;
            font-weight: 500;
            color: var(--foreground);
            margin-bottom: 15px;
        }

        .store-hero-content p {
            font-size: 1.15rem;
            color: var(--muted-foreground);
            margin-bottom: 36px;
        }

        .store-search-wrapper {
            position: relative;
            max-width: 580px;
            width: 100%;
            margin: 0 auto;
        }

        .store-search-form {
            display: flex;
            gap: 0;
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.35);
        }

        .store-search-form input[type="text"] {
            flex: 1;
            padding: 16px 20px;
            border: none;
            background: #ffffff;
            color: #111;
            font-size: 1rem;
            outline: none;
        }

        .store-search-form button {
            padding: 16px 24px;
            background: var(--primary);
            color: var(--primary-foreground);
            border: none;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: opacity 0.2s;
            white-space: nowrap;
        }

        .store-search-form button:hover {
            opacity: 0.88;
        }



        .suggestions-dropdown {
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            right: 0;
            background: var(--card);
            border-radius: var(--radius-md);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            z-index: 1000;
            max-height: 320px;
            overflow-y: auto;
            display: none;
            text-align: left;
        }

        .suggestion-item {
            padding: 10px 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.92rem;
            color: var(--foreground);
            border-bottom: 1px solid var(--border);
        }

        .suggestion-item:last-child { border-bottom: none; }

        .suggestion-item:hover,
        .suggestion-item.active {
            background: var(--muted);
        }

        .suggestion-pill {
            font-size: 0.7rem;
            padding: 2px 7px;
            border-radius: 20px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            flex-shrink: 0;
        }

        .suggestion-pill-category {
            background: color-mix(in srgb, var(--primary) 15%, transparent);
            color: var(--primary);
        }

        .suggestion-pill-product {
            background: var(--secondary);
            color: var(--muted-foreground);
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

<div class="store-hero">
    <div class="store-hero-content">
        <h1>Parts & Tools Store</h1>
        <p>Find the right parts and tools for your daily fixes</p>

        <div class="store-search-wrapper">
            <form class="store-search-form" action="${pageContext.request.contextPath}/search" method="get">
                <input type="text" name="q" id="search-input" placeholder="Search for a part/item or category" autocomplete="off" required>
                <button type="submit">
                    <i class="ph ph-magnifying-glass"></i> Search
                </button>
            </form>
            <div id="suggestions-dropdown" class="suggestions-dropdown" role="listbox" aria-label="Search suggestions"></div>
        </div>
    </div>
</div>

<div class="page-container">

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
<script>
(function () {
    var ctxPath = '${pageContext.request.contextPath}';
    var input      = document.getElementById('search-input');
    var dropdown   = document.getElementById('suggestions-dropdown');
    var activeIdx  = -1;
    var items      = [];
    var debounce   = null;

    function fetchSuggestions(q) {
        if (q.length < 2) { hideDrop(); return; }
        fetch(ctxPath + '/search-suggest?q=' + encodeURIComponent(q), {
            headers: { 'Accept': 'application/json' }
        })
        .then(function(r) { return r.ok ? r.json() : { suggestions: [] }; })
        .then(function(data) { renderDrop(data.suggestions || []); })
        .catch(function() { hideDrop(); });
    }

    function renderDrop(suggestions) {
        dropdown.innerHTML = '';
        items = [];
        activeIdx = -1;

        if (suggestions.length === 0) { hideDrop(); return; }

        suggestions.forEach(function(s, i) {
            var el = document.createElement('div');
            el.className = 'suggestion-item';
            el.setAttribute('role', 'option');
            el.setAttribute('data-idx', i);

            var pill = document.createElement('span');
            pill.className = 'suggestion-pill '
                + (s.kind === 'category' ? 'suggestion-pill-category' : 'suggestion-pill-product');
            pill.textContent = s.kind === 'category' ? 'Category' : 'Product';

            var icon = document.createElement('i');
            icon.className = s.kind === 'category'
                ? 'ph ph-folder-open'
                : 'ph ph-package';

            var text = document.createElement('span');
            text.textContent = s.label;

            el.appendChild(pill);
            el.appendChild(icon);
            el.appendChild(text);

            el.addEventListener('mousedown', function(e) {
                // mousedown fires before blur — use preventDefault to keep focus
                e.preventDefault();
                navigateTo(s.kind, s.label);
            });

            dropdown.appendChild(el);
            items.push(el);
        });

        dropdown.style.display = 'block';
    }

    function hideDrop() {
        dropdown.style.display = 'none';
        activeIdx = -1;
        items.forEach(function(el) { el.classList.remove('active'); });
    }

    function setActive(idx) {
        items.forEach(function(el) { el.classList.remove('active'); });
        activeIdx = idx;
        if (idx >= 0 && idx < items.length) {
            items[idx].classList.add('active');
            items[idx].scrollIntoView({ block: 'nearest' });
        }
    }

    function navigateTo(kind, label) {
        if (kind === 'category') {
            window.location.href = ctxPath + '/products?category=' + encodeURIComponent(label);
        } else {
            window.location.href = ctxPath + '/search?q=' + encodeURIComponent(label);
        }
    }

    input.addEventListener('input', function() {
        clearTimeout(debounce);
        var q = input.value.trim();
        debounce = setTimeout(function() { fetchSuggestions(q); }, 300);
    });

    input.addEventListener('keydown', function(e) {
        if (dropdown.style.display === 'none') return;
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            setActive(Math.min(activeIdx + 1, items.length - 1));
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            setActive(Math.max(activeIdx - 1, -1));
        } else if (e.key === 'Enter' && activeIdx >= 0) {
            e.preventDefault();
            items[activeIdx].dispatchEvent(new MouseEvent('mousedown'));
        } else if (e.key === 'Escape') {
            hideDrop();
        }
    });

    input.addEventListener('blur', function() {
        // Small delay so mousedown on a suggestion fires first
        setTimeout(hideDrop, 150);
    });

    input.addEventListener('focus', function() {
        if (input.value.trim().length >= 2) {
            fetchSuggestions(input.value.trim());
        }
    });
}());
</script>

</body>
</html>
