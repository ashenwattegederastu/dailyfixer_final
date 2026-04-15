package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingRatingDAO;
import com.dailyfixer.model.BookingRating;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/technician/reviews")
public class TechnicianReviewsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String techIdParam = request.getParameter("technicianId");
            if (techIdParam == null || techIdParam.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"technicianId is required\"}");
                return;
            }

            int technicianId = Integer.parseInt(techIdParam);
            BookingRatingDAO ratingDAO = new BookingRatingDAO();

            double avgRating = ratingDAO.getAverageRatingForTechnician(technicianId);
            int totalRatings = ratingDAO.getRatingCountForTechnician(technicianId);
            List<BookingRating> reviews = ratingDAO.getTechnicianReviews(technicianId);

            // Build JSON manually to avoid Gson dependency issues
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"avgRating\":").append(String.format("%.1f", avgRating)).append(",");
            json.append("\"totalRatings\":").append(totalRatings).append(",");
            json.append("\"reviews\":[");
            for (int i = 0; i < reviews.size(); i++) {
                BookingRating r = reviews.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"raterName\":\"").append(escapeJson(r.getRaterName())).append("\",");
                json.append("\"rating\":").append(r.getRating()).append(",");
                json.append("\"review\":\"").append(escapeJson(r.getReview())).append("\",");
                String dateStr = r.getCreatedAt() != null ? r.getCreatedAt().toString().substring(0, 10) : "";
                json.append("\"date\":\"").append(dateStr).append("\"");
                json.append("}");
            }
            json.append("]}");

            out.print(json.toString());

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid technicianId\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Server error\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
