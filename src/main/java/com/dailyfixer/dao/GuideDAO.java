package com.dailyfixer.dao;

import java.sql.*;
import java.util.*;
import com.dailyfixer.model.*;
import com.dailyfixer.util.DBConnection;

public class GuideDAO {

    // ==================== CREATE ====================

    /**
     * Adds a new guide with requirements and steps.
     * 
     * @return The generated guide ID, or -1 on failure
     */
    public int addGuide(Guide guide, List<String> requirements, List<GuideStep> steps) {
        String guideSQL = "INSERT INTO guides (title, main_image_path, main_category, sub_category, youtube_url, created_by, created_role) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String reqSQL = "INSERT INTO guide_requirements (guide_id, requirement) VALUES (?, ?)";
        String stepSQL = "INSERT INTO guide_steps (guide_id, step_order, step_title, step_body) VALUES (?, ?, ?, ?)";
        String imageSQL = "INSERT INTO guide_step_images (step_id, image_path) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Insert guide
            int guideId;
            try (PreparedStatement ps = conn.prepareStatement(guideSQL, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, guide.getTitle());
                ps.setString(2, guide.getMainImagePath());
                ps.setString(3, guide.getMainCategory());
                ps.setString(4, guide.getSubCategory());
                ps.setString(5, guide.getYoutubeUrl());
                ps.setInt(6, guide.getCreatedBy());
                ps.setString(7, guide.getCreatedRole());
                ps.executeUpdate();

                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    guideId = rs.getInt(1);
                } else {
                    conn.rollback();
                    return -1;
                }
            }

            // Insert requirements
            if (requirements != null && !requirements.isEmpty()) {
                try (PreparedStatement psReq = conn.prepareStatement(reqSQL)) {
                    for (String req : requirements) {
                        if (req != null && !req.trim().isEmpty()) {
                            psReq.setInt(1, guideId);
                            psReq.setString(2, req.trim());
                            psReq.addBatch();
                        }
                    }
                    psReq.executeBatch();
                }
            }

            // Insert steps and their images
            if (steps != null && !steps.isEmpty()) {
                try (PreparedStatement psStep = conn.prepareStatement(stepSQL, Statement.RETURN_GENERATED_KEYS)) {
                    for (int i = 0; i < steps.size(); i++) {
                        GuideStep step = steps.get(i);
                        psStep.setInt(1, guideId);
                        psStep.setInt(2, i + 1); // step_order
                        psStep.setString(3, step.getStepTitle());
                        psStep.setString(4, step.getStepBody());
                        psStep.executeUpdate();

                        ResultSet rsStep = psStep.getGeneratedKeys();
                        if (rsStep.next()) {
                            int stepId = rsStep.getInt(1);

                            // Insert step images
                            if (step.getImagePaths() != null && !step.getImagePaths().isEmpty()) {
                                try (PreparedStatement psImg = conn.prepareStatement(imageSQL)) {
                                    for (String imgPath : step.getImagePaths()) {
                                        if (imgPath != null && !imgPath.isEmpty()) {
                                            psImg.setInt(1, stepId);
                                            psImg.setString(2, imgPath);
                                            psImg.addBatch();
                                        }
                                    }
                                    psImg.executeBatch();
                                }
                            }
                        }
                    }
                }
            }

            conn.commit();
            return guideId;

        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    // ==================== READ ====================

    /**
     * Get all active guides (for public listing).
     */
    public List<Guide> getAllGuides() {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                "JOIN users u ON g.created_by = u.user_id " +
                "WHERE g.status = 'ACTIVE' " +
                "ORDER BY g.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                list.add(g);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get guides by creator (for volunteer's "My Guides").
     */
    public List<Guide> getGuidesByCreator(int userId) {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                "JOIN users u ON g.created_by = u.user_id " +
                "WHERE g.created_by = ? ORDER BY g.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                list.add(g);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get all guides including non-active (for admin listing).
     */
    public List<Guide> getAllGuidesAdmin() {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name, " +
                "(SELECT COUNT(*) FROM guide_flags f WHERE f.guide_id = g.guide_id) as flag_count " +
                "FROM guides g JOIN users u ON g.created_by = u.user_id " +
                "ORDER BY g.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                g.setFlagCount(rs.getInt("flag_count"));
                list.add(g);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get guides that have reached the flag threshold (for admin flagged guides page).
     */
    public List<Guide> getFlaggedGuides(int threshold) {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name, " +
                "(SELECT COUNT(*) FROM guide_flags f WHERE f.guide_id = g.guide_id) as flag_count " +
                "FROM guides g JOIN users u ON g.created_by = u.user_id " +
                "WHERE g.status = 'ACTIVE' " +
                "HAVING flag_count >= ? " +
                "ORDER BY flag_count DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                g.setFlagCount(rs.getInt("flag_count"));
                list.add(g);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get hidden guides by a specific creator (for creator's flagged guides view).
     */
    public List<Guide> getHiddenGuidesByCreator(int userId) {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                "JOIN users u ON g.created_by = u.user_id " +
                "WHERE g.created_by = ? AND g.status IN ('HIDDEN', 'PENDING_REVIEW') " +
                "ORDER BY g.hidden_at DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                list.add(g);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get guides pending review (edited hidden guides awaiting admin approval).
     */
    public List<Guide> getPendingReviewGuides() {
        List<Guide> list = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                "JOIN users u ON g.created_by = u.user_id " +
                "WHERE g.status = 'PENDING_REVIEW' " +
                "ORDER BY g.updated_at DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                list.add(g);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Search guides with filters.
     */
    public List<Guide> searchGuides(String keyword, String mainCategory, String subCategory) {
        List<Guide> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                        "JOIN users u ON g.created_by = u.user_id WHERE g.status = 'ACTIVE' ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND g.title LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        if (mainCategory != null && !mainCategory.trim().isEmpty()) {
            sql.append(" AND g.main_category = ? ");
            params.add(mainCategory.trim());
        }
        if (subCategory != null && !subCategory.trim().isEmpty()) {
            sql.append(" AND g.sub_category = ? ");
            params.add(subCategory.trim());
        }

        sql.append(" ORDER BY g.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Guide g = mapGuideFromResultSet(rs);
                g.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                list.add(g);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get a single guide by ID with all details (requirements, steps, images).
     */
    public Guide getGuideById(int guideId) {
        Guide guide = null;

        try (Connection conn = DBConnection.getConnection()) {
            // Get guide main info
            String sql = "SELECT g.*, u.first_name, u.last_name FROM guides g " +
                    "JOIN users u ON g.created_by = u.user_id WHERE g.guide_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, guideId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    guide = mapGuideFromResultSet(rs);
                    guide.setCreatorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                }
            }

            if (guide != null) {
                // Get requirements
                guide.setRequirements(getRequirementsByGuideId(conn, guideId));

                // Get steps with images
                guide.setSteps(getStepsByGuideId(conn, guideId));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return guide;
    }

    private List<String> getRequirementsByGuideId(Connection conn, int guideId) throws SQLException {
        List<String> requirements = new ArrayList<>();
        String sql = "SELECT requirement FROM guide_requirements WHERE guide_id = ? ORDER BY req_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                requirements.add(rs.getString("requirement"));
            }
        }
        return requirements;
    }

    private List<GuideStep> getStepsByGuideId(Connection conn, int guideId) throws SQLException {
        List<GuideStep> steps = new ArrayList<>();
        String sql = "SELECT * FROM guide_steps WHERE guide_id = ? ORDER BY step_order";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                GuideStep step = new GuideStep();
                step.setStepId(rs.getInt("step_id"));
                step.setGuideId(rs.getInt("guide_id"));
                step.setStepOrder(rs.getInt("step_order"));
                step.setStepTitle(rs.getString("step_title"));
                step.setStepBody(rs.getString("step_body"));

                // Get step images
                step.setImagePaths(getStepImages(conn, step.getStepId()));
                steps.add(step);
            }
        }
        return steps;
    }

    private List<String> getStepImages(Connection conn, int stepId) throws SQLException {
        List<String> images = new ArrayList<>();
        String sql = "SELECT image_path FROM guide_step_images WHERE step_id = ? ORDER BY image_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stepId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                images.add(rs.getString("image_path"));
            }
        }
        return images;
    }

    // ==================== UPDATE ====================

    /**
     * Update a guide's basic info (title, categories, youtube URL).
     */
    public boolean updateGuide(Guide guide) {
        String sql = "UPDATE guides SET title = ?, main_image_path = ?, main_category = ?, " +
                "sub_category = ?, youtube_url = ? WHERE guide_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, guide.getTitle());
            ps.setString(2, guide.getMainImagePath());
            ps.setString(3, guide.getMainCategory());
            ps.setString(4, guide.getSubCategory());
            ps.setString(5, guide.getYoutubeUrl());
            ps.setInt(6, guide.getGuideId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Increment the view count of a guide.
     */
    public void incrementViewCount(int guideId) {
        String sql = "UPDATE guides SET view_count = view_count + 1 WHERE guide_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Update requirements for a guide (delete existing, add new).
     */
    public void updateRequirements(int guideId, List<String> requirements) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Delete existing
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM guide_requirements WHERE guide_id = ?")) {
                ps.setInt(1, guideId);
                ps.executeUpdate();
            }

            // Add new
            if (requirements != null && !requirements.isEmpty()) {
                try (PreparedStatement ps = conn
                        .prepareStatement("INSERT INTO guide_requirements (guide_id, requirement) VALUES (?, ?)")) {
                    for (String req : requirements) {
                        if (req != null && !req.trim().isEmpty()) {
                            ps.setInt(1, guideId);
                            ps.setString(2, req.trim());
                            ps.addBatch();
                        }
                    }
                    ps.executeBatch();
                }
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Update steps for a guide (delete existing, add new).
     * Returns list of old image paths that should be deleted from disk.
     */
    public List<String> updateSteps(int guideId, List<GuideStep> steps) {
        List<String> oldImagePaths = new ArrayList<>();
        String stepSQL = "INSERT INTO guide_steps (guide_id, step_order, step_title, step_body) VALUES (?, ?, ?, ?)";
        String imageSQL = "INSERT INTO guide_step_images (step_id, image_path) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Get old step image paths before deleting
            String oldImgSql = "SELECT i.image_path FROM guide_step_images i " +
                    "JOIN guide_steps s ON i.step_id = s.step_id WHERE s.guide_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(oldImgSql)) {
                ps.setInt(1, guideId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String path = rs.getString("image_path");
                    if (path != null) {
                        oldImagePaths.add(path);
                    }
                }
            }

            // Delete existing steps (cascade deletes step_images)
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM guide_steps WHERE guide_id = ?")) {
                ps.setInt(1, guideId);
                ps.executeUpdate();
            }

            // Insert new steps and their images
            if (steps != null && !steps.isEmpty()) {
                try (PreparedStatement psStep = conn.prepareStatement(stepSQL, Statement.RETURN_GENERATED_KEYS)) {
                    for (int i = 0; i < steps.size(); i++) {
                        GuideStep step = steps.get(i);
                        psStep.setInt(1, guideId);
                        psStep.setInt(2, i + 1); // step_order
                        psStep.setString(3, step.getStepTitle());
                        psStep.setString(4, step.getStepBody());
                        psStep.executeUpdate();

                        ResultSet rsStep = psStep.getGeneratedKeys();
                        if (rsStep.next()) {
                            int stepId = rsStep.getInt(1);

                            // Insert step images
                            if (step.getImagePaths() != null && !step.getImagePaths().isEmpty()) {
                                try (PreparedStatement psImg = conn.prepareStatement(imageSQL)) {
                                    for (String imgPath : step.getImagePaths()) {
                                        if (imgPath != null && !imgPath.isEmpty()) {
                                            psImg.setInt(1, stepId);
                                            psImg.setString(2, imgPath);
                                            psImg.addBatch();
                                            // Remove from old paths if it's being kept
                                            oldImagePaths.remove(imgPath);
                                        }
                                    }
                                    psImg.executeBatch();
                                }
                            }
                        }
                    }
                }
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return oldImagePaths;
    }

    // ==================== DELETE ====================

    /**
     * Delete a guide by ID. Returns image paths that need to be deleted from disk.
     */
    public List<String> deleteGuide(int guideId) {
        List<String> imagePaths = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            // First collect all image paths
            String mainImgSql = "SELECT main_image_path FROM guides WHERE guide_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(mainImgSql)) {
                ps.setInt(1, guideId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String path = rs.getString("main_image_path");
                    if (path != null)
                        imagePaths.add(path);
                }
            }

            String stepImgSql = "SELECT i.image_path FROM guide_step_images i " +
                    "JOIN guide_steps s ON i.step_id = s.step_id WHERE s.guide_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(stepImgSql)) {
                ps.setInt(1, guideId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String path = rs.getString("image_path");
                    if (path != null)
                        imagePaths.add(path);
                }
            }

            // Delete guide (cascades to requirements, steps, step_images)
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM guides WHERE guide_id = ?")) {
                ps.setInt(1, guideId);
                ps.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return imagePaths;
    }

    /**
     * Check if a user is the creator of a guide.
     */
    public boolean isGuideCreator(int guideId, int userId) {
        String sql = "SELECT 1 FROM guides WHERE guide_id = ? AND created_by = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guideId);
            ps.setInt(2, userId);
            return ps.executeQuery().next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== HELPER ====================

    private Guide mapGuideFromResultSet(ResultSet rs) throws SQLException {
        Guide g = new Guide();
        g.setGuideId(rs.getInt("guide_id"));
        g.setTitle(rs.getString("title"));
        g.setMainImagePath(rs.getString("main_image_path"));
        g.setMainCategory(rs.getString("main_category"));
        g.setSubCategory(rs.getString("sub_category"));
        g.setYoutubeUrl(rs.getString("youtube_url"));
        g.setCreatedBy(rs.getInt("created_by"));
        g.setCreatedRole(rs.getString("created_role"));
        g.setCreatedAt(rs.getTimestamp("created_at"));
        g.setUpdatedAt(rs.getTimestamp("updated_at"));
        g.setViewCount(rs.getInt("view_count"));
        g.setStatus(rs.getString("status"));
        g.setHideReason(rs.getString("hide_reason"));
        g.setHiddenAt(rs.getTimestamp("hidden_at"));
        g.setHiddenBy(rs.getInt("hidden_by"));
        return g;
    }
}
