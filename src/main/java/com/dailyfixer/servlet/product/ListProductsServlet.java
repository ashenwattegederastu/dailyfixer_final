package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ListProductsServlet extends HttpServlet {
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

        List<Product> products = new ArrayList<>();
        try {
            products = new ProductDAO().getAllProducts(storeUsername);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        request.setAttribute("products", products);
        request.getRequestDispatcher("/pages/dashboards/storedash/productList.jsp").forward(request, response);
    }
}
