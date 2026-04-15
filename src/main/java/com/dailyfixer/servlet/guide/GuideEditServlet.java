package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
import com.dailyfixer.dao.GuideFlagDAO;
import com.dailyfixer.model.Guide;
import com.dailyfixer.model.GuideStep;
import com.dailyfixer.model.User;
import com.dailyfixer.util.ImageUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet for editing an existing guide.
 * URL: /guides/edit?id=123
 */
@WebServlet("/guides/edit")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class GuideEditServlet extends HttpServlet {

    private GuideDAO guideDAO = new GuideDAO();
    private GuideFlagDAO flagDAO = new GuideFlagDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        Guide guide = guideDAO.getGuideById(guideId);
        if (guide == null) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Check if user can edit (admin or creator)
        boolean canEdit = "admin".equals(currentUser.getRole()) ||
                guide.getCreatedBy() == currentUser.getUserId();

        if (!canEdit) {
            response.sendRedirect(request.getContextPath() + "/guides/view?id=" + guideId);
            return;
        }

        request.setAttribute("guide", guide);
        request.getRequestDispatcher("/pages/guides/edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String idParam = request.getParameter("guideId");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        Guide existingGuide = guideDAO.getGuideById(guideId);
        if (existingGuide == null) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Check if user can edit
        boolean canEdit = "admin".equals(currentUser.getRole()) ||
                existingGuide.getCreatedBy() == currentUser.getUserId();

        if (!canEdit) {
            response.sendRedirect(request.getContextPath() + "/guides/view?id=" + guideId);
            return;
        }

        String webAppPath = getServletContext().getRealPath("/");

        try {
            // Get updated info
            String title = request.getParameter("title");
            String mainCategory = request.getParameter("mainCategory");
            String subCategory = request.getParameter("subCategory");
            String youtubeUrl = request.getParameter("youtubeUrl");

            if (title == null || title.trim().isEmpty() ||
                    mainCategory == null || mainCategory.trim().isEmpty() ||
                    subCategory == null || subCategory.trim().isEmpty()) {
                request.setAttribute("error", "Please fill in all required fields.");
                request.setAttribute("guide", existingGuide);
                request.getRequestDispatcher("/pages/guides/edit.jsp").forward(request, response);
                return;
            }

            // Update guide object
            existingGuide.setTitle(title.trim());
            existingGuide.setMainCategory(mainCategory.trim());
            existingGuide.setSubCategory(subCategory.trim());
            existingGuide.setYoutubeUrl(youtubeUrl != null && !youtubeUrl.trim().isEmpty() ? youtubeUrl.trim() : null);

            // Handle main image update
            Part mainImagePart = request.getPart("mainImage");
            if (mainImagePart != null && mainImagePart.getSize() > 0) {
                // Delete old image
                if (existingGuide.getMainImagePath() != null) {
                    ImageUploadUtil.deleteImage(existingGuide.getMainImagePath(), webAppPath);
                }
                // Save new image
                String mainImagePath = ImageUploadUtil.saveTempImage(mainImagePart, "main_" + guideId, webAppPath);
                existingGuide.setMainImagePath(mainImagePath);
            }

            // Update guide
            boolean success = guideDAO.updateGuide(existingGuide);

            // Update requirements
            String[] requirementArray = request.getParameterValues("requirements");
            List<String> requirements = new ArrayList<>();
            if (requirementArray != null) {
                for (String req : requirementArray) {
                    if (req != null && !req.trim().isEmpty()) {
                        requirements.add(req.trim());
                    }
                }
            }
            guideDAO.updateRequirements(guideId, requirements);

            // Update steps
            String[] stepTitles = request.getParameterValues("stepTitle");
            String[] stepBodies = request.getParameterValues("stepBody");
            List<GuideStep> steps = new ArrayList<>();

            if (stepTitles != null) {
                for (int i = 0; i < stepTitles.length; i++) {
                    if (stepTitles[i] != null && !stepTitles[i].trim().isEmpty()) {
                        GuideStep step = new GuideStep();
                        step.setStepTitle(stepTitles[i].trim());
                        step.setStepBody(stepBodies != null && i < stepBodies.length ? stepBodies[i] : "");
                        step.setStepOrder(i + 1);

                        List<String> stepImagePaths = new ArrayList<>();

                        // 1. Handle existing images (kept by user)
                        String[] keptImages = request.getParameterValues("existingImages_" + i);
                        if (keptImages != null) {
                            for (String path : keptImages) {
                                if (path != null && !path.isEmpty()) {
                                    stepImagePaths.add(path);
                                }
                            }
                        }

                        // 2. Handle new images
                        int imageIndex = 0;
                        for (Part part : request.getParts()) {
                            if (part.getName().equals("stepImage_" + i) && part.getSize() > 0) {
                                String imagePath = ImageUploadUtil.saveTempImage(part,
                                        "step_" + i + "_" + System.currentTimeMillis() + "_" + imageIndex, webAppPath);
                                if (imagePath != null) {
                                    stepImagePaths.add(imagePath);
                                    imageIndex++;
                                }
                            }
                        }
                        step.setImagePaths(stepImagePaths);
                        steps.add(step);
                    }
                }
            }

            // Update steps in DB and get list of old images to delete from disk (images
            // that were NOT kept)
            List<String> imagesToDelete = guideDAO.updateSteps(guideId, steps);

            // Delete removed images from disk
            for (String path : imagesToDelete) {
                ImageUploadUtil.deleteImage(path, webAppPath);
            }

            if (success) {
                // If guide was hidden, mark as pending review for admin
                if ("HIDDEN".equals(existingGuide.getStatus())) {
                    flagDAO.markPendingReview(guideId);
                }
                response.sendRedirect(request.getContextPath() + "/guides/view?id=" + guideId + "&success=updated");
            } else {
                request.setAttribute("error", "Failed to update guide. Please try again.");
                request.setAttribute("guide", existingGuide);
                request.getRequestDispatcher("/pages/guides/edit.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.setAttribute("guide", existingGuide);
            request.getRequestDispatcher("/pages/guides/edit.jsp").forward(request, response);
        }
    }
}
