package com.dailyfixer.util;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * Utility class for handling guide image uploads.
 * Stores images in assets/images/uploads/guides/
 */
public class ImageUploadUtil {

    private static final String UPLOAD_DIR = "assets/images/uploads/guides";

    /**
     * Saves the main image for a guide.
     * 
     * @param imagePart  The uploaded file part
     * @param guideId    The guide ID
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved image (for storing in DB)
     */
    public static String saveGuideMainImage(Part imagePart, int guideId, String webAppPath) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        String fileName = "main_" + guideId + "_" + System.currentTimeMillis() + getExtension(imagePart);
        String relativePath = UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relativePath);
        return relativePath;
    }

    /**
     * Saves a step image.
     * 
     * @param imagePart  The uploaded file part
     * @param stepId     The step ID
     * @param imageIndex The index of the image within the step
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved image
     */
    public static String saveStepImage(Part imagePart, int stepId, int imageIndex, String webAppPath)
            throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        String fileName = "step_" + stepId + "_" + imageIndex + "_" + System.currentTimeMillis()
                + getExtension(imagePart);
        String relativePath = UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relativePath);
        return relativePath;
    }

    /**
     * Saves a temporary image during guide creation (before guide ID is known).
     * 
     * @param imagePart  The uploaded file part
     * @param prefix     A prefix like "temp_main" or "temp_step_0_0"
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved image
     */
    public static String saveTempImage(Part imagePart, String prefix, String webAppPath) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        String fileName = prefix + "_" + System.currentTimeMillis() + getExtension(imagePart);
        String relativePath = UPLOAD_DIR + "/" + fileName;

        saveFile(imagePart, webAppPath, relativePath);
        return relativePath;
    }

    private static final String VOLUNTEER_UPLOAD_DIR = "assets/images/uploads/volunteers";

    /**
     * Saves a volunteer-related upload (profile picture, proof image, sample guide
     * PDF).
     *
     * @param filePart   The uploaded file part
     * @param prefix     A prefix like "profile_username" or "proof_0_username"
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved file (for storing in DB)
     */
    public static String saveVolunteerUpload(Part filePart, String prefix, String webAppPath) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String fileName = prefix + "_" + System.currentTimeMillis() + getExtension(filePart);
        String relativePath = VOLUNTEER_UPLOAD_DIR + "/" + fileName;

        Path uploadPath = Paths.get(webAppPath, VOLUNTEER_UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = Paths.get(webAppPath, relativePath);
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        return relativePath;
    }

    private static final String PROFILE_UPLOAD_DIR = "assets/images/uploads/profiles";

    private static final String DRIVER_UPLOAD_DIR = "assets/images/uploads/drivers";

    private static final String TECHNICIAN_UPLOAD_DIR = "assets/images/uploads/technicians";

    private static final String VEHICLE_UPLOAD_DIR = "assets/images/uploads/vehicles";

    /**
     * Saves a vehicle-related upload (photos and documents).
     *
     * @param filePart   The uploaded file part
     * @param prefix     A prefix like "v_front_123" or "v_doc_reg_123"
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved file (for storing in DB), or null if no file
     */
    public static String saveVehicleUpload(Part filePart, String prefix, String webAppPath) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String fileName = prefix + "_" + System.currentTimeMillis() + getExtension(filePart);
        String relativePath = VEHICLE_UPLOAD_DIR + "/" + fileName;

        Path uploadPath = Paths.get(webAppPath, VEHICLE_UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = Paths.get(webAppPath, relativePath);
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        return relativePath;
    }

    /**
     * Saves a driver registration upload (NIC photos, profile picture, license photos).
     *
     * @param filePart   The uploaded file part
     * @param prefix     A prefix like "nic_front_username" or "license_front_username"
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved file (for storing in DB)
     */
    public static String saveDriverUpload(Part filePart, String prefix, String webAppPath) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String fileName = prefix + "_" + System.currentTimeMillis() + getExtension(filePart);
        String relativePath = DRIVER_UPLOAD_DIR + "/" + fileName;

        Path uploadPath = Paths.get(webAppPath, DRIVER_UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = Paths.get(webAppPath, relativePath);
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        return relativePath;
    }

    /**
     * Saves a technician registration upload (profile picture, qualification files, work proof images,
     * employee ID card). Accepts images and PDF files (PDF only valid for qualifications).
     *
     * @param filePart   The uploaded file part
     * @param prefix     A descriptive prefix, e.g. "tech_profile_username"
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved file (for storing in DB)
     */
    public static String saveTechnicianUpload(Part filePart, String prefix, String webAppPath) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String fileName = prefix + "_" + System.currentTimeMillis() + getExtension(filePart);
        String relativePath = TECHNICIAN_UPLOAD_DIR + "/" + fileName;

        Path uploadPath = Paths.get(webAppPath, TECHNICIAN_UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = Paths.get(webAppPath, relativePath);
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        return relativePath;
    }

    /**
     * Saves a user profile picture.
     *
     * @param filePart   The uploaded file part
     * @param userId     The user ID
     * @param webAppPath The absolute path to the webapp directory
     * @return The relative path to the saved file (for storing in DB)
     */
    public static String saveProfilePicture(Part filePart, int userId, String webAppPath) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String fileName = "profile_" + userId + "_" + System.currentTimeMillis() + getExtension(filePart);
        String relativePath = PROFILE_UPLOAD_DIR + "/" + fileName;

        Path uploadPath = Paths.get(webAppPath, PROFILE_UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = Paths.get(webAppPath, relativePath);
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        return relativePath;
    }

    /**
     * Deletes an image file.
     * 
     * @param imagePath  The relative path to the image
     * @param webAppPath The absolute path to the webapp directory
     */
    public static void deleteImage(String imagePath, String webAppPath) {
        if (imagePath == null || imagePath.isEmpty()) {
            return;
        }

        try {
            Path fullPath = Paths.get(webAppPath, imagePath);
            Files.deleteIfExists(fullPath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void saveFile(Part imagePart, String webAppPath, String relativePath) throws IOException {
        Path uploadPath = Paths.get(webAppPath, UPLOAD_DIR);

        // Create directory if it doesn't exist
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = Paths.get(webAppPath, relativePath);

        try (InputStream input = imagePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private static String getExtension(Part part) {
        String submittedFileName = part.getSubmittedFileName();
        if (submittedFileName != null && submittedFileName.contains(".")) {
            return submittedFileName.substring(submittedFileName.lastIndexOf("."));
        }

        // Default to .jpg if no extension found
        String contentType = part.getContentType();
        if (contentType != null) {
            if (contentType.contains("png"))  return ".png";
            if (contentType.contains("gif"))  return ".gif";
            if (contentType.contains("webp")) return ".webp";
            if (contentType.contains("pdf"))  return ".pdf";
        }
        return ".jpg";
    }
}
