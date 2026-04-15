package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingRatingDAO;
import com.dailyfixer.dao.RecurringContractDAO;
import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.dao.TechnicianAvailabilityDAO;
import com.dailyfixer.dao.TechnicianDailyLimitDAO;
import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.RecurringContract;
import com.dailyfixer.model.Service;
import com.dailyfixer.model.TechnicianAvailability;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Map;

@WebServlet("/bookings/create")
public class CreateBookingServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String serviceIdStr = request.getParameter("serviceId");
            if (serviceIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/services");
                return;
            }
            
            int serviceId = Integer.parseInt(serviceIdStr);
            ServiceDAO serviceDAO = new ServiceDAO();
            Service service = serviceDAO.getServiceById(serviceId);
            
            if (service == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Service not found");
                return;
            }
            
            // Get technician availability
            TechnicianAvailabilityDAO availabilityDAO = new TechnicianAvailabilityDAO();
            TechnicianAvailability availability = availabilityDAO.getAvailabilityByTechnicianId(service.getTechnicianId());
            
            // Technician profile enrichment
            UserDAO userDAO = new UserDAO();
            User technician = userDAO.getUserById(service.getTechnicianId());

            BookingRatingDAO ratingDAO = new BookingRatingDAO();
            double avgRating = ratingDAO.getAverageRatingForTechnician(service.getTechnicianId());
            int ratingCount  = ratingDAO.getRatingCountForTechnician(service.getTechnicianId());

            BookingDAO bookingDAO = new BookingDAO();
            int completedJobs = bookingDAO.countCompletedBookingsByTechnician(service.getTechnicianId());

            // Find the nearest day with open capacity to hint the user
            TechnicianDailyLimitDAO limitDAO = new TechnicianDailyLimitDAO();
            LocalDate nearest = findNearestAvailableDate(service.getTechnicianId(), availability, bookingDAO, limitDAO);

            request.setAttribute("service", service);
            request.setAttribute("technician", technician);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("ratingCount", ratingCount);
            request.setAttribute("completedJobs", completedJobs);
            request.setAttribute("availability", availability);
            request.setAttribute("technicianId", service.getTechnicianId());
            if (nearest != null) {
                request.setAttribute("nearestAvailableDate", nearest.toString());
            }
            request.getRequestDispatcher("/pages/bookings/create-booking.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            // Get form parameters
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            String bookingDateStr = request.getParameter("bookingDate");
            String bookingTimeStr = request.getParameter("bookingTime");
            String phoneNumber = request.getParameter("phoneNumber");
            String problemDescription = request.getParameter("problemDescription");
            String locationAddress = request.getParameter("locationAddress");
            String latitudeStr = request.getParameter("latitude");
            String longitudeStr = request.getParameter("longitude");
            
            // Get service and technician info
            ServiceDAO serviceDAO = new ServiceDAO();
            Service service = serviceDAO.getServiceById(serviceId);
            
            if (service == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid service");
                return;
            }
            
            // Validate availability
            TechnicianAvailabilityDAO availabilityDAO = new TechnicianAvailabilityDAO();
            TechnicianAvailability availability = availabilityDAO.getAvailabilityByTechnicianId(service.getTechnicianId());
            
            LocalDate bookingDate = LocalDate.parse(bookingDateStr);
            LocalTime bookingTime = LocalTime.parse(bookingTimeStr);

            // Enforce 24-hour advance booking window
            if (LocalDateTime.of(bookingDate, bookingTime)
                    .isBefore(LocalDateTime.now().plusHours(24))) {
                request.setAttribute("error",
                        "Bookings must be made at least 24 hours in advance. Same-day bookings are not accepted.");
                request.setAttribute("service", service);
                request.setAttribute("availability", availability);
                request.getRequestDispatcher("/pages/bookings/create-booking.jsp").forward(request, response);
                return;
            }

            if (availability != null && !isValidBookingTime(availability, bookingDate, bookingTime)) {
                request.setAttribute("error", "The selected date/time is not available for this technician");
                request.setAttribute("service", service);
                request.setAttribute("availability", availability);
                request.getRequestDispatcher("/pages/bookings/create-booking.jsp").forward(request, response);
                return;
            }
            
            // Create booking
            Booking booking = new Booking();
            booking.setUserId(currentUser.getUserId());
            booking.setTechnicianId(service.getTechnicianId());
            booking.setServiceId(serviceId);
            booking.setBookingDate(Date.valueOf(bookingDate));
            booking.setBookingTime(Time.valueOf(bookingTime));
            booking.setPhoneNumber(phoneNumber);
            booking.setProblemDescription(problemDescription);
            booking.setLocationAddress(locationAddress);
            
            if (latitudeStr != null && !latitudeStr.isEmpty()) {
                booking.setLocationLatitude(new BigDecimal(latitudeStr));
            }
            if (longitudeStr != null && !longitudeStr.isEmpty()) {
                booking.setLocationLongitude(new BigDecimal(longitudeStr));
            }
            
            booking.setStatus("REQUESTED");
            
            BookingDAO bookingDAO = new BookingDAO();
            boolean isRecurring = "true".equals(request.getParameter("isRecurring"));

            if (isRecurring && service.isRecurringEnabled()) {
                // Validate day is ≤ 28 to avoid short-month edge cases
                if (bookingDate.getDayOfMonth() > 28) {
                    request.setAttribute("error", "For recurring bookings please choose a date between the 1st and 28th of the month.");
                    request.setAttribute("service", service);
                    request.setAttribute("availability", availability);
                    request.getRequestDispatcher("/pages/bookings/create-booking.jsp").forward(request, response);
                    return;
                }

                // Prevent duplicate active contracts for the same user+service
                RecurringContractDAO contractDAO = new RecurringContractDAO();
                if (contractDAO.getActiveContractForUserAndService(currentUser.getUserId(), serviceId) != null) {
                    request.setAttribute("error", "You already have an active recurring contract for this service.");
                    request.setAttribute("service", service);
                    request.setAttribute("availability", availability);
                    request.getRequestDispatcher("/pages/bookings/create-booking.jsp").forward(request, response);
                    return;
                }

                // Create the contract (PENDING until technician accepts)
                LocalDate start = bookingDate;
                LocalDate end = start.plusMonths(11).withDayOfMonth(
                        Math.min(start.getDayOfMonth(), 28));

                RecurringContract contract = new RecurringContract();
                contract.setUserId(currentUser.getUserId());
                contract.setTechnicianId(service.getTechnicianId());
                contract.setServiceId(serviceId);
                contract.setStartDate(Date.valueOf(start));
                contract.setEndDate(Date.valueOf(end));
                contract.setBookingDayOfMonth(start.getDayOfMonth());
                contract.setRecurringFee(BigDecimal.valueOf(service.getRecurringFee()));

                int contractId = contractDAO.createContract(contract);

                // Create first booking linked to this contract
                booking.setRecurringContractId(contractId);
                booking.setRecurringSequence(1);
            }

            bookingDAO.createBooking(booking);
            
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/userdash/userdashmain.jsp?bookingSuccess=true");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error creating booking: " + e.getMessage());
        }
    }
    
    private boolean isValidBookingTime(TechnicianAvailability availability, LocalDate date, LocalTime time) {
        // Check if day is available
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        boolean dayAvailable = false;
        
        switch (dayOfWeek) {
            case MONDAY: dayAvailable = availability.isMonday(); break;
            case TUESDAY: dayAvailable = availability.isTuesday(); break;
            case WEDNESDAY: dayAvailable = availability.isWednesday(); break;
            case THURSDAY: dayAvailable = availability.isThursday(); break;
            case FRIDAY: dayAvailable = availability.isFriday(); break;
            case SATURDAY: dayAvailable = availability.isSaturday(); break;
            case SUNDAY: dayAvailable = availability.isSunday(); break;
        }
        
        if (!dayAvailable) {
            return false;
        }
        
        // Check if time is within window
        LocalTime startTime = availability.getStartTime().toLocalTime();
        LocalTime endTime = availability.getEndTime().toLocalTime();
        
        return !time.isBefore(startTime) && !time.isAfter(endTime);
    }

    /**
     * Scans the next 60 days and returns the first date where the technician works
     * and has not yet reached their daily booking limit. Returns null if no such
     * day is found within the window (e.g. technician has no availability set).
     */
    private LocalDate findNearestAvailableDate(int technicianId, TechnicianAvailability availability,
            BookingDAO bookingDAO, TechnicianDailyLimitDAO limitDAO) {
        try {
            int maxPerDay = limitDAO.getMaxBookingsPerDay(technicianId);
            LocalDate start = LocalDate.now().plusDays(1);
            LocalDate end = start.plusDays(59);
            Map<LocalDate, Integer> counts = bookingDAO.getBookingCountsByDateRange(technicianId, start, end);
            for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
                if (availability != null && !isTechnicianWorkingDay(availability, d.getDayOfWeek())) {
                    continue;
                }
                if (counts.getOrDefault(d, 0) < maxPerDay) {
                    return d;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private boolean isTechnicianWorkingDay(TechnicianAvailability availability, DayOfWeek day) {
        switch (day) {
            case MONDAY:    return availability.isMonday();
            case TUESDAY:   return availability.isTuesday();
            case WEDNESDAY: return availability.isWednesday();
            case THURSDAY:  return availability.isThursday();
            case FRIDAY:    return availability.isFriday();
            case SATURDAY:  return availability.isSaturday();
            case SUNDAY:    return availability.isSunday();
            default:        return false;
        }
    }
}
