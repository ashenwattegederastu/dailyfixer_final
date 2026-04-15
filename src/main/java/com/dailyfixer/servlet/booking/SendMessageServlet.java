package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.dao.ChatMessageDAO;
import com.dailyfixer.model.Chat;
import com.dailyfixer.model.ChatMessage;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/chats/send")
public class SendMessageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
                return;
            }
            
            int chatId = Integer.parseInt(request.getParameter("chatId"));
            String messageText = request.getParameter("message");
            
            if (messageText == null || messageText.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Message cannot be empty");
                return;
            }
            
            ChatDAO chatDAO = new ChatDAO();
            Chat chat = chatDAO.getChatById(chatId);
            
            if (chat == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Chat not found");
                return;
            }
            
            // Verify user has access to this chat
            if (chat.getUserId() != currentUser.getUserId() && chat.getTechnicianId() != currentUser.getUserId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }
            
            ChatMessage message = new ChatMessage();
            message.setChatId(chatId);
            message.setSenderId(currentUser.getUserId());
            message.setMessage(messageText.trim());
            message.setRead(false);
            
            ChatMessageDAO messageDAO = new ChatMessageDAO();
            messageDAO.createMessage(message);
            
            response.sendRedirect(request.getContextPath() + "/chats/view?chatId=" + chatId);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error sending message: " + e.getMessage());
        }
    }
}
