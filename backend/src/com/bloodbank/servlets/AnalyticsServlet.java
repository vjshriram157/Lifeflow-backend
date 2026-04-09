package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
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
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * JSON analytics/heatmap API for dashboards.
 *
 * Usage:
 *   /api/analytics?metric=donationsByMonth
 *   /api/analytics?metric=heatmapDemand
 */
@WebServlet(name = "AnalyticsServlet", urlPatterns = {"/api/analytics"})
public class AnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String metric = request.getParameter("metric");
        if (metric == null || metric.isEmpty()) {
            metric = "donationsByMonth";
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject result = new JSONObject();

        try (PrintWriter out = response.getWriter()) {
            Firestore db = FirebaseConfig.getFirestore();

            if ("donationsByMonth".equalsIgnoreCase(metric)) {
                result.put("metric", "donationsByMonth");
                result.put("data", getDonationsByMonth(db));
            } else if ("heatmapDemand".equalsIgnoreCase(metric)) {
                result.put("metric", "heatmapDemand");
                result.put("points", getDemandHeatmap(db));
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("error", "Unknown metric");
                out.print(result.toString());
                return;
            }

            out.print(result.toString());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("error", "Database error: " + e.getMessage());
            try {
                response.getWriter().print(result.toString());
            } catch (IOException ignored) {}
        }
    }

    private JSONArray getDonationsByMonth(Firestore db) throws InterruptedException, ExecutionException {
        // Fetch all completed appointments
        QuerySnapshot apptsSnapshot = db.collection("appointments").whereEqualTo("status", "COMPLETED").get().get();
        // Fetch all users to map donor_id -> blood_group
        QuerySnapshot usersSnapshot = db.collection("users").get().get();
        
        Map<String, String> userBloodGroupMap = new HashMap<>();
        for (QueryDocumentSnapshot doc : usersSnapshot.getDocuments()) {
            userBloodGroupMap.put(doc.getId(), doc.getString("blood_group"));
        }

        // Map: Year-Month-BloodGroup -> Count
        Map<String, Integer> counts = new HashMap<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        for (QueryDocumentSnapshot doc : apptsSnapshot.getDocuments()) {
            String donorId = doc.getString("donor_id");
            String bg = userBloodGroupMap.getOrDefault(donorId, "Unknown");
            
            String timeStr = doc.getString("appointment_time");
            if (timeStr == null || timeStr.isEmpty()) continue;
            
            try {
                LocalDateTime dateTime = LocalDateTime.parse(timeStr, formatter);
                int year = dateTime.getYear();
                int month = dateTime.getMonthValue();
                
                String key = year + "-" + month + "-" + bg;
                counts.put(key, counts.getOrDefault(key, 0) + 1);
            } catch (Exception ignored) {
                // Invalid date format
            }
        }

        JSONArray arr = new JSONArray();
        for (Map.Entry<String, Integer> entry : counts.entrySet()) {
            String[] parts = entry.getKey().split("-");
            int year = Integer.parseInt(parts[0]);
            int month = Integer.parseInt(parts[1]);
            String bg = parts[2];
            
            JSONObject row = new JSONObject();
            row.put("year", year);
            row.put("month", month);
            row.put("bloodGroup", bg);
            row.put("count", entry.getValue());
            arr.put(row);
        }
        return arr;
    }

    private JSONArray getDemandHeatmap(Firestore db) throws InterruptedException, ExecutionException {
        // Query approved banks
        QuerySnapshot banksSnapshot = db.collection("blood_banks").whereEqualTo("status", "APPROVED").get().get();
        
        // Map: bank_id -> (lat, lng, shortage)
        class BankPoint {
            Double lat;
            Double lng;
            double shortage = 0;
            BankPoint(Double lat, Double lng) { this.lat = lat; this.lng = lng; }
        }
        
        Map<String, BankPoint> bankCoords = new HashMap<>();
        for (QueryDocumentSnapshot doc : banksSnapshot.getDocuments()) {
            Double lat = doc.getDouble("latitude");
            Double lng = doc.getDouble("longitude");
            if (lat != null && lng != null) {
                bankCoords.put(doc.getId(), new BankPoint(lat, lng));
            }
        }
        
        // Query blood stock
        QuerySnapshot stockSnapshot = db.collection("blood_stock").get().get();
        for (QueryDocumentSnapshot doc : stockSnapshot.getDocuments()) {
            String bankId = doc.getString("blood_bank_id");
            if (bankId != null && bankCoords.containsKey(bankId)) {
                Long unitsLong = doc.getLong("units");
                long units = unitsLong != null ? unitsLong : 0;
                
                long shortage = Math.max(0, 5 - units);
                bankCoords.get(bankId).shortage += shortage;
            }
        }
        
        JSONArray arr = new JSONArray();
        for (BankPoint bp : bankCoords.values()) {
            if (bp.shortage > 0) {
                JSONObject point = new JSONObject();
                point.put("lat", bp.lat);
                point.put("lng", bp.lng);
                point.put("weight", bp.shortage);
                arr.put(point);
            }
        }
        
        return arr;
    }
}

