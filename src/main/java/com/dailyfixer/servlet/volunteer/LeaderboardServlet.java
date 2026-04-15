package com.dailyfixer.servlet.volunteer;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.dailyfixer.util.DBConnection;

@WebServlet("/leaderboard")
public class LeaderboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> leaderboard = new ArrayList<>();

        String sql = "SELECT u.first_name, u.last_name, v.reputation_score, " +
                "(SELECT b.name FROM volunteer_badges vb JOIN badges b ON vb.badge_id = b.badge_id WHERE vb.volunteer_id = v.volunteer_id ORDER BY b.required_score DESC LIMIT 1) as top_badge "
                +
                "FROM volunteers v " +
                "JOIN users u ON v.user_id = u.user_id " +
                "ORDER BY v.reputation_score DESC " +
                "LIMIT 50";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            int rank = 1;
            while (rs.next()) {
                Map<String, Object> entry = new HashMap<>();
                entry.put("rank", rank++);
                entry.put("name", rs.getString("first_name") + " " + rs.getString("last_name"));
                entry.put("score", rs.getDouble("reputation_score"));
                entry.put("badge", rs.getString("top_badge"));
                leaderboard.add(entry);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("leaderboard", leaderboard);
        request.getRequestDispatcher("/pages/shared/leaderboard.jsp").forward(request, response);
    }
}
