package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String otp = request.getParameter("otp");
        String newPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (email == null || otp == null || newPassword == null || otp.trim().isEmpty() || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
            return;
        }

        try (Connection conn = DBConnectionUtil.getConnection()) {
            // Find user id and token matching
            PreparedStatement psFind = conn.prepareStatement(
                "SELECT pr.user_id FROM password_resets pr " +
                "JOIN users u ON pr.user_id = u.id " +
                "WHERE pr.token = ? AND u.email = ?"
            );
            psFind.setString(1, otp);
            psFind.setString(2, email);
            ResultSet rs = psFind.executeQuery();
            
            if (rs.next()) {
                long userId = rs.getLong("user_id");
                
                // Update user password
                PreparedStatement psUpdate = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?");
                psUpdate.setString(1, newPassword);
                psUpdate.setLong(2, userId);
                psUpdate.executeUpdate();
                
                // Delete used OTP
                PreparedStatement psDelete = conn.prepareStatement("DELETE FROM password_resets WHERE token = ? AND user_id = ?");
                psDelete.setString(1, otp);
                psDelete.setLong(2, userId);
                psDelete.executeUpdate();
                
                // Redirect back to login with success message
                response.sendRedirect(request.getContextPath() + "/login.jsp?resetSuccess=true");
            } else {
                request.setAttribute("error", "Invalid or expired OTP.");
                request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again later.");
            request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
        }
    }
}
