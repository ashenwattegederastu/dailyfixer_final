package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/products")
public class AdminProductListServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchQuery = request.getParameter("search");
        List<Product> products;

        try {
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                products = productDAO.searchProductsByName(searchQuery.trim());
            } else {
                products = productDAO.getAllProductsAdmin();
            }
            request.setAttribute("products", products);
            request.getRequestDispatcher("/pages/dashboards/admindash/products.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            try {
                int productId = Integer.parseInt(request.getParameter("id"));
                productDAO.deleteProduct(productId);
                // Redirect back to list with success message
                response.sendRedirect(request.getContextPath() + "/admin/products?success=deleted");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/products?error=delete_failed");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }
}
