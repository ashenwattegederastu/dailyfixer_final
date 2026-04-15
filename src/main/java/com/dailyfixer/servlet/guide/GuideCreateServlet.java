package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideDAO;
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
 * Servlet for creating a new guide.
 * URL: /guides/create
 */
@WebServlet("/guides/create")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 10, // 10 MB per file
        maxRequestSize = 1024 * 1024 * 50 // 50 MB total
)
public class GuideCreateServlet extends HttpServlet {

    private GuideDAO guideDAO = new GuideDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check if user is logged in as admin or volunteer
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

        String role = currentUser.getRole();
        if (!"admin".equals(role) && !"volunteer".equals(role) && !"technician".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Forward to create form
        request.getRequestDispatcher("/pages/guides/create.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Check if user is logged in as admin or volunteer
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

        String role = currentUser.getRole();
        if (!"admin".equals(role) && !"volunteer".equals(role) && !"technician".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        // Get webapp path for image uploads
        String webAppPath = getServletContext().getRealPath("/");

        try {
            // Get basic guide info
            String title = request.getParameter("title");
            String mainCategory = request.getParameter("mainCategory");
            String subCategory = request.getParameter("subCategory");
            String youtubeUrl = request.getParameter("youtubeUrl");

            // Validate required fields
            if (title == null || title.trim().isEmpty() ||
                    mainCategory == null || mainCategory.trim().isEmpty() ||
                    subCategory == null || subCategory.trim().isEmpty()) {
                request.setAttribute("error", "Please fill in all required fields.");
                request.getRequestDispatcher("/pages/guides/create.jsp").forward(request, response);
                return;
            }

            // Create guide object
            Guide guide = new Guide();
            guide.setTitle(title.trim());
            guide.setMainCategory(mainCategory.trim());
            guide.setSubCategory(subCategory.trim());
            guide.setYoutubeUrl(youtubeUrl != null && !youtubeUrl.trim().isEmpty() ? youtubeUrl.trim() : null);
            guide.setCreatedBy(currentUser.getUserId());
            guide.setCreatedRole(role);

            // Handle main image upload
            Part mainImagePart = request.getPart("mainImage");
            if (mainImagePart != null && mainImagePart.getSize() > 0) {
                String mainImagePath = ImageUploadUtil.saveTempImage(mainImagePart, "main_temp", webAppPath);
                guide.setMainImagePath(mainImagePath);
            }

            // Get requirements
            String[] requirementArray = request.getParameterValues("requirements");
            List<String> requirements = new ArrayList<>();
            if (requirementArray != null) {
                for (String req : requirementArray) {
                    if (req != null && !req.trim().isEmpty()) {
                        requirements.add(req.trim());
                    }
                }
            }

            // Get steps
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

                        // Handle step images
                        List<String> stepImagePaths = new ArrayList<>();
                        int imageIndex = 0;
                        for (Part part : request.getParts()) {
                            if (part.getName().equals("stepImage_" + i) && part.getSize() > 0) {
                                String imagePath = ImageUploadUtil.saveTempImage(part, "step_" + i + "_" + imageIndex,
                                        webAppPath);
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

            // Save guide
            int guideId = guideDAO.addGuide(guide, requirements, steps);

            if (guideId > 0) {
                // Redirect based on role
                if ("admin".equals(role)) {
                    response.sendRedirect(request.getContextPath() + "/pages/guides/admin-list.jsp?success=created");
                } else {
                    response.sendRedirect(request.getContextPath() + "/pages/guides/my-guides.jsp?success=created");
                }
            } else {
                request.setAttribute("error", "Failed to create guide. Please try again.");
                request.getRequestDispatcher("/pages/guides/create.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/pages/guides/create.jsp").forward(request, response);
        }
    }
}
