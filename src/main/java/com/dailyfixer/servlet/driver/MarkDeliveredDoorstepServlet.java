package com.dailyfixer.servlet.driver;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.DeliveryDropProofDAO;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.dao.StoreOrderDAO;
import com.dailyfixer.model.DeliveryAssignment;
import com.dailyfixer.model.DeliveryDropProof;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * POST /driver/markDeliveredDoorstep
 * Completes delivery using doorstep-drop proof photos when buyer is unreachable.
 */
@WebServlet(name = "MarkDeliveredDoorstepServlet", urlPatterns = {"/driver/markDeliveredDoorstep"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 8 * 1024 * 1024,
        maxRequestSize = 20 * 1024 * 1024
)
public class MarkDeliveredDoorstepServlet extends HttpServlet {

    private static final String PROOF_DIR = "assets/images/uploads/delivery-proofs";

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    private final DeliveryDropProofDAO proofDAO = new DeliveryDropProofDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final StoreOrderDAO storeOrderDAO = new StoreOrderDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String assignmentIdStr = req.getParameter("assignmentId");
        String note = req.getParameter("note");
        if (assignmentIdStr == null || assignmentIdStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing assignmentId\"}");
            return;
        }

        Part photoPackagePart = req.getPart("photoPackage");
        Part photoDoorPart = req.getPart("photoDoorContext");
        if (photoPackagePart == null || photoPackagePart.getSize() == 0
                || photoDoorPart == null || photoDoorPart.getSize() == 0) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Two proof photos are required\"}");
            return;
        }

        if (!isImage(photoPackagePart) || !isImage(photoDoorPart)) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Only image files are allowed\"}");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            DeliveryAssignment da = assignmentDAO.getByAssignmentId(assignmentId);
            if (da == null) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Assignment not found\"}");
                return;
            }

            if (da.getDriverId() == null || da.getDriverId() != user.getUserId()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"This assignment is not assigned to you\"}");
                return;
            }

            if (!"PICKED_UP".equalsIgnoreCase(da.getStatus())) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Doorstep completion is only allowed after pickup\"}");
                return;
            }

            Order order = orderDAO.findOrderById(da.getOrderId());
            if (order == null) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Order not found\"}");
                return;
            }

            if (!order.isDoorstepDropConsent()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Buyer did not consent to doorstep drop completion\"}");
                return;
            }

            String webAppPath = req.getServletContext().getRealPath("/");
            String photoPackagePath = saveProofPhoto(photoPackagePart, assignmentId, "pkg", webAppPath);
            String photoDoorPath = saveProofPhoto(photoDoorPart, assignmentId, "door", webAppPath);

            boolean delivered = assignmentDAO.markDeliveredDoorstep(assignmentId, user.getUserId());
            if (!delivered) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Could not mark delivery complete\"}");
                return;
            }

            DeliveryDropProof proof = new DeliveryDropProof();
            proof.setAssignmentId(assignmentId);
            proof.setOrderId(da.getOrderId());
            proof.setDriverId(user.getUserId());
            proof.setPhotoPackagePath(photoPackagePath);
            proof.setPhotoDoorContextPath(photoDoorPath);
            proof.setNote(note);

            boolean proofSaved = proofDAO.create(proof);
            if (!proofSaved) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Delivery was marked complete but proof save failed\"}");
                return;
            }

            orderDAO.updateStatus(da.getOrderId(), "DELIVERED");
            storeOrderDAO.updateCommission(da.getOrderId());

            resp.getWriter().write("{\"success\":true}");
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid assignmentId\"}");
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unexpected error";
            resp.getWriter().write("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }

    private boolean isImage(Part part) {
        return part.getContentType() != null && part.getContentType().startsWith("image/");
    }

    private String saveProofPhoto(Part part, int assignmentId, String kind, String webAppPath) throws IOException {
        String ext = getExtension(part);
        String fileName = "assignment_" + assignmentId + "_" + kind + "_" + System.currentTimeMillis() + ext;
        String relativePath = PROOF_DIR + "/" + fileName;

        Path uploadDir = Paths.get(webAppPath, PROOF_DIR);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }

        Path filePath = Paths.get(webAppPath, relativePath);
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
        return relativePath;
    }

    private String getExtension(Part part) {
        String name = part.getSubmittedFileName();
        if (name != null && name.contains(".")) {
            return name.substring(name.lastIndexOf('.'));
        }
        String ct = part.getContentType();
        if (ct != null) {
            if (ct.contains("png")) return ".png";
            if (ct.contains("gif")) return ".gif";
            if (ct.contains("webp")) return ".webp";
        }
        return ".jpg";
    }
}
