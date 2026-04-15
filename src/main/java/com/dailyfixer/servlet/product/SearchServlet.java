package com.dailyfixer.servlet.product;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Product;
import com.dailyfixer.util.MarketplaceLocationSession;
import com.dailyfixer.util.PurchaseRadiusFilter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        MarketplaceLocationSession.syncFromRequest(request);

        String searchTerm = request.getParameter("q");
        
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            // If no search term, redirect to store main page
            response.sendRedirect(request.getContextPath() + "/pages/stores/store_main.jsp");
            return;
        }

        searchTerm = searchTerm.trim();
        
        // Minimum 2 characters for search (to avoid too many results)
        if (searchTerm.length() < 2) {
            request.setAttribute("error", "Please enter at least 2 characters to search.");
            request.getRequestDispatcher("/pages/stores/store_main.jsp").forward(request, response);
            return;
        }
        
        try {
            ProductDAO productDAO = new ProductDAO();
            List<Product> products = new ArrayList<>();
            String category = null;
            String searchType = "product"; // "category" or "product"
            
            // First, check if search term matches a category (case-insensitive, flexible matching)
            List<String> allCategories = productDAO.getAllCategories();
            String lowerSearchTerm = searchTerm.toLowerCase();
            
            // Try exact match first
            String exactMatch = null;
            String partialMatch = null;
            
            for (String cat : allCategories) {
                if (cat != null) {
                    String lowerCat = cat.toLowerCase();
                    if (lowerCat.equals(lowerSearchTerm)) {
                        // Exact category match - highest priority
                        exactMatch = cat;
                        break;
                    } else if (lowerCat.contains(lowerSearchTerm) || lowerSearchTerm.contains(lowerCat)) {
                        // Partial category match - store first match
                        if (partialMatch == null) {
                            partialMatch = cat;
                        }
                    }
                }
            }
            
            // Use exact match if found, otherwise use partial match
            if (exactMatch != null) {
                category = exactMatch;
                searchType = "category";
                products = productDAO.getProductsByCategory(exactMatch);
            } else if (partialMatch != null) {
                category = partialMatch;
                searchType = "category";
                products = productDAO.getProductsByCategory(partialMatch);
            }
            
            // If not a category match, search by product name
            if (products.isEmpty()) {
                List<Product> nameMatches = productDAO.searchProductsByName(searchTerm);
                
                if (!nameMatches.isEmpty()) {
                    // Found products by name
                    searchType = "product";
                    
                    // Get the first matching product (exact match has priority)
                    Product firstProduct = nameMatches.get(0);
                    category = firstProduct.getType();
                    
                    // Add the exact/priority matches first
                    products.addAll(nameMatches);
                    
                    // Then add related products from the same category (excluding already added products)
                    if (category != null) {
                        List<Product> relatedProducts = productDAO.getRelatedProducts(
                            firstProduct.getProductId(), 
                            category, 
                            10
                        );
                        
                        // Add related products that aren't already in the list
                        for (Product related : relatedProducts) {
                            boolean alreadyAdded = false;
                            for (Product existing : products) {
                                if (existing.getProductId() == related.getProductId()) {
                                    alreadyAdded = true;
                                    break;
                                }
                            }
                            if (!alreadyAdded) {
                                products.add(related);
                            }
                        }
                    }
                }
            }

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

            // Set attributes for the JSP
            request.setAttribute("products", products);
            request.setAttribute("category", category != null ? category : "Search Results");
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("searchType", searchType);
            
            // Forward to category_products.jsp (reuse the same display page)
            request.getRequestDispatcher("/pages/stores/category_products.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error searching products", e);
        }
    }
}
