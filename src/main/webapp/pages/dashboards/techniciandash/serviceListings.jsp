<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.dailyfixer.model.Service" %>
            <%@ page import="com.dailyfixer.dao.ServiceDAO" %>
                <%@ page import="com.dailyfixer.model.User" %>

                    <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
                        !"technician".equalsIgnoreCase(user.getRole())) { response.sendRedirect(request.getContextPath()
                        + "/pages/authentication/login.jsp" ); return; } ServiceDAO dao=new ServiceDAO(); List<Service> services =
                        dao.getServicesByTechnician(user.getUserId());
                        %>

                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>Service Listings | Daily Fixer</title>
                            <!-- Use our shared framework font stack instead of directly loading Inter -->
                            <link
                                href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
                                rel="stylesheet">
                            <!-- Include global framework.css for styles and dark mode -->
                            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">

                            <style>
                                img.service-thumb {
                                    width: 80px;
                                    height: 60px;
                                    border-radius: var(--radius-md);
                                    object-fit: cover;
                                    border: 1px solid var(--border);
                                }

                                .actions {
                                    white-space: nowrap;
                                }
                            </style>
                        </head>

                        <body class="dashboard-layout">

                            <jsp:include page="sidebar.jsp" />

                            <main class="dashboard-container">
                                <!-- Page Header Area -->
                                <div class="dashboard-header"
                                    style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                                    <div>
                                        <h1>My Service Listings</h1>
                                        <p>Manage the services you offer to customers.</p>
                                    </div>

                                    <a href="${pageContext.request.contextPath}/AddServiceServlet" class="btn-primary"
                                        style="display: flex; align-items: center; gap: 8px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20"
                                            viewBox="0 0 256 256">
                                            <path fill="currentColor"
                                                d="M228 128a12 12 0 0 1-12 12h-76v76a12 12 0 0 1-24 0v-76H40a12 12 0 0 1 0-24h76V40a12 12 0 0 1 24 0v76h76a12 12 0 0 1 12 12Z" />
                                        </svg>
                                        Add New Service
                                    </a>
                                </div>

                                <!-- Table Container Area -->
                                <div class="table-container section">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Image</th>
                                                <th>Service Name</th>
                                                <th>Category</th>
                                                <th>Pricing Type</th>
                                                <th>Charges</th>
                                                <th>Recurring</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (services !=null && !services.isEmpty()) { for (Service s : services)
                                                { %>
                                                <tr>
                                                    <td>
                                                        <img src="${pageContext.request.contextPath}/ServiceImageServlet?service_id=<%=s.getServiceId()%>"
                                                            class="service-thumb" alt="Service Image">
                                                    </td>
                                                    <td style="font-weight: 500;">
                                                        <%=s.getServiceName()%>
                                                    </td>
                                                    <td><span
                                                            style="background: var(--muted); padding: 4px 8px; border-radius: 4px; font-size: 0.85em;">
                                                            <%=s.getCategory()%>
                                                        </span></td>
                                                    <td>
                                                        <%=s.getPricingType().equals("fixed") ? "Fixed (Rs. " +
                                                            s.getFixedRate() + ")" : "Hourly (Rs. " + s.getHourlyRate()
                                                            + "/hr)" %>
                                                    </td>
                                                    <td style="font-size: 0.9em; color: var(--muted-foreground);">
                                                        Inspection: <span
                                                            style="font-weight: 600; color: var(--foreground);">Rs.
                                                            <%=s.getInspectionCharge()%>
                                                        </span><br>
                                                        Transport: <span
                                                            style="font-weight: 600; color: var(--foreground);">Rs.
                                                            <%=s.getTransportCharge()%>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <% if (s.isRecurringEnabled()) { %>
                                                            <span style="display: inline-block; background: #dbeafe; color: #1e40af; padding: 3px 9px; border-radius: 4px; font-size: 0.82em; font-weight: 600; white-space: nowrap;">
                                                                &#8635; Rs. <%=(int)s.getRecurringFee()%>/mo
                                                            </span>
                                                        <% } else { %>
                                                            <span style="color: var(--muted-foreground); font-size: 0.85em;">—</span>
                                                        <% } %>
                                                    </td>
                                                    <td class="actions">
                                                        <a href="${pageContext.request.contextPath}/EditServiceServlet?id=<%= s.getServiceId() %>"
                                                            class="action-btn btn-secondary">Edit</a>
                                                        <a href="${pageContext.request.contextPath}/DeleteServiceServlet?id=<%=s.getServiceId()%>"
                                                            onclick="return confirm('Are you sure you want to delete this service?');"
                                                            class="action-btn btn-danger">Delete</a>
                                                    </td>
                                                </tr>
                                                <% } } else { %>
                                                    <tr>
                                                        <td colspan="7">
                                                            <div class="empty-state">
                                                                <svg xmlns="http://www.w3.org/2000/svg" width="64"
                                                                    height="64" viewBox="0 0 256 256"
                                                                    style="color: var(--muted-foreground); margin-bottom: 16px;">
                                                                    <path fill="currentColor"
                                                                        d="M224 48H32a8 8 0 0 0-8 8v144a8 8 0 0 0 8 8h192a8 8 0 0 0 8-8V56a8 8 0 0 0-8-8Zm-8 144H40V64h176ZM88 152a8 8 0 0 1-8 8H56a8 8 0 0 1-8-8v-24a8 8 0 0 1 8-8h24a8 8 0 0 1 8 8Zm64 0a8 8 0 0 1-8 8h-24a8 8 0 0 1-8-8v-48a8 8 0 0 1 8-8h24a8 8 0 0 1 8 8Zm64 0a8 8 0 0 1-8 8h-24a8 8 0 0 1-8-8v-72a8 8 0 0 1 8-8h24a8 8 0 0 1 8 8Z" />
                                                                </svg>
                                                                <h3>No Services Found</h3>
                                                                <p>You haven't added any services yet. Click "Add New
                                                                    Service" to get started.</p>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </main>
                        </body>
                        </html>