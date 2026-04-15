package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.ReviewDAO;
import com.dailyfixer.model.Review;
import com.dailyfixer.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/StoreReviewsServlet")
public class StoreReviewsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the current user from session
        User user = (User) request.getSession().getAttribute("currentUser");

        // Check if user is logged in and is a store owner
        if (user == null || user.getRole() == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String role = user.getRole().trim().toLowerCase();
        if (!("admin".equals(role) || "store".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        try {
            ReviewDAO reviewDAO = new ReviewDAO();
            String storeUsername = user.getUsername();
            
            // Get all reviews for products in this store
            List<Review> reviews = reviewDAO.getReviewsByStoreUsername(storeUsername);
            
            // Set attributes for the JSP
            request.setAttribute("reviews", reviews);
            request.setAttribute("storeUsername", storeUsername);
            
            // Forward to the reviews page
            request.getRequestDispatcher("/pages/dashboards/storedash/storeReviews.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error fetching store reviews", e);
        }
    }
}
