package com.dailyfixer.servlet.auth;

import com.dailyfixer.dao.TechnicianRequestDAO;
import com.dailyfixer.model.TechnicianRequest;
import com.dailyfixer.model.TechnicianRequestFile;
import com.dailyfixer.util.HashUtil;
import com.dailyfixer.util.ImageUploadUtil;

import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@WebServlet("/registerTechnician")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 1024 * 1024 * 10,  // 10 MB per file (PDFs may be larger)
    maxRequestSize    = 1024 * 1024 * 60   // 60 MB total (3 quals + 5 proofs + profile + id card)
)
public class RegisterTechnicianServlet extends HttpServlet {

    private TechnicianRequestDAO requestDAO = new TechnicianRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String webAppPath = getServletContext().getRealPath("/");

        try {
            // === Basic fields ===
            String firstName = request.getParameter("firstName");
            String lastName  = request.getParameter("lastName");
            String username  = request.getParameter("username");
            String email     = request.getParameter("email");
            String password  = request.getParameter("password");
            String confirmPw = request.getParameter("confirmPassword");
            String phone     = request.getParameter("phone");
            String city      = request.getParameter("city");

            // === Server-side basic validation ===
            if (firstName == null || firstName.trim().isEmpty()
                    || lastName == null || lastName.trim().isEmpty()
                    || username == null || username.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || password == null || password.trim().isEmpty()
                    || city == null || city.trim().isEmpty()) {
                redirect(response, "Please fill in all required fields.");
                return;
            }

            if (!password.equals(confirmPw)) {
                redirect(response, "Passwords do not match.");
                return;
            }

            if (password.length() < 6) {
                redirect(response, "Password must be at least 6 characters.");
                return;
            }

            if (requestDAO.usernameExists(username.trim())) {
                redirect(response, "Username already taken or pending review.");
                return;
            }

            if (requestDAO.emailExists(email.trim())) {
                redirect(response, "Email already registered or pending review.");
                return;
            }

            // === Profile picture (required) ===
            Part profilePicPart = request.getPart("profile_picture");
            if (profilePicPart == null || profilePicPart.getSize() == 0) {
                redirect(response, "A profile picture is required.");
                return;
            }
            if (profilePicPart.getContentType() == null || !profilePicPart.getContentType().startsWith("image/")) {
                redirect(response, "Profile picture must be an image file.");
                return;
            }

            // === Qualification files (up to 3; image or PDF) ===
            List<Part> qualParts = new ArrayList<>();
            Collection<Part> allParts = request.getParts();
            for (Part p : allParts) {
                if ("qualifications[]".equals(p.getName()) && p.getSize() > 0) {
                    String ct = p.getContentType();
                    if (ct == null || (!ct.startsWith("image/") && !ct.equals("application/pdf"))) {
                        redirect(response, "Qualification files must be images or PDF documents.");
                        return;
                    }
                    qualParts.add(p);
                }
            }
            if (qualParts.size() > 3) {
                redirect(response, "You may upload at most 3 qualification files.");
                return;
            }

            // === Experience fields ===
            String expCompany = request.getParameter("experience_company");
            String expRole    = request.getParameter("experience_role");
            String expYearsStr = request.getParameter("experience_years");
            String empIdName  = request.getParameter("emp_id_card_name");
            Part   empIdPart  = request.getPart("emp_id_card");

            boolean hasQualifications = !qualParts.isEmpty();
            boolean hasExperience     = expCompany != null && !expCompany.trim().isEmpty();

            // At least one of qualifications or experience is required
            if (!hasQualifications && !hasExperience) {
                redirect(response, "You must provide at least one qualification file or workplace experience details.");
                return;
            }

            // If experience section is filled, require employee ID card and name
            if (hasExperience) {
                if (empIdPart == null || empIdPart.getSize() == 0) {
                    redirect(response, "An Employee ID card image is required when providing work experience.");
                    return;
                }
                if (empIdPart.getContentType() == null || !empIdPart.getContentType().startsWith("image/")) {
                    redirect(response, "Employee ID card must be an image file.");
                    return;
                }
                if (empIdName == null || empIdName.trim().isEmpty()) {
                    redirect(response, "Please enter the name as it appears on your Employee ID card.");
                    return;
                }
                // Name on ID card must match registered name (case-insensitive)
                String fullName = (firstName.trim() + " " + lastName.trim()).toLowerCase();
                if (!empIdName.trim().toLowerCase().equals(fullName)) {
                    redirect(response, "The name on your Employee ID card must match your registered name (" + firstName.trim() + " " + lastName.trim() + ").");
                    return;
                }
            }

            // === Optional work proof images (up to 5) ===
            List<Part> proofParts = new ArrayList<>();
            for (Part p : allParts) {
                if ("work_proofs[]".equals(p.getName()) && p.getSize() > 0) {
                    if (p.getContentType() == null || !p.getContentType().startsWith("image/")) {
                        redirect(response, "Work proof files must be image files.");
                        return;
                    }
                    proofParts.add(p);
                }
            }
            if (proofParts.size() > 5) {
                redirect(response, "You may upload at most 5 work proof images.");
                return;
            }

            // === Save files ===
            String safeUsername = username.trim().replaceAll("[^a-zA-Z0-9_]", "_");

            String profilePicPath = ImageUploadUtil.saveTechnicianUpload(profilePicPart, "tech_profile_" + safeUsername, webAppPath);

            List<TechnicianRequestFile> fileRecords = new ArrayList<>();

            for (int i = 0; i < qualParts.size(); i++) {
                Part p = qualParts.get(i);
                String savedPath = ImageUploadUtil.saveTechnicianUpload(p, "tech_qual_" + i + "_" + safeUsername, webAppPath);
                TechnicianRequestFile f = new TechnicianRequestFile();
                f.setFileType("QUALIFICATION");
                f.setFilePath(savedPath);
                f.setOriginalFilename(p.getSubmittedFileName());
                fileRecords.add(f);
            }

            String empIdCardPath = null;
            if (hasExperience) {
                empIdCardPath = ImageUploadUtil.saveTechnicianUpload(empIdPart, "tech_empid_" + safeUsername, webAppPath);
            }

            for (int i = 0; i < proofParts.size(); i++) {
                Part p = proofParts.get(i);
                String savedPath = ImageUploadUtil.saveTechnicianUpload(p, "tech_proof_" + i + "_" + safeUsername, webAppPath);
                TechnicianRequestFile f = new TechnicianRequestFile();
                f.setFileType("WORK_PROOF");
                f.setFilePath(savedPath);
                f.setOriginalFilename(p.getSubmittedFileName());
                fileRecords.add(f);
            }

            // === Build and submit request ===
            TechnicianRequest techRequest = new TechnicianRequest();
            techRequest.setFirstName(firstName.trim());
            techRequest.setLastName(lastName.trim());
            techRequest.setUsername(username.trim());
            techRequest.setEmail(email.trim());
            techRequest.setPhone(phone != null ? phone.trim() : null);
            techRequest.setPasswordHash(HashUtil.sha256(password));
            techRequest.setCity(city.trim());
            techRequest.setProfilePicturePath(profilePicPath);
            techRequest.setHasQualifications(hasQualifications);
            techRequest.setHasExperience(hasExperience);
            techRequest.setFiles(fileRecords);

            if (hasExperience) {
                techRequest.setExperienceCompany(expCompany.trim());
                techRequest.setExperienceRole(expRole != null ? expRole.trim() : null);
                if (expYearsStr != null && !expYearsStr.trim().isEmpty()) {
                    try { techRequest.setExperienceYears(Integer.parseInt(expYearsStr.trim())); } catch (NumberFormatException ignored) {}
                }
                techRequest.setEmpIdCardPath(empIdCardPath);
                techRequest.setEmpIdCardName(empIdName.trim());
            }

            int requestId = requestDAO.submitRequest(techRequest);

            if (requestId > 0) {
                response.sendRedirect(request.getContextPath()
                        + "/pages/authentication/login.jsp?msg=Technician+registration+submitted.+Your+application+is+pending+admin+review.");
            } else {
                redirect(response, "Registration failed. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirect(response, "An unexpected error occurred: " + e.getMessage());
        }
    }

    private void redirect(HttpServletResponse response, String error) throws IOException {
        response.sendRedirect("pages/authentication/register/registerTechnician.jsp?error="
                + java.net.URLEncoder.encode(error, "UTF-8"));
    }
}
