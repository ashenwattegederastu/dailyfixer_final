package com.dailyfixer.servlet.diagnostic;

import com.dailyfixer.dao.DecisionTreeDAO;
import com.dailyfixer.dao.TreeRatingDAO;
import com.dailyfixer.model.DecisionTree;
import com.dailyfixer.model.TreeRating;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet for handling tree rating operations.
 * URL: /api/diagnostic/ratings
 */
@WebServlet(urlPatterns = { "/api/diagnostic/ratings", "/api/diagnostic/ratings/*" })
public class DiagnosticRatingServlet extends HttpServlet {

    private TreeRatingDAO ratingDAO;
    private DecisionTreeDAO treeDAO;

    @Override
    public void init() throws ServletException {
        ratingDAO = new TreeRatingDAO();
        treeDAO = new DecisionTreeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String treeIdParam = request.getParameter("tree");
            String userRatingParam = request.getParameter("userRating");

            if (treeIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Tree ID is required\"}");
                return;
            }

            int treeId = Integer.parseInt(treeIdParam);

            // Check if requesting user's own rating
            if ("true".equals(userRatingParam)) {
                HttpSession session = request.getSession(false);
                if (session == null) {
                    out.print("{\"hasRated\": false}");
                    return;
                }
                User currentUser = (User) session.getAttribute("currentUser");
                if (currentUser == null) {
                    out.print("{\"hasRated\": false}");
                    return;
                }

                TreeRating userRating = ratingDAO.getUserRating(treeId, currentUser.getUserId());
                if (userRating != null) {
                    out.print("{\"hasRated\": true, \"rating\": " + userRating.getRating() +
                            ", \"feedback\": \"" + escapeJson(userRating.getFeedback()) + "\"}");
                } else {
                    out.print("{\"hasRated\": false}");
                }
            } else {
                // Return average rating and count
                double avgRating = ratingDAO.getAverageRating(treeId);
                int ratingCount = ratingDAO.getRatingCount(treeId);
                int[] distribution = ratingDAO.getRatingDistribution(treeId);

                StringBuilder sb = new StringBuilder("{");
                sb.append("\"averageRating\":").append(String.format("%.1f", avgRating)).append(",");
                sb.append("\"ratingCount\":").append(ratingCount).append(",");
                sb.append("\"distribution\":[");
                for (int i = 0; i < distribution.length; i++) {
                    if (i > 0)
                        sb.append(",");
                    sb.append(distribution[i]);
                }
                sb.append("]}");
                out.print(sb.toString());
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid tree ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to fetch ratings\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Login required to rate\"}");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Login required to rate\"}");
            return;
        }

        try {
            String treeIdParam = request.getParameter("treeId");
            String ratingParam = request.getParameter("rating");
            String feedback = request.getParameter("feedback");

            if (treeIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Tree ID is required\"}");
                return;
            }

            if (ratingParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Rating is required\"}");
                return;
            }

            int treeId = Integer.parseInt(treeIdParam);
            int rating = Integer.parseInt(ratingParam);

            // Validate rating range
            if (rating < 1 || rating > 5) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Rating must be between 1 and 5\"}");
                return;
            }

            // Verify tree exists and is published
            DecisionTree tree = treeDAO.getTreeById(treeId);
            if (tree == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Tree not found\"}");
                return;
            }

            if (!tree.isPublished()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Cannot rate unpublished tree\"}");
                return;
            }

            TreeRating treeRating = new TreeRating();
            treeRating.setTreeId(treeId);
            treeRating.setUserId(currentUser.getUserId());
            treeRating.setRating(rating);
            treeRating.setFeedback(feedback != null ? feedback.trim() : null);

            boolean success = ratingDAO.addOrUpdateRating(treeRating);

            if (success) {
                double newAvgRating = ratingDAO.getAverageRating(treeId);
                int newRatingCount = ratingDAO.getRatingCount(treeId);
                out.print("{\"success\": true, \"averageRating\": " + String.format("%.1f", newAvgRating) +
                        ", \"ratingCount\": " + newRatingCount + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"Failed to submit rating\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid ID or rating format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to submit rating\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Login required\"}");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Login required\"}");
            return;
        }

        try {
            String treeIdParam = request.getParameter("tree");
            if (treeIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Tree ID is required\"}");
                return;
            }

            int treeId = Integer.parseInt(treeIdParam);
            boolean deleted = ratingDAO.deleteRating(treeId, currentUser.getUserId());

            if (deleted) {
                out.print("{\"success\": true}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Rating not found\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Invalid tree ID\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Failed to delete rating\"}");
        }
    }

    private String escapeJson(String str) {
        if (str == null)
            return "";
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
