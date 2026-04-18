package com.dailyfixer.servlet.admin;

import com.dailyfixer.dao.AdminDashboardDAO;
import com.dailyfixer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@WebServlet(name = "AdminReportServlet", urlPatterns = {"/admin/report"})
public class AdminReportServlet extends HttpServlet {

    private static final int MAX_RANGE_DAYS = 365;
    private static final Set<String> VALID_SECTIONS = new HashSet<>(
            Arrays.asList("orders", "revenue", "bookings", "users"));

    private AdminDashboardDAO dao;

    @Override
    public void init() throws ServletException {
        super.init();
        dao = new AdminDashboardDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Auth check ──
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;
        if (user == null || user.getRole() == null
                || !"admin".equalsIgnoreCase(user.getRole().trim())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        // ── Parse & validate dates ──
        String startParam = req.getParameter("startDate");
        String endParam   = req.getParameter("endDate");

        if (startParam == null || startParam.isBlank()
                || endParam == null || endParam.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "startDate and endDate are required.");
            return;
        }

        LocalDate start, end;
        try {
            start = LocalDate.parse(startParam.trim());
            end   = LocalDate.parse(endParam.trim());
        } catch (DateTimeParseException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid date format. Use YYYY-MM-DD.");
            return;
        }

        LocalDate today = LocalDate.now();
        if (start.isAfter(today)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Start date cannot be in the future.");
            return;
        }
        if (end.isBefore(start)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "End date must be on or after start date.");
            return;
        }
        long rangeDays = ChronoUnit.DAYS.between(start, end);
        if (rangeDays > MAX_RANGE_DAYS) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Date range cannot exceed " + MAX_RANGE_DAYS + " days.");
            return;
        }

        // ── Parse & validate sections ──
        String[] sectionsParam = req.getParameterValues("sections");
        Set<String> sections = new HashSet<>();
        if (sectionsParam != null) {
            for (String s : sectionsParam) {
                String lower = s.toLowerCase();
                if (VALID_SECTIONS.contains(lower)) {
                    sections.add(lower);
                }
            }
        }
        if (sections.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "At least one report section must be selected.");
            return;
        }

        // ── Stream CSV response ──
        String filename = "dailyfixer_report_" + start + "_" + end + ".csv";
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        resp.setCharacterEncoding("UTF-8");

        PrintWriter out = resp.getWriter();

        // UTF-8 BOM so Excel opens without encoding prompts
        out.print('\uFEFF');
        out.println("Daily Fixer - Admin Report");
        out.println("Generated," + today);
        out.println("Period," + start + " to " + end);
        out.println();

        if (sections.contains("orders"))   appendOrdersSection(out, start, end);
        if (sections.contains("revenue"))  appendRevenueSection(out, start, end);
        if (sections.contains("bookings")) appendBookingsSection(out, start, end);
        if (sections.contains("users"))    appendUsersSection(out, start, end);

        out.flush();
    }

    private void appendOrdersSection(PrintWriter out, LocalDate start, LocalDate end) {
        out.println("## ORDERS");
        out.println("Date,Orders");
        Map<String, Integer> data = dao.getOrdersInRange(start, end);
        int total = 0;
        for (Map.Entry<String, Integer> e : data.entrySet()) {
            out.println(e.getKey() + "," + e.getValue());
            total += e.getValue();
        }
        if (data.isEmpty()) out.println("(no data in range),");
        out.println("TOTAL," + total);
        out.println();

        out.println("Orders by Status");
        out.println("Status,Count");
        Map<String, Integer> statusData = dao.getOrdersByStatusInRange(start, end);
        for (Map.Entry<String, Integer> e : statusData.entrySet()) {
            out.println(e.getKey() + "," + e.getValue());
        }
        if (statusData.isEmpty()) out.println("(no data in range),");
        out.println();
    }

    private void appendRevenueSection(PrintWriter out, LocalDate start, LocalDate end) {
        out.println("## REVENUE (LKR)");
        out.println("Date,Revenue (LKR)");
        Map<String, Double> data = dao.getRevenueInRange(start, end);
        double total = 0;
        for (Map.Entry<String, Double> e : data.entrySet()) {
            out.println(e.getKey() + "," + String.format("%.2f", e.getValue()));
            total += e.getValue();
        }
        if (data.isEmpty()) out.println("(no data in range),");
        out.println("TOTAL," + String.format("%.2f", total));
        out.println();
    }

    private void appendBookingsSection(PrintWriter out, LocalDate start, LocalDate end) {
        out.println("## BOOKINGS");
        out.println("Date,Bookings");
        Map<String, Integer> data = dao.getBookingsInRange(start, end);
        int total = 0;
        for (Map.Entry<String, Integer> e : data.entrySet()) {
            out.println(e.getKey() + "," + e.getValue());
            total += e.getValue();
        }
        if (data.isEmpty()) out.println("(no data in range),");
        out.println("TOTAL," + total);
        out.println();
    }

    private void appendUsersSection(PrintWriter out, LocalDate start, LocalDate end) {
        out.println("## NEW USERS");
        out.println("Date,New Registrations");
        Map<String, Integer> data = dao.getNewUsersInRange(start, end);
        int total = 0;
        for (Map.Entry<String, Integer> e : data.entrySet()) {
            out.println(e.getKey() + "," + e.getValue());
            total += e.getValue();
        }
        if (data.isEmpty()) out.println("(no data in range),");
        out.println("TOTAL," + total);
        out.println();

        out.println("New Users by Role");
        out.println("Role,Count");
        Map<String, Integer> roleData = dao.getNewUsersByRoleInRange(start, end);
        for (Map.Entry<String, Integer> e : roleData.entrySet()) {
            out.println(e.getKey() + "," + e.getValue());
        }
        if (roleData.isEmpty()) out.println("(no data in range),");
        out.println();
    }
}
