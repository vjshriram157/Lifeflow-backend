package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;
import com.bloodbank.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String bloodGroup = request.getParameter("bloodGroup");
        String city = request.getParameter("city");

        // 🔹 Basic validation
        if (fullName == null || email == null || password == null || confirmPassword == null
                || fullName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Please fill in all required fields.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        String role = request.getParameter("role");
        if (role == null || (!"DONOR".equals(role) && !"BANK".equals(role))) {
            role = "DONOR";
        }

        String passwordHash = PasswordUtil.hashPassword(password);

        try (Connection conn = DBConnectionUtil.getConnection()) {

            // 🔒 CHECK IF EMAIL ALREADY EXISTS
            String checkSql = "SELECT id FROM users WHERE email = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, email);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                request.setAttribute("error", "This email is already registered. Please login.");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            // 📝 INSERT NEW USER (UNVERIFIED EMAIL)
            String insertSql =
                    "INSERT INTO users (full_name, email, phone, password_hash, blood_group, role, status, city) " +
                    "VALUES (?, ?, ?, ?, ?, ?, 'UNVERIFIED', ?)";

            PreparedStatement ps = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, passwordHash);
            ps.setString(5, bloodGroup);
            ps.setString(6, role);
            ps.setString(7, city);
            ps.executeUpdate();
            
            ResultSet generatedKeys = ps.getGeneratedKeys();
            if (generatedKeys.next()) {
                long userId = generatedKeys.getLong(1);
                
                // Generate 6-digit OTP
                String otp = String.format("%06d", new java.util.Random().nextInt(999999));
                
                // Insert OTP into password_resets (reusing this table for tokens)
                PreparedStatement psToken = conn.prepareStatement("INSERT INTO password_resets (user_id, token) VALUES (?, ?)");
                psToken.setLong(1, userId);
                psToken.setString(2, otp);
                psToken.executeUpdate();
                
                // Dispatch real email
                com.bloodbank.util.EmailService.sendOtpEmail(email, otp);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to register. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // ✅ Redirect to OTP verification page
        response.sendRedirect(request.getContextPath() + "/verifyRegistrationOtp.jsp?email=" + email);
    }
}
