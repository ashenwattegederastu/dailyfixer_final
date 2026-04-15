package com.dailyfixer.servlet.driver;

import com.dailyfixer.dao.UserDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * POST /driver/updateLocation
 * Saves the driver's home base latitude/longitude to users.latitude/longitude.
 * Also updates the session object so the profile page reflects the new value immediately.
 */
@WebServlet(name = "UpdateDriverLocationServlet", urlPatterns = {"/driver/updateLocation"})
public class UpdateDriverLocationServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String latStr = req.getParameter("latitude");
        String lngStr = req.getParameter("longitude");

        if (latStr == null || latStr.isBlank() || lngStr == null || lngStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing coordinates\"}");
            return;
        }

        try {
            double lat = Double.parseDouble(latStr);
            double lng = Double.parseDouble(lngStr);

            boolean saved = userDAO.updateHomeLocation(user.getUserId(), lat, lng);
            if (saved) {
                // Update session so the page reflects the new location without re-login
                user.setLatitude(lat);
                user.setLongitude(lng);
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Database update failed\"}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid coordinates\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"message\":\"Server error\"}");
        }
    }
}
