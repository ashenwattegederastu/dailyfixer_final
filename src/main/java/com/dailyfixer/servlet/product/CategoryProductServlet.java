package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Product;
import com.dailyfixer.util.MarketplaceLocationSession;
import com.dailyfixer.util.ProductJsonUtil;
import com.dailyfixer.util.PurchaseRadiusFilter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/products")
public class CategoryProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("category");

        MarketplaceLocationSession.syncFromRequest(request);

        try {
            List<Product> products = new ProductDAO().getProductsByCategory(category);
            StoreDAO storeDAO = new StoreDAO();

            HttpSession session = request.getSession();
            Double userLat = MarketplaceLocationSession.getLat(session);
            Double userLng = MarketplaceLocationSession.getLng(session);
            if (userLat != null && userLng != null && products != null) {
                int before = products.size();
                products = PurchaseRadiusFilter.withinRadius(products, userLat, userLng, storeDAO);
                if (before > 0 && products.isEmpty()) {
                    request.setAttribute("purchaseRadiusFilteredEmpty", Boolean.TRUE);
                }
            }

            boolean radiusEmpty = Boolean.TRUE.equals(request.getAttribute("purchaseRadiusFilteredEmpty"));

            // Detect AJAX: Accept header or explicit format=json parameter
            String accept = request.getHeader("Accept");
            boolean isAjax = (accept != null && accept.contains("application/json"))
                    || "json".equals(request.getParameter("format"));

            if (isAjax) {
                String json = ProductJsonUtil.toJson(products, radiusEmpty, category, null, "category");
                response.setContentType("application/json;charset=UTF-8");
                response.setCharacterEncoding("UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.print(json);
                }
                return;
            }

            request.setAttribute("products", products);
            request.setAttribute("category", category);

            request.getRequestDispatcher("/pages/stores/category_products.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
