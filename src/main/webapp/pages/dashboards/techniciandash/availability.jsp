<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set Availability - Technician Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=Lora:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
</head>
<body>
    <jsp:include page="sidebar.jsp" />
    
    <div class="dashboard-container">
        <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 1rem; color: var(--foreground);">Set Your Availability</h1>
        
        <c:if test="${param.success}">
            <div style="background: #10b981; color: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1rem;">
                Availability updated successfully!
            </div>
        </c:if>
        
        <form method="post" action="${pageContext.request.contextPath}/availability">
            <div style="background: var(--card); padding: 1.5rem; border-radius: var(--radius); box-shadow: var(--shadow-sm);">
                <h3 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem;">Working Schedule</h3>
                
                <div style="margin-bottom: 1.5rem;">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Availability Mode *</label>
                    <select name="availabilityMode" id="availabilityMode" required onchange="toggleDaysSelection()"
                            style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input);">
                        <option value="WEEKDAYS" ${availability.availabilityMode == 'WEEKDAYS' ? 'selected' : ''}>Weekdays (Mon-Fri)</option>
                        <option value="WEEKENDS" ${availability.availabilityMode == 'WEEKENDS' ? 'selected' : ''}>Weekends (Sat-Sun)</option>
                        <option value="CUSTOM" ${availability.availabilityMode == 'CUSTOM' ? 'selected' : ''}>Custom Days</option>
                    </select>
                </div>
                
                <div id="customDays" style="margin-bottom: 1.5rem; display: ${availability.availabilityMode == 'CUSTOM' ? 'block' : 'none'};">
                    <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Select Available Days:</label>
                    <div style="display: flex; flex-wrap: wrap; gap: 0.5rem;">
                        <label style="display: flex; align-items: center; padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: 0.5rem; cursor: pointer;">
                            <input type="checkbox" name="monday" ${availability.monday ? 'checked' : ''} style="margin-right: 0.5rem;"> Monday
                        </label>
                        <label style="display: flex; align-items: center; padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: 0.5rem; cursor: pointer;">
                            <input type="checkbox" name="tuesday" ${availability.tuesday ? 'checked' : ''} style="margin-right: 0.5rem;"> Tuesday
                        </label>
                        <label style="display: flex; align-items: center; padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: 0.5rem; cursor: pointer;">
                            <input type="checkbox" name="wednesday" ${availability.wednesday ? 'checked' : ''} style="margin-right: 0.5rem;"> Wednesday
                        </label>
                        <label style="display: flex; align-items: center; padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: 0.5rem; cursor: pointer;">
                            <input type="checkbox" name="thursday" ${availability.thursday ? 'checked' : ''} style="margin-right: 0.5rem;"> Thursday
                        </label>
                        <label style="display: flex; align-items: center; padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: 0.5rem; cursor: pointer;">
                            <input type="checkbox" name="friday" ${availability.friday ? 'checked' : ''} style="margin-right: 0.5rem;"> Friday
                        </label>
                        <label style="display: flex; align-items: center; padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: 0.5rem; cursor: pointer;">
                            <input type="checkbox" name="saturday" ${availability.saturday ? 'checked' : ''} style="margin-right: 0.5rem;"> Saturday
                        </label>
                        <label style="display: flex; align-items: center; padding: 0.5rem 1rem; border: 1px solid var(--border); border-radius: 0.5rem; cursor: pointer;">
                            <input type="checkbox" name="sunday" ${availability.sunday ? 'checked' : ''} style="margin-right: 0.5rem;"> Sunday
                        </label>
                    </div>
                </div>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.5rem;">
                    <div>
                        <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Start Time *</label>
                        <input type="time" name="startTime" required value="${not empty availability and not empty availability.startTime ? fn:substring(availability.startTime, 0, 5) : '09:00'}"
                               style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input);">
                    </div>
                    <div>
                        <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">End Time *</label>
                        <input type="time" name="endTime" required value="${not empty availability and not empty availability.endTime ? fn:substring(availability.endTime, 0, 5) : '17:00'}"
                               style="width: 100%; padding: 0.75rem; border: 1px solid var(--border); border-radius: 0.5rem; background: var(--input);">
                    </div>
                </div>
                
                <div style="display: flex; gap: 1rem;">
                    <button type="submit" style="flex: 1; background: var(--primary); color: var(--primary-foreground); padding: 0.75rem; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer;">
                        Save Availability
                    </button>
                    <a href="${pageContext.request.contextPath}/technician/dashboard" 
                       style="flex: 1; text-align: center; background: var(--secondary); color: var(--secondary-foreground); padding: 0.75rem; border-radius: 0.5rem; text-decoration: none; font-weight: 600; display: flex; align-items: center; justify-content: center;">
                        Cancel
                    </a>
                </div>
            </div>
        </form>
    </div>
    
    <script>
        function toggleDaysSelection() {
            const mode = document.getElementById('availabilityMode').value;
            const customDays = document.getElementById('customDays');
            customDays.style.display = mode === 'CUSTOM' ? 'block' : 'none';
        }
    </script>
</body>
</html>
