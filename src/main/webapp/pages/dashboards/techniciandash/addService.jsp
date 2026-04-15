<%@ page contentType="text/html;charset=UTF-8" %>
  <%@ taglib uri="jakarta.tags.core" prefix="c" %>
    <%@ page import="com.dailyfixer.model.User" %>

      <% User user=(User) session.getAttribute("currentUser"); if (user==null || user.getRole()==null ||
        !"technician".equalsIgnoreCase(user.getRole())) { response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp"
        ); return; } %>

        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Add New Service | Daily Fixer</title>
          <link
            href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap"
            rel="stylesheet">
          <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
        </head>

        <body class="dashboard-layout">

          <jsp:include page="sidebar.jsp" />

          <main class="dashboard-container">

            <div style="margin-bottom: 24px;">
              <a href="${pageContext.request.contextPath}/pages/dashboards/techniciandash/serviceListings.jsp"
                class="btn-secondary"
                style="display: inline-flex; align-items: center; gap: 8px; font-size: 0.9rem; padding: 0.5rem 1rem;">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 256 256">
                  <path fill="currentColor"
                    d="M224 128a8 8 0 0 1-8 8H59.31l58.35 58.34a8 8 0 0 1-11.32 11.32l-72-72a8 8 0 0 1 0-11.32l72-72a8 8 0 0 1 11.32 11.32L59.31 120H216a8 8 0 0 1 8 8Z" />
                </svg>
                Back to Listings
              </a>
            </div>

            <!-- Form layout using standard framework constraints -->
            <div class="form-container">
              <h2 style="margin-bottom: 24px; color: var(--foreground); font-size: 1.8rem;">Add New Service</h2>

              <form action="${pageContext.request.contextPath}/AddServiceServlet" method="post"
                enctype="multipart/form-data">

                <div class="form-group">
                  <label>Service Name:</label>
                  <input type="text" name="serviceName" required placeholder="e.g. Broken Pipe Repair">
                </div>

                <div class="form-group">
                  <label>Category:</label>
                  <select name="category" id="categorySelect" class="filter-select"
                    style="width: 100%; border: 2px solid var(--border); box-shadow: none;" required
                    onchange="toggleNewCategory()">
                    <option value="">Select Category</option>
                    <c:forEach var="cat" items="${categories}">
                      <option value="${cat.name}">${cat.name}</option>
                    </c:forEach>
                    <option value="__new__">+ Add New Category</option>
                  </select>
                </div>

                <div class="form-group" id="newCategoryDiv" style="display:none;">
                  <label>New Category Name:</label>
                  <input type="text" name="newCategoryName" id="newCategoryInput" placeholder="e.g. Plumbing">
                </div>

                <div class="form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                  <div>
                    <label>Pricing Type:</label>
                    <select name="pricingType" id="pricingType" class="filter-select"
                      style="width: 100%; border: 2px solid var(--border); box-shadow: none;" required
                      onchange="toggleRates()">
                      <option value="">Select Type</option>
                      <option value="hourly">Hourly</option>
                      <option value="fixed">Fixed</option>
                    </select>
                  </div>
                </div>

                <div class="form-group" id="hourlyRateDiv" style="display:none;">
                  <label>Hourly Rate (Rs):</label>
                  <input type="number" name="hourlyRate" min="0" step="1"
                    style="width: 100%; padding: 10px 15px; border: 2px solid var(--border); border-radius: var(--radius-md); background-color: var(--input); color: var(--foreground);">
                </div>

                <div class="form-group" id="fixedRateDiv" style="display:none;">
                  <label>Fixed Charge (Rs):</label>
                  <input type="number" name="fixedRate" min="0" step="1"
                    style="width: 100%; padding: 10px 15px; border: 2px solid var(--border); border-radius: var(--radius-md); background-color: var(--input); color: var(--foreground);">
                </div>

                <div class="form-group" style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                  <div>
                    <label>Inspection Charge (Rs):</label>
                    <input type="number" name="inspectionCharge" min="0" step="1" required
                      style="width: 100%; padding: 10px 15px; border: 2px solid var(--border); border-radius: var(--radius-md); background-color: var(--input); color: var(--foreground);">
                  </div>
                  <div>
                    <label>Transport Charge (Rs):</label>
                    <input type="number" name="transportCharge" min="0" step="1" required
                      style="width: 100%; padding: 10px 15px; border: 2px solid var(--border); border-radius: var(--radius-md); background-color: var(--input); color: var(--foreground);">
                  </div>
                </div>

                <div class="form-group">
                  <label>Service Description:</label>
                  <textarea name="description" placeholder="Brief overview of the service you offer..." rows="4" style="width: 100%; padding: 10px 15px; border: 2px solid var(--border); border-radius: var(--radius-md); background-color: var(--input); color: var(--foreground); resize: vertical;"></textarea>
                </div>

                <div class="form-group" style="margin-top: 24px;">
                  <label>Service Thumbnail Image:</label>
                  <input type="file" name="serviceImage" accept="image/*" style="background-color: var(--card);">
                </div>

                <!-- Recurring Bookings -->
                <div class="form-group" style="margin-top: 8px; padding: 16px; border: 2px solid var(--border); border-radius: var(--radius-md); background: var(--muted);">
                  <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                    <input type="checkbox" name="recurringEnabled" id="recurringEnabled" onchange="toggleRecurring()" style="width: 18px; height: 18px; cursor: pointer; accent-color: var(--primary);">
                    <label for="recurringEnabled" style="font-weight: 600; cursor: pointer; margin: 0;">Enable Recurring Bookings</label>
                  </div>
                  <p style="font-size: 0.85rem; color: var(--muted-foreground); margin: 0 0 12px 28px;">Customers can book this service monthly for 1 year (12 bookings). Payments are handled directly between you and the customer.</p>
                  <div id="recurringFeeDiv" style="display: none; margin-top: 8px;">
                    <label style="font-weight: 500;">Monthly Recurring Fee (Rs):</label>
                    <input type="number" name="recurringFee" id="recurringFee" min="0" step="1"
                      style="width: 100%; padding: 10px 15px; border: 2px solid var(--border); border-radius: var(--radius-md); background-color: var(--input); color: var(--foreground);"
                      placeholder="e.g. 2500">
                    <p style="font-size: 0.8rem; color: var(--muted-foreground); margin-top: 4px;">This is the total monthly fee shown to the customer for the recurring contract.</p>
                  </div>
                </div>

                <div class="form-actions">
                  <button type="submit" class="btn-primary" style="width: 100%; justify-content: center;">Create
                    Service</button>
                </div>
              </form>
            </div>
          </main>

          <script>
            function toggleRates() {
              const type = document.getElementById('pricingType').value;
              document.getElementById('hourlyRateDiv').style.display = type === 'hourly' ? 'block' : 'none';
              document.getElementById('fixedRateDiv').style.display = type === 'fixed' ? 'block' : 'none';
            }

            function toggleNewCategory() {
              const select = document.getElementById('categorySelect');
              const newCatDiv = document.getElementById('newCategoryDiv');
              const newCatInput = document.getElementById('newCategoryInput');
              if (select.value === '__new__') {
                newCatDiv.style.display = 'block';
                newCatInput.required = true;
              } else {
                newCatDiv.style.display = 'none';
                newCatInput.required = false;
                newCatInput.value = '';
              }
            }

            function toggleRecurring() {
              const enabled = document.getElementById('recurringEnabled').checked;
              const feeDiv = document.getElementById('recurringFeeDiv');
              const feeInput = document.getElementById('recurringFee');
              feeDiv.style.display = enabled ? 'block' : 'none';
              feeInput.required = enabled;
            }
          </script>
        </body>
        </html>