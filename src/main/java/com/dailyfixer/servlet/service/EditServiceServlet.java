package com.dailyfixer.servlet.service;

import com.dailyfixer.dao.ServiceCategoryDAO;
import com.dailyfixer.dao.ServiceDAO;
import com.dailyfixer.model.Service;
import com.dailyfixer.model.ServiceCategory;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

@WebServlet("/EditServiceServlet")
@MultipartConfig(maxFileSize = 16177215)
public class EditServiceServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            if (currentUser == null || !"technician".equalsIgnoreCase(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }

            int serviceId = Integer.parseInt(request.getParameter("id"));
            Service s = new ServiceDAO().getServiceById(serviceId);
            if (s == null) {
                response.getWriter().println("Service not found!");
                return;
            }

            ServiceCategoryDAO categoryDAO = new ServiceCategoryDAO();
            List<ServiceCategory> categories = categoryDAO.getAllCategories();
            request.setAttribute("categories", categories);

            request.setAttribute("service", s);
            request.getRequestDispatcher("/pages/dashboards/techniciandash/editService.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            Service s = new ServiceDAO().getServiceById(serviceId);
            if (s == null) {
                response.getWriter().println("Service not found!");
                return;
            }

            String category = request.getParameter("category");
            if ("__new__".equals(category)) {
                String newCategoryName = request.getParameter("newCategoryName");
                if (newCategoryName == null || newCategoryName.trim().isEmpty()) {
                    throw new ServletException("New category name is required.");
                }
                category = newCategoryName.trim();

                ServiceCategoryDAO categoryDAO = new ServiceCategoryDAO();
                if (categoryDAO.getCategoryByName(category) == null) {
                    ServiceCategory newCat = new ServiceCategory();
                    newCat.setName(category);
                    newCat.setDescription("");
                    categoryDAO.addCategory(newCat);
                }
            }

            s.setServiceName(request.getParameter("serviceName"));
            s.setCategory(category);
            s.setPricingType(request.getParameter("pricingType"));
            s.setFixedRate(request.getParameter("fixedRate") == null || request.getParameter("fixedRate").isEmpty() ? 0 : Double.parseDouble(request.getParameter("fixedRate")));
            s.setHourlyRate(request.getParameter("hourlyRate") == null || request.getParameter("hourlyRate").isEmpty() ? 0 : Double.parseDouble(request.getParameter("hourlyRate")));
            s.setInspectionCharge(Double.parseDouble(request.getParameter("inspectionCharge")));
            s.setTransportCharge(Double.parseDouble(request.getParameter("transportCharge")));

            boolean recurringEnabled = "on".equals(request.getParameter("recurringEnabled"));
            s.setRecurringEnabled(recurringEnabled);
            String recurringFeeStr = request.getParameter("recurringFee");
            if (recurringEnabled && recurringFeeStr != null && !recurringFeeStr.isEmpty()) {
                s.setRecurringFee(Double.parseDouble(recurringFeeStr));
            } else {
                s.setRecurringFee(0);
            }
            
            String description = request.getParameter("description");
            s.setDescription(description != null ? description.trim() : "");

            Part imagePart = request.getPart("serviceImage");
            if (imagePart != null && imagePart.getSize() > 0) {
                InputStream is = imagePart.getInputStream();
                s.setServiceImage(is.readAllBytes());
                s.setImageType(imagePart.getContentType());
            }

            new ServiceDAO().updateService(s);
            response.sendRedirect(request.getContextPath() + "/pages/dashboards/techniciandash/serviceListings.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
