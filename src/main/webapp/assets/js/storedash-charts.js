(function () {
    "use strict";

    // ── Theme ─────────────────────────────────────────────────────────────────

    var LIGHT_THEME = {
        text:    "#334155",
        muted:   "#64748b",
        grid:    "rgba(148, 163, 184, 0.22)",
        track:   "rgba(148, 163, 184, 0.16)",
        surface: "#ffffff",
        palette: ["#0ea5e9", "#14b8a6", "#f59e0b", "#8b5cf6", "#ef476f", "#22c55e", "#f97316", "#06b6d4"]
    };

    var DARK_THEME = {
        text:    "#e5e7eb",
        muted:   "#94a3b8",
        grid:    "rgba(148, 163, 184, 0.24)",
        track:   "rgba(148, 163, 184, 0.18)",
        surface: "#1f2937",
        palette: ["#38bdf8", "#2dd4bf", "#fbbf24", "#a78bfa", "#fb7185", "#4ade80", "#fb923c", "#22d3ee"]
    };

    function getTheme() {
        return document.documentElement.classList.contains("dark") ? DARK_THEME : LIGHT_THEME;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    function hexToRgba(hex, alpha) {
        var n = String(hex || "").replace("#", "");
        if (n.length === 3) { n = n.split("").map(function (c) { return c + c; }).join(""); }
        if (n.length !== 6) { return "rgba(59,130,246," + alpha + ")"; }
        return "rgba(" + parseInt(n.slice(0,2),16) + "," + parseInt(n.slice(2,4),16) + "," + parseInt(n.slice(4,6),16) + "," + alpha + ")";
    }

    function formatNumber(value) {
        return new Intl.NumberFormat("en-US", {
            maximumFractionDigits: value % 1 === 0 ? 0 : 2
        }).format(value);
    }

    function setupCanvas(canvas) {
        if (!canvas) { return null; }
        var rect = canvas.getBoundingClientRect();
        var cssW  = Math.max(1, Math.round(rect.width  || canvas.clientWidth  || 320));
        var cssH  = Math.max(1, Math.round(rect.height || canvas.clientHeight || 260));
        var dpr   = window.devicePixelRatio || 1;
        if (canvas.width !== Math.round(cssW * dpr) || canvas.height !== Math.round(cssH * dpr)) {
            canvas.width  = Math.round(cssW * dpr);
            canvas.height = Math.round(cssH * dpr);
        }
        var ctx = canvas.getContext("2d");
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        ctx.clearRect(0, 0, cssW, cssH);
        return { ctx: ctx, width: cssW, height: cssH };
    }

    function drawRoundedRect(ctx, x, y, width, height, radius, fillStyle) {
        var r = Math.min(radius, width / 2, height / 2);
        ctx.beginPath();
        ctx.moveTo(x + r, y);
        ctx.arcTo(x + width, y,     x + width, y + height, r);
        ctx.arcTo(x + width, y + height, x, y + height,    r);
        ctx.arcTo(x, y + height, x, y,                     r);
        ctx.arcTo(x, y, x + width, y,                      r);
        ctx.closePath();
        ctx.fillStyle = fillStyle;
        ctx.fill();
    }

    function drawEmptyState(ctx, width, height, theme) {
        ctx.fillStyle = theme.muted;
        ctx.font = "600 14px Plus Jakarta Sans, Inter, sans-serif";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillText("No data available", width / 2, height / 2);
    }

    function drawGrid(ctx, width, height, pad, maxValue, theme, ticks) {
        var plotH = height - pad.t - pad.b;
        var plotW = width  - pad.l - pad.r;
        ctx.strokeStyle = theme.grid;
        ctx.lineWidth   = 1;
        ctx.font        = "12px Inter, sans-serif";
        ctx.fillStyle   = theme.muted;
        ctx.textAlign   = "right";
        ctx.textBaseline = "middle";
        for (var i = 0; i <= ticks; i++) {
            var progress = i / ticks;
            var y = pad.t + plotH * progress;
            ctx.beginPath();
            ctx.moveTo(pad.l, y);
            ctx.lineTo(pad.l + plotW, y);
            ctx.stroke();
            ctx.fillText(formatNumber(Math.round(maxValue * (1 - progress))), pad.l - 8, y);
        }
    }

    // ── Chart 1: Order Status – gradient vertical bars, per-status colour ─────

    function drawOrderStatusBars(canvas, labels, values) {
        var chart = setupCanvas(canvas);
        if (!chart) { return; }
        var ctx = chart.ctx, W = chart.width, H = chart.height;
        var theme = getTheme();

        var pad = { t: 28, b: 48, l: 40, r: 16 };
        var plotW = W - pad.l - pad.r;
        var plotH = H - pad.t - pad.b;
        if (plotW <= 0 || plotH <= 0) { return; }

        var allZero = values.every(function (v) { return v === 0; });
        if (allZero) { drawEmptyState(ctx, W, H, theme); return; }

        var STATUS_COLORS = ["#f59e0b", "#ec4899", "#06b6d4", "#10b981"];
        var SHORT_LABELS   = ["Pending", "Processing", "Out for Del.", "Delivered"];
        var maxV = Math.max(1, Math.max.apply(null, values));

        drawGrid(ctx, W, H, pad, maxV, theme, 4);

        var n    = labels.length;
        var step = plotW / n;
        var barW = Math.min(44, step * 0.58);

        ctx.textBaseline = "bottom";
        for (var i = 0; i < n; i++) {
            var color   = STATUS_COLORS[i % STATUS_COLORS.length];
            var x       = pad.l + i * step + (step - barW) / 2;
            var barH    = values[i] > 0 ? Math.max(4, (values[i] / maxV) * plotH) : 0;
            var y       = pad.t + plotH - barH;

            if (barH > 0) {
                var grad = ctx.createLinearGradient(0, y, 0, y + barH);
                grad.addColorStop(0, hexToRgba(color, 0.95));
                grad.addColorStop(1, hexToRgba(color, 0.55));
                drawRoundedRect(ctx, x, y, barW, barH, 8, grad);

                // Count above bar
                ctx.fillStyle = theme.text;
                ctx.textAlign = "center";
                ctx.font = "600 12px Inter, sans-serif";
                ctx.fillText(formatNumber(values[i]), x + barW / 2, Math.max(pad.t - 2, y - 4));
            }

            // Colour swatch + label below x-axis
            var lbl  = SHORT_LABELS[i] || labels[i] || "";
            var lblX = x + barW / 2;
            var lblY = H - pad.b + 14;
            ctx.fillStyle = color;
            ctx.beginPath();
            ctx.arc(lblX - ctx.measureText(lbl).width / 2 - 7, lblY - 3, 4, 0, Math.PI * 2);
            ctx.fill();
            ctx.fillStyle = theme.muted;
            ctx.font = "12px Inter, sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "top";
            ctx.fillText(lbl, lblX, H - pad.b + 10);
        }
    }

    // ── Chart 2: Orders & Revenue (last 7 days) ───────────────────────────────

    function drawOrdersRevenue(canvas, labels, orders, revenue) {
        var chart = setupCanvas(canvas);
        if (!chart) { return; }
        var ctx = chart.ctx, W = chart.width, H = chart.height;
        var theme = getTheme();

        var ORDER_COLOR   = "#0ea5e9";
        var REVENUE_COLOR = "#8b5cf6";
        var LEGEND_H      = 22;
        var pad = { t: LEGEND_H + 18, b: 38, l: 46, r: 18 };
        var plotW = W - pad.l - pad.r;
        var plotH = H - pad.t - pad.b;
        if (plotW <= 0 || plotH <= 0) { return; }

        var hasOrders  = orders.some(function (v) { return v > 0; });
        var hasRevenue = revenue.some(function (v) { return v > 0; });

        if (!hasOrders && !hasRevenue) { drawEmptyState(ctx, W, H, theme); return; }

        var maxOrders  = Math.max(1, Math.max.apply(null, orders));
        var maxRevenue = Math.max(1, Math.max.apply(null, revenue));

        drawGrid(ctx, W, H, pad, maxOrders, theme, 4);

        var n    = labels.length;
        var step = plotW / Math.max(n, 1);
        var barW = Math.min(32, step * 0.52);

        // Order bars
        var barGrad = ctx.createLinearGradient(0, pad.t, 0, H - pad.b);
        barGrad.addColorStop(0, hexToRgba(ORDER_COLOR, 0.90));
        barGrad.addColorStop(1, hexToRgba(ORDER_COLOR, 0.50));

        ctx.textBaseline = "bottom";
        for (var i = 0; i < n; i++) {
            var x    = pad.l + i * step + (step - barW) / 2;
            var barH = orders[i] > 0 ? Math.max(4, (orders[i] / maxOrders) * plotH) : 0;
            var y    = pad.t + plotH - barH;
            if (barH > 0) {
                drawRoundedRect(ctx, x, y, barW, barH, 8, barGrad);
                if (orders[i] > 0) {
                    ctx.fillStyle = theme.text;
                    ctx.textAlign = "center";
                    ctx.font = "600 11px Inter, sans-serif";
                    ctx.fillText(formatNumber(orders[i]), x + barW / 2, Math.max(pad.t - 2, y - 4));
                }
            }
            // Date label
            ctx.fillStyle = theme.muted;
            ctx.font = "12px Inter, sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "top";
            ctx.fillText(labels[i] || "", pad.l + i * step + step / 2, H - pad.b + 8);
        }

        // Revenue area + line
        var revPoints = [];
        for (var j = 0; j < n; j++) {
            revPoints.push({
                x: pad.l + j * step + step / 2,
                y: pad.t + plotH - (revenue[j] / maxRevenue) * plotH
            });
        }

        // Gradient fill
        var areaGrad = ctx.createLinearGradient(0, pad.t, 0, H - pad.b);
        areaGrad.addColorStop(0, hexToRgba(REVENUE_COLOR, 0.20));
        areaGrad.addColorStop(1, hexToRgba(REVENUE_COLOR, 0.03));

        ctx.beginPath();
        revPoints.forEach(function (pt, idx) {
            if (idx === 0) { ctx.moveTo(pt.x, pt.y); }
            else {
                var prev = revPoints[idx - 1];
                var cx   = (prev.x + pt.x) / 2;
                ctx.bezierCurveTo(cx, prev.y, cx, pt.y, pt.x, pt.y);
            }
        });
        ctx.lineTo(revPoints[revPoints.length - 1].x, H - pad.b);
        ctx.lineTo(revPoints[0].x, H - pad.b);
        ctx.closePath();
        ctx.fillStyle = areaGrad;
        ctx.fill();

        // Line
        ctx.beginPath();
        revPoints.forEach(function (pt, idx) {
            if (idx === 0) { ctx.moveTo(pt.x, pt.y); }
            else {
                var prev = revPoints[idx - 1];
                var cx   = (prev.x + pt.x) / 2;
                ctx.bezierCurveTo(cx, prev.y, cx, pt.y, pt.x, pt.y);
            }
        });
        ctx.strokeStyle = REVENUE_COLOR;
        ctx.lineWidth   = 2.5;
        ctx.stroke();

        // Dots
        revPoints.forEach(function (pt) {
            ctx.beginPath();
            ctx.arc(pt.x, pt.y, 4, 0, Math.PI * 2);
            ctx.fillStyle = theme.surface;
            ctx.fill();
            ctx.beginPath();
            ctx.arc(pt.x, pt.y, 3, 0, Math.PI * 2);
            ctx.fillStyle = REVENUE_COLOR;
            ctx.fill();
        });

        // Legend
        var lx = pad.l;
        drawRoundedRect(ctx, lx, 5, 12, 12, 3, hexToRgba(ORDER_COLOR, 0.85));
        ctx.fillStyle = theme.text;
        ctx.textAlign = "left";
        ctx.textBaseline = "middle";
        ctx.font = "12px Inter, sans-serif";
        ctx.fillText("Orders", lx + 16, 11);

        drawRoundedRect(ctx, lx + 80, 5, 12, 12, 3, REVENUE_COLOR);
        ctx.fillText("Revenue (LKR)", lx + 96, 11);
    }

    // ── Chart 3: Most Selling Items – pill horizontal bars ────────────────────

    function drawMostSelling(canvas, labels, values) {
        var chart = setupCanvas(canvas);
        if (!chart) { return; }
        var ctx = chart.ctx, W = chart.width, H = chart.height;
        var theme = getTheme();

        var pad = { t: 16, b: 18, l: Math.min(148, W * 0.36), r: 48 };
        var plotW = W - pad.l - pad.r;
        var plotH = H - pad.t - pad.b;
        if (plotW <= 0 || plotH <= 0) { return; }

        var allZero = values.every(function (v) { return v === 0; });
        if (allZero) { drawEmptyState(ctx, W, H, theme); return; }

        var maxV   = Math.max(1, Math.max.apply(null, values));
        var rowH   = plotH / Math.max(values.length, 1);
        var barH   = Math.min(22, rowH * 0.56);

        ctx.font = "12px Inter, sans-serif";
        ctx.textBaseline = "middle";

        for (var i = 0; i < values.length; i++) {
            var y       = pad.t + i * rowH + (rowH - barH) / 2;
            var fillW   = (values[i] / maxV) * plotW;
            var color   = theme.palette[i % theme.palette.length];

            // Grey track
            drawRoundedRect(ctx, pad.l, y, plotW, barH, 999, theme.track);

            // Filled bar
            if (fillW > 0) {
                drawRoundedRect(ctx, pad.l, y, Math.max(fillW, 8), barH, 999, color);
            }

            // Product name label
            ctx.fillStyle = theme.text;
            ctx.textAlign = "right";
            ctx.save();
            ctx.beginPath();
            ctx.rect(0, y - 2, pad.l - 10, barH + 4);
            ctx.clip();
            ctx.fillText(labels[i] || "", pad.l - 10, y + barH / 2);
            ctx.restore();

            // Value after bar
            ctx.fillStyle = theme.muted;
            ctx.textAlign = "left";
            ctx.font = "bold 12px Inter, sans-serif";
            var valStr = formatNumber(values[i]);
            var valX   = Math.min(pad.l + fillW + 8, W - pad.r + 4);
            ctx.fillText(valStr, valX, y + barH / 2);
            ctx.font = "12px Inter, sans-serif";
        }
    }

    // ── Render ────────────────────────────────────────────────────────────────

    function renderStoreDashboardCharts() {
        var d = window.storeDashData;
        if (!d) { return; }

        var statusLabels = d.statusLabels || ["Pending", "Processing", "Out for Delivery", "Delivered"];
        var statusValues = (d.statusValues || [0, 0, 0, 0]).map(Number);

        var dayLabels   = d.dayLabels   || [];
        var orderCounts = (d.orderCounts  || []).map(Number);
        var revenueByDay = (d.revenueByDay || []).map(Number);

        var mostSelling = d.mostSelling || [];
        var sellLabels  = mostSelling.map(function (item) {
            var nm = item && item.name ? String(item.name) : "";
            return nm.length > 22 ? nm.substring(0, 21) + "\u2026" : nm;
        });
        var sellValues = mostSelling.map(function (item) {
            return item && typeof item.qty === "number" ? item.qty : 0;
        });

        drawOrderStatusBars(document.getElementById("chartOrderStatus"), statusLabels, statusValues);
        drawOrdersRevenue(document.getElementById("chartOrdersOverTime"), dayLabels, orderCounts, revenueByDay);
        drawMostSelling(document.getElementById("chartMostSelling"), sellLabels, sellValues);
    }

    function debounce(fn, delay) {
        var t = null;
        return function () { clearTimeout(t); t = setTimeout(fn, delay); };
    }

    var rerender = debounce(renderStoreDashboardCharts, 120);

    new MutationObserver(rerender).observe(document.documentElement, {
        attributes: true, attributeFilter: ["class"]
    });
    window.addEventListener("resize", rerender);

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", renderStoreDashboardCharts);
    } else {
        renderStoreDashboardCharts();
    }
})();
