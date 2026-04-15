package com.dailyfixer.model;

import java.sql.Timestamp;

public class TechnicianRequestFile {
    private int fileId;
    private int requestId;
    private String fileType;        // "QUALIFICATION" or "WORK_PROOF"
    private String filePath;
    private String originalFilename;
    private Timestamp uploadedAt;

    public int getFileId() { return fileId; }
    public void setFileId(int fileId) { this.fileId = fileId; }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public String getOriginalFilename() { return originalFilename; }
    public void setOriginalFilename(String originalFilename) { this.originalFilename = originalFilename; }

    public Timestamp getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(Timestamp uploadedAt) { this.uploadedAt = uploadedAt; }

    public boolean isPdf() {
        return filePath != null && filePath.toLowerCase().endsWith(".pdf");
    }
}
