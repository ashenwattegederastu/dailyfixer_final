package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Product;
import com.dailyfixer.util.MarketplaceLocationSession;
import com.dailyfixer.util.PurchaseRadiusFilter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
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

            request.setAttribute("products", products);
            request.setAttribute("category", category);

            request.getRequestDispatcher("/pages/stores/category_products.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
