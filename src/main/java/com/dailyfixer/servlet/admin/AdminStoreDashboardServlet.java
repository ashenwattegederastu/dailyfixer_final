package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.AdminDashboardDAO;
import com.dailyfixer.model.Order;
import com.dailyfixer.model.ProductSales;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/store-dashboard")
public class AdminStoreDashboardServlet extends HttpServlet {

    private AdminDashboardDAO adminDashboardDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        adminDashboardDAO = new AdminDashboardDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Fetch stats
        int totalStores = adminDashboardDAO.getTotalRegisteredStores();
        int totalProducts = adminDashboardDAO.getTotalProductsListed();
        int totalSalesToday = adminDashboardDAO.getTotalSalesToday();
        double revenueToday = adminDashboardDAO.getTotalRevenueToday();
        double revenueMonth = adminDashboardDAO.getTotalRevenueMonth();

        // Fetch lists
        List<ProductSales> bestSellingItems = adminDashboardDAO.getBestSellingItems(5);

        String searchQuery = request.getParameter("search");
        List<Order> transactions;
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            transactions = adminDashboardDAO.searchTransactions(searchQuery.trim());
        } else {
            transactions = adminDashboardDAO.getLatestTransactions(10);
        }

        // Set attributes
        request.setAttribute("totalStores", totalStores);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalSalesToday", totalSalesToday);
        request.setAttribute("revenueToday", revenueToday);
        request.setAttribute("revenueMonth", revenueMonth);
        request.setAttribute("bestSellingItems", bestSellingItems);
        request.setAttribute("transactions", transactions);

        // Forward to JSP
        request.getRequestDispatcher("/pages/dashboards/admindash/store_dashboard.jsp").forward(request, response);
    }
}
