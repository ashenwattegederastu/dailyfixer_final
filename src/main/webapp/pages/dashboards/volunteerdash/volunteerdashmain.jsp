<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page
            import="com.dailyfixer.model.User,com.dailyfixer.model.VolunteerStats,com.dailyfixer.dao.VolunteerStatsDAO,com.dailyfixer.model.Guide,java.util.List"
            %>
            <%@ page trimDirectiveWhitespaces="true" %>

                <% User user=(User) session.getAttribute("currentUser"); if (user==null ||
                    !"volunteer".equals(user.getRole())) { response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp"
                    ); return; } VolunteerStatsDAO statsDAO=new VolunteerStatsDAO(); VolunteerStats
                    stats=statsDAO.getStats(user.getUserId()); List<Guide> topGuides =
                    statsDAO.getTopRatedGuides(user.getUserId(), 3);
                    %>

                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Volunteer Dashboard | Daily Fixer</title>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                            rel="stylesheet">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                        <link rel="stylesheet" type="text/css"
                              href="${pageContext.request.contextPath}/assets/icons/regular/style.css" />
                        <link rel="stylesheet" type="text/css"
                              href="${pageContext.request.contextPath}/assets/icons/fill/style.css" />
                        <style>
                            .container {
                                flex: 1;
                                margin-left: 240px;
                                padding: 30px;
                                background-color: var(--background);
                            }

                            .container h2 {
                                font-size: 1.6em;
                                margin-bottom: 20px;
                                color: var(--foreground);
                            }

                            .volunteer-stats {
                                background: var(--card);
                                padding: 25px;
                                border-radius: var(--radius-lg);
                                box-shadow: var(--shadow-lg);
                                border: 1px solid var(--border);
                                margin-bottom: 30px;
                            }

                            .volunteer-stats h3 {
                                font-size: 1.3em;
                                margin-bottom: 20px;
                                color: var(--foreground);
                                border-bottom: 1px solid var(--border);
                                padding-bottom: 10px;
                            }

                            .stats-grid {
                                display: grid;
                                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                                gap: 20px;
                            }

                            .stat-card {
                                background: var(--card);
                                padding: 20px;
                                border-radius: var(--radius-md);
                                box-shadow: var(--shadow-sm);
                                border: 1px solid var(--border);
                                text-align: center;
                                transition: all 0.2s;
                            }

                            .stat-card:hover {
                                transform: translateY(-3px);
                                box-shadow: var(--shadow-md);
                            }

                            .stat-card .number {
                                font-size: 2em;
                                font-weight: 700;
                                color: var(--primary);
                                margin-bottom: 5px;
                            }

                            .stat-card .label {
                                color: var(--muted-foreground);
                                font-weight: 500;
                                font-size: 0.9em;
                            }

                            .section-grid {
                                display: grid;
                                grid-template-columns: 2fr 1fr;
                                gap: 30px;
                            }

                            @media (max-width: 992px) {
                                .section-grid {
                                    grid-template-columns: 1fr;
                                }
                            }

                            .quick-links {
                                display: grid;
                                grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
                                gap: 15px;
                                margin-top: 20px;
                            }

                            .quick-link-btn {
                                background: var(--muted);
                                color: var(--foreground);
                                padding: 15px;
                                border-radius: var(--radius-md);
                                text-align: center;
                                text-decoration: none;
                                font-weight: 600;
                                transition: all 0.2s;
                                border: 1px solid var(--border);
                                display: flex;
                                flex-direction: column;
                                align-items: center;
                                gap: 8px;
                            }

                            .quick-link-btn:hover {
                                background: var(--accent);
                                color: var(--accent-foreground);
                                transform: translateY(-2px);
                            }

                            .top-guides-list {
                                list-style: none;
                            }

                            .top-guide-item {
                                display: flex;
                                align-items: center;
                                gap: 15px;
                                padding: 12px 0;
                                border-bottom: 1px solid var(--border);
                            }

                            .top-guide-item:last-child {
                                border-bottom: none;
                            }

                            .top-guide-img {
                                width: 60px;
                                height: 40px;
                                object-fit: cover;
                                border-radius: 4px;
                                background: var(--muted);
                            }

                            .top-guide-info {
                                flex: 1;
                            }

                            .top-guide-title {
                                font-weight: 600;
                                color: var(--foreground);
                                display: block;
                                text-decoration: none;
                                margin-bottom: 2px;
                            }

                            .top-guide-title:hover {
                                color: var(--primary);
                                text-decoration: underline;
                            }

                            .top-guide-meta {
                                font-size: 0.85em;
                                color: var(--muted-foreground);
                            }

                            /* Charts Container */
                            .charts-container {
                                display: grid;
                                grid-template-columns: 1fr 1fr;
                                gap: 30px;
                                margin-top: 20px;
                            }

                            @media (max-width: 768px) {
                                .charts-container {
                                    grid-template-columns: 1fr;
                                }
                            }

                            .chart-wrapper {
                                background: var(--card);
                                border: 1px solid var(--border);
                                border-radius: var(--radius-md);
                                padding: 20px;
                                text-align: center;
                            }

                            .chart-wrapper h5 {
                                margin-bottom: 15px;
                                color: var(--foreground);
                                font-size: 0.95em;
                                font-weight: 600;
                            }

                            .chart-wrapper canvas {
                                width: 100% !important;
                                max-width: 350px;
                                height: auto !important;
                                margin: 0 auto;
                                display: block;
                            }

                            i.ph {
                                font-size: 20px;
                                line-height: 1;
                            }
                        </style>
                    </head>

                    <body>

                        <jsp:include page="/pages/dashboards/volunteerdash/sidebar.jsp" />

                        <main class="container">
                            <h2>Dashboard</h2>

                            <div class="volunteer-stats">
                                <h3>Overview</h3>
                                <div class="stats-grid">
                                    <div class="stat-card">
                                        <p class="number">
                                            <%= stats.getTotalGuides() %>
                                        </p>
                                        <p class="label">Total Guides</p>
                                    </div>
                                    <div class="stat-card">
                                        <p class="number">
                                            <%= stats.getTotalViews() %>
                                        </p>
                                        <p class="label">Total Views</p>
                                    </div>
                                    <div class="stat-card">
                                        <p class="number">
                                            <%= stats.getTotalLikes() %>
                                        </p>
                                        <p class="label">Total Likes</p>
                                    </div>
                                    <div class="stat-card">
                                        <p class="number">
                                            <%= stats.getApprovalRating() %>%
                                        </p>
                                        <p class="label">Approval Rating</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Reputation Section -->
                            <div class="volunteer-stats">
                                <div
                                    style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 10px; margin-bottom: 20px;">
                                    <h3 style="border-bottom: none; margin-bottom: 0; padding-bottom: 0;">Reputation &
                                        Badges</h3>
                                    <a href="${pageContext.request.contextPath}/leaderboard"
                                        style="font-size: 0.9em; color: var(--primary); text-decoration: none; font-weight: 600;">View
                                        Leaderboard →</a>
                                </div>
                                <div class="stats-grid">
                                    <div class="stat-card">
                                        <p class="number" style="color: var(--primary);">
                                            <%= stats.getReputationScore() %>
                                        </p>
                                        <p class="label">Reputation Score</p>
                                    </div>
                                    <div class="stat-card" style="grid-column: span 2;">
                                        <p class="number" style="font-size: 1.5em; color: var(--accent-foreground);">
                                            <%= com.dailyfixer.util.ReputationUtils.getBadgeForScore(stats.getReputationScore())
                                                %>
                                        </p>
                                        <p class="label">Current Tier</p>
                                    </div>
                                </div>

                                <div style="margin-top: 20px;">
                                    <h4
                                        style="margin-bottom: 15px; color: var(--muted-foreground); text-align: center;">
                                        Score Breakdown</h4>
                                    <div class="charts-container">
                                        <div class="chart-wrapper">
                                            <h5><i class="ph ph-chart-bar"></i> Bar Chart View</h5>
                                            <canvas id="reputationChart" width="350" height="220"></canvas>
                                        </div>
                                        <div class="chart-wrapper">
                                            <h5><i class="ph ph-graph"></i> Radar Chart View</h5>
                                            <canvas id="reputationRadarChart" width="350" height="280"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <!-- Next Tier Progress -->
                                <% double currentScore=stats.getReputationScore(); String
                                    nextTierName=com.dailyfixer.util.ReputationUtils.getNextTierName(currentScore); int
                                    nextTierScore=com.dailyfixer.util.ReputationUtils.getNextTierScore(currentScore);
                                    double pointsNeeded=nextTierScore - currentScore; double progressPercent=0; if
                                    (nextTierScore> 0) {
                                    progressPercent = Math.min(100, (currentScore / nextTierScore) * 100);
                                    }
                                    %>
                                    <% if (nextTierScore> 0) { %>
                                        <div
                                            style="margin-top: 25px; padding-top: 20px; border-top: 1px solid var(--border);">
                                            <div
                                                style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.9em;">
                                                <span style="color: var(--muted-foreground);">Progress to <strong>
                                                        <%= nextTierName %>
                                                    </strong></span>
                                                <span style="color: var(--primary); font-weight: 600;">
                                                    <%= Math.round(pointsNeeded * 10.0)/10.0 %> pts needed
                                                </span>
                                            </div>
                                            <div
                                                style="width: 100%; height: 8px; background: var(--muted); border-radius: 4px; overflow: hidden;">
                                                <div
                                                    style="width: <%= progressPercent %>%; height: 100%; background: var(--primary); border-radius: 4px; transition: width 0.5s ease;">
                                                </div>
                                            </div>
                                        </div>
                                        <% } else { %>
                                            <div
                                                style="margin-top: 25px; text-align: center; color: var(--accent-foreground); font-weight: 600;">
                                                <i class="ph ph-trophy"></i> You have reached the highest tier!
                                            </div>
                                            <% } %>
                            </div>

                            <!-- Diagnostic Tool Access Requirements -->
                            <div class="volunteer-stats">
                                <h3>Diagnostic Tool Access</h3>
                                <div style="color: var(--muted-foreground); font-size: 0.95em; line-height: 1.6;">
                                    <p style="margin-bottom: 15px;">
                                        To gain access to the <strong>Smart Diagnostic Decision Tree</strong>
                                        contribution tools, you must demonstrate consistent quality and expertise.
                                    </p>
                                    <ul style="list-style: none; padding: 0;">
                                        <li style="margin-bottom: 10px; display: flex; align-items: center; gap: 10px;">
                                            <span style="font-size: 1.2em;"><i class="ph ph-pipe-wrench"></i></span>
                                            <span>Reach <strong>Diagnostic Contributor</strong> tier (150+
                                                Reputation)</span>
                                        </li>
                                        <li style="margin-bottom: 10px; display: flex; align-items: center; gap: 10px;">
                                            <span style="font-size: 1.2em;"><i class="ph ph-star"></i></span>
                                            <span>Maintain <strong>90%+ Approval Rating</strong></span>
                                        </li>
                                        <li style="margin-bottom: 10px; display: flex; align-items: center; gap: 10px;">
                                            <span style="font-size: 1.2em;"><i class="ph ph-clipboard-text"></i></span>
                                            <span>Contribute at least <strong>10 High-Quality Guides</strong></span>
                                        </li>
                                    </ul>
                                    <div
                                        style="margin-top: 15px; padding: 10px; background: var(--muted); border-radius: var(--radius-md); font-size: 0.85em; border-left: 3px solid var(--accent);">
                                        <strong>Note:</strong> Access is granted automatically once criteria are met.
                                    </div>
                                </div>
                            </div>

                            <div class="section-grid">
                                <!-- Top Guides -->
                                <div class="volunteer-stats">
                                    <h3>Top Rated Guides</h3>
                                    <% if (topGuides !=null && !topGuides.isEmpty()) { %>
                                        <ul class="top-guides-list">
                                            <% for (Guide g : topGuides) { %>
                                                <li class="top-guide-item">
                                                    <c:if test="<%= g.getMainImagePath() != null %>">
                                                        <img src="${pageContext.request.contextPath}/<%= g.getMainImagePath() %>"
                                                            class="top-guide-img" alt="Guide">
                                                    </c:if>
                                                    <div class="top-guide-info">
                                                        <a href="${pageContext.request.contextPath}/ViewGuideServlet?id=<%= g.getGuideId() %>"
                                                            class="top-guide-title">
                                                            <%= g.getTitle() %>
                                                        </a>
                                                        <span class="top-guide-meta">
                                                            <%= g.getMainCategory() %> • <%= g.getViewCount() %> views
                                                        </span>
                                                    </div>
                                                </li>
                                                <% } %>
                                        </ul>
                                        <% } else { %>
                                            <p style="color: var(--muted-foreground); padding: 10px 0;">No guides
                                                ratings yet.</p>
                                            <% } %>
                                </div>

                                <!-- Quick Actions -->
                                <div class="volunteer-stats">
                                    <h3>Quick Actions</h3>
                                    <div class="quick-links">
                                        <a href="${pageContext.request.contextPath}/guides/create"
                                            class="quick-link-btn">
                                            <span><i class="ph ph-pencil-ruler"></i></span> Create Guide
                                        </a>
                                        <a href="${pageContext.request.contextPath}/pages/guides/my-guides.jsp"
                                            class="quick-link-btn">
                                            <span><i class="ph ph-folder"></i></span> My Guides
                                        </a>
                                        <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/guideComments.jsp"
                                            class="quick-link-btn">
                                            <span><i class="ph ph-chat-circle-dots"></i></span> Comments
                                        </a>
                                        <a href="${pageContext.request.contextPath}/pages/dashboards/volunteerdash/myProfile.jsp"
                                            class="quick-link-btn">
                                            <span><i class="ph ph-user"></i></span> Profile
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </main>
                        <script
                            src="${pageContext.request.contextPath}/assets/js/volunteer-dashboard-charts.js"></script>
                        <script>
                            // Initialize Dashboard Animations with data from JSP
                            document.addEventListener("DOMContentLoaded", function () {
                                // Chart data from server
                                const chartData = {
                                    labels: ['Guides', 'Approval'],
                                    values: [
                                        <%= stats.getContributionScore() %>,
                                        <%= stats.getQualityScore() %>
                                    ]
                                };

                                // Initialize all dashboard animations
                                if (window.VolunteerDashboardCharts) {
                                    window.VolunteerDashboardCharts.init(chartData);
                                }
                            });
                        </script>
                    </body>
                    </html>