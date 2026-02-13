package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;
import com.bloodbank.util.PasswordUtil;

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
import java.sql.SQLException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Trim inputs to avoid whitespace issues
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null) email = email.trim();

        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnectionUtil.getConnection()) {

            String sql = "SELECT id, full_name, password_hash, role, status " +
                         "FROM users WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            long userId = rs.getLong("id");
            String fullName = rs.getString("full_name");
            String passwordHash = rs.getString("password_hash");
            String role = rs.getString("role");
            String status = rs.getString("status");

            // Verify password
            if (!PasswordUtil.verifyPassword(password, passwordHash)) {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Check approval status
            if (!"APPROVED".equalsIgnoreCase(status)) {
                request.setAttribute(
                        "error",
                        "Your account is pending approval. Please try again later."
                );
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // 🔐 Create new session (prevent session fixation)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("userId", userId);
            session.setAttribute("fullName", fullName);
            session.setAttribute("role", role);

            String ctx = request.getContextPath();

            // Redirect based on role
            if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect(ctx + "/dashboard/admin/home.jsp");
            } else if ("BANK".equalsIgnoreCase(role)) {
                response.sendRedirect(ctx + "/dashboard/bank/home.jsp");
            } else {
                response.sendRedirect(ctx + "/dashboard/donor/home.jsp");
            }

        } catch (SQLException e) {
    e.printStackTrace();   // 👈 ADD THIS LINE
    request.setAttribute("error", "DB Error: " + e.getMessage());
    request.getRequestDispatcher("/login.jsp").forward(request, response);
}
    }
}
