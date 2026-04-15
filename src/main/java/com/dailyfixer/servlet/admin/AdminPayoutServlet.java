package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.BankDetailDAO;
import com.dailyfixer.dao.PayoutDAO;
import com.dailyfixer.dao.StoreOrderDAO;
import com.dailyfixer.model.BankDetail;
import com.dailyfixer.model.Payout;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;

/**
 * Admin Payout Management.
 *
 * GET  /admin/payouts              → renders payouts.jsp
 * POST /admin/payouts?action=generate   → batch-create PENDING payouts (JSON)
 * POST /admin/payouts?action=lock       → optimistic lock a payout (JSON)
 * POST /admin/payouts?action=unlock     → release lock (JSON)
 * POST /admin/payouts?action=complete   → upload receipt + complete (multipart, JSON)
 * GET  /admin/payouts?action=detail&id= → payout detail with bank info (JSON)
 */
@WebServlet(name = "AdminPayoutServlet", urlPatterns = {"/admin/payouts"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize       = 5 * 1024 * 1024,  // 5 MB
    maxRequestSize    = 10 * 1024 * 1024   // 10 MB
)
public class AdminPayoutServlet extends HttpServlet {

    private static final String RECEIPT_DIR = "assets/images/uploads/receipts";
    private final PayoutDAO payoutDAO = new PayoutDAO();
    private final BankDetailDAO bankDetailDAO = new BankDetailDAO();
    private final StoreOrderDAO storeOrderDAO = new StoreOrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // JSON detail endpoint
        if ("detail".equals(action)) {
            handleDetail(req, resp, user);
            return;
        }

        // JSON list endpoint (called by the JSP's fetch)
        if ("list".equals(action)) {
            handleList(resp);
            return;
        }

        // Default: render the JSP
        req.getRequestDispatcher("/pages/dashboards/admindash/payouts.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            sendJson(resp, HttpServletResponse.SC_FORBIDDEN,
                     "{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        // For multipart requests, get action from the parts
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "generate":
                handleGenerate(resp);
                break;
            case "lock":
                handleLock(req, resp, user);
                break;
            case "unlock":
                handleUnlock(req, resp, user);
                break;
            case "complete":
                handleComplete(req, resp, user);
                break;
            default:
                sendJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                         "{\"success\":false,\"message\":\"Unknown action\"}");
        }
    }

    // ── Generate ────────────────────────────────────────────────────────────

    private void handleGenerate(HttpServletResponse resp) throws IOException {
        int count = payoutDAO.generatePayouts();
        sendJson(resp, HttpServletResponse.SC_OK,
                 "{\"success\":true,\"created\":" + count
                 + ",\"message\":\"" + count + " payout(s) generated.\"}");
    }

    // ── List (JSON) ─────────────────────────────────────────────────────────

    private void handleList(HttpServletResponse resp) throws IOException {
        List<Payout> pending    = payoutDAO.getPayoutsByStatus("PENDING");
        List<Payout> processing = payoutDAO.getPayoutsByStatus("PROCESSING");
        List<Payout> completed  = payoutDAO.getPayoutsByStatus("COMPLETED");

        java.math.BigDecimal totalCommission = storeOrderDAO.getTotalCommissionCollected();

        StringBuilder json = new StringBuilder("{\"success\":true");
        json.append(",\"pending\":").append(payoutsToJson(pending));
        json.append(",\"processing\":").append(payoutsToJson(processing));
        json.append(",\"completed\":").append(payoutsToJson(completed));
        json.append(",\"totalCommission\":").append(totalCommission);
        json.append("}");
        sendJson(resp, HttpServletResponse.SC_OK, json.toString());
    }

    private String payoutsToJson(List<Payout> payouts) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < payouts.size(); i++) {
            Payout p = payouts.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"payoutId\":").append(p.getPayoutId());
            sb.append(",\"payeeType\":\"").append(esc(p.getPayeeType())).append("\"");
            sb.append(",\"payeeName\":\"").append(esc(p.getPayeeName())).append("\"");
            sb.append(",\"payeeId\":").append(p.getPayeeId());
            sb.append(",\"amount\":").append(p.getAmount());
            sb.append(",\"status\":\"").append(esc(p.getStatus())).append("\"");
            sb.append(",\"lockedByAdminId\":").append(p.getLockedByAdminId());
            sb.append(",\"adminName\":\"").append(esc(p.getAdminName())).append("\"");
            sb.append(",\"receiptImagePath\":");
            if (p.getReceiptImagePath() != null) {
                sb.append("\"").append(esc(p.getReceiptImagePath())).append("\"");
            } else {
                sb.append("null");
            }
            sb.append(",\"createdAt\":\"").append(
                p.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(p.getCreatedAt()) : "").append("\"");
            sb.append(",\"updatedAt\":\"").append(
                p.getUpdatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(p.getUpdatedAt()) : "").append("\"");
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    // ── Lock ────────────────────────────────────────────────────────────────

    private void handleLock(HttpServletRequest req, HttpServletResponse resp, User admin)
            throws IOException {
        String idStr = req.getParameter("payoutId");
        if (idStr == null || idStr.isBlank()) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                     "{\"success\":false,\"message\":\"Missing payoutId\"}");
            return;
        }
        int payoutId = Integer.parseInt(idStr);
        boolean locked = payoutDAO.lockPayout(payoutId, admin.getUserId());
        if (locked) {
            sendJson(resp, HttpServletResponse.SC_OK, "{\"success\":true}");
        } else {
            sendJson(resp, HttpServletResponse.SC_CONFLICT,
                     "{\"success\":false,\"message\":\"Another admin is already processing this payout.\"}");
        }
    }

    // ── Unlock ──────────────────────────────────────────────────────────────

    private void handleUnlock(HttpServletRequest req, HttpServletResponse resp, User admin)
            throws IOException {
        String idStr = req.getParameter("payoutId");
        if (idStr == null || idStr.isBlank()) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                     "{\"success\":false,\"message\":\"Missing payoutId\"}");
            return;
        }
        int payoutId = Integer.parseInt(idStr);
        boolean ok = payoutDAO.unlockPayout(payoutId, admin.getUserId());
        sendJson(resp, HttpServletResponse.SC_OK,
                 "{\"success\":" + ok + "}");
    }

    // ── Complete (multipart – receipt upload) ───────────────────────────────

    private void handleComplete(HttpServletRequest req, HttpServletResponse resp, User admin)
            throws IOException, ServletException {
        String idStr = req.getParameter("payoutId");
        if (idStr == null || idStr.isBlank()) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                     "{\"success\":false,\"message\":\"Missing payoutId\"}");
            return;
        }
        int payoutId = Integer.parseInt(idStr);

        // Save receipt image
        Part receiptPart = req.getPart("receipt");
        if (receiptPart == null || receiptPart.getSize() == 0) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                     "{\"success\":false,\"message\":\"Receipt image is required\"}");
            return;
        }

        String webAppPath = req.getServletContext().getRealPath("/");
        String ext = getExtension(receiptPart);
        String fileName = "receipt_" + payoutId + "_" + System.currentTimeMillis() + ext;
        String relativePath = RECEIPT_DIR + "/" + fileName;

        Path uploadDir = Paths.get(webAppPath, RECEIPT_DIR);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
        Path filePath = Paths.get(webAppPath, relativePath);
        try (InputStream input = receiptPart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        boolean ok = payoutDAO.completePayout(payoutId, admin.getUserId(), relativePath);
        if (ok) {
            sendJson(resp, HttpServletResponse.SC_OK, "{\"success\":true}");
        } else {
            sendJson(resp, HttpServletResponse.SC_CONFLICT,
                     "{\"success\":false,\"message\":\"Could not complete payout. It may have been modified.\"}");
        }
    }

    // ── Detail (JSON) ───────────────────────────────────────────────────────

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp, User admin)
            throws IOException {
        String idStr = req.getParameter("payoutId");
        if (idStr == null || idStr.isBlank()) {
            idStr = req.getParameter("id");
        }
        if (idStr == null || idStr.isBlank()) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                     "{\"success\":false,\"message\":\"Missing id\"}");
            return;
        }

        int payoutId = Integer.parseInt(idStr);
        Payout payout = payoutDAO.getPayoutById(payoutId);
        if (payout == null) {
            sendJson(resp, HttpServletResponse.SC_NOT_FOUND,
                     "{\"success\":false,\"message\":\"Payout not found\"}");
            return;
        }

        BankDetail bank = payoutDAO.getBankDetailForPayout(payout);

        // Build available balance for the payee
        BigDecimal[] balances;
        if ("STORE".equals(payout.getPayeeType())) {
            balances = payoutDAO.getStoreBalances(payout.getPayeeId());
        } else {
            balances = payoutDAO.getDriverBalances(payout.getPayeeId());
        }

        StringBuilder json = new StringBuilder("{\"success\":true");
        json.append(",\"payout\":{");
        json.append("\"payoutId\":").append(payout.getPayoutId());
        json.append(",\"payeeType\":\"").append(esc(payout.getPayeeType())).append("\"");
        json.append(",\"payeeName\":\"").append(esc(payout.getPayeeName())).append("\"");
        json.append(",\"amount\":").append(payout.getAmount());
        json.append(",\"status\":\"").append(esc(payout.getStatus())).append("\"");
        json.append("}");

        json.append(",\"balances\":{");
        json.append("\"lifetime\":").append(balances[0]);
        json.append(",\"pending\":").append(balances[1]);
        json.append(",\"available\":").append(balances[2]);
        json.append("}");

        if (bank != null) {
            json.append(",\"bank\":{");
            json.append("\"bankName\":\"").append(esc(bank.getBankName())).append("\"");
            json.append(",\"branch\":\"").append(esc(bank.getBranch() != null ? bank.getBranch() : "")).append("\"");
            json.append(",\"accountNumber\":\"").append(esc(bank.getAccountNumber())).append("\"");
            json.append(",\"accountHolderName\":\"").append(esc(bank.getAccountHolderName())).append("\"");
            json.append("}");
        } else {
            json.append(",\"bank\":null");
        }

        json.append("}");
        sendJson(resp, HttpServletResponse.SC_OK, json.toString());
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private boolean isAdmin(User user) {
        return user != null && user.getRole() != null
                && "admin".equalsIgnoreCase(user.getRole().trim());
    }

    private void sendJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            out.write(json);
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String getExtension(Part part) {
        String name = part.getSubmittedFileName();
        if (name != null && name.contains(".")) {
            return name.substring(name.lastIndexOf("."));
        }
        String ct = part.getContentType();
        if (ct != null) {
            if (ct.contains("png")) return ".png";
            if (ct.contains("gif")) return ".gif";
            if (ct.contains("webp")) return ".webp";
            if (ct.contains("pdf")) return ".pdf";
        }
        return ".jpg";
    }
}
