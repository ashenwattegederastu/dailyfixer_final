<%@ page contentType="text/html;charset=UTF-8" %>

    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Repair Guides | Daily Fixer</title>
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
        <style>
            /* ── Full-page background backdrop ──────────────────── */
            .hub-page-bg {
                position: fixed;
                inset: 0;
                z-index: -1;
                background-image: url('<%= request.getContextPath() %>/assets/images/backgrounds/guides.jpg');
                background-size: cover;
                background-position: center;
                background-repeat: no-repeat;
            }

            /* ── Hero ────────────────────────────────────────────── */
            .hub-hero {
                position: relative;
                min-height: 350px;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                text-align: center;
                /* top-padding pushes content below the floating nav (~80px) */
                padding: 130px 30px 30px;
            }

            /* Readability overlay — only covers the hero portion */
            /*.hub-hero::before {*/
            /*    content: '';*/
            /*    position: absolute;*/
            /*    inset: 0;*/
            /*    background: linear-gradient(*/
            /*            to bottom,*/
            /*            rgba(0, 0, 0, 0.60) 0%,*/
            /*            rgba(0, 0, 0, 0.40) 70%,*/
            /*            transparent 100%*/
            /*    );*/
            /*    pointer-events: none;*/
            /*}*/

            .hub-hero-content {
                position: relative;
                z-index: 1;
            }

            .hub-hero-content h1 {
                font-size: 3rem;
                font-weight: 800;
                color: var(--foreground);
                margin-bottom: 12px;
                letter-spacing: -0.02em;
                /*text-shadow: 0 2px 12px rgba(0, 0, 0, 0.4);*/
            }

            .hub-hero-content p {
                font-size: 1.15rem;
                color: var(--muted-foreground);
                margin-bottom: 36px;
                /*text-shadow: 0 1px 6px rgba(0, 0, 0, 0.35);*/
            }

            /* ── Search wrapper ──────────────────────────────────── */
            .hub-search-wrapper {
                position: relative;
                max-width: 580px;
                width: 100%;
                margin: 0 auto;
            }

            .hub-search-form {
                display: flex;
                gap: 0;
                border-radius: var(--radius-lg);
                overflow: hidden;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.35);
            }

            .hub-search-form input[type="text"] {
                flex: 1;
                padding: 16px 20px;
                border: none;
                background: #ffffff;
                color: #111;
                font-size: 1rem;
                outline: none;
            }

            .hub-search-form button {
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

            .hub-search-form button:hover {
                opacity: 0.88;
            }

            /* ── AJAX Suggestions dropdown ───────────────────────── */
            .hub-suggestions {
                position: absolute;
                top: calc(100% + 4px);
                left: 0;
                right: 0;
                background: #ffffff;
                border-radius: var(--radius-md);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
                overflow: hidden;
                z-index: 200;
                display: none;
            }

            .hub-suggestions.visible {
                display: block;
            }

            .hub-suggestion-item {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 12px 18px;
                cursor: pointer;
                text-decoration: none;
                color: #111;
                border-bottom: 1px solid #f0f0f0;
                transition: background 0.15s;
            }

            .hub-suggestion-item:last-child {
                border-bottom: none;
            }

            .hub-suggestion-item:hover,
            .hub-suggestion-item.active {
                background: #f5f5f5;
            }

            .hub-suggestion-icon {
                font-size: 1.1rem;
                color: #888;
                flex-shrink: 0;
            }

            .hub-suggestion-text {
                flex: 1;
                min-width: 0;
            }

            .hub-suggestion-title {
                font-size: 0.93rem;
                font-weight: 500;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .hub-suggestion-cat {
                font-size: 0.78rem;
                color: #888;
                margin-top: 1px;
            }

            .hub-suggestion-arrow {
                font-size: 1rem;
                color: #bbb;
                flex-shrink: 0;
            }

            /* ── Body Section ────────────────────────────────────── */
            .hub-body {
                max-width: 1300px;
                margin: 0 auto;
                padding: 30px 30px 80px;
            }

            .hub-section-heading {
                font-size: 1.6rem;
                font-weight: 700;
                color: var(--foreground);
                margin-bottom: 8px;
            }

            .hub-section-sub {
                color: var(--muted-foreground);
                font-size: 0.97rem;
                margin-bottom: 36px;
            }

            /* ── Category Grid ───────────────────────────────────── */
            .hub-category-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 28px;
            }

            @media (max-width: 1024px) {
                .hub-category-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
            }

            @media (max-width: 580px) {
                .hub-category-grid {
                    grid-template-columns: 1fr;
                }

                .hub-hero-content h1 {
                    font-size: 2rem;
                }
            }

            /* ── Category Card ───────────────────────────────────── */
            .hub-cat-card {
                background: var(--card);
                border: 1px solid var(--border);
                border-radius: var(--radius-lg);
                overflow: hidden;
                display: flex;
                flex-direction: column;
                text-decoration: none;
                transition: transform 0.2s, box-shadow 0.2s;
            }

            .hub-cat-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--shadow-xl);
            }

            /* Image area – replace placeholder with <img class="hub-cat-img"> when ready */
            .hub-cat-img {
                width: 100%;
                height: 200px;
                object-fit: contain;
                padding: 40px;
                background: var(--muted);
                display: block;
            }

            .hub-cat-img-placeholder {
                width: 100%;
                height: 200px;
                background: var(--muted);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 3.5rem;
                color: var(--muted-foreground);
            }

            .hub-cat-body {
                padding: 22px 20px 20px;
                flex: 1;
                display: flex;
                flex-direction: column;
            }

            .hub-cat-title {
                font-size: 1.15rem;
                font-weight: 700;
                color: var(--foreground);
                margin-bottom: 6px;
            }

            .hub-cat-desc {
                font-size: 0.87rem;
                color: var(--muted-foreground);
                line-height: 1.5;
                flex: 1;
                margin-bottom: 18px;
            }

            /* ── "View All" card ─────────────────────────────────── */
            .hub-cat-card.hub-view-all .hub-cat-img-placeholder {
                background: var(--accent);
                color: var(--accent-foreground);
                font-size: 4rem;
            }

            /* ── Browse button ───────────────────────────────────── */
            .hub-browse-btn {
                display: block;
                width: 100%;
                text-align: center;
                padding: 10px 0;
                border-radius: var(--radius-md);
                font-size: 0.92rem;
                font-weight: 600;
                cursor: pointer;
                text-decoration: none;
                transition: opacity 0.2s;
            }

            .hub-browse-btn:hover {
                opacity: 0.85;
            }

            .hub-browse-btn.primary {
                background: var(--primary);
                color: var(--primary-foreground);
            }

            .hub-browse-btn.secondary {
                background: var(--secondary);
                color: var(--secondary-foreground);
                border: 1px solid var(--border);
            }
        </style>
    </head>

    <body>
        <!-- Fixed full-page background: sits behind everything, unaffected by framework.css body styles -->

        <jsp:include page="/pages/shared/header.jsp" />
        <div class="hub-page-bg"></div>
        <!-- ── Hero ─────────────────────────────────────────────── -->
        <div class="hub-hero">
            <div class="hub-hero-content">
                <h1>Repair Guides</h1>
                <p>Learn how to fix things yourself with step-by-step community guides</p>

                <div class="hub-search-wrapper">
                    <form class="hub-search-form" id="hub-search-form"
                        action="${pageContext.request.contextPath}/guides" method="get" autocomplete="off">
                        <input type="text" id="hub-search-input" name="keyword" placeholder="Search all guides..."
                            autocomplete="off">
                        <button type="submit">
                            <i class="ph ph-magnifying-glass"></i> Search
                        </button>
                    </form>
                    <div class="hub-suggestions" id="hub-suggestions" role="listbox"></div>
                </div>
            </div>
        </div>

        <!-- ── Body ─────────────────────────────────────────────── -->
        <div class="hub-body">
            <h2 class="hub-section-heading">Browse by Category</h2>
            <p class="hub-section-sub">Choose a repair category to explore guides in that area</p>

            <div class="hub-category-grid">

                <!-- ── Home Repair ───────────────────────────────── -->
                <%-- TO ADD AN IMAGE: replace the <div class="hub-cat-img-placeholder"> block below with:
                    <img src="${pageContext.request.contextPath}/assets/images/guides/home-repair.jpg" alt="Home Repair"
                        class="hub-cat-img">
                    --%>
                    <a href="${pageContext.request.contextPath}/guides?mainCategory=Home+Repair" class="hub-cat-card">
                        <img src="${pageContext.request.contextPath}/assets/images/home.png" alt="Home Repair"
                             class="hub-cat-img">
                        <div class="hub-cat-body">
                            <h3 class="hub-cat-title">Home Repair</h3>
                            <p class="hub-cat-desc">Walls, plumbing, flooring, doors, and general household fixes.</p>
                            <span class="hub-browse-btn primary">Browse Guides <i class="ph ph-arrow-right"></i></span>
                        </div>
                    </a>

                    <!-- ── Home Electronics / Appliance Repair ───────── -->
                    <%-- TO ADD AN IMAGE: replace the <div class="hub-cat-img-placeholder"> block below with:
                        <img src="${pageContext.request.contextPath}/assets/images/guides/electronics-repair.jpg"
                            alt="Home Electronics / Appliance Repair" class="hub-cat-img">
                        --%>
                        <a href="${pageContext.request.contextPath}/guides?mainCategory=Home+Electronics+%2F+Appliance+Repair"
                            class="hub-cat-card">
                            <img src="${pageContext.request.contextPath}/assets/images/tv.png" alt="Electronic Repair"
                                 class="hub-cat-img">
                            <div class="hub-cat-body">
                                <h3 class="hub-cat-title">Home Electronics &amp; Appliance Repair</h3>
                                <p class="hub-cat-desc">TVs, washing machines, refrigerators, and other household
                                    electronics.</p>
                                <span class="hub-browse-btn primary">Browse Guides <i
                                        class="ph ph-arrow-right"></i></span>
                            </div>
                        </a>

                        <!-- ── Vehicle Repair ────────────────────────────── -->
                        <%-- TO ADD AN IMAGE: replace the <div class="hub-cat-img-placeholder"> block below with:
                            <img src="${pageContext.request.contextPath}/assets/images/guides/vehicle-repair.jpg"
                                alt="Vehicle Repair" class="hub-cat-img">
                            --%>
                            <a href="${pageContext.request.contextPath}/guides?mainCategory=Vehicle+Repair"
                                class="hub-cat-card">
                                <img src="${pageContext.request.contextPath}/assets/images/tyre.png" alt="Vehicle Repair"
                                     class="hub-cat-img">
                                <div class="hub-cat-body">
                                    <h3 class="hub-cat-title">Vehicle Repair</h3>
                                    <p class="hub-cat-desc">Cars, motorcycles, tyres, engines, and roadside
                                        troubleshooting.</p>
                                    <span class="hub-browse-btn primary">Browse Guides <i
                                            class="ph ph-arrow-right"></i></span>
                                </div>
                            </a>

                            <!-- ── View All ──────────────────────────────────── -->
                            <a href="${pageContext.request.contextPath}/guides?viewAll=true"
                                class="hub-cat-card hub-view-all">
                                <div class="hub-cat-img-placeholder">
                                    <i class="ph ph-books"></i>
                                </div>
                                <div class="hub-cat-body">
                                    <h3 class="hub-cat-title">View All Guides</h3>
                                    <p class="hub-cat-desc">Browse the complete library of repair guides across all
                                        categories.</p>
                                    <span class="hub-browse-btn secondary">View All <i
                                            class="ph ph-arrow-right"></i></span>
                                </div>
                            </a>

            </div>
        </div>
        <jsp:include page="/pages/shared/translate.jsp" />

        <script>
            (function () {
                var ctxPath = '${pageContext.request.contextPath}';
                var input = document.getElementById('hub-search-input');
                var dropdown = document.getElementById('hub-suggestions');
                var form = document.getElementById('hub-search-form');

                var debounceTimer = null;
                var activeIndex = -1;
                var currentItems = [];

                function fetchSuggestions(q) {
                    if (q.length < 2) {
                        hideDrop();
                        return;
                    }
                    fetch(ctxPath + '/guides/suggest?q=' + encodeURIComponent(q))
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            renderDrop(data, q);
                        })
                        .catch(function () {
                            hideDrop();
                        });
                }

                function renderDrop(items, q) {
                    if (!items || items.length === 0) {
                        hideDrop();
                        return;
                    }

                    currentItems = items;
                    activeIndex = -1;
                    dropdown.innerHTML = '';

                    items.forEach(function (item, idx) {
                        var a = document.createElement('a');
                        a.className = 'hub-suggestion-item';
                        a.href = ctxPath + '/guides/view?id=' + item.guideId;
                        a.setAttribute('role', 'option');
                        a.dataset.idx = idx;

                        // Highlight the matching portion of the title
                        var highlighted = highlightMatch(item.title, q);

                        a.innerHTML =
                            '<span class="hub-suggestion-icon"><i class="ph ph-book-open"></i></span>' +
                            '<span class="hub-suggestion-text">' +
                            '<span class="hub-suggestion-title">' + highlighted + '</span>' +
                            '<span class="hub-suggestion-cat">' + escapeHtml(item.mainCategory) + '</span>' +
                            '</span>' +
                            '<span class="hub-suggestion-arrow"><i class="ph ph-arrow-right"></i></span>';

                        a.addEventListener('mousedown', function (e) {
                            // mousedown fires before blur; prevent blur from hiding first
                            e.preventDefault();
                        });

                        dropdown.appendChild(a);
                    });

                    dropdown.classList.add('visible');
                }

                function hideDrop() {
                    dropdown.classList.remove('visible');
                    dropdown.innerHTML = '';
                    activeIndex = -1;
                    currentItems = [];
                }

                function setActive(idx) {
                    var items = dropdown.querySelectorAll('.hub-suggestion-item');
                    items.forEach(function (el) {
                        el.classList.remove('active');
                    });
                    if (idx >= 0 && idx < items.length) {
                        items[idx].classList.add('active');
                        activeIndex = idx;
                    } else {
                        activeIndex = -1;
                    }
                }

                function highlightMatch(title, q) {
                    var escaped = escapeHtml(title);
                    var escapedQ = escapeHtml(q);
                    try {
                        var re = new RegExp('(' + escapedQ.replace(/[.*+?^\${}()|[\]\\]/g, '\\$&') + ')', 'gi');
                        return escaped.replace(re, '<strong>$1</strong>');
                    } catch (e) {
                        return escaped;
                    }
                }

                function escapeHtml(s) {
                    if (!s) return '';
                    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                }

                // Input handler with debounce
                input.addEventListener('input', function () {
                    clearTimeout(debounceTimer);
                    var q = input.value.trim();
                    debounceTimer = setTimeout(function () {
                        fetchSuggestions(q);
                    }, 220);
                });

                // Keyboard navigation
                input.addEventListener('keydown', function (e) {
                    var items = dropdown.querySelectorAll('.hub-suggestion-item');
                    if (e.key === 'ArrowDown') {
                        e.preventDefault();
                        setActive(Math.min(activeIndex + 1, items.length - 1));
                    } else if (e.key === 'ArrowUp') {
                        e.preventDefault();
                        setActive(Math.max(activeIndex - 1, -1));
                    } else if (e.key === 'Enter') {
                        if (activeIndex >= 0 && items[activeIndex]) {
                            e.preventDefault();
                            window.location.href = items[activeIndex].href;
                        }
                        // else let the form submit normally
                    } else if (e.key === 'Escape') {
                        hideDrop();
                    }
                });

                // Hide on blur (with slight delay so click on item registers)
                input.addEventListener('blur', function () {
                    setTimeout(hideDrop, 150);
                });

                // Hide when clicking outside
                document.addEventListener('click', function (e) {
                    if (!e.target.closest('.hub-search-wrapper')) {
                        hideDrop();
                    }
                });
            })();
        </script>

    </body>

    </html>