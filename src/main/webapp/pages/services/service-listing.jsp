<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
    <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Book a Technician - Daily Fixer</title>
            <jsp:include page="../shared/header.jsp" />
            <style>
                body {
                    background-image: url('<%= request.getContextPath() %>/assets/images/backgrounds/guides.jpg'); /* your image path */
                    background-size: cover;       /* fill entire screen */
                    background-repeat: no-repeat; /* no tiling */
                    background-position: center;  /* center the image */
                }

                .service-hero {
                    position: relative;
                    min-height: 55vh;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    text-align: center;
                    padding: 130px 30px 70px;
                }

                .service-hero-content {
                    position: relative;
                    z-index: 1;
                    width: 100%;
                }

                .service-hero-content h1 {
                    font-size: 3rem;
                    font-weight: 800;
                    color: var(--foreground);
                    margin-bottom: 12px;
                    letter-spacing: -0.02em;
                }

                .service-slogan {
                    font-size: 1.5rem;
                    font-weight: 500;
                    color: var(--foreground);
                    margin-bottom: 15px;
                }

                .service-hero-content p {
                    font-size: 1.15rem;
                    color: var(--muted-foreground);
                    margin-bottom: 36px;
                }

                .service-search-wrapper {
                    position: relative;
                    max-width: 800px;
                    width: 100%;
                    margin: 0 auto;
                }

                .service-search-form {
                    display: flex;
                    gap: 0;
                    border-radius: var(--radius-lg);
                    overflow: hidden;
                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.35);
                    background: #fff;
                }

                .service-search-form input[type="text"],
                .service-search-form select {
                    flex: 1;
                    padding: 16px 20px;
                    border: none;
                    border-right: 1px solid #eee;
                    background: transparent;
                    color: #111;
                    font-size: 1rem;
                    outline: none;
                }

                .service-search-form select {
                    appearance: auto;
                    cursor: pointer;
                }

                .service-search-form button {
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

                .service-search-form button:hover {
                    opacity: 0.88;
                }
            </style>
        </head>

        <body>
            <div class="service-hero">
                <div class="service-hero-content">
                    <h1>Book a Technician</h1>
                    <p>Find the best local professionals for all your home repair and maintenance needs</p>

                    <div class="service-search-wrapper">
                        <form class="service-search-form" method="get" action="${pageContext.request.contextPath}/services">
                            <input type="text" name="search" value="${searchQuery}" placeholder="Search services...">
                            <select name="category">
                                <option value="">All Categories</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.name}" ${selectedCategory==cat.name ? 'selected' : '' }>
                                        ${cat.name}
                                    </option>
                                </c:forEach>
                            </select>
                            <select name="city">
                                <option value="">All Cities</option>
                                <c:forEach var="city" items="${cities}">
                                    <option value="${city}" ${selectedCity==city ? 'selected' : ''}>${city}</option>
                                </c:forEach>
                            </select>
                            <button type="submit">
                                <i class="ph ph-magnifying-glass"></i> Search
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <div style="max-width: 1200px; margin: 0 auto 2rem; padding: 0 1rem;">

                <!-- Services Grid -->
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem;">
                    <c:forEach var="service" items="${services}">
                        <c:set var="tech" value="${techUsers[service.technicianId]}" />
                        <c:set var="completedJobs" value="${techJobsCount[service.technicianId] != null ? techJobsCount[service.technicianId] : 0}" />

                        <div style="background: var(--card); border-radius: var(--radius-lg); padding: 1.5rem; box-shadow: var(--shadow-sm); border: 1px solid var(--border); display: flex; flex-direction: column; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-4px)'; this.style.boxShadow='var(--shadow-md)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='var(--shadow-sm)';">
                            
                            <!-- Service Name -->
                            <h2 style="font-size: 1.25rem; font-weight: 700; color: var(--foreground); margin: 0 0 1.25rem 0; line-height: 1.3;">
                                ${service.serviceName}
                            </h2>

                            <!-- Profile Header -->
                            <div style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.25rem;">
                                <!-- Avatar -->
                                <div style="width: 55px; height: 55px; border-radius: 50%; overflow: hidden; background: var(--muted); flex-shrink: 0; display: flex; align-items: center; justify-content: center; border: 1px solid var(--border);">
                                    <c:choose>
                                        <c:when test="${not empty tech.profilePicturePath}">
                                            <img src="${pageContext.request.contextPath}/${tech.profilePicturePath}" alt="Avatar" style="width: 100%; height: 100%; object-fit: cover;">
                                        </c:when>
                                        <c:otherwise>
                                            <i class="ph ph-user-circle" style="font-size: 30px; color: var(--muted-foreground);"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <!-- Name & Location -->
                                <div>
                                    <h3 style="font-size: 1.15rem; font-weight: 600; color: var(--foreground); margin: 0 0 0.2rem 0;">
                                        ${tech.firstName} ${fn:substring(tech.lastName, 0, 1)}.
                                    </h3>
                                    <p style="color: var(--muted-foreground); font-size: 0.9rem; margin: 0;">
                                        ${tech.city}, Sri Lanka
                                    </p>
                                </div>
                            </div>

                            <!-- Metrics Row -->
                            <div style="display: flex; gap: 1.25rem; align-items: center; margin-bottom: 0.75rem;">
                                <!-- Rate -->
                                <span style="font-size: 1.1rem; font-weight: 600; color: var(--primary);">
                                    <c:choose>
                                        <c:when test="${service.pricingType == 'fixed'}">
                                            Rs.${service.fixedRate}
                                        </c:when>
                                        <c:otherwise>
                                            Rs.${service.hourlyRate}/hr
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                                
                                <!-- Rating -->
                                <div style="display: flex; align-items: center; gap: 0.3rem; font-size: 1.05rem; font-weight: 500; color: var(--foreground);">
                                    <i class="ph-fill ph-star" style="color: #f59e0b; font-size: 1.2rem;"></i>
                                    <c:choose>
                                        <c:when test="${techRatingCounts[service.technicianId] > 0}">
                                            <fmt:formatNumber value="${techAvgRatings[service.technicianId]}" maxFractionDigits="1" minFractionDigits="1"/>
                                        </c:when>
                                        <c:otherwise>
                                            No Rating
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Jobs -->
                                <div style="display: flex; align-items: center; gap: 0.4rem; font-size: 1.05rem; font-weight: 500; color: var(--foreground);">
                                    <i class="ph ph-suitcase-simple" style="color: var(--foreground); font-size: 1.2rem;"></i>
                                    ${completedJobs} jobs
                                </div>
                            </div>

                            <!-- Extra Charges -->
                            <div style="display: flex; flex-direction: column; gap: 0.25rem; margin-bottom: 1.25rem;">
                                <c:if test="${service.inspectionCharge > 0}">
                                    <span style="font-size: 0.85rem; color: var(--muted-foreground);">+ Inspection: Rs.${service.inspectionCharge}</span>
                                </c:if>
                                <c:if test="${service.transportCharge > 0}">
                                    <span style="font-size: 0.85rem; color: var(--muted-foreground);">+ Transport: Rs.${service.transportCharge}</span>
                                </c:if>
                            </div>

                            <!-- Description -->
                            <p style="color: var(--muted-foreground); font-size: 0.95rem; line-height: 1.6; margin-bottom: 1.25rem; flex-grow: 1; display: -webkit-box; -webkit-line-clamp: 3; line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;">
                                ${service.description}
                            </p>

                            <!-- Tags -->
                            <div style="margin-bottom: 1.5rem; display: flex; flex-wrap: wrap; gap: 0.5rem;">
                                <span style="background: var(--muted); color: var(--foreground); padding: 0.4rem 0.8rem; border-radius: 20px; font-size: 0.85rem; font-weight: 500;">
                                    ${service.category}
                                </span>
                                <c:if test="${service.recurringEnabled}">
                                    <span style="background: #dbeafe; color: #1e40af; padding: 0.4rem 0.8rem; border-radius: 20px; font-size: 0.85rem; font-weight: 600;">
                                        &#8635; Recurring Available
                                    </span>
                                </c:if>
                            </div>

                            <!-- See Profile Button -->
                            <a href="${pageContext.request.contextPath}/bookings/create?serviceId=${service.serviceId}"
                                style="display: block; text-align: center; background: #16a34a; color: white; padding: 0.75rem; border-radius: var(--radius-md); text-decoration: none; font-weight: 600; font-size: 1rem; transition: background 0.2s;" onmouseover="this.style.background='#15803d';" onmouseout="this.style.background='#16a34a';">
                                Book This Service
                            </a>
                        </div>
                    </c:forEach>
                </div>

                <c:if test="${empty services}">
                    <div
                        style="text-align: center; padding: 3rem; background: var(--card); border-radius: 0; margin-top: 2rem;">
                        <p style="font-size: 1.125rem; color: var(--muted-foreground);">No services found matching your criteria.</p>
                    </div>
                </c:if>
            </div>
        </body>

        </html>