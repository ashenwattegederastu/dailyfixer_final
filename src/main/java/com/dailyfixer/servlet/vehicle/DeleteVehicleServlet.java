package com.dailyfixer.servlet.vehicle;

import com.dailyfixer.dao.VehicleDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.model.Vehicle;
import com.dailyfixer.util.ImageUploadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/DeleteVehicleServlet")
public class DeleteVehicleServlet extends HttpServlet {
    private VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (!"driver".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
                return;
            }
            int id = Integer.parseInt(idParam);
            Vehicle vehicle = vehicleDAO.getVehicleById(id);
            if (vehicle == null || vehicle.getDriverId() != user.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
                return;
            }

            // Delete all uploaded files before removing the DB record
            String webAppPath = getServletContext().getRealPath("/");
            ImageUploadUtil.deleteImage(vehicle.getImgFront(), webAppPath);
            ImageUploadUtil.deleteImage(vehicle.getImgLeft(), webAppPath);
            ImageUploadUtil.deleteImage(vehicle.getImgRight(), webAppPath);
            ImageUploadUtil.deleteImage(vehicle.getImgBack(), webAppPath);
            ImageUploadUtil.deleteImage(vehicle.getDocRegistration(), webAppPath);
            ImageUploadUtil.deleteImage(vehicle.getDocInsurance(), webAppPath);
            ImageUploadUtil.deleteImage(vehicle.getDocRevenue(), webAppPath);

            vehicleDAO.deleteVehicle(id);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
    }
}
