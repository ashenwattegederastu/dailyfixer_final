package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Serves the admin refund management page and handles marking orders as refunded.
 * GET  /admin/refunds          — renders refunds.jsp with all REFUND_PENDING orders
 * POST /admin/refunds          — marks a single order as REFUNDED, returns JSON
 */
@WebServlet(name = "AdminRefundsServlet", urlPatterns = {"/admin/refunds"})
public class AdminRefundsServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.sendRedirect(req.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        List<Order> pendingRefunds = orderDAO.getOrdersByStatus("REFUND_PENDING");
        req.setAttribute("pendingRefunds", pendingRefunds);
        req.getRequestDispatcher("/pages/dashboards/admindash/refunds.jsp")
           .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("currentUser");
        if (!isAdmin(user)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String orderId      = req.getParameter("orderId");
        String refundNumber = req.getParameter("refundNumber");

        if (orderId == null || orderId.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Missing orderId\"}");
            return;
        }
        if (refundNumber == null || refundNumber.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Refund number is required\"}");
            return;
        }

        boolean ok = orderDAO.markRefunded(orderId.trim(), refundNumber.trim());
        if (ok) {
            resp.getWriter().write("{\"success\":true}");
        } else {
            resp.getWriter().write("{\"success\":false,\"message\":\"Order not found or not in REFUND_PENDING state\"}");
        }
    }

    private boolean isAdmin(User user) {
        return user != null && user.getRole() != null
                && "admin".equalsIgnoreCase(user.getRole().trim());
    }
}
