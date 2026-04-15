package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.PayoutDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Payout;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * Returns payout history for the logged-in store or driver.
 *
 * GET /payout-history → JSON array of past payouts
 */
@WebServlet(name = "PayoutHistoryServlet", urlPatterns = {"/payout-history"})
public class PayoutHistoryServlet extends HttpServlet {

    private final PayoutDAO payoutDAO = new PayoutDAO();
    private final StoreDAO storeDAO = new StoreDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || user.getRole() == null) {
            sendJson(resp, 403, "{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String role = user.getRole().trim().toLowerCase();
        List<Payout> payouts;

        if ("store".equals(role)) {
            Store store = storeDAO.getStoreByUserId(user.getUserId());
            if (store == null) {
                sendJson(resp, 404, "{\"success\":false,\"message\":\"Store not found\"}");
                return;
            }
            payouts = payoutDAO.getPayoutsByPayee("STORE", store.getStoreId());
        } else if ("driver".equals(role)) {
            payouts = payoutDAO.getPayoutsByPayee("DRIVER", user.getUserId());
        } else {
            sendJson(resp, 403, "{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        StringBuilder json = new StringBuilder("{\"success\":true,\"payouts\":[");
        for (int i = 0; i < payouts.size(); i++) {
            Payout p = payouts.get(i);
            if (i > 0) json.append(",");
            json.append("{\"payoutId\":").append(p.getPayoutId());
            json.append(",\"amount\":").append(p.getAmount());
            json.append(",\"status\":\"").append(esc(p.getStatus())).append("\"");
            json.append(",\"receiptImagePath\":").append(
                p.getReceiptImagePath() != null
                    ? "\"" + esc(p.getReceiptImagePath()) + "\""
                    : "null");
            json.append(",\"createdAt\":\"").append(
                p.getCreatedAt() != null ? dtf.format(p.getCreatedAt()) : "").append("\"");
            json.append(",\"updatedAt\":\"").append(
                p.getUpdatedAt() != null ? dtf.format(p.getUpdatedAt()) : "").append("\"");
            json.append("}");
        }
        json.append("]}");
        sendJson(resp, 200, json.toString());
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
