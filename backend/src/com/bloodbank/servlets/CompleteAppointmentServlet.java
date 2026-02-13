package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/CompleteAppointmentServlet")
public class CompleteAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔐 Ensure only BANK can do this
        HttpSession session = request.getSession(false);
        if (session == null || !"BANK".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String idParam = request.getParameter("appointmentId");
        if (idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        long appointmentId = Long.parseLong(idParam);
        Long bankUserId = (Long) session.getAttribute("userId");

        try (Connection conn = DBConnectionUtil.getConnection()) {

            // ✅ Step 1: Get correct bank_id from blood_banks table
            PreparedStatement psBank = conn.prepareStatement(
                "SELECT id FROM blood_banks WHERE email = (SELECT email FROM users WHERE id = ?)"
            );
            psBank.setLong(1, bankUserId);

            ResultSet rs = psBank.executeQuery();

            long bankId = -1;
            if (rs.next()) {
                bankId = rs.getLong("id");
            }

            if (bankId == -1) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            // ✅ Step 2: Update only that bank's appointment
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE appointments SET status = 'COMPLETED' WHERE id = ? AND bank_id = ?"
            );

            ps.setLong(1, appointmentId);
            ps.setLong(2, bankId);

            ps.executeUpdate();

        } catch (Exception e) {
            throw new ServletException("Failed to complete appointment", e);
        }

        // 🔁 Back to bank dashboard
        response.sendRedirect(request.getContextPath() + "/dashboard/bank/home.jsp");
    }
}
