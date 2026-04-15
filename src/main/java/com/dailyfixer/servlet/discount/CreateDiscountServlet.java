package com.dailyfixer.servlet.discount;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet("/CreateDiscountServlet")
public class CreateDiscountServlet extends HttpServlet {
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

        String storeUsername = user.getUsername();

        try {
            String discountName = request.getParameter("discountName");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String[] productIds = request.getParameterValues("productIds");
            String[] variantIds = request.getParameterValues("variantIds");

            if (discountName == null || discountType == null || discountValueStr == null ||
                discountName.isBlank() || discountType.isBlank() || discountValueStr.isBlank()) {
                request.setAttribute("error", "Please fill in all required fields");
                request.getRequestDispatcher("/pages/dashboards/storedash/addDiscount.jsp").forward(request, response);
                return;
            }

            BigDecimal discountValue = new BigDecimal(discountValueStr);
            Timestamp startDate = null;
            Timestamp endDate = null;

            if (startDateStr != null && !startDateStr.isBlank()) {
                // Handle datetime-local format: "yyyy-MM-ddTHH:mm"
                String formattedStartDate = startDateStr.replace("T", " ") + ":00";
                startDate = Timestamp.valueOf(formattedStartDate);
            }
            if (endDateStr != null && !endDateStr.isBlank()) {
                // Handle datetime-local format: "yyyy-MM-ddTHH:mm"
                String formattedEndDate = endDateStr.replace("T", " ") + ":00";
                endDate = Timestamp.valueOf(formattedEndDate);
            }

            Discount discount = new Discount(discountName, discountType, discountValue, startDate, endDate, storeUsername);
            DiscountDAO discountDAO = new DiscountDAO();
            int discountId = discountDAO.addDiscount(discount);

            // Link products
            if (productIds != null && productIds.length > 0) {
                List<Integer> productIdList = new ArrayList<>();
                for (String productIdStr : productIds) {
                    try {
                        productIdList.add(Integer.parseInt(productIdStr));
                    } catch (NumberFormatException e) {
                        // Skip invalid IDs
                    }
                }
                if (!productIdList.isEmpty()) {
                    discountDAO.linkDiscountToProducts(discountId, productIdList);
                }
            }

            // Link variants
            if (variantIds != null && variantIds.length > 0) {
                List<Integer> variantIdList = new ArrayList<>();
                for (String variantIdStr : variantIds) {
                    try {
                        variantIdList.add(Integer.parseInt(variantIdStr));
                    } catch (NumberFormatException e) {
                        // Skip invalid IDs
                    }
                }
                if (!variantIdList.isEmpty()) {
                    discountDAO.linkDiscountToVariants(discountId, variantIdList);
                }
            }

            response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error creating discount: " + e.getMessage());
            request.getRequestDispatcher("/pages/dashboards/storedash/addDiscount.jsp").forward(request, response);
        }
    }
}
