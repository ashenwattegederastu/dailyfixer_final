package com.dailyfixer.dao;

import com.dailyfixer.model.Chat;
import com.dailyfixer.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    public void createChat(Chat chat) throws Exception {
        String sql = "INSERT INTO chats (user_id, technician_id) VALUES (?, ?)";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, chat.getUserId());
            ps.setInt(2, chat.getTechnicianId());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    chat.setChatId(rs.getInt(1));
                }
            }
        }
    }

    public Chat getChatByPair(int userId, int technicianId) throws Exception {
        String sql = "SELECT c.*, u1.first_name as user_first_name, u1.last_name as user_last_name, u1.profile_picture_path as user_pic, " +
                "u2.first_name as tech_first_name, u2.last_name as tech_last_name, u2.profile_picture_path as tech_pic " +
                "FROM chats c " +
                "JOIN users u1 ON c.user_id = u1.user_id " +
                "JOIN users u2 ON c.technician_id = u2.user_id " +
                "WHERE c.user_id = ? AND c.technician_id = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractChatFromResultSet(rs);
                }
            }
        }
        return null;
    }

    public Chat getChatById(int chatId) throws Exception {
        String sql = "SELECT c.*, u1.first_name as user_first_name, u1.last_name as user_last_name, u1.profile_picture_path as user_pic, " +
                "u2.first_name as tech_first_name, u2.last_name as tech_last_name, u2.profile_picture_path as tech_pic " +
                "FROM chats c " +
                "JOIN users u1 ON c.user_id = u1.user_id " +
                "JOIN users u2 ON c.technician_id = u2.user_id " +
                "WHERE c.chat_id = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, chatId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractChatFromResultSet(rs);
                }
            }
        }
        return null;
    }

    public List<Chat> getChatsByUserId(int userId) throws Exception {
        List<Chat> list = new ArrayList<>();
        String sql = "SELECT c.*, u1.first_name as user_first_name, u1.last_name as user_last_name, u1.profile_picture_path as user_pic, " +
                "u2.first_name as tech_first_name, u2.last_name as tech_last_name, u2.profile_picture_path as tech_pic, " +
                "(SELECT COUNT(*) FROM chat_messages cm WHERE cm.chat_id = c.chat_id AND cm.sender_id != ? AND cm.is_read = 0) as unread_count, "
                +
                "(SELECT message FROM chat_messages cm WHERE cm.chat_id = c.chat_id ORDER BY cm.created_at DESC LIMIT 1) as last_message, "
                +
                "(SELECT created_at FROM chat_messages cm WHERE cm.chat_id = c.chat_id ORDER BY cm.created_at DESC LIMIT 1) as last_message_time "
                +
                "FROM chats c " +
                "JOIN users u1 ON c.user_id = u1.user_id " +
                "JOIN users u2 ON c.technician_id = u2.user_id " +
                "WHERE c.user_id = ? " +
                "ORDER BY last_message_time DESC";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Chat chat = extractChatFromResultSet(rs);
                    chat.setUnreadCount(rs.getInt("unread_count"));
                    chat.setLastMessage(rs.getString("last_message"));
                    chat.setLastMessageTime(rs.getTimestamp("last_message_time"));
                    list.add(chat);
                }
            }
        }
        return list;
    }

    public List<Chat> getChatsByTechnicianId(int technicianId) throws Exception {
        List<Chat> list = new ArrayList<>();
        String sql = "SELECT c.*, u1.first_name as user_first_name, u1.last_name as user_last_name, u1.profile_picture_path as user_pic, " +
                "u2.first_name as tech_first_name, u2.last_name as tech_last_name, u2.profile_picture_path as tech_pic, " +
                "(SELECT COUNT(*) FROM chat_messages cm WHERE cm.chat_id = c.chat_id AND cm.sender_id != ? AND cm.is_read = 0) as unread_count, "
                +
                "(SELECT message FROM chat_messages cm WHERE cm.chat_id = c.chat_id ORDER BY cm.created_at DESC LIMIT 1) as last_message, "
                +
                "(SELECT created_at FROM chat_messages cm WHERE cm.chat_id = c.chat_id ORDER BY cm.created_at DESC LIMIT 1) as last_message_time "
                +
                "FROM chats c " +
                "JOIN users u1 ON c.user_id = u1.user_id " +
                "JOIN users u2 ON c.technician_id = u2.user_id " +
                "WHERE c.technician_id = ? " +
                "ORDER BY last_message_time DESC";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, technicianId);
            ps.setInt(2, technicianId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Chat chat = extractChatFromResultSet(rs);
                    chat.setUnreadCount(rs.getInt("unread_count"));
                    chat.setLastMessage(rs.getString("last_message"));
                    chat.setLastMessageTime(rs.getTimestamp("last_message_time"));
                    list.add(chat);
                }
            }
        }
        return list;
    }

    public int getTotalUnreadCountForUser(int userId) throws Exception {
        String sql = "SELECT COUNT(cm.message_id) as total_unread " +
                "FROM chat_messages cm " +
                "JOIN chats c ON cm.chat_id = c.chat_id " +
                "WHERE (c.user_id = ? OR c.technician_id = ?) " +
                "AND cm.sender_id != ? AND cm.is_read = 0";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_unread");
                }
            }
        }
        return 0;
    }

    private Chat extractChatFromResultSet(ResultSet rs) throws SQLException {
        Chat chat = new Chat();
        chat.setChatId(rs.getInt("chat_id"));
        chat.setUserId(rs.getInt("user_id"));
        chat.setTechnicianId(rs.getInt("technician_id"));
        chat.setCreatedAt(rs.getTimestamp("created_at"));

        // Set display names
        chat.setUserName(rs.getString("user_first_name") + " " + rs.getString("user_last_name"));
        chat.setTechnicianName(rs.getString("tech_first_name") + " " + rs.getString("tech_last_name"));

        // Set profile pics
        chat.setUserProfilePic(rs.getString("user_pic"));
        chat.setTechnicianProfilePic(rs.getString("tech_pic"));

        return chat;
    }
}
