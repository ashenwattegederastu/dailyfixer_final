package com.dailyfixer.servlet.auth;

import com.dailyfixer.dao.DriverRequestDAO;
import com.dailyfixer.model.DriverRequest;
import com.dailyfixer.util.HashUtil;
import com.dailyfixer.util.ImageUploadUtil;

import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/RegisterDriverServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize       = 1024 * 1024 * 5,   // 5 MB per file
    maxRequestSize    = 1024 * 1024 * 30   // 30 MB total
)
public class RegisterDriverServlet extends HttpServlet {

    private DriverRequestDAO requestDAO = new DriverRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String webAppPath = getServletContext().getRealPath("/");

        try {
            // === Basic Account Info ===
            String firstName = request.getParameter("first_name");
            String lastName  = request.getParameter("last_name");
            String username  = request.getParameter("username");
            String email     = request.getParameter("email");
            String password  = request.getParameter("password");
            String confirmPw = request.getParameter("confirmPassword");
            String phone     = request.getParameter("phone_number");
            String city      = request.getParameter("city");
            String nicNumber = request.getParameter("nic_number");
            String policyParam = request.getParameter("policy_accepted");

            String fullName = (firstName != null ? firstName.trim() : "") + " " + (lastName != null ? lastName.trim() : "");
            fullName = fullName.trim();

            // === Server-side validation ===
            if (fullName.isEmpty() || username == null || username.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || password == null || password.trim().isEmpty()) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Please+fill+in+all+required+fields");
                return;
            }

            if (!password.equals(confirmPw)) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Passwords+do+not+match");
                return;
            }

            if (password.length() < 6) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Password+must+be+at+least+6+characters");
                return;
            }

            // NIC validation: 9 digits + V/X or 12 digits
            if (nicNumber == null || nicNumber.trim().isEmpty()
                    || !nicNumber.trim().matches("^\\d{9}[VvXx]$|^\\d{12}$")) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Invalid+NIC+number+format");
                return;
            }

            if (!"on".equals(policyParam) && !"true".equals(policyParam)) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=You+must+accept+the+driver+policies");
                return;
            }

            // Duplicate checks
            if (requestDAO.usernameExists(username.trim())) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Username+already+exists+or+is+pending+review");
                return;
            }
            if (requestDAO.emailExists(email.trim())) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Email+already+exists+or+is+pending+review");
                return;
            }

            // === File uploads ===
            Part nicFrontPart     = request.getPart("nic_front");
            Part nicBackPart      = request.getPart("nic_back");
            Part profilePicPart   = request.getPart("profile_picture");
            Part licenseFrontPart = request.getPart("license_front");
            Part licenseBackPart  = request.getPart("license_back");

            // Validate required file uploads
            if (nicFrontPart == null || nicFrontPart.getSize() == 0
                    || nicBackPart == null || nicBackPart.getSize() == 0
                    || profilePicPart == null || profilePicPart.getSize() == 0
                    || licenseFrontPart == null || licenseFrontPart.getSize() == 0) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Please+upload+all+required+documents");
                return;
            }

            // Validate file types (images only)
            Part[] requiredParts = {nicFrontPart, nicBackPart, profilePicPart, licenseFrontPart};
            for (Part p : requiredParts) {
                if (p.getContentType() == null || !p.getContentType().startsWith("image/")) {
                    response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Only+image+files+are+accepted+for+uploads");
                    return;
                }
            }
            if (licenseBackPart != null && licenseBackPart.getSize() > 0
                    && (licenseBackPart.getContentType() == null || !licenseBackPart.getContentType().startsWith("image/"))) {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Only+image+files+are+accepted+for+uploads");
                return;
            }

            String safeUsername = username.trim().replaceAll("[^a-zA-Z0-9_]", "_");

            String nicFrontPath     = ImageUploadUtil.saveDriverUpload(nicFrontPart, "nic_front_" + safeUsername, webAppPath);
            String nicBackPath      = ImageUploadUtil.saveDriverUpload(nicBackPart, "nic_back_" + safeUsername, webAppPath);
            String profilePicPath   = ImageUploadUtil.saveDriverUpload(profilePicPart, "profile_" + safeUsername, webAppPath);
            String licenseFrontPath = ImageUploadUtil.saveDriverUpload(licenseFrontPart, "license_front_" + safeUsername, webAppPath);
            String licenseBackPath  = null;
            if (licenseBackPart != null && licenseBackPart.getSize() > 0) {
                licenseBackPath = ImageUploadUtil.saveDriverUpload(licenseBackPart, "license_back_" + safeUsername, webAppPath);
            }

            // === Build request object ===
            String hashedPassword = HashUtil.sha256(password);

            DriverRequest driverRequest = new DriverRequest();
            driverRequest.setFullName(fullName);
            driverRequest.setUsername(username.trim());
            driverRequest.setEmail(email.trim());
            driverRequest.setPhone(phone != null ? phone.trim() : null);
            driverRequest.setPasswordHash(hashedPassword);
            driverRequest.setCity(city != null ? city.trim() : null);
            driverRequest.setNicNumber(nicNumber.trim());
            driverRequest.setNicFrontPath(nicFrontPath);
            driverRequest.setNicBackPath(nicBackPath);
            driverRequest.setProfilePicturePath(profilePicPath);
            driverRequest.setLicenseFrontPath(licenseFrontPath);
            driverRequest.setLicenseBackPath(licenseBackPath);
            driverRequest.setPolicyAccepted(true);

            int requestId = requestDAO.submitRequest(driverRequest);

            if (requestId > 0) {
                response.sendRedirect("pages/authentication/login.jsp?msg=Driver+registration+submitted+successfully.+Your+application+is+pending+admin+verification.");
            } else {
                response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=Registration+failed.+Please+try+again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/authentication/register/registerDriver.jsp?error=An+unexpected+error+occurred.+Please+try+again.");
        }
    }
}
