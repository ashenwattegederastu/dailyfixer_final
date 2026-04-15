package com.dailyfixer.servlet.product;

import java.io.*;
import java.math.BigDecimal;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.model.User;
import com.dailyfixer.util.ProductImageUtil;

@MultipartConfig(maxFileSize = 16177215) // 16 MB max
public class AddProductServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get logged-in User object from session
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
        String webAppPath = getServletContext().getRealPath("/");

        // 2. Get form parameters
        String name        = request.getParameter("name");
        String type        = request.getParameter("type");
        // "Other" category: use custom text if selected
        if ("Other".equals(type)) {
            String custom = request.getParameter("customCategory");
            if (custom != null && !custom.trim().isEmpty()) {
                type = custom.trim();
            }
        }
        String quantityStr = request.getParameter("quantity");
        int quantity = 0;
        if (quantityStr != null && !quantityStr.trim().isEmpty()) {
            try { quantity = Integer.parseInt(quantityStr); } catch (NumberFormatException ignored) {}
        }
        String quantityUnit  = request.getParameter("quantityUnit");
        double price         = 0.0;
        String mainPriceStr  = request.getParameter("price");
        if (mainPriceStr != null && !mainPriceStr.trim().isEmpty()) {
            try { price = Double.parseDouble(mainPriceStr); } catch (NumberFormatException ignored) {}
        }
        String description   = request.getParameter("description");
        String warrantyInfo  = request.getParameter("warrantyInfo");

        try {
            String negErr = validateAddProductNonNegative(request, quantity, price);
            if (negErr != null) {
                request.setAttribute("errorMsg", negErr);
                request.getServletContext()
                        .getRequestDispatcher("/pages/dashboards/storedash/addProduct.jsp")
                        .forward(request, response);
                return;
            }

            // Require at least one image: main product image OR at least one variant image
            Part imagePartEarly = request.getPart("image");
            boolean hasMainImage = imagePartEarly != null && imagePartEarly.getSize() > 0;
            boolean hasAnyVariantImage = false;
            try {
                for (Part part : request.getParts()) {
                    if ("variantImage[]".equals(part.getName()) && part.getSize() > 0) {
                        hasAnyVariantImage = true;
                        break;
                    }
                }
            } catch (Exception ignored) {}
            if (!hasMainImage && !hasAnyVariantImage) {
                request.setAttribute("errorMsg",
                        "Please upload a main product image, or at least one variant image.");
                request.getServletContext()
                        .getRequestDispatcher("/pages/dashboards/storedash/addProduct.jsp")
                        .forward(request, response);
                return;
            }

            // 3. Create Product object (without image first — we need the ID to name the file)
            Product p = new Product();
            p.setName(name);
            p.setType(type);
            p.setQuantity(quantity);
            p.setQuantityUnit(quantityUnit);
            p.setPrice(price);
            p.setStoreUsername(storeUsername);
            p.setDescription(description);
            p.setWarrantyInfo((warrantyInfo != null && !warrantyInfo.isBlank()) ? warrantyInfo.trim() : null);

            // 4. Save product to DB and get generated ID
            ProductDAO productDAO = new ProductDAO();
            int productId = productDAO.addProductAndReturnId(p);

            // 5. Save main image now that we have the productId
            Part imagePart = request.getPart("image");
            String imagePath = ProductImageUtil.saveProductMainImage(imagePart, productId, webAppPath);
            if (imagePath != null) {
                p.setImagePath(imagePath);
                productDAO.updateProduct(p);
            }

            // 6. Handle variants
            String[] variantColors     = request.getParameterValues("variantColor[]");
            String[] variantSizes      = request.getParameterValues("variantSize[]");
            String[] variantPowers     = request.getParameterValues("variantPower[]");
            String[] variantPrices     = request.getParameterValues("variantPrice[]");
            String[] variantQuantities = request.getParameterValues("variantQuantity[]");
            Part[]   variantImages     = null;
            try {
                java.util.Collection<Part> allParts = request.getParts();
                java.util.List<Part> imgParts = new java.util.ArrayList<>();
                for (Part part : allParts) {
                    if ("variantImage[]".equals(part.getName())) imgParts.add(part);
                }
                variantImages = imgParts.toArray(new Part[0]);
            } catch (Exception ignored) {}

            boolean hasVariants = false;
            if (variantColors != null && variantColors.length > 0) {
                ProductVariantDAO variantDAO = new ProductVariantDAO();
                for (int i = 0; i < variantColors.length; i++) {
                    String color  = variantColors[i] != null ? variantColors[i].trim() : "";
                    String size   = (variantSizes    != null && i < variantSizes.length)    ? variantSizes[i].trim()    : "";
                    String power  = (variantPowers   != null && i < variantPowers.length)   ? variantPowers[i].trim()   : "";
                    String pStr   = (variantPrices   != null && i < variantPrices.length)   ? variantPrices[i]          : "";
                    String qStr   = (variantQuantities != null && i < variantQuantities.length) ? variantQuantities[i]  : "";

                    if (color.isEmpty() && size.isEmpty() && power.isEmpty() &&
                        (pStr == null || pStr.trim().isEmpty()) &&
                        (qStr == null || qStr.trim().isEmpty())) continue;

                    try {
                        hasVariants = true;
                        BigDecimal variantPrice = (pStr != null && !pStr.trim().isEmpty())
                                ? new BigDecimal(pStr.trim()) : BigDecimal.valueOf(price);
                        int variantQty = 0;
                        if (qStr != null && !qStr.trim().isEmpty()) {
                            try { variantQty = Integer.parseInt(qStr.trim()); } catch (NumberFormatException ignored) {}
                        }
                        ProductVariant variant = new ProductVariant();
                        variant.setProductId(productId);
                        variant.setColor(color.isEmpty() ? null : color);
                        variant.setSize(size.isEmpty()   ? null : size);
                        variant.setPower(power.isEmpty() ? null : power);
                        variant.setPrice(variantPrice);
                        variant.setQuantity(variantQty);

                        int variantId = variantDAO.addVariantAndReturnId(variant);

                        // Save variant image if provided
                        if (variantImages != null && i < variantImages.length) {
                            String vImgPath = ProductImageUtil.saveVariantImage(variantImages[i], variantId, webAppPath);
                            if (vImgPath != null) {
                                variant.setVariantId(variantId);
                                variant.setImagePath(vImgPath);
                                variantDAO.updateVariant(variant);
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            // If variants were added, set main product quantity to 0
            if (hasVariants) {
                p.setQuantity(0);
                productDAO.updateProduct(p);
            }

            response.sendRedirect(request.getContextPath() + "/ListProductsServlet");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error adding product: " + e.getMessage());
        }
    }

    /** Ensures main and variant prices/quantities are not negative. */
    private static String validateAddProductNonNegative(HttpServletRequest request, int quantity, double price) {
        if (quantity < 0 || price < 0) {
            return "Price and quantity cannot be negative.";
        }
        String[] variantColors = request.getParameterValues("variantColor[]");
        if (variantColors == null || variantColors.length == 0) {
            return null;
        }
        String[] variantSizes = request.getParameterValues("variantSize[]");
        String[] variantPowers = request.getParameterValues("variantPower[]");
        String[] variantPrices = request.getParameterValues("variantPrice[]");
        String[] variantQuantities = request.getParameterValues("variantQuantity[]");
        for (int i = 0; i < variantColors.length; i++) {
            String color = variantColors[i] != null ? variantColors[i].trim() : "";
            String size = (variantSizes != null && i < variantSizes.length) ? variantSizes[i].trim() : "";
            String power = (variantPowers != null && i < variantPowers.length) ? variantPowers[i].trim() : "";
            String pStr = (variantPrices != null && i < variantPrices.length) ? variantPrices[i] : "";
            String qStr = (variantQuantities != null && i < variantQuantities.length) ? variantQuantities[i] : "";
            if (color.isEmpty() && size.isEmpty() && power.isEmpty()
                    && (pStr == null || pStr.trim().isEmpty())
                    && (qStr == null || qStr.trim().isEmpty())) {
                continue;
            }
            try {
                BigDecimal vp = (pStr != null && !pStr.trim().isEmpty())
                        ? new BigDecimal(pStr.trim()) : BigDecimal.valueOf(price);
                if (vp.compareTo(BigDecimal.ZERO) < 0) {
                    return "Variant prices cannot be negative.";
                }
                int vq = 0;
                if (qStr != null && !qStr.trim().isEmpty()) {
                    vq = Integer.parseInt(qStr.trim());
                }
                if (vq < 0) {
                    return "Variant stock cannot be negative.";
                }
            } catch (NumberFormatException e) {
                return "Invalid variant price or quantity.";
            }
        }
        return null;
    }
}
