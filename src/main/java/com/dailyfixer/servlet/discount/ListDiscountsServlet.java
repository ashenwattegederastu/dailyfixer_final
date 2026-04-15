package com.dailyfixer.servlet.discount;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ListDiscountsServlet")
public class ListDiscountsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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

        String storeUsername = user.getUsername();
        List<Discount> discounts = null;
        try {
            discounts = new DiscountDAO().getAllDiscounts(storeUsername);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("discounts", discounts);
        request.getRequestDispatcher("/pages/dashboards/storedash/discountList.jsp").forward(request, response);
    }
}
