package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.DeliveryRateDAO;
import com.dailyfixer.model.DeliveryRate;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "AdminDeliveryRatesServlet", urlPatterns = {"/admin/deliveryRates"})
public class AdminDeliveryRatesServlet extends HttpServlet {

    private DeliveryRateDAO deliveryRateDAO = new DeliveryRateDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req, resp)) return;

        List<DeliveryRate> rates = deliveryRateDAO.getAllRates();
        req.setAttribute("rates", rates);
        req.getRequestDispatcher("/pages/dashboards/admindash/deliveryRates.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req, resp)) return;

        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            int rateId = Integer.parseInt(req.getParameter("rateId"));
            deliveryRateDAO.deleteRate(rateId);

        } else if ("add".equals(action)) {
            DeliveryRate rate = parseRateFromRequest(req);
            deliveryRateDAO.addRate(rate);

        } else if ("edit".equals(action)) {
            int rateId = Integer.parseInt(req.getParameter("rateId"));
            DeliveryRate rate = parseRateFromRequest(req);
            rate.setRateId(rateId);
            deliveryRateDAO.updateRate(rate);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/deliveryRates");
    }

    private DeliveryRate parseRateFromRequest(HttpServletRequest req) {
        DeliveryRate rate = new DeliveryRate();
        rate.setVehicleType(req.getParameter("vehicleType").trim());
        rate.setCostPerKm(new BigDecimal(req.getParameter("costPerKm")));
        rate.setBaseFee(new BigDecimal(req.getParameter("baseFee")));
        rate.setDistributionWeight(new BigDecimal(req.getParameter("distributionWeight")));
        rate.setActive("on".equals(req.getParameter("isActive")) || "true".equals(req.getParameter("isActive")));
        String maxStr = req.getParameter("maxSimultaneousOrders");
        int maxOrders = 3; // safe default
        try {
            if (maxStr != null && !maxStr.isBlank()) maxOrders = Integer.parseInt(maxStr);
            if (maxOrders < 1) maxOrders = 1;
        } catch (NumberFormatException ignored) {}
        rate.setMaxSimultaneousOrders(maxOrders);
        return rate;
    }

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return false;
        }
        return true;
    }
}
