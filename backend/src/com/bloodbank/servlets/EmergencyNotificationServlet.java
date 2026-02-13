package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;
import com.bloodbank.util.FcmClient;
import org.json.JSONArray;
import org.json.JSONObject;

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

@WebServlet(name = "EmergencyNotificationServlet", urlPatterns = {"/api/emergency-broadcast"})
public class EmergencyNotificationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String bankIdParam = request.getParameter("bankId");
        String bloodGroup = request.getParameter("bloodGroup");
        String radiusParam = request.getParameter("radiusKm");
        String message = request.getParameter("message");

        JSONObject result = new JSONObject();

        try (PrintWriter out = response.getWriter()) {
            if (bankIdParam == null || bloodGroup == null || bloodGroup.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("error", "bankId and bloodGroup are required");
                out.print(result.toString());
                return;
            }

            long bankId = Long.parseLong(bankIdParam);
            double radiusKm = radiusParam != null ? Double.parseDouble(radiusParam) : 10.0;

            try (Connection conn = DBConnectionUtil.getConnection()) {
                conn.setAutoCommit(false);

                // 1) Lookup bank coordinates
                double bankLat = 0;
                double bankLng = 0;
                PreparedStatement psBank = conn.prepareStatement(
                        "SELECT latitude, longitude FROM blood_banks WHERE id = ? AND status = 'APPROVED'");
                psBank.setLong(1, bankId);
                ResultSet rsBank = psBank.executeQuery();
                if (!rsBank.next()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.put("error", "Invalid or unapproved blood bank");
                    out.print(result.toString());
                    conn.rollback();
                    return;
                }
                bankLat = rsBank.getDouble("latitude");
                bankLng = rsBank.getDouble("longitude");

                // 2) Insert alert record
                PreparedStatement psAlert = conn.prepareStatement(
                        "INSERT INTO emergency_alerts (bank_id, blood_group, radius_km, message) VALUES (?, ?, ?, ?)",
                        PreparedStatement.RETURN_GENERATED_KEYS);
                psAlert.setLong(1, bankId);
                psAlert.setString(2, bloodGroup);
                psAlert.setDouble(3, radiusKm);
                psAlert.setString(4, message != null ? message : "Urgent need for " + bloodGroup + " blood");
                psAlert.executeUpdate();

                long alertId = 0;
                ResultSet alertKeys = psAlert.getGeneratedKeys();
                if (alertKeys.next()) {
                    alertId = alertKeys.getLong(1);
                }

                // 3) Find eligible donors by blood group and radius using last known location
                StringBuilder sql = new StringBuilder();
                sql.append("SELECT d.user_id, d.device_token, d.platform, ");
                sql.append("( 6371 * ACOS( ");
                sql.append("COS(RADIANS(?)) * COS(RADIANS(d.last_latitude)) * ");
                sql.append("COS(RADIANS(d.last_longitude) - RADIANS(?)) + ");
                sql.append("SIN(RADIANS(?)) * SIN(RADIANS(d.last_latitude)) ");
                sql.append(") ) AS distance_km ");
                sql.append("FROM device_tokens d ");
                sql.append("JOIN users u ON u.id = d.user_id ");
                sql.append("WHERE u.blood_group = ? ");
                sql.append("AND u.status = 'APPROVED' ");
                sql.append("AND ( ");
                sql.append("SELECT COUNT(1) FROM appointments a ");
                sql.append("WHERE a.donor_id = u.id ");
                sql.append("AND a.status = 'COMPLETED' ");
                sql.append("AND a.appointment_time >= DATE_SUB(NOW(), INTERVAL 3 MONTH) ");
                sql.append(") = 0 ");
                sql.append("HAVING distance_km <= ? ");

                PreparedStatement psDonors = conn.prepareStatement(sql.toString());
                int idx = 1;
                psDonors.setDouble(idx++, bankLat);
                psDonors.setDouble(idx++, bankLng);
                psDonors.setDouble(idx++, bankLat);
                psDonors.setString(idx++, bloodGroup);
                psDonors.setDouble(idx, radiusKm);

                ResultSet rsDonors = psDonors.executeQuery();

                JSONArray notifiedDevices = new JSONArray();
                java.util.List<String> fcmTokens = new java.util.ArrayList<>();

                while (rsDonors.next()) {
                    JSONObject dev = new JSONObject();
                    dev.put("userId", rsDonors.getLong("user_id"));
                    dev.put("deviceToken", rsDonors.getString("device_token"));
                    String token = rsDonors.getString("device_token");
                    dev.put("platform", rsDonors.getString("platform"));
                    dev.put("distanceKm", rsDonors.getDouble("distance_km"));
                    notifiedDevices.put(dev);
                    if (token != null && !token.isEmpty()) {
                        fcmTokens.add(token);
                    }
                }

                // 4) Push high-priority emergency notifications via FCM (best-effort, non-blocking for DB commit)
                String title = "Emergency need for " + bloodGroup + " blood";
                String bodyText = message != null && !message.isEmpty()
                        ? message
                        : "Nearby blood bank requires " + bloodGroup + " donors urgently.";
                FcmClient.sendEmergencyAlertToDevices(
                        fcmTokens,
                        title,
                        bodyText,
                        String.valueOf(alertId),
                        String.valueOf(bankId),
                        bloodGroup
                );

                conn.commit();

                result.put("alertId", alertId);
                result.put("notifiedCount", notifiedDevices.length());
                result.put("devices", notifiedDevices);
                result.put("status", "QUEUED");
                response.setStatus(HttpServletResponse.SC_OK);
                out.print(result.toString());
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.put("error", "Database error: " + e.getMessage());
                response.getWriter().print(result.toString());
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("error", "Invalid numeric parameter");
            response.getWriter().print(result.toString());
        }
    }
}

