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

public class ExportReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"System_Report.csv\"");

        try (Connection conn = DBConnectionUtil.getConnection();
             PrintWriter out = response.getWriter()) {
             
            out.println("ID,Full Name,Role,Email,Phone,Blood Group,Status,City,Created At");

            String sql = "SELECT id, full_name, role, email, phone, blood_group, status, city, created_at FROM users ORDER BY created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                 
                while (rs.next()) {
                    out.print(rs.getInt("id") + ",");
                    out.print(escapeCSV(rs.getString("full_name")) + ",");
                    out.print(escapeCSV(rs.getString("role")) + ",");
                    out.print(escapeCSV(rs.getString("email")) + ",");
                    out.print(escapeCSV(rs.getString("phone")) + ",");
                    out.print(escapeCSV(rs.getString("blood_group")) + ",");
                    out.print(escapeCSV(rs.getString("status")) + ",");
                    out.print(escapeCSV(rs.getString("city")) + ",");
                    out.print(rs.getTimestamp("created_at") + "\n");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating report");
        }
    }

    private String escapeCSV(String data) {
        if (data == null) return "";
        data = data.replaceAll("\"", "\"\"");
        if (data.contains(",") || data.contains("\"") || data.contains("\n")) {
            return "\"" + data + "\"";
        }
        return data;
    }
}
