package com.dailyfixer.servlet.guide;

import com.dailyfixer.dao.GuideCommentDAO;
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

/**
 * Servlet for adding and deleting comments on guides.
 * URL: /guides/comment
 */
@WebServlet("/guides/comment")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 1024 * 1024 * 5,             // 5 MB per file
        maxRequestSize = 1024 * 1024 * 10          // 10 MB total
)
public class GuideCommentServlet extends HttpServlet {

    private GuideCommentDAO commentDAO = new GuideCommentDAO();

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

        String action = request.getParameter("action");
        String guideIdParam = request.getParameter("guideId");

        if (guideIdParam == null || guideIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        int guideId;
        try {
            guideId = Integer.parseInt(guideIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/guides");
            return;
        }

        if ("add".equals(action)) {
            // Add a new comment
            String comment = request.getParameter("comment");
            if (comment != null && !comment.trim().isEmpty()) {
                String imagePath = null;
                try {
                    Part imagePart = request.getPart("commentImage");
                    if (imagePart != null && imagePart.getSize() > 0) {
                        String webAppPath = getServletContext().getRealPath("/");
                        imagePath = ImageUploadUtil.saveTempImage(imagePart, "comment", webAppPath);
                    }
                } catch (Exception e) {
                    // Image upload failed; proceed without image
                }
                commentDAO.addComment(guideId, currentUser.getUserId(), comment.trim(), imagePath);
            }
        } else if ("edit".equals(action)) {
            // Edit own comment text
            String commentIdParam = request.getParameter("commentId");
            String newText = request.getParameter("comment");
            if (commentIdParam != null && newText != null && !newText.trim().isEmpty()) {
                try {
                    int commentId = Integer.parseInt(commentIdParam);
                    commentDAO.updateComment(commentId, currentUser.getUserId(), newText.trim());
                } catch (NumberFormatException e) {
                    // Ignore invalid ID
                }
            }
        } else if ("delete".equals(action)) {
            // Delete a comment (only if owner)
            String commentIdParam = request.getParameter("commentId");
            if (commentIdParam != null) {
                try {
                    int commentId = Integer.parseInt(commentIdParam);
                    String webAppPath = getServletContext().getRealPath("/");
                    commentDAO.deleteComment(commentId, currentUser.getUserId(), webAppPath);
                } catch (NumberFormatException e) {
                    // Ignore invalid comment ID
                }
            }
        } else if ("reply".equals(action) || "editReply".equals(action)) {
            // Guide creator adds or updates a reply
            String commentIdParam = request.getParameter("commentId");
            String replyText = request.getParameter("reply");
            if (commentIdParam != null && replyText != null && !replyText.trim().isEmpty()) {
                try {
                    int commentId = Integer.parseInt(commentIdParam);
                    commentDAO.addOrUpdateReply(commentId, currentUser.getUserId(), replyText.trim());
                } catch (NumberFormatException e) {
                    // Ignore invalid ID
                }
            }
        } else if ("deleteReply".equals(action)) {
            // Guide creator deletes their reply
            String commentIdParam = request.getParameter("commentId");
            if (commentIdParam != null) {
                try {
                    int commentId = Integer.parseInt(commentIdParam);
                    commentDAO.deleteReply(commentId, currentUser.getUserId());
                } catch (NumberFormatException e) {
                    // Ignore invalid ID
                }
            }
        }

        // Redirect back to guide view
        response.sendRedirect(request.getContextPath() + "/guides/view?id=" + guideId);
    }
}
