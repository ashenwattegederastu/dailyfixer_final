package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingRatingDAO;
import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.dao.TechnicianPenaltyDAO;
import com.dailyfixer.model.Booking;
import com.dailyfixer.model.TechnicianPenalty;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/technician/dashboard")
public class TechnicianDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;

        if (user == null || user.getRole() == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String role = user.getRole().trim().toLowerCase();
        if (!("admin".equals(role) || "technician".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        int techId = user.getUserId();

        int pendingCount = 0;
        int activeCount = 0;
        int completedCount = 0;
        int thisMonthCount = 0;
        double avgRating = 0.0;
        int ratingCount = 0;
        int serviceCount = 0;
        int activePenaltyLevel = 0;
        List<Booking> recentBookings = List.of();
        List<TechnicianPenalty> recentPenalties = List.of();

        try {
            BookingDAO bookingDAO = new BookingDAO();
            BookingRatingDAO ratingDAO = new BookingRatingDAO();
            ServiceDAO serviceDAO = new ServiceDAO();
            TechnicianPenaltyDAO penaltyDAO = new TechnicianPenaltyDAO();

            pendingCount   = bookingDAO.countPendingBookingsByTechnicianId(techId);
            completedCount = bookingDAO.countCompletedBookingsByTechnician(techId);
            activeCount    = bookingDAO.getBookingsByTechnicianAndStatus(techId, "ACCEPTED").size();
            avgRating      = ratingDAO.getAverageRatingForTechnician(techId);
            ratingCount    = ratingDAO.getRatingCountForTechnician(techId);
            serviceCount   = serviceDAO.getServicesByTechnician(techId).size();
            activePenaltyLevel = penaltyDAO.getHighestActivePenaltyLevel(techId);
            List<TechnicianPenalty> allPenalties = penaltyDAO.getPenaltyHistory(techId);
            recentPenalties = allPenalties.size() > 5 ? allPenalties.subList(0, 5) : allPenalties;

            List<Booking> all = bookingDAO.getBookingsByTechnicianId(techId);

            LocalDate now = LocalDate.now();
            int curMonth = now.getMonthValue();
            int curYear  = now.getYear();
            for (Booking b : all) {
                String st = b.getStatus();
                if (("FULLY_COMPLETED".equals(st) || "TECHNICIAN_COMPLETED".equals(st))
                        && b.getBookingDate() != null) {
                    LocalDate bd = b.getBookingDate().toLocalDate();
                    if (bd.getMonthValue() == curMonth && bd.getYear() == curYear) {
                        thisMonthCount++;
                    }
                }
            }

            recentBookings = all.size() > 5 ? all.subList(0, 5) : all;

        } catch (Exception e) {
            e.printStackTrace();
        }

        String avgRatingStr = avgRating > 0 ? String.format("%.1f", avgRating) : "N/A";

        request.setAttribute("pendingCount",      pendingCount);
        request.setAttribute("activeCount",       activeCount);
        request.setAttribute("completedCount",    completedCount);
        request.setAttribute("thisMonthCount",    thisMonthCount);
        request.setAttribute("avgRatingStr",      avgRatingStr);
        request.setAttribute("ratingCount",       ratingCount);
        request.setAttribute("serviceCount",      serviceCount);
        request.setAttribute("recentBookings",    recentBookings);
        request.setAttribute("activePenaltyLevel", activePenaltyLevel);
        request.setAttribute("recentPenalties",   recentPenalties);

        request.getRequestDispatcher(
                "/pages/dashboards/techniciandash/techniciandashmain.jsp"
        ).forward(request, response);
    }
}
