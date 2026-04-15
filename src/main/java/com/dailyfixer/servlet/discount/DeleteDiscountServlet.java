package com.dailyfixer.servlet.discount;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteDiscountServlet")
public class DeleteDiscountServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user == null || !"store".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
            return;
        }

        String discountIdStr = request.getParameter("discountId");
        if (discountIdStr != null && !discountIdStr.isBlank()) {
            try {
                int discountId = Integer.parseInt(discountIdStr);
                new DiscountDAO().deleteDiscount(discountId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");
    }
}
