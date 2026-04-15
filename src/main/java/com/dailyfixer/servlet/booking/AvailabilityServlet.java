package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.TechnicianAvailabilityDAO;
import com.dailyfixer.model.TechnicianAvailability;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalTime;
import java.sql.Time;

@WebServlet("/availability")
public class AvailabilityServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            TechnicianAvailabilityDAO dao = new TechnicianAvailabilityDAO();
            TechnicianAvailability availability = dao.getAvailabilityByTechnicianId(currentUser.getUserId());
            
            request.setAttribute("availability", availability);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/availability.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading availability: " + e.getMessage());
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            String availabilityMode = request.getParameter("availabilityMode");
            String startTime = request.getParameter("startTime");
            String endTime = request.getParameter("endTime");
            
            TechnicianAvailability availability = new TechnicianAvailability();
            availability.setTechnicianId(currentUser.getUserId());
            availability.setAvailabilityMode(availabilityMode);
            availability.setStartTime(parseSqlTime(startTime));
            availability.setEndTime(parseSqlTime(endTime));
            
            // Set days based on mode
            if ("WEEKDAYS".equals(availabilityMode)) {
                availability.setMonday(true);
                availability.setTuesday(true);
                availability.setWednesday(true);
                availability.setThursday(true);
                availability.setFriday(true);
                availability.setSaturday(false);
                availability.setSunday(false);
            } else if ("WEEKENDS".equals(availabilityMode)) {
                availability.setMonday(false);
                availability.setTuesday(false);
                availability.setWednesday(false);
                availability.setThursday(false);
                availability.setFriday(false);
                availability.setSaturday(true);
                availability.setSunday(true);
            } else { // CUSTOM
                availability.setMonday(request.getParameter("monday") != null);
                availability.setTuesday(request.getParameter("tuesday") != null);
                availability.setWednesday(request.getParameter("wednesday") != null);
                availability.setThursday(request.getParameter("thursday") != null);
                availability.setFriday(request.getParameter("friday") != null);
                availability.setSaturday(request.getParameter("saturday") != null);
                availability.setSunday(request.getParameter("sunday") != null);
            }
            
            TechnicianAvailabilityDAO dao = new TechnicianAvailabilityDAO();
            dao.saveOrUpdateAvailability(availability);
            
            response.sendRedirect(request.getContextPath() + "/availability?success=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error saving availability: " + e.getMessage());
        }
    }

    private Time parseSqlTime(String rawTime) {
        if (rawTime == null || rawTime.isBlank()) {
            throw new IllegalArgumentException("Time value is required");
        }
        return Time.valueOf(LocalTime.parse(rawTime.trim()));
    }
}
