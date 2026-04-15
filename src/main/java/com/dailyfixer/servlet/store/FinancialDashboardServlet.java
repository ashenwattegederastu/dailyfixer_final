package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.PayoutDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;

/**
 * Returns the financial balances for the logged-in store or driver.
 *
 * GET /financial-dashboard → JSON {lifetime, pending, available}
 */
@WebServlet(name = "FinancialDashboardServlet", urlPatterns = {"/financial-dashboard"})
public class FinancialDashboardServlet extends HttpServlet {

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
        BigDecimal[] balances;

        if ("store".equals(role)) {
            Store store = storeDAO.getStoreByUserId(user.getUserId());
            if (store == null) {
                sendJson(resp, 404, "{\"success\":false,\"message\":\"Store not found\"}");
                return;
            }
            balances = payoutDAO.getStoreBalances(store.getStoreId());
        } else if ("driver".equals(role)) {
            balances = payoutDAO.getDriverBalances(user.getUserId());
        } else {
            sendJson(resp, 403, "{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String refundedField    = balances.length > 3 ? ",\"refunded\":"    + balances[3] : "";
        String commissionField  = balances.length > 4 ? ",\"commission\":" + balances[4] : "";
        sendJson(resp, 200, "{\"success\":true"
            + ",\"lifetime\":"  + balances[0]
            + ",\"pending\":"   + balances[1]
            + ",\"available\":" + balances[2]
            + refundedField
            + commissionField
            + "}");
    }

    private void sendJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        try (PrintWriter out = resp.getWriter()) { out.write(json); }
    }
}
