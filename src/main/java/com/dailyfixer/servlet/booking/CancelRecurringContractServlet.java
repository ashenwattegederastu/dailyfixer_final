package com.dailyfixer.servlet.booking;

import com.dailyfixer.dao.BookingDAO;
import com.dailyfixer.dao.RecurringContractDAO;
import com.dailyfixer.model.RecurringContract;
import com.dailyfixer.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/recurring/cancel")
public class CancelRecurringContractServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");

            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
                return;
            }

            int contractId = Integer.parseInt(request.getParameter("contractId"));

            RecurringContractDAO contractDAO = new RecurringContractDAO();
            RecurringContract contract = contractDAO.getContractById(contractId);

            if (contract == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Contract not found");
                return;
            }

            // Only the user or technician on this contract may cancel it
            boolean isTechnician = "technician".equalsIgnoreCase(currentUser.getRole())
                    && contract.getTechnicianId() == currentUser.getUserId();
            boolean isUser = "user".equalsIgnoreCase(currentUser.getRole())
                    && contract.getUserId() == currentUser.getUserId();

            if (!isTechnician && !isUser) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
                return;
            }

            // Guard: only ACTIVE or PENDING contracts may be cancelled
            if (!"ACTIVE".equals(contract.getStatus()) && !"PENDING".equals(contract.getStatus())) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Contract is not in a cancellable state.");
                return;
            }

            // Cancel future ACCEPTED bookings, then mark contract CANCELLED
            BookingDAO bookingDAO = new BookingDAO();
            bookingDAO.cancelFutureBookingsByContractId(contractId);
            contractDAO.updateContractStatus(contractId, "CANCELLED");

            // Redirect back to the appropriate dashboard
            if (isTechnician) {
                response.sendRedirect(request.getContextPath() +
                        "/pages/dashboards/techniciandash/recurringContracts.jsp?cancelled=true");
            } else {
                response.sendRedirect(request.getContextPath() +
                        "/pages/dashboards/userdash/recurringContracts.jsp?cancelled=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
        }
    }
}
