package com.dailyfixer.util;

import com.dailyfixer.dao.DiscountDAO;
import com.dailyfixer.dao.ProductVariantDAO;
import com.dailyfixer.model.Discount;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;

import java.util.List;

/**
 * Builds a JSON response for product listing pages without any external library.
 * Mirrors the discount/variant price logic from category_products.jsp.
 */
public final class ProductJsonUtil {

    private ProductJsonUtil() {}

    /**
     * Serialises the product list (with discount and image resolution) to a JSON string.
     *
     * @param products                    products to include; may be null
     * @param purchaseRadiusFilteredEmpty true when a location filter removed all results
     * @param category                    display category label
     * @param searchTerm                  the original search query (may be null)
     * @param searchType                  "product" or "category"
     * @return well-formed JSON object string
     */
    public static String toJson(List<Product> products,
                                boolean purchaseRadiusFilteredEmpty,
                                String category,
                                String searchTerm,
                                String searchType) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"purchaseRadiusFilteredEmpty\":").append(purchaseRadiusFilteredEmpty).append(",");
        sb.append("\"category\":").append(jsonString(category)).append(",");
        sb.append("\"searchTerm\":").append(jsonString(searchTerm)).append(",");
        sb.append("\"searchType\":").append(jsonString(searchType)).append(",");
        sb.append("\"products\":[");

        if (products != null && !products.isEmpty()) {
            DiscountDAO discountDAO = new DiscountDAO();
            boolean first = true;

            for (Product item : products) {
                if (!first) sb.append(",");
                first = false;

                // --- Resolve effective list price (mirrors JSP logic) ---
                double listPrice = item.getPrice();
                List<ProductVariant> itemVariants = null;
                try {
                    ProductVariantDAO variantDAO = new ProductVariantDAO();
                    itemVariants = variantDAO.getVariantsByProductId(item.getProductId());
                    if (item.getPrice() == 0.00 && itemVariants != null && !itemVariants.isEmpty()
                            && itemVariants.get(0).getPrice() != null) {
                        listPrice = itemVariants.get(0).getPrice().doubleValue();
                    }
                } catch (Exception ignored) {
                    // fall back to main price
                }

                // --- Resolve active discount (mirrors JSP logic) ---
                Discount activeDiscount = null;
                try {
                    boolean useFirstVariant = item.getPrice() == 0.00
                            && itemVariants != null && !itemVariants.isEmpty();
                    if (useFirstVariant) {
                        activeDiscount = discountDAO.getActiveDiscountForVariant(
                                itemVariants.get(0).getVariantId());
                        if (activeDiscount == null || !activeDiscount.isValid()) {
                            activeDiscount = discountDAO.getActiveDiscountForProduct(item.getProductId());
                        }
                    } else {
                        activeDiscount = discountDAO.getActiveDiscountForProduct(item.getProductId());
                    }
                } catch (Exception ignored) {
                    activeDiscount = null;
                }

                double originalPrice = listPrice;
                double finalPrice = listPrice;
                boolean showDiscount = false;
                String discountBadgeText = "";
                String discountTitle = "";

                if (activeDiscount != null && activeDiscount.isValid() && originalPrice > 0) {
                    double discounted = activeDiscount.calculateDiscountedPrice(originalPrice);
                    if (discounted + 1e-6 < originalPrice) {
                        finalPrice = discounted;
                        showDiscount = true;
                    }
                }

                if (showDiscount) {
                    discountTitle = activeDiscount.getDiscountName() != null
                            ? activeDiscount.getDiscountName() : "";
                    if ("PERCENTAGE".equalsIgnoreCase(activeDiscount.getDiscountType())) {
                        double pct = activeDiscount.getDiscountValue().doubleValue();
                        discountBadgeText = (pct == Math.floor(pct))
                                ? String.format("%.0f", pct) + "% OFF"
                                : String.format("%.1f", pct) + "% OFF";
                    } else {
                        double fixed = activeDiscount.getDiscountValue().doubleValue();
                        discountBadgeText = "Rs. " + (fixed == Math.floor(fixed)
                                ? String.format("%.0f", fixed)
                                : String.format("%.2f", fixed)) + " OFF";
                    }
                }

                String imagePath = ProductDisplayUtil.getDisplayImagePath(item, itemVariants);

                // --- Build product JSON object ---
                sb.append("{");
                sb.append("\"productId\":").append(item.getProductId()).append(",");
                sb.append("\"name\":").append(jsonString(item.getName())).append(",");
                sb.append("\"description\":").append(jsonString(item.getDescription())).append(",");
                sb.append("\"originalPrice\":").append(String.format("%.2f", originalPrice)).append(",");
                sb.append("\"finalPrice\":").append(String.format("%.2f", finalPrice)).append(",");
                sb.append("\"showDiscount\":").append(showDiscount).append(",");
                sb.append("\"discountBadgeText\":").append(jsonString(discountBadgeText)).append(",");
                sb.append("\"discountTitle\":").append(jsonString(discountTitle)).append(",");
                sb.append("\"imagePath\":").append(jsonString(imagePath != null ? imagePath : ""));
                sb.append("}");
            }
        }

        sb.append("]}");
        return sb.toString();
    }

    /** Encodes a Java string as a JSON string literal, or JSON null. */
    private static String jsonString(String s) {
        if (s == null) return "null";
        return "\""
                + s.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t")
                + "\"";
    }
}
