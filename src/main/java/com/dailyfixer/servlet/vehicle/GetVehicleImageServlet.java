package com.dailyfixer.servlet.vehicle;

import com.dailyfixer.dao.VehicleDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.model.Vehicle;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Serves vehicle image/document files from disk using stored file paths.
 *
 * Query params:
 *   id    – vehicle primary key
 *   type  – one of: front | left | right | back | registration | insurance | revenue
 */
@WebServlet("/GetVehicleImageServlet")
public class GetVehicleImageServlet extends HttpServlet {

    private VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        User user = (User) session.getAttribute("currentUser");

        String idStr = request.getParameter("id");
        String type  = request.getParameter("type");
        if (idStr == null || type == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing id or type");
            return;
        }

        try {
            int vehicleId = Integer.parseInt(idStr);
            Vehicle vehicle = vehicleDAO.getVehicleById(vehicleId);

            if (vehicle == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehicle not found");
                return;
            }

            // Only allow the owning driver or admin to view vehicle files
            if (!"admin".equals(user.getRole()) && vehicle.getDriverId() != user.getUserId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String storedPath = switch (type) {
                case "front"        -> vehicle.getImgFront();
                case "left"         -> vehicle.getImgLeft();
                case "right"        -> vehicle.getImgRight();
                case "back"         -> vehicle.getImgBack();
                case "registration" -> vehicle.getDocRegistration();
                case "insurance"    -> vehicle.getDocInsurance();
                case "revenue"      -> vehicle.getDocRevenue();
                default             -> null;
            };

            if (storedPath == null || storedPath.isEmpty()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No file for type: " + type);
                return;
            }

            Path filePath = Paths.get(getServletContext().getRealPath("/"), storedPath);
            if (!Files.exists(filePath)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on disk");
                return;
            }

            byte[] data = Files.readAllBytes(filePath);
            String contentType = getServletContext().getMimeType(filePath.getFileName().toString());
            response.setContentType(contentType != null ? contentType : "image/jpeg");
            response.setContentLength(data.length);
            try (OutputStream out = response.getOutputStream()) {
                out.write(data);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid vehicle id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error");
        }
    }
}

