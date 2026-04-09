package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.util.FcmClient;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
            if (bankIdParam == null || bankIdParam.trim().isEmpty() || bloodGroup == null || bloodGroup.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("error", "bankId and bloodGroup are required");
                out.print(result.toString());
                return;
            }

            double radiusKm = radiusParam != null ? Double.parseDouble(radiusParam) : 10.0;

            try {
                Firestore db = FirebaseConfig.getFirestore();

                // 1) Lookup bank coordinates
                DocumentSnapshot bankDoc = db.collection("blood_banks").document(bankIdParam).get().get();
                if (!bankDoc.exists() || !"APPROVED".equals(bankDoc.getString("status"))) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.put("error", "Invalid or unapproved blood bank");
                    out.print(result.toString());
                    return;
                }
                
                Double bankLatObj = bankDoc.getDouble("latitude");
                Double bankLngObj = bankDoc.getDouble("longitude");
                double bankLat = bankLatObj != null ? bankLatObj : 0;
                double bankLng = bankLngObj != null ? bankLngObj : 0;

                // 2) Insert alert record
                Map<String, Object> alertData = new HashMap<>();
                alertData.put("bank_id", bankIdParam);
                alertData.put("blood_group", bloodGroup);
                alertData.put("radius_km", radiusKm);
                alertData.put("message", message != null ? message : "Urgent need for " + bloodGroup + " blood");
                alertData.put("created_at", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                
                DocumentReference alertRef = db.collection("emergency_alerts").document();
                alertRef.set(alertData).get();
                String alertId = alertRef.getId();

                // 3) Find eligible donors
                QuerySnapshot usersSnapshot = db.collection("users")
                        .whereEqualTo("blood_group", bloodGroup)
                        .whereEqualTo("status", "APPROVED")
                        .get().get();

                JSONArray notifiedDevices = new JSONArray();
                List<String> fcmTokens = new ArrayList<>();
                LocalDateTime threeMonthsAgo = LocalDateTime.now().minusMonths(3);
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

                for (QueryDocumentSnapshot userDoc : usersSnapshot.getDocuments()) {
                    String userId = userDoc.getId();

                    // Check device token
                    DocumentSnapshot tokenDoc = db.collection("device_tokens").document(userId).get().get();
                    if (!tokenDoc.exists()) continue;

                    Double devLat = tokenDoc.getDouble("last_latitude");
                    Double devLng = tokenDoc.getDouble("last_longitude");
                    if (devLat == null || devLng == null) continue;

                    // Calculate Haversine distance
                    double dLat = Math.toRadians(devLat - bankLat);
                    double dLng = Math.toRadians(devLng - bankLng);
                    double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                            Math.cos(Math.toRadians(bankLat)) * Math.cos(Math.toRadians(devLat)) *
                            Math.sin(dLng / 2) * Math.sin(dLng / 2);
                    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                    double distanceKm = 6371 * c;

                    if (distanceKm <= radiusKm) {
                        // Check appointments
                        QuerySnapshot apptSnapshot = db.collection("appointments")
                                .whereEqualTo("donor_id", userId)
                                .whereEqualTo("status", "COMPLETED")
                                .get().get();
                        
                        boolean hasRecent = false;
                        for (QueryDocumentSnapshot appt : apptSnapshot.getDocuments()) {
                            String timeStr = appt.getString("appointment_time");
                            if (timeStr != null && !timeStr.isEmpty()) {
                                try {
                                    LocalDateTime apptTime = LocalDateTime.parse(timeStr, formatter);
                                    if (apptTime.isAfter(threeMonthsAgo)) {
                                        hasRecent = true;
                                        break;
                                    }
                                } catch (Exception ignored) {}
                            }
                        }

                        if (!hasRecent) {
                            String token = tokenDoc.getString("device_token");
                            if (token != null && !token.isEmpty()) {
                                JSONObject dev = new JSONObject();
                                dev.put("userId", userId);
                                dev.put("deviceToken", token);
                                dev.put("platform", tokenDoc.getString("platform"));
                                dev.put("distanceKm", distanceKm);
                                notifiedDevices.put(dev);
                                fcmTokens.add(token);
                            }
                        }
                    }
                }

                // 4) Push notification
                String title = "Emergency need for " + bloodGroup + " blood";
                String bodyText = message != null && !message.isEmpty()
                        ? message
                        : "Nearby blood bank requires " + bloodGroup + " donors urgently.";
                        
                FcmClient.sendEmergencyAlertToDevices(
                        fcmTokens,
                        title,
                        bodyText,
                        alertId,
                        bankIdParam,
                        bloodGroup
                );

                result.put("alertId", alertId);
                result.put("notifiedCount", notifiedDevices.length());
                result.put("devices", notifiedDevices);
                result.put("status", "QUEUED");
                response.setStatus(HttpServletResponse.SC_OK);
                out.print(result.toString());

            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.put("error", "Database error: " + e.getMessage());
                try {
                    response.getWriter().print(result.toString());
                } catch (IOException ignored) {}
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("error", "Invalid numeric parameter");
            try {
                response.getWriter().print(result.toString());
            } catch (IOException ignored) {}
        }
    }
}

