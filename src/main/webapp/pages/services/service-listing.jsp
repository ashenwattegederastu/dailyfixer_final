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
        </head>

        <body>
            <div style="max-width: 1200px; margin: 100px auto 2rem; padding: 0 1rem;">
                <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; color: var(--foreground);">Book a
                    Technician</h1>

                <!-- Search and Filter Section -->
                <div
                    style="background: var(--card); padding: 1.5rem; border-radius: 0; margin-bottom: 2rem; box-shadow: var(--shadow-sm);">
                    <form method="get" action="${pageContext.request.contextPath}/services">
                        <div
                            style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1rem;">
                            <div>
                                <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Search</label>
                                <input type="text" name="search" value="${searchQuery}" placeholder="Search services..."
                                    style="width: 100%; padding: 0.5rem; border: 1px solid var(--border); border-radius: 0; background: var(--input);">
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Category</label>
                                <select name="category"
                                    style="width: 100%; padding: 0.5rem; border: 1px solid var(--border); border-radius: 0; background: var(--input);">
                                    <option value="">All Categories</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.name}" ${selectedCategory==cat.name ? 'selected' : '' }>
                                            ${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">City</label>
                                <select name="city"
                                    style="width: 100%; padding: 0.5rem; border: 1px solid var(--border); border-radius: 0; background: var(--input);">
                                    <option value="">All Cities</option>
                                    <c:forEach var="city" items="${cities}">
                                        <option value="${city}" ${selectedCity==city ? 'selected' : ''}>${city}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <button type="submit"
                            style="background: var(--primary); color: var(--primary-foreground); padding: 0.5rem 1.5rem; border: none; border-radius: 0; font-weight: 600; cursor: pointer;">
                            Search
                        </button>
                    </form>
                </div>

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