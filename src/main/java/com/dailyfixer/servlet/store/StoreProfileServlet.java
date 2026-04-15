package com.dailyfixer.servlet.store;

import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Store;
import com.dailyfixer.model.User;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;

/**
 * Handles store profile updates.
 * POST /store-profile → updates store name, address, city, type.
 */
@WebServlet(name = "StoreProfileServlet", urlPatterns = {"/store-profile"})
public class StoreProfileServlet extends HttpServlet {

    private static final Set<String> VALID_TYPES = Set.of("electronics", "hardware", "vehicle repair", "other");

    private final StoreDAO storeDAO = new StoreDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isStoreOrAdmin(user)) {
            sendJson(resp, 403, "{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        String storeName    = req.getParameter("storeName");
        String storeAddress = req.getParameter("storeAddress");
        String storeCity    = req.getParameter("storeCity");
        String storeType    = req.getParameter("storeType");

        if (isBlank(storeName) || isBlank(storeAddress) || isBlank(storeCity)) {
            sendJson(resp, 400, "{\"success\":false,\"message\":\"Store name, address and city are required.\"}");
            return;
        }

        String typeNorm = (storeType != null) ? storeType.trim().toLowerCase() : "other";
        if (!VALID_TYPES.contains(typeNorm)) typeNorm = "other";

        Store store = storeDAO.getStoreByUserId(user.getUserId());
        if (store == null) {
            sendJson(resp, 404, "{\"success\":false,\"message\":\"Store not found.\"}");
            return;
        }

        store.setStoreName(storeName.trim());
        store.setStoreAddress(storeAddress.trim());
        store.setStoreCity(storeCity.trim());
        store.setStoreType(typeNorm);

        boolean ok = storeDAO.updateStore(store);
        sendJson(resp, 200, "{\"success\":" + ok + (ok ? "" : ",\"message\":\"Failed to update store.\"") + "}");
    }

    private boolean isStoreOrAdmin(User u) {
        if (u == null || u.getRole() == null) return false;
        String r = u.getRole().trim().toLowerCase();
        return "store".equals(r) || "admin".equals(r);
    }

    private boolean isBlank(String s) { return s == null || s.isBlank(); }

    private void sendJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        try (PrintWriter out = resp.getWriter()) { out.write(json); }
    }
}
