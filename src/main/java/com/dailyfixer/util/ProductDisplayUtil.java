package com.dailyfixer.util;

import com.dailyfixer.model.Product;
import com.dailyfixer.model.ProductVariant;

import java.util.List;

/**
 * Helpers for how products appear in listings (catalog, marketplace, etc.).
 */
public final class ProductDisplayUtil {

    private ProductDisplayUtil() {}

    /**
     * Relative image path for grids and thumbnails: main product image if set,
     * otherwise the first variant image (non-blank), in database order.
     *
     * @return relative path, or {@code null} if no image is available
     */
    public static String getDisplayImagePath(Product product, List<ProductVariant> variants) {
        if (product == null) {
            return null;
        }
        String main = product.getImagePath();
        if (main != null && !main.isBlank()) {
            return main;
        }
        if (variants == null) {
            return null;
        }
        for (ProductVariant v : variants) {
            if (v == null) {
                continue;
            }
            String vp = v.getImagePath();
            if (vp != null && !vp.isBlank()) {
                return vp;
            }
        }
        return null;
    }

    /**
     * Store review modal / similar: when the product has variants, prefer the first variant's
     * image (first non-blank in list order); otherwise main product image, then any variant image.
     */
    public static String getDisplayImagePathVariantFirst(Product product, List<ProductVariant> variants) {
        if (product == null) {
            return null;
        }
        if (variants != null && !variants.isEmpty()) {
            for (ProductVariant v : variants) {
                if (v == null) {
                    continue;
                }
                String vp = v.getImagePath();
                if (vp != null && !vp.isBlank()) {
                    return vp;
                }
            }
        }
        String main = product.getImagePath();
        if (main != null && !main.isBlank()) {
            return main;
        }
        return null;
    }

    /**
     * Image path for cart and checkout line items: the selected variant's image if present,
     * otherwise the product's main image.
     */
    public static String resolveCartThumbnailPath(Product product, ProductVariant selectedVariant) {
        if (selectedVariant != null) {
            String vPath = selectedVariant.getImagePath();
            if (vPath != null && !vPath.isBlank()) {
                return vPath.trim();
            }
        }
        if (product == null) {
            return null;
        }
        String main = product.getImagePath();
        if (main != null && !main.isBlank()) {
            return main.trim();
        }
        return null;
    }
}
