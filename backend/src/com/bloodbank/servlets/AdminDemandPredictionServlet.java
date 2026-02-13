package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;
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

/**
 * Simple moving-average based demand prediction stub.
 *
 * Endpoint: GET /api/demand-prediction
 * Optional params:
 *   bankId (long) – if provided, restrict to a single bank, else all.
 *
 * Response:
 * {
 *   "horizonDays": 7,
 *   "predictions": [
 *     { "bankId": 1, "bloodGroup": "O+", "forecastUnits": 15, "dailyAvg": 2.1, "currentStock": 8 },
 *     ...
 *   ]
 * }
 */
@WebServlet(name = "AdminDemandPredictionServlet", urlPatterns = {"/api/demand-prediction"})
public class AdminDemandPredictionServlet extends HttpServlet {

    private static final int WINDOW_DAYS = 30;
    private static final int HORIZON_DAYS = 7;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bankIdParam = request.getParameter("bankId");
        Long bankId = null;
        if (bankIdParam != null && !bankIdParam.isEmpty()) {
            try {
                bankId = Long.parseLong(bankIdParam);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid bankId");
                return;
            }
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject result = new JSONObject();
        result.put("horizonDays", HORIZON_DAYS);

        try (PrintWriter out = response.getWriter();
             Connection conn = DBConnectionUtil.getConnection()) {

            StringBuilder sql = new StringBuilder();
            sql.append("SELECT a.bank_id, u.blood_group, ");
            sql.append("COUNT(*) / ? AS daily_avg, ");
            sql.append("COALESCE(SUM(CASE WHEN a.appointment_time >= DATE_SUB(CURDATE(), INTERVAL ? DAY) THEN 1 ELSE 0 END), 0) AS recent_count ");
            sql.append("FROM appointments a ");
            sql.append("JOIN users u ON u.id = a.donor_id ");
            sql.append("WHERE a.status = 'COMPLETED' ");
            sql.append("AND a.appointment_time >= DATE_SUB(CURDATE(), INTERVAL ? DAY) ");
            if (bankId != null) {
                sql.append("AND a.bank_id = ? ");
            }
            sql.append("GROUP BY a.bank_id, u.blood_group");

            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            ps.setInt(idx++, WINDOW_DAYS);
            ps.setInt(idx++, WINDOW_DAYS);
            ps.setInt(idx++, WINDOW_DAYS);
            if (bankId != null) {
                ps.setLong(idx++, bankId);
            }

            ResultSet rs = ps.executeQuery();
            JSONArray arr = new JSONArray();

            while (rs.next()) {
                long bId = rs.getLong("bank_id");
                String bloodGroup = rs.getString("blood_group");
                double dailyAvg = rs.getDouble("daily_avg");

                // Forecast is daily average * horizon
                int forecastUnits = (int) Math.round(dailyAvg * HORIZON_DAYS);

                // Look up current stock for this bank + group
                int currentStock = 0;
                PreparedStatement psStock = conn.prepareStatement(
                        "SELECT units_available FROM blood_stock WHERE bank_id = ? AND blood_group = ?");
                psStock.setLong(1, bId);
                psStock.setString(2, bloodGroup);
                ResultSet rsStock = psStock.executeQuery();
                if (rsStock.next()) {
                    currentStock = rsStock.getInt("units_available");
                }

                JSONObject row = new JSONObject();
                row.put("bankId", bId);
                row.put("bloodGroup", bloodGroup);
                row.put("dailyAvg", dailyAvg);
                row.put("forecastUnits", forecastUnits);
                row.put("currentStock", currentStock);
                arr.put(row);
            }

            result.put("predictions", arr);
            out.print(result.toString());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("error", "Database error: " + e.getMessage());
            response.getWriter().print(result.toString());
        }
    }
}

