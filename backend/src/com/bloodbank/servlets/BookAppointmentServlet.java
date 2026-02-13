package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookAppointmentServlet extends HttpServlet {

    // 🔹 Load blood banks for dropdown
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection con = DBConnectionUtil.getConnection()) {

            String sql = "SELECT id, bank_name FROM blood_banks";


            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            List<String[]> banks = new ArrayList<>();

            while (rs.next()) {
                banks.add(new String[]{
                        rs.getString("id"),
                        rs.getString("bank_name")

                });
            }

            request.setAttribute("banks", banks);

            request.getRequestDispatcher("/dashboard/donor/bookAppointment.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }

    // 🔹 Insert appointment
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Long donorId = (Long) session.getAttribute("userId");

        if (donorId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String bankId = request.getParameter("bankId");
        String appointmentTime = request.getParameter("appointmentTime");

        try (Connection con = DBConnectionUtil.getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO appointments (donor_id, bank_id, appointment_time, status) " +
                    "VALUES (?, ?, ?, 'PENDING')"
            );

            appointmentTime = appointmentTime.replace("T", " ") + ":00";

ps.setLong(1, donorId);
ps.setInt(2, Integer.parseInt(bankId));
ps.setTimestamp(3, Timestamp.valueOf(appointmentTime));


            ps.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/dashboard/donor/home.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}
