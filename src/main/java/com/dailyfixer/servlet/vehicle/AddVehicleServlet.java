package com.dailyfixer.servlet.vehicle;

import com.dailyfixer.dao.VehicleDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.model.Vehicle;
import com.dailyfixer.util.ImageUploadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.regex.Pattern;

@WebServlet("/AddVehicleServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 10) // 10 MB per part
public class AddVehicleServlet extends HttpServlet {

    // Accepts: AB AB-1234  or  AAA-0001
    private static final Pattern PLATE_PATTERN =
            Pattern.compile("^[A-Z]{2}\\s[A-Z]{2}-\\d{4}$|^[A-Z]{3}-\\d{4}$");

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

        // Enforce 1-vehicle-per-driver at app level
        if (vehicleDAO.getVehicleByDriver(user.getUserId()) != null) {
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
            return;
        }

        try {
            String webAppPath      = getServletContext().getRealPath("/");
            String vehicleCategory = getPart(request, "vehicleCategory");
            String brand           = getPart(request, "brand");
            String customMake      = getPart(request, "customMake");
            String model           = getPart(request, "model");
            String plateNumber     = getPart(request, "plateNumber");

            // If driver chose "Other", register and use the custom make
            if ("Other".equals(brand) && customMake != null && !customMake.isBlank()) {
                vehicleDAO.addCustomMake(vehicleCategory, customMake.trim());
                brand = customMake.trim();
            }

            // Validate plate
            if (plateNumber == null || !PLATE_PATTERN.matcher(plateNumber.trim()).matches()) {
                request.setAttribute("error", "Invalid plate number format. Use AB AB-1234 or AAA-0001.");
                request.getRequestDispatcher("/pages/dashboards/driverdash/addVehicle.jsp").forward(request, response);
                return;
            }

            // Save 4 required vehicle photos
            String uid = String.valueOf(user.getUserId());
            String imgFront = ImageUploadUtil.saveVehicleUpload(request.getPart("imgFront"), "v_front_" + uid, webAppPath);
            String imgLeft  = ImageUploadUtil.saveVehicleUpload(request.getPart("imgLeft"),  "v_left_"  + uid, webAppPath);
            String imgRight = ImageUploadUtil.saveVehicleUpload(request.getPart("imgRight"), "v_right_" + uid, webAppPath);
            String imgBack  = ImageUploadUtil.saveVehicleUpload(request.getPart("imgBack"),  "v_back_"  + uid, webAppPath);

            if (imgFront == null || imgLeft == null || imgRight == null || imgBack == null) {
                request.setAttribute("error", "All 4 vehicle photos are required.");
                request.getRequestDispatcher("/pages/dashboards/driverdash/addVehicle.jsp").forward(request, response);
                return;
            }

            // Save documents
            String docRegistration = ImageUploadUtil.saveVehicleUpload(request.getPart("docRegistration"), "v_doc_reg_" + uid, webAppPath);
            String docInsurance    = ImageUploadUtil.saveVehicleUpload(request.getPart("docInsurance"),    "v_doc_ins_" + uid, webAppPath); // optional
            String docRevenue      = ImageUploadUtil.saveVehicleUpload(request.getPart("docRevenue"),      "v_doc_rev_" + uid, webAppPath);

            if (docRegistration == null || docRevenue == null) {
                request.setAttribute("error", "Registration Document and Revenue Document are required.");
                request.getRequestDispatcher("/pages/dashboards/driverdash/addVehicle.jsp").forward(request, response);
                return;
            }

            Vehicle vehicle = new Vehicle();
            vehicle.setDriverId(user.getUserId());
            vehicle.setVehicleCategory(vehicleCategory);
            vehicle.setBrand(brand);
            vehicle.setModel(model);
            vehicle.setPlateNumber(plateNumber.trim().toUpperCase());
            vehicle.setImgFront(imgFront);
            vehicle.setImgLeft(imgLeft);
            vehicle.setImgRight(imgRight);
            vehicle.setImgBack(imgBack);
            vehicle.setDocRegistration(docRegistration);
            vehicle.setDocInsurance(docInsurance);
            vehicle.setDocRevenue(docRevenue);

            vehicleDAO.addVehicle(vehicle);
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
            request.getRequestDispatcher("/pages/dashboards/driverdash/addVehicle.jsp").forward(request, response);
        }
    }

    private String getPart(HttpServletRequest request, String name) throws IOException, ServletException {
        Part part = request.getPart(name);
        if (part == null) return null;
        try (InputStream is = part.getInputStream()) {
            return new String(is.readAllBytes()).trim();
        }
    }
}
