package com.dailyfixer.servlet.user;

import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.dao.ClientNoShowPenaltyDAO;
import com.dailyfixer.model.ClientNoShowPenalty;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * POST /client/penalty/upload-proof
 *
 * Client uploads their payment screenshot/receipt for a no-show penalty.
 * - Validates the client owns this penalty (and it's in PENDING state).
 * - Saves the uploaded file to assets/images/uploads/penalties/.
 * - Updates penalty status to PROOF_UPLOADED.
 * - Notifies the assigned technician.
 */
@WebServlet("/client/penalty/upload-proof")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB threshold before writing to disk
    maxFileSize       = 2 * 1024 * 1024,   // 2 MB max per file
    maxRequestSize    = 5 * 1024 * 1024    // 5 MB max request
)
public class ClientPenaltyServlet extends HttpServlet {

    private static final String UPLOAD_DIR   = "assets/images/uploads/penalties";
    private static final long   MAX_SIZE_BYTES = 2 * 1024 * 1024L;

    private final ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();
    private final BookingNotificationDAO notifDAO   = new BookingNotificationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String penaltyIdStr = req.getParameter("penaltyId");
        if (penaltyIdStr == null || penaltyIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyError=missingId");
            return;
        }

        int penaltyId;
        try {
            penaltyId = Integer.parseInt(penaltyIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyError=invalidId");
            return;
        }

        try {
            ClientNoShowPenalty penalty = penaltyDAO.getByPenaltyId(penaltyId);

            if (penalty == null || penalty.getClientId() != user.getUserId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }

            if (!"PENDING".equals(penalty.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyError=alreadySubmitted");
                return;
            }

            Part filePart = req.getPart("proofFile");
            if (filePart == null || filePart.getSize() == 0) {
                resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyError=noFile");
                return;
            }

            // Validate file type
            String contentType = filePart.getContentType();
            if (contentType == null ||
                (!contentType.equalsIgnoreCase("image/jpeg") && !contentType.equalsIgnoreCase("image/png"))) {
                resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyError=invalidType");
                return;
            }

            // Validate file size
            if (filePart.getSize() > MAX_SIZE_BYTES) {
                resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyError=tooLarge");
                return;
            }

            // Determine extension
            String extension = contentType.equalsIgnoreCase("image/png") ? ".png" : ".jpg";
            String fileName = "penalty_" + penaltyId + "_" + user.getUserId()
                    + "_" + System.currentTimeMillis() + extension;
            String relativePath = UPLOAD_DIR + "/" + fileName;

            // Save file
            String webAppPath = getServletContext().getRealPath("/");
            Path uploadPath = Paths.get(webAppPath, UPLOAD_DIR);
            Files.createDirectories(uploadPath);

            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, uploadPath.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            }

            // Update DB
            penaltyDAO.uploadProof(penaltyId, relativePath);

            // Notify technician
            notifDAO.createNotification(
                    penalty.getTechnicianId(),
                    penalty.getBookingId(),
                    "Client has uploaded payment proof for booking #" + penalty.getBookingId()
                    + " no-show penalty (Rs. 2,500). Please review and confirm in your Booking Calendar. "
                    + "You have 48 hours to take action before it escalates to admin.");

            resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyProofSubmitted=true");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/user/bookings/active?penaltyError=serverError");
        }
    }
}
