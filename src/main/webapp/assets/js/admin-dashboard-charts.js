(function () {
    "use strict";

    var LIGHT_THEME = {
        text: "#334155",
        muted: "#64748b",
        grid: "rgba(148, 163, 184, 0.22)",
        track: "rgba(148, 163, 184, 0.16)",
        surface: "#ffffff",
        palette: ["#0ea5e9", "#14b8a6", "#f59e0b", "#8b5cf6", "#ef476f", "#22c55e", "#f97316", "#06b6d4"]
    };

    var DARK_THEME = {
        text: "#e5e7eb",
        muted: "#94a3b8",
        grid: "rgba(148, 163, 184, 0.24)",
        track: "rgba(148, 163, 184, 0.18)",
        surface: "#1f2937",
        palette: ["#38bdf8", "#2dd4bf", "#fbbf24", "#a78bfa", "#fb7185", "#4ade80", "#fb923c", "#22d3ee"]
    };

    function getTheme() {
        return document.documentElement.classList.contains("dark") ? DARK_THEME : LIGHT_THEME;
    }

    function hexToRgba(hex, alpha) {
        var normalized = String(hex || "").replace("#", "");
        if (normalized.length === 3) {
            normalized = normalized.split("").map(function (value) {
                return value + value;
            }).join("");
        }
        if (normalized.length !== 6) {
            return "rgba(59, 130, 246, " + alpha + ")";
        }
        var red = parseInt(normalized.slice(0, 2), 16);
        var green = parseInt(normalized.slice(2, 4), 16);
        var blue = parseInt(normalized.slice(4, 6), 16);
        return "rgba(" + red + ", " + green + ", " + blue + ", " + alpha + ")";
    }

    function formatNumber(value) {
        return new Intl.NumberFormat("en-US", {
            maximumFractionDigits: value % 1 === 0 ? 0 : 2
        }).format(value);
    }

    function normalizeSeries(series) {
        var labels = Array.isArray(series && series.labels) ? series.labels.slice() : [];
        var rawValues = Array.isArray(series && series.values) ? series.values.slice() : [];
        var values = rawValues.map(function (value) {
            var number = Number(value);
            return Number.isFinite(number) ? number : 0;
        });

        return {
            labels: labels,
            values: values
        };
    }

    function hasMeaningfulData(series) {
        return series.values.length > 0 && series.values.some(function (value) {
            return value > 0;
        });
    }

    function setupCanvas(canvas) {
        if (!canvas) {
            return null;
        }

        var rect = canvas.getBoundingClientRect();
        var cssWidth = Math.max(1, Math.round(rect.width || canvas.clientWidth || 320));
        var cssHeight = Math.max(1, Math.round(rect.height || canvas.clientHeight || 280));
        var dpr = window.devicePixelRatio || 1;
        var scaledWidth = Math.round(cssWidth * dpr);
        var scaledHeight = Math.round(cssHeight * dpr);

        if (canvas.width !== scaledWidth || canvas.height !== scaledHeight) {
            canvas.width = scaledWidth;
            canvas.height = scaledHeight;
        }

        var ctx = canvas.getContext("2d");
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        ctx.clearRect(0, 0, cssWidth, cssHeight);

        return {
            ctx: ctx,
            width: cssWidth,
            height: cssHeight
        };
    }

    function drawRoundedRect(ctx, x, y, width, height, radius, fillStyle) {
        var safeRadius = Math.min(radius, width / 2, height / 2);
        ctx.beginPath();
        ctx.moveTo(x + safeRadius, y);
        ctx.arcTo(x + width, y, x + width, y + height, safeRadius);
        ctx.arcTo(x + width, y + height, x, y + height, safeRadius);
        ctx.arcTo(x, y + height, x, y, safeRadius);
        ctx.arcTo(x, y, x + width, y, safeRadius);
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

    function drawGrid(ctx, width, height, padding, maxValue, theme, tickCount) {
        var plotHeight = height - padding.top - padding.bottom;
        var plotWidth = width - padding.left - padding.right;
        ctx.strokeStyle = theme.grid;
        ctx.lineWidth = 1;
        ctx.fillStyle = theme.muted;
        ctx.font = "12px Inter, sans-serif";
        ctx.textAlign = "right";
        ctx.textBaseline = "middle";

        for (var index = 0; index <= tickCount; index++) {
            var progress = index / tickCount;
            var y = padding.top + plotHeight * progress;
            var tickValue = Math.round(maxValue * (1 - progress));

            ctx.beginPath();
            ctx.moveTo(padding.left, y);
            ctx.lineTo(padding.left + plotWidth, y);
            ctx.stroke();
            ctx.fillText(formatNumber(tickValue), padding.left - 8, y);
        }
    }

    function drawLineChart(canvas, series, options) {
        var chart = setupCanvas(canvas);
        if (!chart) {
            return;
        }

        var ctx = chart.ctx;
        var width = chart.width;
        var height = chart.height;
        var theme = getTheme();
        var padding = { top: 18, right: 18, bottom: 42, left: 46 };
        var plotWidth = width - padding.left - padding.right;
        var plotHeight = height - padding.top - padding.bottom;

        if (!hasMeaningfulData(series)) {
            drawEmptyState(ctx, width, height, theme);
            return;
        }

        var maxValue = Math.max.apply(null, series.values.concat([1]));
        drawGrid(ctx, width, height, padding, maxValue, theme, 4);

        var points = [];
        var lastIndex = Math.max(series.values.length - 1, 1);

        series.values.forEach(function (value, index) {
            var x = padding.left + plotWidth * (index / lastIndex);
            var y = padding.top + plotHeight - (value / maxValue) * plotHeight;
            points.push({ x: x, y: y, value: value, label: series.labels[index] || "" });
        });

        var gradient = ctx.createLinearGradient(0, padding.top, 0, height - padding.bottom);
        gradient.addColorStop(0, hexToRgba(options.color, 0.24));
        gradient.addColorStop(1, hexToRgba(options.color, 0.03));

        ctx.beginPath();
        points.forEach(function (point, index) {
            if (index === 0) {
                ctx.moveTo(point.x, point.y);
            } else {
                var previous = points[index - 1];
                var controlX = (previous.x + point.x) / 2;
                ctx.bezierCurveTo(controlX, previous.y, controlX, point.y, point.x, point.y);
            }
        });
        ctx.lineTo(points[points.length - 1].x, height - padding.bottom);
        ctx.lineTo(points[0].x, height - padding.bottom);
        ctx.closePath();
        ctx.fillStyle = gradient;
        ctx.fill();

        ctx.beginPath();
        points.forEach(function (point, index) {
            if (index === 0) {
                ctx.moveTo(point.x, point.y);
            } else {
                var previous = points[index - 1];
                var controlX = (previous.x + point.x) / 2;
                ctx.bezierCurveTo(controlX, previous.y, controlX, point.y, point.x, point.y);
            }
        });
        ctx.strokeStyle = options.color;
        ctx.lineWidth = 3;
        ctx.stroke();

        ctx.textAlign = "center";
        ctx.textBaseline = "top";
        ctx.font = "12px Inter, sans-serif";
        ctx.fillStyle = theme.muted;
        var step = Math.max(1, Math.ceil(series.labels.length / 6));

        points.forEach(function (point, index) {
            if (index % step === 0 || index === points.length - 1) {
                ctx.fillText(point.label, point.x, height - padding.bottom + 12);
            }

            ctx.beginPath();
            ctx.arc(point.x, point.y, 4, 0, Math.PI * 2);
            ctx.fillStyle = theme.surface;
            ctx.fill();
            ctx.beginPath();
            ctx.arc(point.x, point.y, 3, 0, Math.PI * 2);
            ctx.fillStyle = options.color;
            ctx.fill();
        });
    }

    function drawVerticalBars(canvas, series, options) {
        var chart = setupCanvas(canvas);
        if (!chart) {
            return;
        }

        var ctx = chart.ctx;
        var width = chart.width;
        var height = chart.height;
        var theme = getTheme();
        var padding = { top: 18, right: 16, bottom: 48, left: 46 };
        var plotWidth = width - padding.left - padding.right;
        var plotHeight = height - padding.top - padding.bottom;

        if (!hasMeaningfulData(series)) {
            drawEmptyState(ctx, width, height, theme);
            return;
        }

        var maxValue = Math.max.apply(null, series.values.concat([1]));
        drawGrid(ctx, width, height, padding, maxValue, theme, 4);

        var barCount = Math.max(series.values.length, 1);
        var step = plotWidth / barCount;
        var barWidth = Math.min(34, step * 0.58);
        var gradient = ctx.createLinearGradient(0, padding.top, 0, height - padding.bottom);
        gradient.addColorStop(0, hexToRgba(options.color, 0.95));
        gradient.addColorStop(1, hexToRgba(options.color, 0.55));

        ctx.textAlign = "center";
        ctx.font = "12px Inter, sans-serif";
        ctx.textBaseline = "top";

        series.values.forEach(function (value, index) {
            var x = padding.left + index * step + (step - barWidth) / 2;
            var barHeight = value <= 0 ? 0 : Math.max(4, (value / maxValue) * plotHeight);
            var y = padding.top + plotHeight - barHeight;

            if (barHeight > 0) {
                drawRoundedRect(ctx, x, y, barWidth, barHeight, 10, gradient);
                ctx.fillStyle = theme.text;
                ctx.textBaseline = "bottom";
                ctx.font = "600 12px Inter, sans-serif";
                ctx.fillText(formatNumber(value), x + barWidth / 2, y - 6);
            }

            ctx.fillStyle = theme.muted;
            ctx.textBaseline = "top";
            ctx.font = "12px Inter, sans-serif";
            ctx.fillText(series.labels[index] || "", x + barWidth / 2, height - padding.bottom + 12);
        });
    }

    function drawHorizontalBars(canvas, series) {
        var chart = setupCanvas(canvas);
        if (!chart) {
            return;
        }

        var ctx = chart.ctx;
        var width = chart.width;
        var height = chart.height;
        var theme = getTheme();
        var padding = { top: 16, right: 48, bottom: 18, left: Math.min(148, width * 0.36) };
        var plotWidth = width - padding.left - padding.right;
        var plotHeight = height - padding.top - padding.bottom;

        if (!hasMeaningfulData(series)) {
            drawEmptyState(ctx, width, height, theme);
            return;
        }

        var maxValue = Math.max.apply(null, series.values.concat([1]));
        var rowHeight = plotHeight / Math.max(series.values.length, 1);
        var barHeight = Math.min(22, rowHeight * 0.56);

        ctx.font = "12px Inter, sans-serif";
        ctx.textBaseline = "middle";

        series.values.forEach(function (value, index) {
            var y = padding.top + index * rowHeight + (rowHeight - barHeight) / 2;
            var barWidth = (value / maxValue) * plotWidth;
            var color = theme.palette[index % theme.palette.length];

            drawRoundedRect(ctx, padding.left, y, plotWidth, barHeight, 999, theme.track);

            if (barWidth > 0) {
                drawRoundedRect(ctx, padding.left, y, Math.max(barWidth, 8), barHeight, 999, color);
            }

            ctx.fillStyle = theme.text;
            ctx.textAlign = "right";
            ctx.fillText(series.labels[index] || "", padding.left - 10, y + barHeight / 2);

            ctx.fillStyle = theme.muted;
            ctx.textAlign = "left";
            ctx.fillText(formatNumber(value), Math.min(padding.left + barWidth + 8, width - padding.right + 4), y + barHeight / 2);
        });
    }

    function renderCharts() {
        var data = window.adminDashboardData;
        if (!data) {
            return;
        }

        drawLineChart(document.getElementById("ordersChart"), normalizeSeries(data.ordersTrend), {
            color: "#0ea5e9"
        });
        drawVerticalBars(document.getElementById("revenueChart"), normalizeSeries(data.revenueTrend), {
            color: "#14b8a6"
        });
        drawVerticalBars(document.getElementById("usersChart"), normalizeSeries(data.registrationsTrend), {
            color: "#f59e0b"
        });
        drawLineChart(document.getElementById("bookingsChart"), normalizeSeries(data.bookingsTrend), {
            color: "#8b5cf6"
        });
        drawHorizontalBars(document.getElementById("roleChart"), normalizeSeries(data.usersByRole));
        drawHorizontalBars(document.getElementById("statusChart"), normalizeSeries(data.ordersByStatus));
    }

    function debounce(fn, delay) {
        var timer = null;
        return function () {
            clearTimeout(timer);
            timer = setTimeout(fn, delay);
        };
    }

    var rerender = debounce(renderCharts, 120);

    document.addEventListener("DOMContentLoaded", function () {
        renderCharts();
        window.addEventListener("resize", rerender);

        var observer = new MutationObserver(rerender);
        observer.observe(document.documentElement, {
            attributes: true,
            attributeFilter: ["class"]
        });
    });
})();