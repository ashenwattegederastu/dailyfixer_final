package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.BookingNotificationDAO;
import com.dailyfixer.dao.ClientNoShowPenaltyDAO;
import com.dailyfixer.model.Booking;
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
 * POST /bookings/client-no-show
 *
 * Called when a technician marks that the client was not home.
 * - Validates technician owns this booking and it is ACCEPTED or IN_PROGRESS.
 * - Updates booking status to CLIENT_NO_SHOW.
 * - Creates a client_no_show_penalties record (PENDING, Rs. 2 500).
 * - Sends a notification to the client.
 */
@WebServlet("/bookings/client-no-show")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB
    maxFileSize       = 5 * 1024 * 1024,   // 5 MB max per file
    maxRequestSize    = 8 * 1024 * 1024    // 8 MB max request
)
public class MarkClientNoShowServlet extends HttpServlet {

    private static final String UPLOAD_DIR     = "assets/images/uploads/penalties/tech";
    private static final long   MAX_SIZE_BYTES  = 5 * 1024 * 1024L;

    private final BookingDAO bookingDAO = new BookingDAO();
    private final ClientNoShowPenaltyDAO penaltyDAO = new ClientNoShowPenaltyDAO();
    private final BookingNotificationDAO notifDAO = new BookingNotificationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || !"technician".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=missingId");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=invalidId");
            return;
        }

        try {
            Booking booking = bookingDAO.getBookingById(bookingId);

            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=notFound");
                return;
            }

            // Only the assigned technician may mark client not home
            if (booking.getTechnicianId() != user.getUserId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }

            String status = booking.getStatus();
            if (!"ACCEPTED".equals(status) && !"IN_PROGRESS".equals(status)) {
                resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=invalidStatus");
                return;
            }

            // Handle technician arrival proof photo (required)
            Part filePart = req.getPart("techProofFile");
            if (filePart == null || filePart.getSize() == 0) {
                resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=noProofFile");
                return;
            }
            String contentType = filePart.getContentType();
            if (contentType == null ||
                    (!contentType.equalsIgnoreCase("image/jpeg") && !contentType.equalsIgnoreCase("image/png"))) {
                resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=invalidProofType");
                return;
            }
            if (filePart.getSize() > MAX_SIZE_BYTES) {
                resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=proofTooLarge");
                return;
            }

            String ext = contentType.equalsIgnoreCase("image/png") ? ".png" : ".jpg";
            String fileName = "arrival_" + bookingId + "_" + user.getUserId()
                    + "_" + System.currentTimeMillis() + ext;
            String relativePath = UPLOAD_DIR + "/" + fileName;

            String webAppPath = getServletContext().getRealPath("/");
            Path uploadPath = Paths.get(webAppPath, UPLOAD_DIR);
            Files.createDirectories(uploadPath);
            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, uploadPath.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            }

            // Update booking status
            bookingDAO.updateBookingStatus(bookingId, "CLIENT_NO_SHOW");

            // Create penalty record with arrival proof
            ClientNoShowPenalty penalty = penaltyDAO.createPenalty(
                    bookingId, booking.getUserId(), user.getUserId(), relativePath);

            // Notify client
            String penaltyIdStr = penalty != null ? String.valueOf(penalty.getPenaltyId()) : "?";
            notifDAO.createNotification(
                    booking.getUserId(),
                    bookingId,
                    "Your technician arrived for booking #" + bookingId
                    + " but could not reach you. A no-show penalty of Rs. 2,500 has been applied. "
                    + "Please log in to your Active Bookings page to upload payment proof. "
                    + "Penalty reference: #" + penaltyIdStr + ".");

            resp.sendRedirect(req.getContextPath() + "/bookings/calendar?clientNoShow=true");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/bookings/calendar?error=serverError");
        }
    }
}
