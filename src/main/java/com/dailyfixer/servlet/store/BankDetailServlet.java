package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.BankDetailDAO;
import com.dailyfixer.model.BankDetail;
import com.dailyfixer.model.User;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Bank details CRUD for the currently logged-in store or driver.
 *
 * GET  /bank-details  → returns current user's bank detail as JSON
 * POST /bank-details  → creates or updates bank detail (form params)
 */
@WebServlet(name = "BankDetailServlet", urlPatterns = {"/bank-details"})
public class BankDetailServlet extends HttpServlet {

    private final BankDetailDAO dao = new BankDetailDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isStoreOrDriver(user)) {
            sendJson(resp, 403, "{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        BankDetail bd = dao.getByUserId(user.getUserId());
        if (bd == null) {
            sendJson(resp, 200, "{\"success\":true,\"bank\":null}");
            return;
        }

        sendJson(resp, 200, "{\"success\":true,\"bank\":{"
            + "\"bankName\":\"" + esc(bd.getBankName()) + "\""
            + ",\"branch\":\"" + esc(bd.getBranch() != null ? bd.getBranch() : "") + "\""
            + ",\"accountNumber\":\"" + esc(bd.getAccountNumber()) + "\""
            + ",\"accountHolderName\":\"" + esc(bd.getAccountHolderName()) + "\""
            + "}}");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isStoreOrDriver(user)) {
            sendJson(resp, 403, "{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String bankName    = req.getParameter("bankName");
        String branch      = req.getParameter("branch");
        String accountNum  = req.getParameter("accountNumber");
        String holderName  = req.getParameter("accountHolderName");

        if (bankName == null || bankName.isBlank() ||
            accountNum == null || accountNum.isBlank() ||
            holderName == null || holderName.isBlank()) {
            sendJson(resp, 400,
                "{\"success\":false,\"message\":\"Bank name, account number and holder name are required.\"}");
            return;
        }

        BankDetail bd = new BankDetail();
        bd.setUserId(user.getUserId());
        bd.setBankName(bankName.trim());
        bd.setBranch(branch != null ? branch.trim() : null);
        bd.setAccountNumber(accountNum.trim());
        bd.setAccountHolderName(holderName.trim());

        boolean ok = dao.upsert(bd);
        sendJson(resp, 200,
            "{\"success\":" + ok + (ok ? "" : ",\"message\":\"Failed to save bank details\"") + "}");
    }

    private boolean isStoreOrDriver(User u) {
        if (u == null || u.getRole() == null) return false;
        String r = u.getRole().trim().toLowerCase();
        return "store".equals(r) || "driver".equals(r);
    }

    private void sendJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        try (PrintWriter out = resp.getWriter()) { out.write(json); }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
