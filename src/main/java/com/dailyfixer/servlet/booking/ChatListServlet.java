package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.ChatDAO;
import com.dailyfixer.model.Chat;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/chats")
public class ChatListServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }
            
            ChatDAO chatDAO = new ChatDAO();
            List<Chat> chats;
            
            if ("technician".equalsIgnoreCase(currentUser.getRole())) {
                chats = chatDAO.getChatsByTechnicianId(currentUser.getUserId());
            } else {
                chats = chatDAO.getChatsByUserId(currentUser.getUserId());
            }
            
            request.setAttribute("chats", chats);
            request.getRequestDispatcher("/pages/chat/chat-list.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading chats: " + e.getMessage());
        }
    }
}
