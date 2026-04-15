package com.dailyfixer.servlet.service;

import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.model.Service;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.OutputStream;

@WebServlet("/ServiceImageServlet")
public class ServiceImageServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int serviceId = Integer.parseInt(request.getParameter("service_id"));
            Service service = new ServiceDAO().getServiceImage(serviceId);
            if (service != null && service.getServiceImage() != null) {
                response.setContentType(service.getImageType());
                OutputStream out = response.getOutputStream();
                out.write(service.getServiceImage());
                out.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
