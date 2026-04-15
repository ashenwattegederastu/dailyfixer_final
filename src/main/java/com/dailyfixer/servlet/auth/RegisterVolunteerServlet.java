package com.dailyfixer.servlet.auth;

import com.dailyfixer.dao.VolunteerRequestDAO;
import com.dailyfixer.model.VolunteerProof;
import com.dailyfixer.model.VolunteerRequest;
import com.dailyfixer.util.HashUtil;
import com.dailyfixer.util.ImageUploadUtil;

import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "RegisterVolunteerServlet", urlPatterns = { "/registerVolunteer" })
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 5, // 5 MB per file
        maxRequestSize = 1024 * 1024 * 30 // 30 MB total
)
public class RegisterVolunteerServlet extends HttpServlet {

    private VolunteerRequestDAO requestDAO = new VolunteerRequestDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String webAppPath = getServletContext().getRealPath("/");

        try {
            // === Step 1: Basic Account Info ===
            String fullName = req.getParameter("fullName");
            String username = req.getParameter("username");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String password = req.getParameter("password");
            String confirmPassword = req.getParameter("confirmPassword");
            String city = req.getParameter("city");

            // Server-side validation
            if (fullName == null || fullName.trim().isEmpty() ||
                    username == null || username.trim().isEmpty() ||
                    email == null || email.trim().isEmpty() ||
                    password == null || password.trim().isEmpty()) {
                req.setAttribute("errorMsg", "Please fill in all required fields.");
                req.getRequestDispatcher("pages/authentication/register/registerVolunteer.jsp").forward(req, resp);
                return;
            }

            if (!password.equals(confirmPassword)) {
                req.setAttribute("errorMsg", "Passwords do not match.");
                req.getRequestDispatcher("pages/authentication/register/registerVolunteer.jsp").forward(req, resp);
                return;
            }

            // Check for duplicate username/email
            if (requestDAO.usernameExists(username.trim())) {
                req.setAttribute("errorMsg", "Username already exists or is pending review.");
                req.getRequestDispatcher("pages/authentication/register/registerVolunteer.jsp").forward(req, resp);
                return;
            }

            if (requestDAO.emailExists(email.trim())) {
                req.setAttribute("errorMsg", "Email already exists or is pending review.");
                req.getRequestDispatcher("pages/authentication/register/registerVolunteer.jsp").forward(req, resp);
                return;
            }

            // Handle profile picture upload
            String profilePicPath = null;
            Part profilePicPart = req.getPart("profilePicture");
            if (profilePicPart != null && profilePicPart.getSize() > 0) {
                profilePicPath = ImageUploadUtil.saveVolunteerUpload(profilePicPart, "profile_" + username.trim(),
                        webAppPath);
            }

            // === Step 2: Professional Info ===
            String[] expertiseArray = req.getParameterValues("expertise");
            String expertise = "";
            if (expertiseArray != null) {
                expertise = String.join(", ", expertiseArray);
            }
            String expertiseOther = req.getParameter("expertiseOther");
            if (expertiseOther != null && !expertiseOther.trim().isEmpty()) {
                if (!expertise.isEmpty())
                    expertise += ", ";
                expertise += expertiseOther.trim();
            }

            String skillLevel = req.getParameter("skillLevel");
            String bio = req.getParameter("bio");

            // Handle sample guide PDF upload
            String sampleGuideFilePath = null;
            Part sampleGuidePart = req.getPart("sampleGuideFile");
            if (sampleGuidePart != null && sampleGuidePart.getSize() > 0) {
                sampleGuideFilePath = ImageUploadUtil.saveVolunteerUpload(sampleGuidePart, "sample_" + username.trim(),
                        webAppPath);
            }

            // === Step 3: Qualification Proofs ===
            List<VolunteerProof> proofs = new ArrayList<>();
            for (int i = 0; i < 5; i++) {
                Part proofImagePart = req.getPart("proofImage_" + i);
                String proofType = req.getParameter("proofType_" + i);
                String proofDesc = req.getParameter("proofDesc_" + i);

                if (proofImagePart != null && proofImagePart.getSize() > 0 && proofType != null
                        && !proofType.isEmpty()) {
                    String proofPath = ImageUploadUtil.saveVolunteerUpload(proofImagePart,
                            "proof_" + i + "_" + username.trim(), webAppPath);
                    if (proofPath != null) {
                        VolunteerProof proof = new VolunteerProof();
                        proof.setProofType(proofType);
                        proof.setImagePath(proofPath);
                        proof.setDescription(proofDesc != null ? proofDesc.trim() : "");
                        proof.setUploadOrder(i + 1);
                        proofs.add(proof);
                    }
                }
            }

            // === Build Request Object ===
            VolunteerRequest request = new VolunteerRequest();
            request.setFullName(fullName.trim());
            request.setUsername(username.trim());
            request.setEmail(email.trim());
            request.setPhone(phone != null ? phone.trim() : "");
            request.setPasswordHash(HashUtil.sha256(password));
            request.setCity(city != null ? city.trim() : "");
            request.setProfilePicturePath(profilePicPath);
            request.setExpertise(expertise);
            request.setSkillLevel(skillLevel);
            request.setBio(bio != null ? bio.trim() : "");
            request.setSampleGuideFilePath(sampleGuideFilePath);
            request.setProofs(proofs);

            // === Submit ===
            int requestId = requestDAO.submitRequest(request);

            if (requestId > 0) {
                resp.sendRedirect(req.getContextPath() + "/pages/authentication/register/volunteerRegistrationSuccess.jsp");
            } else {
                req.setAttribute("errorMsg", "Registration failed. Please try again.");
                req.getRequestDispatcher("pages/authentication/register/registerVolunteer.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "An error occurred: " + e.getMessage());
            req.getRequestDispatcher("pages/authentication/register/registerVolunteer.jsp").forward(req, resp);
        }
    }
}
