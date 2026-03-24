package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "DonationCertificateServlet", urlPatterns = {"/certificate"})
public class DonationCertificateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        long userId = (Long) session.getAttribute("userId");

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
                    "WHERE a.id = ? AND a.donor_id = ? AND a.status = 'COMPLETED'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, appointmentId);
            ps.setLong(2, userId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No completed donation found for this appointment.");
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
            String ctx = request.getContextPath();
            String qrUrl = ctx + "/certificate-qr?appointmentId=" + appointmentId;

            out.println("<!DOCTYPE html>");
            out.println("<html><head><meta charset='UTF-8'><title>Donation Certificate</title>");
            out.println("<style>");
            out.println("body{font-family:system-ui,Segoe UI,sans-serif;background:#f1f5f9;margin:0;padding:40px;}");
            out.println(".cert{max-width:720px;margin:0 auto;background:white;border-radius:18px;padding:32px 40px;box-shadow:0 20px 60px rgba(15,23,42,0.35);}");
            out.println(".brand{color:#b91c1c;font-weight:700;letter-spacing:.08em;text-transform:uppercase;font-size:.8rem;}");
            out.println(".name{font-size:1.4rem;font-weight:700;margin-bottom:4px;}");
            out.println(".meta{color:#6b7280;font-size:.9rem;}");
            out.println("</style></head><body>");
            out.println("<div class='cert'>");
            out.println("<div class='brand'>LIFEFLOW BLOOD NETWORK</div>");
            out.println("<h1 style='margin-top:10px;margin-bottom:6px;'>Certificate of Blood Donation</h1>");
            out.println("<p class='meta'>This certifies that</p>");
            out.println("<div class='name'>" + escape(donorName) + "</div>");
            out.println("<p class='meta'>donated <strong>blood (" + escape(bloodGroup) + ")</strong> at <strong>" +
                    escape(bankName) + "</strong> in " + escape(city) + " on <strong>" + completedOn + "</strong>.</p>");
            out.println("<p style='margin-top:20px;'>We gratefully acknowledge this act of kindness and contribution " +
                    "towards saving lives.</p>");
            out.println("<div style='display:flex;justify-content:space-between;align-items:flex-end;margin-top:30px;'>");
            out.println("<div style='font-size:.8rem;color:#6b7280;'>");
            out.println("Certificate ID: " + appointmentId + "<br>");
            out.println("Verify authenticity by scanning the QR code.");
            out.println("</div>");
            out.println("<div><img src='" + qrUrl + "' alt='QR Code' style='width:140px;height:140px;border-radius:12px;border:1px solid #e5e7eb;'/></div>");
            out.println("</div>");
            out.println("</div></body></html>");
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}

