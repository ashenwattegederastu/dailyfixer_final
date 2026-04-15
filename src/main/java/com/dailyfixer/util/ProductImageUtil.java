package com.dailyfixer.util;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * Utility class for handling product and product variant image uploads.
 * Stores images under assets/images/uploads/products/
 */
public class ProductImageUtil {

    private static final String PRODUCT_UPLOAD_DIR   = "assets/images/uploads/products";
    private static final String VARIANT_UPLOAD_DIR   = "assets/images/uploads/products/variants";
    private static final long   MAX_SIZE_BYTES        = 16 * 1024 * 1024; // 16 MB

    // -----------------------------------------------------------------------
    // Product main image
    // -----------------------------------------------------------------------

    /**
     * Saves the main image for a product.
     *
     * @param imagePart  The uploaded file Part (may be null / empty)
     * @param productId  The product ID (used to build unique file name)
     * @param webAppPath Absolute path to the webapp root (from servlet context)
     * @return Relative path stored in the DB (e.g. assets/images/uploads/products/main_5_1234.jpg),
     *         or {@code null} if no file was provided.
     */
    public static String saveProductMainImage(Part imagePart, int productId, String webAppPath) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }
        if (imagePart.getSize() > MAX_SIZE_BYTES) {
            throw new IOException("Product image exceeds 16 MB limit");
        }

        String ext      = getExtension(imagePart);
        String fileName = "main_" + productId + "_" + System.currentTimeMillis() + ext;
        String relative = PRODUCT_UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relative);
        return relative;
    }

    // -----------------------------------------------------------------------
    // Variant image
    // -----------------------------------------------------------------------

    /**
     * Saves an image for a product variant.
     *
     * @param imagePart  The uploaded file Part (may be null / empty)
     * @param variantId  The variant ID (or a transient negative index before DB insert)
     * @param webAppPath Absolute path to the webapp root
     * @return Relative path stored in the DB, or {@code null} if no file was provided.
     */
    public static String saveVariantImage(Part imagePart, int variantId, String webAppPath) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }
        if (imagePart.getSize() > MAX_SIZE_BYTES) {
            throw new IOException("Variant image exceeds 16 MB limit");
        }

        String ext      = getExtension(imagePart);
        String fileName = "variant_" + variantId + "_" + System.currentTimeMillis() + ext;
        String relative = VARIANT_UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relative);
        return relative;
    }

    // -----------------------------------------------------------------------
    // Cleanup
    // -----------------------------------------------------------------------

    /**
     * Deletes an image file from disk given its relative path.
     * Silently ignores null / empty paths or non-existing files.
     */
    public static void deleteImage(String relativePath, String webAppPath) {
        if (relativePath == null || relativePath.isBlank()) return;
        try {
            Path full = Paths.get(webAppPath, relativePath.replace("/", java.io.File.separator));
            Files.deleteIfExists(full);
        } catch (IOException e) {
            // Log but do not bubble — delete failures are non-fatal
            System.err.println("[ProductImageUtil] Failed to delete " + relativePath + ": " + e.getMessage());
        }
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------

    private static void saveFile(Part part, String webAppPath, String relativePath) throws IOException {
        Path target = Paths.get(webAppPath, relativePath.replace("/", java.io.File.separator));
        Files.createDirectories(target.getParent());
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private static String getExtension(Part part) {
        String header = part.getHeader("content-disposition");
        if (header != null) {
            for (String token : header.split(";")) {
                token = token.trim();
                if (token.toLowerCase().startsWith("filename")) {
                    String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                    int dot = name.lastIndexOf('.');
                    if (dot >= 0) {
                        return name.substring(dot).toLowerCase();
                    }
                }
            }
        }
        // Fallback: derive from content type
        String ct = part.getContentType();
        if (ct != null) {
            if (ct.contains("png"))  return ".png";
            if (ct.contains("gif"))  return ".gif";
            if (ct.contains("webp")) return ".webp";
        }
        return ".jpg";
    }
}
