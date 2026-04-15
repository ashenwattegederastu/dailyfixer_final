<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ page import="com.dailyfixer.model.User" %>

            <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                !"technician".equalsIgnoreCase(user.getRole())) { response.sendRedirect(request.getContextPath()
                + "/pages/authentication/login.jsp" ); return; } String profilePath=request.getContextPath() + "/technician/profile" ; %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Edit Profile | Daily Fixer</title>
                    <!-- Use our shared framework font stack instead of directly loading Inter -->
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                        rel="stylesheet">
                    <!-- Include global framework.css for styles and dark mode -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                </head>

                <body class="dashboard-layout">

                    <jsp:include page="sidebar.jsp" />

                    <main class="dashboard-container">

                        <div style="margin-bottom: 24px;">
                            <a href="<%= profilePath %>" class="btn-secondary"
                                style="display: inline-flex; align-items: center; gap: 8px; font-size: 0.9rem; padding: 0.5rem 1rem;">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 256 256">
                                    <path fill="currentColor"
                                        d="M224 128a8 8 0 0 1-8 8H59.31l58.35 58.34a8 8 0 0 1-11.32 11.32l-72-72a8 8 0 0 1 0-11.32l72-72a8 8 0 0 1 11.32 11.32L59.31 120H216a8 8 0 0 1 8 8Z" />
                                </svg>
                                Back to Profile
                            </a>
                        </div>

                        <div class="form-container">
                            <h2 style="margin-bottom: 24px; color: var(--foreground); font-size: 1.8rem;">Edit Account
                                Info</h2>

                            <form action="${pageContext.request.contextPath}/UpdateProfileServlet" method="post"
                                enctype="multipart/form-data">
                                <input type="hidden" name="userId" value="${sessionScope.currentUser.userId}">
                                <input type="hidden" name="returnUrl" value="${pageContext.request.requestURI}">

                                <!-- Profile Picture Upload -->
                                <div class="form-group" style="margin-bottom: 24px;">
                                    <label>Profile Picture</label>
                                    <div style="display: flex; align-items: center; gap: 16px; margin-top: 8px;">
                                        <div
                                            style="width: 80px; height: 80px; border-radius: 50%; overflow: hidden; background: var(--primary); display: flex; align-items: center; justify-content: center; color: var(--primary-foreground); font-size: 2em; font-weight: bold;">
                                            <% if (user.getProfilePicturePath() !=null &&
                                                !user.getProfilePicturePath().isEmpty()) { %>
                                                <img src="<%= request.getContextPath() + " /" +
                                                    user.getProfilePicturePath() %>" alt="Profile"
                                                style="width:100%;height:100%;object-fit:cover;">
                                                <% } else { %>
                                                    <%= user.getFirstName() !=null && user.getFirstName().length()> 0 ?
                                                        user.getFirstName().substring(0,1).toUpperCase() : "?" %>
                                                        <% } %>
                                        </div>
                                        <input type="file" name="profilePicture" accept="image/*" style="flex: 1;">
                                    </div>
                                </div>

                                <div class="form-group"
                                    style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                                    <div>
                                        <label>First Name</label>
                                        <input type="text" name="firstName"
                                            value="${sessionScope.currentUser.firstName}" required>
                                    </div>
                                    <div>
                                        <label>Last Name</label>
                                        <input type="text" name="lastName" value="${sessionScope.currentUser.lastName}"
                                            required>
                                    </div>
                                </div>

                                <div class="form-group"
                                    style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                                    <div>
                                        <label>Phone Number</label>
                                        <input type="text" name="phoneNumber"
                                            value="${sessionScope.currentUser.phoneNumber}" required pattern="[0-9]{10}"
                                            title="Enter 10 digit phone number">
                                    </div>
                                    <div>
                                        <label>City / Region</label>
                                        <select name="city" required class="filter-select"
                                            style="width: 100%; border: 2px solid var(--border); box-shadow: none;">
                                            <option value="">Select City</option>
                                            <c:forEach var="city"
                                                items="${['Colombo','Kandy','Galle','Matara','Jaffna','Kurunegala','Negombo','Anuradhapura','Ratnapura','Nuwara Eliya','Gampaha','Trincomalee','Badulla','Hambantota','Batticaloa','Kalutara','Polonnaruwa']}">
                                                <option value="${city}" <c:if
                                                    test="${sessionScope.currentUser.city == city}">selected</c:if>
                                                    >${city}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>

                                <!-- About Me / Bio -->
                                <div class="form-group" style="margin-top: 16px;">
                                    <label>About Me</label>
                                    <textarea name="bio" rows="4"
                                        placeholder="Tell customers about yourself, your experience, and your specialties..."
                                        style="width: 100%; resize: vertical;"><%= user.getBio() != null ? user.getBio() : "" %></textarea>
                                </div>

                                <div class="form-actions"
                                    style="margin-top: 32px; display: flex; justify-content: flex-end; gap: 12px;">
                                    <a href="<%= profilePath %>" class="btn-secondary"
                                        style="padding: 12px 24px;">Cancel</a>
                                    <button type="submit" class="btn-primary" style="padding: 12px 24px;">Save
                                        Changes</button>
                                </div>
                            </form>
                        </div>
                    </main>
                </body>
                </html>