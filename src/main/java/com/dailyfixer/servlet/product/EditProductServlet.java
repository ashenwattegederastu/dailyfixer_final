package com.dailyfixer.servlet.product;

import java.io.*;
import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.dailyfixer.dao.ProductDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;
import com.dailyfixer.util.ProductImageUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig(maxFileSize = 16177215) // 16 MB max
public class EditProductServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String webAppPath = getServletContext().getRealPath("/");
            ProductDAO productDAO = new ProductDAO();

            int id = Integer.parseInt(request.getParameter("productId"));

            // Resolve type — handle "Other" custom category
            String type = request.getParameter("type");
            if ("Other".equals(type)) {
                String custom = request.getParameter("customCategory");
                if (custom != null && !custom.trim().isEmpty()) type = custom.trim();
            }

            String name         = request.getParameter("name");
            String quantityStr  = request.getParameter("quantity");
            int quantity = 0;
            if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                try { quantity = Integer.parseInt(quantityStr); } catch (NumberFormatException ignored) {}
            }
            String quantityUnit = request.getParameter("quantityUnit");
            double price        = 0.0;
            String mainPriceStr = request.getParameter("price");
            if (mainPriceStr != null && !mainPriceStr.trim().isEmpty()) {
                try { price = Double.parseDouble(mainPriceStr); } catch (NumberFormatException ignored) {}
            }
            String description  = request.getParameter("description");
            String warrantyInfo = request.getParameter("warrantyInfo");

            String negErr = validateEditProductNonNegative(request, quantity, price);
            if (negErr != null) {
                request.getSession().setAttribute("editProductFlashError", negErr);
                response.sendRedirect(request.getContextPath()
                        + "/pages/dashboards/storedash/editProduct.jsp?productId=" + id);
                return;
            }

            // Resolve image path — keep existing if no new file uploaded
            Product existing   = productDAO.getProductById(id);
            String  imagePath  = existing.getImagePath();
            Part    filePart   = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                ProductImageUtil.deleteImage(imagePath, webAppPath);
                imagePath = ProductImageUtil.saveProductMainImage(filePart, id, webAppPath);
            }

            Product p = new Product();
            p.setProductId(id);
            p.setName(name);
            p.setType(type);
            p.setQuantity(quantity);
            p.setQuantityUnit(quantityUnit);
            p.setPrice(price);
            p.setImagePath(imagePath);
            p.setDescription(description);
            p.setWarrantyInfo((warrantyInfo != null && !warrantyInfo.isBlank()) ? warrantyInfo.trim() : null);
            p.setStoreUsername(existing.getStoreUsername());

            // Handle variants
            String[] variantIds        = request.getParameterValues("variantId[]");
            String[] variantColors     = request.getParameterValues("variantColor[]");
            String[] variantSizes      = request.getParameterValues("variantSize[]");
            String[] variantPowers     = request.getParameterValues("variantPower[]");
            String[] variantPrices     = request.getParameterValues("variantPrice[]");
            String[] variantQuantities = request.getParameterValues("variantQuantity[]");

            // Collect variant image parts (ordered by their position)
            Part[] variantImages = null;
            try {
                java.util.List<Part> imgParts = new java.util.ArrayList<>();
                for (Part part : request.getParts()) {
                    if ("variantImage[]".equals(part.getName())) imgParts.add(part);
                }
                variantImages = imgParts.toArray(new Part[0]);
            } catch (Exception ignored) {}

            boolean hasVariants = false;
            ProductVariantDAO variantDAO = new ProductVariantDAO();

            // Snapshot IDs before any inserts/deletes — orphan cleanup must not remove newly added rows
            Set<Integer> variantIdsAtStart = new HashSet<>();
            List<ProductVariant> initialVariants = variantDAO.getVariantsByProductId(id);
            if (initialVariants != null) {
                for (ProductVariant v : initialVariants) {
                    variantIdsAtStart.add(v.getVariantId());
                }
            }

            if (variantIds != null && variantIds.length > 0) {
                for (int i = 0; i < variantIds.length; i++) {
                    String variantIdStr = variantIds[i];
                    String color  = (variantColors    != null && i < variantColors.length)    ? variantColors[i].trim()    : "";
                    String size   = (variantSizes     != null && i < variantSizes.length)     ? variantSizes[i].trim()     : "";
                    String power  = (variantPowers    != null && i < variantPowers.length)    ? variantPowers[i].trim()    : "";
                    String pStr   = (variantPrices    != null && i < variantPrices.length)    ? variantPrices[i]           : "";
                    String qStr   = (variantQuantities != null && i < variantQuantities.length) ? variantQuantities[i]     : "";

                    boolean isEmpty = color.isEmpty() && size.isEmpty() && power.isEmpty() &&
                                      (pStr == null || pStr.trim().isEmpty()) &&
                                      (qStr == null || qStr.trim().isEmpty());

                    if (variantIdStr != null && !variantIdStr.trim().isEmpty()) {
                        // Existing variant
                        try {
                            int variantId = Integer.parseInt(variantIdStr);
                            if (isEmpty) {
                                // Delete variant and its image
                                ProductVariant old = variantDAO.getVariantById(variantId);
                                if (old != null) ProductImageUtil.deleteImage(old.getImagePath(), webAppPath);
                                variantDAO.deleteVariant(variantId);
                            } else {
                                hasVariants = true;
                                ProductVariant old = variantDAO.getVariantById(variantId);
                                String vImgPath = (old != null) ? old.getImagePath() : null;

                                // Save new variant image if provided
                                if (variantImages != null && i < variantImages.length && variantImages[i].getSize() > 0) {
                                    ProductImageUtil.deleteImage(vImgPath, webAppPath);
                                    vImgPath = ProductImageUtil.saveVariantImage(variantImages[i], variantId, webAppPath);
                                }

                                BigDecimal variantPrice = (pStr != null && !pStr.trim().isEmpty())
                                        ? new BigDecimal(pStr.trim()) : BigDecimal.valueOf(price);
                                int variantQty = 0;
                                if (qStr != null && !qStr.trim().isEmpty()) {
                                    try { variantQty = Integer.parseInt(qStr.trim()); } catch (NumberFormatException ignored) {}
                                }

                                ProductVariant variant = new ProductVariant();
                                variant.setVariantId(variantId);
                                variant.setProductId(id);
                                variant.setColor(color.isEmpty() ? null : color);
                                variant.setSize(size.isEmpty()   ? null : size);
                                variant.setPower(power.isEmpty() ? null : power);
                                variant.setPrice(variantPrice);
                                variant.setQuantity(variantQty);
                                variant.setImagePath(vImgPath);
                                variantDAO.updateVariant(variant);
                            }
                        } catch (Exception e) { e.printStackTrace(); }
                    } else {
                        // New variant
                        if (!isEmpty) {
                            try {
                                hasVariants = true;
                                BigDecimal variantPrice = (pStr != null && !pStr.trim().isEmpty())
                                        ? new BigDecimal(pStr.trim()) : BigDecimal.valueOf(price);
                                int variantQty = 0;
                                if (qStr != null && !qStr.trim().isEmpty()) {
                                    try { variantQty = Integer.parseInt(qStr.trim()); } catch (NumberFormatException ignored) {}
                                }

                                ProductVariant variant = new ProductVariant();
                                variant.setProductId(id);
                                variant.setColor(color.isEmpty() ? null : color);
                                variant.setSize(size.isEmpty()   ? null : size);
                                variant.setPower(power.isEmpty() ? null : power);
                                variant.setPrice(variantPrice);
                                variant.setQuantity(variantQty);

                                int newVId = variantDAO.addVariantAndReturnId(variant);
                                if (variantImages != null && i < variantImages.length && variantImages[i].getSize() > 0) {
                                    String vImgPath = ProductImageUtil.saveVariantImage(variantImages[i], newVId, webAppPath);
                                    variant.setVariantId(newVId);
                                    variant.setImagePath(vImgPath);
                                    variantDAO.updateVariant(variant);
                                }
                            } catch (Exception e) { e.printStackTrace(); }
                        }
                    }
                }
            }

            // Rows removed in the browser do not post variantId[] — delete only variants that
            // existed before this request and are no longer on the form (new rows have empty id).
            Set<Integer> postedVariantIds = new HashSet<>();
            if (variantIds != null) {
                for (String vid : variantIds) {
                    if (vid != null && !vid.trim().isEmpty()) {
                        try {
                            postedVariantIds.add(Integer.parseInt(vid.trim()));
                        } catch (NumberFormatException ignored) {
                        }
                    }
                }
            }
            List<ProductVariant> dbVariants = variantDAO.getVariantsByProductId(id);
            if (dbVariants != null) {
                for (ProductVariant ev : dbVariants) {
                    int dbVid = ev.getVariantId();
                    if (!postedVariantIds.contains(dbVid) && variantIdsAtStart.contains(dbVid)) {
                        ProductImageUtil.deleteImage(ev.getImagePath(), webAppPath);
                        variantDAO.deleteVariant(dbVid);
                    }
                }
            }

            List<ProductVariant> remainingVariants = variantDAO.getVariantsByProductId(id);
            hasVariants = remainingVariants != null && !remainingVariants.isEmpty();

            if (hasVariants) p.setQuantity(0);
            productDAO.updateProduct(p);

            response.sendRedirect(request.getContextPath() + "/ListProductsServlet?updated=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ListProductsServlet?updated=error");
        }
    }

    private static String validateEditProductNonNegative(HttpServletRequest request, int quantity, double price) {
        if (quantity < 0 || price < 0) {
            return "Price and quantity cannot be negative.";
        }
        String[] variantIds = request.getParameterValues("variantId[]");
        if (variantIds == null || variantIds.length == 0) {
            return null;
        }
        String[] variantColors = request.getParameterValues("variantColor[]");
        String[] variantSizes = request.getParameterValues("variantSize[]");
        String[] variantPowers = request.getParameterValues("variantPower[]");
        String[] variantPrices = request.getParameterValues("variantPrice[]");
        String[] variantQuantities = request.getParameterValues("variantQuantity[]");
        for (int i = 0; i < variantIds.length; i++) {
            String color = (variantColors != null && i < variantColors.length) ? variantColors[i].trim() : "";
            String size = (variantSizes != null && i < variantSizes.length) ? variantSizes[i].trim() : "";
            String power = (variantPowers != null && i < variantPowers.length) ? variantPowers[i].trim() : "";
            String pStr = (variantPrices != null && i < variantPrices.length) ? variantPrices[i] : "";
            String qStr = (variantQuantities != null && i < variantQuantities.length) ? variantQuantities[i] : "";
            boolean isEmpty = color.isEmpty() && size.isEmpty() && power.isEmpty()
                    && (pStr == null || pStr.trim().isEmpty())
                    && (qStr == null || qStr.trim().isEmpty());
            if (isEmpty) {
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
