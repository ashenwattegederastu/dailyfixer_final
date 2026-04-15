/**
 * Volunteer Dashboard Charts - Pure JavaScript (No External Libraries)
 * Features:
 * - Animated Bar Chart
 * - Animated Radar Chart
 * - Smooth CSS-like animations using requestAnimationFrame
 */

(function () {
    'use strict';

    // Animation utilities
    const AnimationUtils = {
        // Easing function - easeOutCubic for smooth deceleration
        easeOutCubic: function (t) {
            return 1 - Math.pow(1 - t, 3);
        },

        // Easing function - easeOutElastic for bouncy effect
        easeOutElastic: function (t) {
            const c4 = (2 * Math.PI) / 3;
            return t === 0 ? 0 : t === 1 ? 1 : Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * c4) + 1;
        },

        // Linear interpolation
        lerp: function (start, end, t) {
            return start + (end - start) * t;
        }
    };

    // Color palette for charts
    const ChartColors = {
        primary: '#10b981',
        primaryLight: '#34d399',
        secondary: '#3b82f6',
        tertiary: '#8b5cf6',
        quaternary: '#f59e0b',
        background: 'rgba(16, 185, 129, 0.1)',
        gridLine: '#e5e7eb',
        text: '#374151',
        textMuted: '#6b7280'
    };

    /**
     * Animated Bar Chart Class
     */
    class AnimatedBarChart {
        constructor(canvasId, data, options = {}) {
            this.canvas = document.getElementById(canvasId);
            if (!this.canvas) return;

            this.ctx = this.canvas.getContext('2d');
            this.data = data;
            this.options = {
                padding: options.padding || 50,
                barSpacing: options.barSpacing || 20,
                animationDuration: options.animationDuration || 1200,
                showValues: options.showValues !== false,
                showGrid: options.showGrid !== false,
                colors: options.colors || [ChartColors.primary, ChartColors.secondary, ChartColors.tertiary, ChartColors.quaternary],
                maxValue: options.maxValue || 100
            };

            this.animationProgress = 0;
            this.isAnimating = false;
            this.setupCanvas();
        }

        setupCanvas() {
            // Handle high DPI displays
            const dpr = window.devicePixelRatio || 1;
            const rect = this.canvas.getBoundingClientRect();

            this.canvas.width = rect.width * dpr;
            this.canvas.height = rect.height * dpr;

            this.ctx.scale(dpr, dpr);

            this.width = rect.width;
            this.height = rect.height;
        }

        animate() {
            if (this.isAnimating) return;

            this.isAnimating = true;
            this.animationProgress = 0;
            const startTime = performance.now();

            const animationLoop = (currentTime) => {
                const elapsed = currentTime - startTime;
                this.animationProgress = Math.min(elapsed / this.options.animationDuration, 1);

                this.draw(AnimationUtils.easeOutCubic(this.animationProgress));

                if (this.animationProgress < 1) {
                    requestAnimationFrame(animationLoop);
                } else {
                    this.isAnimating = false;
                }
            };

            requestAnimationFrame(animationLoop);
        }

        draw(progress = 1) {
            const { ctx, width, height, data, options } = this;
            const { padding, barSpacing, colors, maxValue, showGrid, showValues } = options;

            // Clear canvas
            ctx.clearRect(0, 0, width, height);

            const chartWidth = width - padding * 2;
            const chartHeight = height - padding * 2;
            const barCount = data.values.length;
            const barWidth = (chartWidth - (barSpacing * (barCount - 1))) / barCount;

            // Draw grid lines
            if (showGrid) {
                ctx.strokeStyle = ChartColors.gridLine;
                ctx.lineWidth = 1;

                for (let i = 0; i <= 4; i++) {
                    const y = padding + (chartHeight * (i / 4));
                    ctx.beginPath();
                    ctx.setLineDash([5, 5]);
                    ctx.moveTo(padding, y);
                    ctx.lineTo(width - padding, y);
                    ctx.stroke();

                    // Grid labels
                    ctx.fillStyle = ChartColors.textMuted;
                    ctx.font = '11px sans-serif';
                    ctx.textAlign = 'right';
                    ctx.fillText(Math.round(maxValue - (maxValue * i / 4)), padding - 10, y + 4);
                }
                ctx.setLineDash([]);
            }

            // Draw bars with animation
            data.values.forEach((value, index) => {
                const x = padding + index * (barWidth + barSpacing);
                const targetHeight = (value / maxValue) * chartHeight;
                const currentHeight = targetHeight * progress;
                const y = height - padding - currentHeight;

                // Bar gradient
                const gradient = ctx.createLinearGradient(x, y, x, height - padding);
                gradient.addColorStop(0, colors[index % colors.length]);
                gradient.addColorStop(1, this.adjustColor(colors[index % colors.length], -20));

                // Draw bar with rounded top
                ctx.fillStyle = gradient;
                this.roundedRect(x, y, barWidth, currentHeight, 6);
                ctx.fill();

                // Add subtle shadow
                ctx.shadowColor = 'rgba(0, 0, 0, 0.1)';
                ctx.shadowBlur = 10;
                ctx.shadowOffsetY = 5;

                // Value label (animated fade-in)
                if (showValues && progress > 0.5) {
                    const valueOpacity = (progress - 0.5) * 2;
                    ctx.shadowColor = 'transparent';
                    ctx.fillStyle = `rgba(55, 65, 81, ${valueOpacity})`;
                    ctx.font = 'bold 14px sans-serif';
                    ctx.textAlign = 'center';
                    ctx.fillText(Math.round(value * progress), x + barWidth / 2, y - 10);
                }

                // Reset shadow
                ctx.shadowColor = 'transparent';
                ctx.shadowBlur = 0;
                ctx.shadowOffsetY = 0;

                // Bar label
                ctx.fillStyle = ChartColors.textMuted;
                ctx.font = '12px sans-serif';
                ctx.textAlign = 'center';
                ctx.fillText(data.labels[index], x + barWidth / 2, height - padding + 20);
            });

            // Draw x-axis
            ctx.strokeStyle = ChartColors.gridLine;
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(padding, height - padding);
            ctx.lineTo(width - padding, height - padding);
            ctx.stroke();
        }

        roundedRect(x, y, width, height, radius) {
            const { ctx } = this;
            if (height < 0) return;

            radius = Math.min(radius, height / 2, width / 2);

            ctx.beginPath();
            ctx.moveTo(x + radius, y);
            ctx.lineTo(x + width - radius, y);
            ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
            ctx.lineTo(x + width, y + height);
            ctx.lineTo(x, y + height);
            ctx.lineTo(x, y + radius);
            ctx.quadraticCurveTo(x, y, x + radius, y);
            ctx.closePath();
        }

        adjustColor(color, amount) {
            const clamp = (val) => Math.min(255, Math.max(0, val));

            let r, g, b;
            if (color.startsWith('#')) {
                r = parseInt(color.slice(1, 3), 16);
                g = parseInt(color.slice(3, 5), 16);
                b = parseInt(color.slice(5, 7), 16);
            }

            r = clamp(r + amount);
            g = clamp(g + amount);
            b = clamp(b + amount);

            return `rgb(${r}, ${g}, ${b})`;
        }
    }

    /**
     * Animated Radar Chart Class
     */
    class AnimatedRadarChart {
        constructor(canvasId, data, options = {}) {
            this.canvas = document.getElementById(canvasId);
            if (!this.canvas) return;

            this.ctx = this.canvas.getContext('2d');
            this.data = data;
            this.options = {
                padding: options.padding || 40,
                animationDuration: options.animationDuration || 1500,
                levels: options.levels || 5,
                maxValue: options.maxValue || 100,
                fillColor: options.fillColor || 'rgba(16, 185, 129, 0.25)',
                strokeColor: options.strokeColor || '#10b981',
                pointColor: options.pointColor || '#10b981',
                gridColor: options.gridColor || '#e5e7eb',
                labelColor: options.labelColor || '#374151',
                showPoints: options.showPoints !== false,
                showLabels: options.showLabels !== false,
                showValues: options.showValues !== false
            };

            this.animationProgress = 0;
            this.isAnimating = false;
            this.hoverIndex = -1;

            this.setupCanvas();
            this.setupInteraction();
        }

        setupCanvas() {
            const dpr = window.devicePixelRatio || 1;
            const rect = this.canvas.getBoundingClientRect();

            this.canvas.width = rect.width * dpr;
            this.canvas.height = rect.height * dpr;

            this.ctx.scale(dpr, dpr);

            this.width = rect.width;
            this.height = rect.height;
            this.centerX = this.width / 2;
            this.centerY = this.height / 2;
            this.radius = Math.min(this.width, this.height) / 2 - this.options.padding;
        }

        setupInteraction() {
            this.canvas.addEventListener('mousemove', (e) => {
                const rect = this.canvas.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;

                this.checkHover(x, y);
            });

            this.canvas.addEventListener('mouseleave', () => {
                this.hoverIndex = -1;
                if (!this.isAnimating) this.draw(1);
            });
        }

        checkHover(mouseX, mouseY) {
            const { data, centerX, centerY, radius, options } = this;
            const angleStep = (Math.PI * 2) / data.values.length;
            let newHoverIndex = -1;

            data.values.forEach((value, index) => {
                const angle = -Math.PI / 2 + index * angleStep;
                const distance = (value / options.maxValue) * radius;
                const x = centerX + Math.cos(angle) * distance;
                const y = centerY + Math.sin(angle) * distance;

                const distToMouse = Math.sqrt((mouseX - x) ** 2 + (mouseY - y) ** 2);
                if (distToMouse < 15) {
                    newHoverIndex = index;
                }
            });

            if (newHoverIndex !== this.hoverIndex) {
                this.hoverIndex = newHoverIndex;
                if (!this.isAnimating) this.draw(1);
            }
        }

        animate() {
            if (this.isAnimating) return;

            this.isAnimating = true;
            this.animationProgress = 0;
            const startTime = performance.now();

            const animationLoop = (currentTime) => {
                const elapsed = currentTime - startTime;
                this.animationProgress = Math.min(elapsed / this.options.animationDuration, 1);

                this.draw(AnimationUtils.easeOutCubic(this.animationProgress));

                if (this.animationProgress < 1) {
                    requestAnimationFrame(animationLoop);
                } else {
                    this.isAnimating = false;
                }
            };

            requestAnimationFrame(animationLoop);
        }

        draw(progress = 1) {
            const { ctx, width, height, centerX, centerY, radius, data, options } = this;
            const { levels, maxValue, gridColor, fillColor, strokeColor, pointColor, showPoints, showLabels, showValues } = options;

            // Clear canvas
            ctx.clearRect(0, 0, width, height);

            const pointCount = data.values.length;
            const angleStep = (Math.PI * 2) / pointCount;

            // Draw grid levels
            for (let level = 1; level <= levels; level++) {
                const levelRadius = (radius / levels) * level;

                ctx.beginPath();
                ctx.strokeStyle = gridColor;
                ctx.lineWidth = 1;

                for (let i = 0; i <= pointCount; i++) {
                    const angle = -Math.PI / 2 + i * angleStep;
                    const x = centerX + Math.cos(angle) * levelRadius;
                    const y = centerY + Math.sin(angle) * levelRadius;

                    if (i === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }
                }

                ctx.closePath();
                ctx.stroke();
            }

            // Draw axis lines
            for (let i = 0; i < pointCount; i++) {
                const angle = -Math.PI / 2 + i * angleStep;
                const x = centerX + Math.cos(angle) * radius;
                const y = centerY + Math.sin(angle) * radius;

                ctx.beginPath();
                ctx.moveTo(centerX, centerY);
                ctx.lineTo(x, y);
                ctx.strokeStyle = gridColor;
                ctx.lineWidth = 1;
                ctx.stroke();
            }

            // Draw data polygon
            ctx.beginPath();
            data.values.forEach((value, index) => {
                const angle = -Math.PI / 2 + index * angleStep;
                const distance = (value / maxValue) * radius * progress;
                const x = centerX + Math.cos(angle) * distance;
                const y = centerY + Math.sin(angle) * distance;

                if (index === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            });
            ctx.closePath();

            // Fill with gradient
            const gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius);
            gradient.addColorStop(0, 'rgba(16, 185, 129, 0.4)');
            gradient.addColorStop(1, 'rgba(16, 185, 129, 0.1)');
            ctx.fillStyle = gradient;
            ctx.fill();

            // Stroke
            ctx.strokeStyle = strokeColor;
            ctx.lineWidth = 2.5;
            ctx.stroke();

            // Draw points
            if (showPoints) {
                data.values.forEach((value, index) => {
                    const angle = -Math.PI / 2 + index * angleStep;
                    const distance = (value / maxValue) * radius * progress;
                    const x = centerX + Math.cos(angle) * distance;
                    const y = centerY + Math.sin(angle) * distance;

                    const isHovered = index === this.hoverIndex;
                    const pointRadius = isHovered ? 8 : 5;

                    // Outer glow for hover
                    if (isHovered) {
                        ctx.beginPath();
                        ctx.arc(x, y, 12, 0, Math.PI * 2);
                        ctx.fillStyle = 'rgba(16, 185, 129, 0.2)';
                        ctx.fill();
                    }

                    // Point
                    ctx.beginPath();
                    ctx.arc(x, y, pointRadius, 0, Math.PI * 2);
                    ctx.fillStyle = isHovered ? '#059669' : pointColor;
                    ctx.fill();

                    // White inner ring
                    ctx.beginPath();
                    ctx.arc(x, y, pointRadius - 2, 0, Math.PI * 2);
                    ctx.fillStyle = '#ffffff';
                    ctx.fill();

                    ctx.beginPath();
                    ctx.arc(x, y, pointRadius - 3, 0, Math.PI * 2);
                    ctx.fillStyle = isHovered ? '#059669' : pointColor;
                    ctx.fill();

                    // Value tooltip on hover
                    if (isHovered && showValues) {
                        this.drawTooltip(x, y - 25, data.labels[index], value);
                    }
                });
            }

            // Draw labels
            if (showLabels) {
                ctx.font = 'bold 12px sans-serif';
                ctx.textAlign = 'center';

                data.labels.forEach((label, index) => {
                    const angle = -Math.PI / 2 + index * angleStep;
                    const labelDistance = radius + 25;
                    let x = centerX + Math.cos(angle) * labelDistance;
                    let y = centerY + Math.sin(angle) * labelDistance;

                    // Adjust text alignment based on position
                    if (Math.abs(Math.cos(angle)) > 0.7) {
                        ctx.textAlign = Math.cos(angle) > 0 ? 'left' : 'right';
                        x += Math.cos(angle) > 0 ? -15 : 15;
                    }

                    ctx.fillStyle = this.hoverIndex === index ? '#059669' : options.labelColor;
                    ctx.fillText(label, x, y + 4);

                    // Show value next to label if not hovering
                    if (showValues && this.hoverIndex !== index && progress === 1) {
                        ctx.font = '11px sans-serif';
                        ctx.fillStyle = ChartColors.textMuted;
                        ctx.fillText(`(${data.values[index]})`, x, y + 18);
                        ctx.font = 'bold 12px sans-serif';
                    }
                });
            }
        }

        drawTooltip(x, y, label, value) {
            const { ctx } = this;
            const text = `${label}: ${value}`;
            const padding = 8;

            ctx.font = 'bold 12px sans-serif';
            const textWidth = ctx.measureText(text).width;
            const boxWidth = textWidth + padding * 2;
            const boxHeight = 24;

            // Tooltip background
            ctx.fillStyle = 'rgba(55, 65, 81, 0.95)';
            this.roundedRect(x - boxWidth / 2, y - boxHeight / 2, boxWidth, boxHeight, 6);
            ctx.fill();

            // Tooltip arrow
            ctx.beginPath();
            ctx.moveTo(x - 6, y + boxHeight / 2);
            ctx.lineTo(x, y + boxHeight / 2 + 6);
            ctx.lineTo(x + 6, y + boxHeight / 2);
            ctx.closePath();
            ctx.fill();

            // Tooltip text
            ctx.fillStyle = '#ffffff';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(text, x, y);
            ctx.textBaseline = 'alphabetic';
        }

        roundedRect(x, y, width, height, radius) {
            const { ctx } = this;
            ctx.beginPath();
            ctx.moveTo(x + radius, y);
            ctx.lineTo(x + width - radius, y);
            ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
            ctx.lineTo(x + width, y + height - radius);
            ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
            ctx.lineTo(x + radius, y + height);
            ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
            ctx.lineTo(x, y + radius);
            ctx.quadraticCurveTo(x, y, x + radius, y);
            ctx.closePath();
        }
    }

    /**
     * Stat Card Animation - Animates numbers counting up
     */
    class StatCardAnimator {
        constructor(selector, duration = 1000) {
            this.cards = document.querySelectorAll(selector);
            this.duration = duration;
            this.hasAnimated = false;
        }

        animate() {
            if (this.hasAnimated) return;
            this.hasAnimated = true;

            this.cards.forEach((card, index) => {
                const numberEl = card.querySelector('.number');
                if (!numberEl) return;

                const originalText = numberEl.textContent.trim();
                const hasPercent = originalText.includes('%');
                const targetValue = parseFloat(originalText.replace('%', ''));

                if (isNaN(targetValue)) return;

                // Add entrance animation class
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';

                setTimeout(() => {
                    card.style.transition = 'all 0.5s ease-out';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';

                    // Animate the number
                    this.animateValue(numberEl, 0, targetValue, this.duration, hasPercent);
                }, index * 100);
            });
        }

        animateValue(element, start, end, duration, hasPercent) {
            const startTime = performance.now();
            const isDecimal = !Number.isInteger(end);

            const updateValue = (currentTime) => {
                const elapsed = currentTime - startTime;
                const progress = Math.min(elapsed / duration, 1);
                const easedProgress = AnimationUtils.easeOutCubic(progress);
                const currentValue = AnimationUtils.lerp(start, end, easedProgress);

                if (isDecimal) {
                    element.textContent = currentValue.toFixed(1) + (hasPercent ? '%' : '');
                } else {
                    element.textContent = Math.round(currentValue) + (hasPercent ? '%' : '');
                }

                if (progress < 1) {
                    requestAnimationFrame(updateValue);
                }
            };

            requestAnimationFrame(updateValue);
        }
    }

    /**
     * Progress Bar Animator
     */
    class ProgressBarAnimator {
        constructor(selector, duration = 800) {
            this.progressBars = document.querySelectorAll(selector);
            this.duration = duration;
        }

        animate() {
            this.progressBars.forEach((bar) => {
                const targetWidth = bar.style.width;
                bar.style.width = '0%';
                bar.style.transition = `width ${this.duration}ms ease-out`;

                requestAnimationFrame(() => {
                    bar.style.width = targetWidth;
                });
            });
        }
    }

    /**
     * Initialize all dashboard animations
     */
    function initDashboardAnimations(chartData) {
        // Create and animate bar chart
        if (document.getElementById('reputationChart')) {
            const barChart = new AnimatedBarChart('reputationChart', {
                labels: chartData.labels,
                values: chartData.values
            }, {
                padding: 50,
                barSpacing: 25,
                animationDuration: 1200,
                colors: [ChartColors.primary, ChartColors.secondary, ChartColors.tertiary, ChartColors.quaternary]
            });

            // Delay bar chart animation slightly
            setTimeout(() => {
                barChart.animate();
            }, 300);
        }

        // Create and animate radar chart
        if (document.getElementById('reputationRadarChart')) {
            const radarChart = new AnimatedRadarChart('reputationRadarChart', {
                labels: chartData.labels,
                values: chartData.values
            }, {
                padding: 50,
                animationDuration: 1500,
                maxValue: 100
            });

            // Delay radar chart animation slightly more
            setTimeout(() => {
                radarChart.animate();
            }, 600);
        }

        // Animate stat cards
        const statAnimator = new StatCardAnimator('.stat-card');

        // Use Intersection Observer for scroll-triggered animations
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    statAnimator.animate();
                    observer.disconnect();
                }
            });
        }, { threshold: 0.2 });

        const statsSection = document.querySelector('.volunteer-stats');
        if (statsSection) {
            observer.observe(statsSection);
        }

        // Animate progress bars
        const progressAnimator = new ProgressBarAnimator('[style*="background: var(--primary)"]');
        setTimeout(() => {
            progressAnimator.animate();
        }, 800);

        // Add hover effects to quick link buttons
        document.querySelectorAll('.quick-link-btn').forEach((btn, index) => {
            btn.style.opacity = '0';
            btn.style.transform = 'translateY(15px)';

            setTimeout(() => {
                btn.style.transition = 'all 0.4s ease-out';
                btn.style.opacity = '1';
                btn.style.transform = 'translateY(0)';
            }, 1000 + index * 80);
        });

        // Add hover effects to top guide items
        document.querySelectorAll('.top-guide-item').forEach((item, index) => {
            item.style.opacity = '0';
            item.style.transform = 'translateX(-15px)';

            setTimeout(() => {
                item.style.transition = 'all 0.4s ease-out';
                item.style.opacity = '1';
                item.style.transform = 'translateX(0)';
            }, 1200 + index * 100);
        });
    }

    // Expose to global scope
    window.VolunteerDashboardCharts = {
        AnimatedBarChart,
        AnimatedRadarChart,
        StatCardAnimator,
        ProgressBarAnimator,
        init: initDashboardAnimations
    };

})();
