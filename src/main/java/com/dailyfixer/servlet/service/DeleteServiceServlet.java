package com.dailyfixer.servlet.service;

import com.dailyfixer.dao.ServiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/DeleteServiceServlet")
public class DeleteServiceServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            // Get the service ID from URL
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                throw new IllegalArgumentException("Service ID is missing.");
            }

            int serviceId = Integer.parseInt(idParam);

            // Call DAO to delete
            new ServiceDAO().deleteService(serviceId);

            // Redirect to service listing page
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/techniciandash/serviceListings.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error deleting service: " + e.getMessage());
        }
    }

    // Optional: block POST (so browser can’t accidentally trigger it)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "POST not supported for deletion.");
    }
}
