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
import java.sql.SQLException;

/**
 * Registers or updates a mobile device token + last known coordinates for a user.
 *
 * Endpoint: POST /api/register-device
 * Params:
 *   userId      (required, long)
 *   token       (required, string)
 *   platform    (required, ANDROID|IOS)
 *   lat         (optional, double)
 *   lng         (optional, double)
 */
@WebServlet(name = "RegisterDeviceServlet", urlPatterns = {"/api/register-device"})
public class RegisterDeviceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String userIdParam = request.getParameter("userId");
        String token = request.getParameter("token");
        String platform = request.getParameter("platform");
        String latParam = request.getParameter("lat");
        String lngParam = request.getParameter("lng");

        try (PrintWriter out = response.getWriter()) {
            if (userIdParam == null || token == null || platform == null ||
                    userIdParam.isEmpty() || token.isEmpty() || platform.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"userId, token, and platform are required\"}");
                return;
            }

            long userId;
            try {
                userId = Long.parseLong(userIdParam);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid userId\"}");
                return;
            }

            Double lat = null;
            Double lng = null;
            try {
                if (latParam != null && !latParam.isEmpty()) {
                    lat = Double.parseDouble(latParam);
                }
                if (lngParam != null && !lngParam.isEmpty()) {
                    lng = Double.parseDouble(lngParam);
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid lat/lng\"}");
                return;
            }

            String normalizedPlatform = platform.toUpperCase();
            if (!"ANDROID".equals(normalizedPlatform) && !"IOS".equals(normalizedPlatform)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"platform must be ANDROID or IOS\"}");
                return;
            }

            try (Connection conn = DBConnectionUtil.getConnection()) {
                String sql = "INSERT INTO device_tokens (user_id, device_token, platform, last_latitude, last_longitude) " +
                        "VALUES (?, ?, ?, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE device_token = VALUES(device_token), " +
                        "platform = VALUES(platform), last_latitude = VALUES(last_latitude), " +
                        "last_longitude = VALUES(last_longitude)";

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setLong(1, userId);
                ps.setString(2, token);
                ps.setString(3, normalizedPlatform);
                if (lat != null) {
                    ps.setDouble(4, lat);
                } else {
                    ps.setNull(4, java.sql.Types.DOUBLE);
                }
                if (lng != null) {
                    ps.setDouble(5, lng);
                } else {
                    ps.setNull(5, java.sql.Types.DOUBLE);
                }
                ps.executeUpdate();
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Database error: " + e.getMessage() + "\"}");
                return;
            }

            out.print("{\"status\":\"OK\"}");
        }
    }
}

