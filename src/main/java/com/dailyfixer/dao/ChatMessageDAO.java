package com.dailyfixer.dao;

import com.dailyfixer.model.ChatMessage;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatMessageDAO {

    public void createMessage(ChatMessage message) throws Exception {
        String sql = "INSERT INTO chat_messages (chat_id, sender_id, message, is_read) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, message.getChatId());
            ps.setInt(2, message.getSenderId());
            ps.setString(3, message.getMessage());
            ps.setBoolean(4, message.isRead());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    message.setMessageId(rs.getInt(1));
                }
            }
        }
    }

    public List<ChatMessage> getMessagesByChatId(int chatId) throws Exception {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT cm.*, u.first_name, u.last_name " +
                     "FROM chat_messages cm " +
                     "JOIN users u ON cm.sender_id = u.user_id " +
                     "WHERE cm.chat_id = ? " +
                     "ORDER BY cm.created_at ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, chatId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatMessage message = new ChatMessage();
                    message.setMessageId(rs.getInt("message_id"));
                    message.setChatId(rs.getInt("chat_id"));
                    message.setSenderId(rs.getInt("sender_id"));
                    message.setMessage(rs.getString("message"));
                    message.setRead(rs.getBoolean("is_read"));
                    message.setCreatedAt(rs.getTimestamp("created_at"));
                    message.setSenderName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    list.add(message);
                }
            }
        }
        return list;
    }

    public void markMessagesAsRead(int chatId, int recipientId) throws Exception {
        String sql = "UPDATE chat_messages SET is_read = 1 WHERE chat_id = ? AND sender_id != ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, chatId);
            ps.setInt(2, recipientId);
            ps.executeUpdate();
        }
    }

    public int getUnreadCountByChatId(int chatId, int recipientId) throws Exception {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE chat_id = ? AND sender_id != ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, chatId);
            ps.setInt(2, recipientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int getTotalUnreadCountByUserId(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM chat_messages cm " +
                     "JOIN chats c ON cm.chat_id = c.chat_id " +
                     "WHERE (c.user_id = ? OR c.technician_id = ?) AND cm.sender_id != ? AND cm.is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
}
