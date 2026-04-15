package com.dailyfixer.servlet.vehicle;

import com.dailyfixer.dao.DeliveryRateDAO;
import com.dailyfixer.dao.VehicleDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.model.Vehicle;
import com.dailyfixer.util.ImageUploadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.regex.Pattern;

@WebServlet("/EditVehicleServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 10) // 10 MB per part
public class EditVehicleServlet extends HttpServlet {

    private static final Pattern PLATE_PATTERN =
            Pattern.compile("^[A-Z]{2}\\s[A-Z]{2}-\\d{4}$|^[A-Z]{3}-\\d{4}$");

    private VehicleDAO vehicleDAO = new VehicleDAO();

    /** GET Ã¢â‚¬â€ load existing vehicle data and forward to the edit JSP */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        Vehicle vehicle = vehicleDAO.getVehicleByDriver(user.getUserId());
        if (vehicle == null) {
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");
            return;
        }

        DeliveryRateDAO rateDAO = new DeliveryRateDAO();
        List<String> vehicleCategories = rateDAO.getActiveVehicleTypes();
        List<String> makesForCategory  = vehicleDAO.getMakesByCategory(vehicle.getVehicleCategory());

        request.setAttribute("vehicle", vehicle);
        request.setAttribute("vehicleCategories", vehicleCategories);
        request.setAttribute("makesForCategory", makesForCategory);
        request.getRequestDispatcher("/pages/dashboards/driverdash/editVehicle.jsp").forward(request, response);
    }

    /** POST Ã¢â‚¬â€ process edit form submission */
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

            String webAppPath      = getServletContext().getRealPath("/");
            String vehicleCategory = request.getParameter("vehicleCategory");
            String brand           = request.getParameter("brand");
            String customMake      = request.getParameter("customMake");
            String model           = request.getParameter("model");
            String plateNumber     = request.getParameter("plateNumber");

            if ("Other".equals(brand) && customMake != null && !customMake.isBlank()) {
                vehicleDAO.addCustomMake(vehicleCategory, customMake.trim());
                brand = customMake.trim();
            }

            if (plateNumber == null || !PLATE_PATTERN.matcher(plateNumber.trim().toUpperCase()).matches()) {
                request.setAttribute("error", "Invalid plate number format. Use AB AB-1234 or AAA-0001.");
                request.setAttribute("vehicle", vehicle);
                request.setAttribute("vehicleCategories", new DeliveryRateDAO().getActiveVehicleTypes());
                request.setAttribute("makesForCategory", vehicleDAO.getMakesByCategory(vehicleCategory));
                request.getRequestDispatcher("/pages/dashboards/driverdash/editVehicle.jsp").forward(request, response);
                return;
            }

            vehicle.setVehicleCategory(vehicleCategory);
            vehicle.setBrand(brand);
            vehicle.setModel(model);
            vehicle.setPlateNumber(plateNumber.trim().toUpperCase());

            String uid = String.valueOf(user.getUserId());

            // Only replace files if a new upload was provided; delete the old file when replacing
            String newFront = ImageUploadUtil.saveVehicleUpload(request.getPart("imgFront"), "v_front_" + uid, webAppPath);
            if (newFront != null) { ImageUploadUtil.deleteImage(vehicle.getImgFront(), webAppPath); vehicle.setImgFront(newFront); }

            String newLeft = ImageUploadUtil.saveVehicleUpload(request.getPart("imgLeft"), "v_left_" + uid, webAppPath);
            if (newLeft != null) { ImageUploadUtil.deleteImage(vehicle.getImgLeft(), webAppPath); vehicle.setImgLeft(newLeft); }

            String newRight = ImageUploadUtil.saveVehicleUpload(request.getPart("imgRight"), "v_right_" + uid, webAppPath);
            if (newRight != null) { ImageUploadUtil.deleteImage(vehicle.getImgRight(), webAppPath); vehicle.setImgRight(newRight); }

            String newBack = ImageUploadUtil.saveVehicleUpload(request.getPart("imgBack"), "v_back_" + uid, webAppPath);
            if (newBack != null) { ImageUploadUtil.deleteImage(vehicle.getImgBack(), webAppPath); vehicle.setImgBack(newBack); }

            String newReg = ImageUploadUtil.saveVehicleUpload(request.getPart("docRegistration"), "v_doc_reg_" + uid, webAppPath);
            if (newReg != null) { ImageUploadUtil.deleteImage(vehicle.getDocRegistration(), webAppPath); vehicle.setDocRegistration(newReg); }

            String newIns = ImageUploadUtil.saveVehicleUpload(request.getPart("docInsurance"), "v_doc_ins_" + uid, webAppPath);
            if (newIns != null) { ImageUploadUtil.deleteImage(vehicle.getDocInsurance(), webAppPath); vehicle.setDocInsurance(newIns); }

            String newRev = ImageUploadUtil.saveVehicleUpload(request.getPart("docRevenue"), "v_doc_rev_" + uid, webAppPath);
            if (newRev != null) { ImageUploadUtil.deleteImage(vehicle.getDocRevenue(), webAppPath); vehicle.setDocRevenue(newRev); }

            vehicleDAO.updateVehicle(vehicle);
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/driverdash/vehicleManagement.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
            request.getRequestDispatcher("/pages/dashboards/driverdash/editVehicle.jsp").forward(request, response);
        }
    }
}
