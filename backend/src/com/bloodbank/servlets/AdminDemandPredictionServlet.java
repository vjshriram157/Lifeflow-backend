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

@WebServlet(name = "AdminDemandPredictionServlet", urlPatterns = {"/api/demand-prediction"})
public class AdminDemandPredictionServlet extends HttpServlet {

    private static final int WINDOW_DAYS = 30;
    private static final int HORIZON_DAYS = 7;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bankIdParam = request.getParameter("bankId");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject result = new JSONObject();
        result.put("horizonDays", HORIZON_DAYS);

        try (PrintWriter out = response.getWriter()) {
            Firestore db = FirebaseConfig.getFirestore();

            // Fetch users for blood group lookup
            QuerySnapshot usersSnapshot = db.collection("users").get().get();
            Map<String, String> userBloodGroupMap = new HashMap<>();
            for (QueryDocumentSnapshot doc : usersSnapshot.getDocuments()) {
                userBloodGroupMap.put(doc.getId(), doc.getString("blood_group"));
            }

            // Fetch completed appointments
            QuerySnapshot apptsSnapshot = db.collection("appointments").whereEqualTo("status", "COMPLETED").get().get();

            LocalDateTime windowStart = LocalDateTime.now().minusDays(WINDOW_DAYS);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

            // Aggregation map: bankId|bloodGroup -> recentCount
            Map<String, Integer> aggregation = new HashMap<>();

            for (QueryDocumentSnapshot doc : apptsSnapshot.getDocuments()) {
                String bId = doc.getString("bank_id");
                
                if (bankIdParam != null && !bankIdParam.trim().isEmpty() && !bankIdParam.equals(bId)) {
                    continue;
                }

                String donorId = doc.getString("donor_id");
                String bGroup = userBloodGroupMap.getOrDefault(donorId, "Unknown");
                String timeStr = doc.getString("appointment_time");

                if (timeStr == null || timeStr.isEmpty()) continue;

                try {
                    LocalDateTime apptTime = LocalDateTime.parse(timeStr, formatter);
                    if (apptTime.isAfter(windowStart)) {
                        String key = bId + "|" + bGroup;
                        aggregation.put(key, aggregation.getOrDefault(key, 0) + 1);
                    }
                } catch (Exception ignored) {}
            }

            // Fetch current stock mapped by bankId|bloodGroup
            QuerySnapshot stockSnapshot = db.collection("blood_stock").get().get();
            Map<String, Long> stockMap = new HashMap<>();
            for (QueryDocumentSnapshot doc : stockSnapshot.getDocuments()) {
                String sBankId = doc.getString("blood_bank_id");
                String sGroup = doc.getString("blood_group");
                Long units = doc.getLong("units");
                if (units == null) units = 0L;
                stockMap.put(sBankId + "|" + sGroup, units);
            }

            JSONArray arr = new JSONArray();

            for (Map.Entry<String, Integer> entry : aggregation.entrySet()) {
                String[] parts = entry.getKey().split("\\|");
                String bId = parts[0];
                String bGroup = parts[1];
                int recentCount = entry.getValue();

                double dailyAvg = (double) recentCount / WINDOW_DAYS;
                int forecastUnits = (int) Math.round(dailyAvg * HORIZON_DAYS);
                long currentStock = stockMap.getOrDefault(bId + "|" + bGroup, 0L);

                JSONObject row = new JSONObject();
                row.put("bankId", bId);
                row.put("bloodGroup", bGroup);
                row.put("dailyAvg", dailyAvg);
                row.put("forecastUnits", forecastUnits);
                row.put("currentStock", currentStock);
                arr.put(row);
            }

            result.put("predictions", arr);
            out.print(result.toString());

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("error", "Database error: " + e.getMessage());
            try {
                response.getWriter().print(result.toString());
            } catch (IOException ignored) {}
        }
    }
}

