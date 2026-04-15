package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.ReviewDAO;
import com.dailyfixer.model.Review;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/productReview")
public class ProductReviewServlet extends HttpServlet {

    private ReviewDAO reviewDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        reviewDAO = new ReviewDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        // Check if user is logged in
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("{\"success\":false,\"error\":\"Please login to submit a review\"}");
            out.flush();
            return;
        }

        try {
            String productIdStr = request.getParameter("productId");
            String ratingStr = request.getParameter("rating");
            String comment = request.getParameter("comment");

            System.out.println("ProductReviewServlet - Received: productId=" + productIdStr + ", rating=" + ratingStr + ", comment=" + (comment != null ? comment.substring(0, Math.min(50, comment.length())) : "null"));

            if (productIdStr == null || ratingStr == null || comment == null ||
                    productIdStr.isEmpty() || ratingStr.isEmpty() || comment.trim().isEmpty()) {
                out.print("{\"success\":false,\"error\":\"All fields are required\"}");
                out.flush();
                return;
            }

            int productId = Integer.parseInt(productIdStr);
            int rating = Integer.parseInt(ratingStr);

            // Validate rating range
            if (rating < 1 || rating > 5) {
                out.print("{\"success\":false,\"error\":\"Rating must be between 1 and 5\"}");
                out.flush();
                return;
            }

            // Check if user has already reviewed this product
            if (reviewDAO.hasUserReviewed(productId, currentUser.getUserId())) {
                out.print("{\"success\":false,\"error\":\"You have already reviewed this product\"}");
                out.flush();
                return;
            }

            // Create and save review
            Review review = new Review();
            review.setProductId(productId);
            review.setUserId(currentUser.getUserId());
            review.setRating(rating);
            review.setComment(comment.trim());

            reviewDAO.addReview(review);
            System.out.println("ProductReviewServlet - Review saved successfully for productId: " + productId);

            // Get updated average rating and review count
            double avgRating = reviewDAO.getAverageRating(productId);
            int reviewCount = reviewDAO.getReviewCount(productId);

            String jsonResponse = "{\"success\":true,\"message\":\"Review submitted successfully\",\"avgRating\":" + 
                     String.format("%.1f", avgRating) + ",\"reviewCount\":" + reviewCount + "}";
            System.out.println("ProductReviewServlet - Response: " + jsonResponse);
            out.print(jsonResponse);
            out.flush();

        } catch (NumberFormatException e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"Invalid product ID or rating\"}");
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") : "Unknown error";
            out.print("{\"success\":false,\"error\":\"Server error: " + errorMsg + "\"}");
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String productIdStr = request.getParameter("productId");
            if (productIdStr == null || productIdStr.isEmpty()) {
                out.print("{\"success\":false,\"error\":\"Product ID is required\"}");
                out.flush();
                return;
            }

            int productId = Integer.parseInt(productIdStr);
            java.util.List<Review> reviews = reviewDAO.getReviewsByProductId(productId);
            double avgRating = reviewDAO.getAverageRating(productId);
            int reviewCount = reviewDAO.getReviewCount(productId);

            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"avgRating\":").append(String.format("%.1f", avgRating));
            json.append(",\"reviewCount\":").append(reviewCount);
            json.append(",\"reviews\":[");

            for (int i = 0; i < reviews.size(); i++) {
                Review review = reviews.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"reviewId\":").append(review.getReviewId()).append(",");
                json.append("\"username\":\"").append(escapeJson(review.getUsername() != null ? review.getUsername() : "Anonymous")).append("\",");
                json.append("\"rating\":").append(review.getRating()).append(",");
                json.append("\"comment\":\"").append(escapeJson(review.getComment())).append("\",");
                json.append("\"createdAt\":\"").append(review.getCreatedAt() != null ? review.getCreatedAt().toString() : "").append("\"");
                json.append("}");
            }

            json.append("]}");
            out.print(json.toString());
            out.flush();

        } catch (NumberFormatException e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"Invalid product ID\"}");
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") : "Unknown error";
            out.print("{\"success\":false,\"error\":\"Server error: " + errorMsg + "\"}");
            out.flush();
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
