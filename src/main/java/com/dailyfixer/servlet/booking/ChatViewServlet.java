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
import java.util.List;

@WebServlet("/chats/view")
public class ChatViewServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            int chatId = Integer.parseInt(request.getParameter("chatId"));
            
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
            
            ChatMessageDAO messageDAO = new ChatMessageDAO();
            List<ChatMessage> messages = messageDAO.getMessagesByChatId(chatId);
            
            // Mark messages as read
            messageDAO.markMessagesAsRead(chatId, currentUser.getUserId());
            
            request.setAttribute("chat", chat);
            request.setAttribute("messages", messages);
            request.getRequestDispatcher("/pages/chat/chat-view.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading chat: " + e.getMessage());
        }
    }
}
