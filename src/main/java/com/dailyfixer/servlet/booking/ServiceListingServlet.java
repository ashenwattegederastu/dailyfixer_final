package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingRatingDAO;
import com.dailyfixer.dao.ServiceCategoryDAO;
import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.Service;
import com.dailyfixer.model.ServiceCategory;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/services")
public class ServiceListingServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            ServiceDAO serviceDAO = new ServiceDAO();
            ServiceCategoryDAO categoryDAO = new ServiceCategoryDAO();
            BookingRatingDAO ratingDAO = new BookingRatingDAO();
            UserDAO userDAO = new UserDAO();
            BookingDAO bookingDAO = new BookingDAO();

            // Get all services
            List<Service> services = serviceDAO.getAllServices();

            // Get all categories for filter
            List<ServiceCategory> categories = categoryDAO.getAllCategories();

            // Get filter parameters
            String categoryFilter = request.getParameter("category");
            String searchQuery = request.getParameter("search");
            String cityFilter = request.getParameter("city");

            // Apply category filter
            if (categoryFilter != null && !categoryFilter.isEmpty()) {
                services = services.stream()
                    .filter(s -> categoryFilter.equalsIgnoreCase(s.getCategory()))
                    .toList();
            }

            // Apply search filter
            if (searchQuery != null && !searchQuery.isEmpty()) {
                String query = searchQuery.toLowerCase();
                services = services.stream()
                    .filter(s -> s.getServiceName().toLowerCase().contains(query) ||
                               (s.getDescription() != null && s.getDescription().toLowerCase().contains(query)))
                    .toList();
            }

            // Build tech user map before city filtering (needed for dropdown + filter)
            Map<Integer, User> techUsers = new HashMap<>();
            for (Service s : services) {
                int tid = s.getTechnicianId();
                if (!techUsers.containsKey(tid)) {
                    techUsers.put(tid, userDAO.getUserById(tid));
                }
            }

            // Collect distinct sorted cities for the dropdown
            List<String> cities = techUsers.values().stream()
                .filter(u -> u != null && u.getCity() != null && !u.getCity().isEmpty())
                .map(User::getCity)
                .distinct()
                .sorted()
                .toList();

            // Apply city filter
            if (cityFilter != null && !cityFilter.isEmpty()) {
                final String cityLower = cityFilter.toLowerCase();
                services = services.stream()
                    .filter(s -> {
                        User tech = techUsers.get(s.getTechnicianId());
                        return tech != null && tech.getCity() != null
                            && tech.getCity().toLowerCase().equals(cityLower);
                    })
                    .toList();
            }

            // Build rating maps keyed by technicianId
            Map<Integer, Double> techAvgRatings = new HashMap<>();
            Map<Integer, Integer> techRatingCounts = new HashMap<>();
            Map<Integer, Integer> techJobsCount = new HashMap<>();

            for (Service s : services) {
                int tid = s.getTechnicianId();
                if (!techAvgRatings.containsKey(tid)) {
                    techAvgRatings.put(tid, ratingDAO.getAverageRatingForTechnician(tid));
                    techRatingCounts.put(tid, ratingDAO.getRatingCountForTechnician(tid));
                    techJobsCount.put(tid, bookingDAO.countCompletedBookingsByTechnician(tid));
                }
            }

            request.setAttribute("services", services);
            request.setAttribute("categories", categories);
            request.setAttribute("cities", cities);
            request.setAttribute("selectedCategory", categoryFilter);
            request.setAttribute("selectedCity", cityFilter);
            request.setAttribute("searchQuery", searchQuery);
            request.setAttribute("techAvgRatings", techAvgRatings);
            request.setAttribute("techRatingCounts", techRatingCounts);
            request.setAttribute("techUsers", techUsers);
            request.setAttribute("techJobsCount", techJobsCount);

            request.getRequestDispatcher("/pages/services/service-listing.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading services: " + e.getMessage());
        }
    }
}
