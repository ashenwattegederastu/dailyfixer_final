package com.dailyfixer.servlet.vehicle;

import com.dailyfixer.dao.VehicleDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/GetVehicleMakesServlet")
public class GetVehicleMakesServlet extends HttpServlet {

    private VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (!"driver".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String category = request.getParameter("category");
        if (category == null || category.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing category");
            return;
        }

        List<String> makes = vehicleDAO.getMakesByCategory(category);

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print("[");
        for (int i = 0; i < makes.size(); i++) {
            String make = makes.get(i).replace("\"", "\\\"");
            out.print("\"" + make + "\"");
            if (i < makes.size() - 1) out.print(",");
        }
        out.print("]");
    }
}
