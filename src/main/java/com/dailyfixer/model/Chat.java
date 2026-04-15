package com.dailyfixer.model;

import java.sql.Timestamp;

public class Chat {
    private int chatId;
    private int userId;
    private int technicianId;
    private Timestamp createdAt;

    // Extended fields for display
    private String userName;
    private String technicianName;
    private String userProfilePic;
    private String technicianProfilePic;
    private int unreadCount;
    private String lastMessage;
    private Timestamp lastMessageTime;

    // Getters and setters
    public String getUserProfilePic() { return userProfilePic; }
    public void setUserProfilePic(String userProfilePic) { this.userProfilePic = userProfilePic; }

    public String getTechnicianProfilePic() { return technicianProfilePic; }
    public void setTechnicianProfilePic(String technicianProfilePic) { this.technicianProfilePic = technicianProfilePic; }

    public int getChatId() { return chatId; }
    public void setChatId(int chatId) { this.chatId = chatId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getTechnicianName() { return technicianName; }
    public void setTechnicianName(String technicianName) { this.technicianName = technicianName; }

    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public Timestamp getLastMessageTime() { return lastMessageTime; }
    public void setLastMessageTime(Timestamp lastMessageTime) { this.lastMessageTime = lastMessageTime; }
}
