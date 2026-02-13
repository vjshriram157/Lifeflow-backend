package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "VerifyCertificateServlet", urlPatterns = {"/verify-certificate"})
public class VerifyCertificateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String appointmentParam = request.getParameter("appointmentId");
        if (appointmentParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing appointmentId");
            return;
        }

        long appointmentId;
        try {
            appointmentId = Long.parseLong(appointmentParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid appointmentId");
            return;
        }

        String donorName = null;
        String bloodGroup = null;
        String bankName = null;
        String city = null;
        String completedOn = null;

        try (Connection conn = DBConnectionUtil.getConnection()) {
            String sql = "SELECT u.full_name, u.blood_group, b.bank_name, b.city, a.appointment_time " +
                    "FROM appointments a " +
                    "JOIN users u ON u.id = a.donor_id " +
                    "JOIN blood_banks b ON b.id = a.bank_id " +
                    "WHERE a.id = ? AND a.status = 'COMPLETED'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Certificate not found or not valid.");
                return;
            }
            donorName = rs.getString("full_name");
            bloodGroup = rs.getString("blood_group");
            bankName = rs.getString("bank_name");
            city = rs.getString("city");
            completedOn = rs.getString("appointment_time");
        } catch (SQLException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
            return;
        }

        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Verify Donation Certificate</title>");
            out.println("<style>body{font-family:system-ui,Segoe UI,sans-serif;background:#0f172a;color:white;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;} .card{background:#020617;border-radius:18px;padding:28px 32px;box-shadow:0 24px 80px rgba(15,23,42,0.8);max-width:520px;width:100%;}</style>");
            out.println("</head><body><div class='card'>");
            out.println("<h1 style='margin-top:0;margin-bottom:10px;'>Certificate Verified</h1>");
            out.println("<p style='color:#9ca3af;font-size:.95rem;'>This donation certificate is valid and was issued by the LifeFlow Blood Network.</p>");
            out.println("<ul style='list-style:none;padding-left:0;margin-top:18px;color:#e5e7eb;font-size:.95rem;'>");
            out.println("<li><strong>Donor:</strong> " + donorName + "</li>");
            out.println("<li><strong>Blood Group:</strong> " + bloodGroup + "</li>");
            out.println("<li><strong>Blood Bank:</strong> " + bankName + " (" + city + ")</li>");
            out.println("<li><strong>Date:</strong> " + completedOn + "</li>");
            out.println("<li><strong>Certificate ID:</strong> " + appointmentId + "</li>");
            out.println("</ul>");
            out.println("</div></body></html>");
        }
    }
}

