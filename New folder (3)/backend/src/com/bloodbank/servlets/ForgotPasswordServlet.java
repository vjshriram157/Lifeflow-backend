package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;
import com.bloodbank.util.EmailService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Random;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required.");
            request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnectionUtil.getConnection()) {
            PreparedStatement psUser = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
            psUser.setString(1, email);
            ResultSet rsUser = psUser.executeQuery();
            
            if (rsUser.next()) {
                long userId = rsUser.getLong("id");
                
                // Generate 6-digit OTP
                String otp = String.format("%06d", new Random().nextInt(999999));
                
                // Clear existing tokens
                PreparedStatement psDelete = conn.prepareStatement("DELETE FROM password_resets WHERE user_id = ?");
                psDelete.setLong(1, userId);
                psDelete.executeUpdate();
                
                // Insert new OTP
                PreparedStatement psInsert = conn.prepareStatement("INSERT INTO password_resets (user_id, token) VALUES (?, ?)");
                psInsert.setLong(1, userId);
                psInsert.setString(2, otp);
                psInsert.executeUpdate();
                
                // Dispatch real email
                EmailService.sendOtpEmail(email, otp);
                
                // Redirect user to the OTP verification page
                response.sendRedirect(request.getContextPath() + "/verifyOtp.jsp?email=" + email);
                return;
            } else {
                // If account does not exist, silently succeed to prevent enum, but redirect to OTP anyway
                response.sendRedirect(request.getContextPath() + "/verifyOtp.jsp?email=" + email);
                return;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing your request.");
            request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
        }
    }
}
