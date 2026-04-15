package com.dailyfixer.servlet.discount;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/EditDiscountServlet")
public class EditDiscountServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to discount list if accessed via GET
        response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");
    }

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
            String discountIdStr = request.getParameter("discountId");
            if (discountIdStr == null || discountIdStr.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");
                return;
            }

            int discountId = Integer.parseInt(discountIdStr);
            DiscountDAO discountDAO = new DiscountDAO();
            Discount existingDiscount = discountDAO.getDiscountById(discountId);

            // Verify discount belongs to this store
            if (existingDiscount == null || !existingDiscount.getStoreUsername().equals(storeUsername)) {
                response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");
                return;
            }

            String discountName = request.getParameter("discountName");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String isActiveStr = request.getParameter("isActive");
            String[] productIds = request.getParameterValues("productIds");
            String[] variantIds = request.getParameterValues("variantIds");

            if (discountName == null || discountType == null || discountValueStr == null ||
                discountName.isBlank() || discountType.isBlank() || discountValueStr.isBlank()) {
                request.setAttribute("error", "Please fill in all required fields");
                response.sendRedirect(request.getContextPath() + "/pages/dashboards/storedash/editDiscount.jsp?discountId=" + discountId);
                return;
            }

            BigDecimal discountValue = new BigDecimal(discountValueStr);
            Timestamp startDate = null;
            Timestamp endDate = null;
            boolean isActive = isActiveStr != null && "true".equals(isActiveStr);

            if (startDateStr != null && !startDateStr.isBlank()) {
                String formattedStartDate = startDateStr.replace("T", " ") + ":00";
                startDate = Timestamp.valueOf(formattedStartDate);
            }
            if (endDateStr != null && !endDateStr.isBlank()) {
                String formattedEndDate = endDateStr.replace("T", " ") + ":00";
                endDate = Timestamp.valueOf(formattedEndDate);
            }

            // Update discount
            existingDiscount.setDiscountName(discountName);
            existingDiscount.setDiscountType(discountType);
            existingDiscount.setDiscountValue(discountValue);
            existingDiscount.setStartDate(startDate);
            existingDiscount.setEndDate(endDate);
            existingDiscount.setActive(isActive);

            discountDAO.updateDiscount(existingDiscount);

            // Update product links
            List<Integer> productIdList = new ArrayList<>();
            if (productIds != null && productIds.length > 0) {
                for (String productId : productIds) {
                    try {
                        productIdList.add(Integer.parseInt(productId));
                    } catch (NumberFormatException e) {
                        // Skip invalid product IDs
                    }
                }
            }
            discountDAO.linkDiscountToProducts(discountId, productIdList);

            // Update variant links
            List<Integer> variantIdList = new ArrayList<>();
            if (variantIds != null && variantIds.length > 0) {
                for (String variantId : variantIds) {
                    try {
                        variantIdList.add(Integer.parseInt(variantId));
                    } catch (NumberFormatException e) {
                        // Skip invalid variant IDs
                    }
                }
            }
            discountDAO.linkDiscountToVariants(discountId, variantIdList);

            response.sendRedirect(request.getContextPath() + "/ListDiscountsServlet");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error updating discount: " + e.getMessage());
            String discountIdStr = request.getParameter("discountId");
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/storedash/editDiscount.jsp?discountId=" + discountIdStr);
        }
    }
}
