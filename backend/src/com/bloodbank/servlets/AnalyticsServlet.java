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

        try (PrintWriter out = response.getWriter();
             Connection conn = DBConnectionUtil.getConnection()) {

            if ("donationsByMonth".equalsIgnoreCase(metric)) {
                result.put("metric", "donationsByMonth");
                result.put("data", getDonationsByMonth(conn));
            } else if ("heatmapDemand".equalsIgnoreCase(metric)) {
                result.put("metric", "heatmapDemand");
                result.put("points", getDemandHeatmap(conn));
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("error", "Unknown metric");
                out.print(result.toString());
                return;
            }

            out.print(result.toString());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("error", "Database error: " + e.getMessage());
            response.getWriter().print(result.toString());
        }
    }

    /**
     * For Chart.js line/bar chart:
     * SELECT YEAR(appointment_time), MONTH(appointment_time), blood_group, COUNT(*)
     * FROM appointments WHERE status = 'COMPLETED'
     * GROUP BY YEAR, MONTH, blood_group
     */
    private JSONArray getDonationsByMonth(Connection conn) throws SQLException {
        String sql = "SELECT YEAR(a.appointment_time) AS yr, MONTH(a.appointment_time) AS mn, " +
                "a.blood_group AS bg, COUNT(*) AS total " +
                "FROM appointments a " +
                "JOIN users u ON u.id = a.donor_id " +
                "WHERE a.status = 'COMPLETED' " +
                "GROUP BY yr, mn, bg " +
                "ORDER BY yr, mn, bg";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        JSONArray arr = new JSONArray();
        while (rs.next()) {
            JSONObject row = new JSONObject();
            row.put("year", rs.getInt("yr"));
            row.put("month", rs.getInt("mn")); // 1-12, map to labels client-side
            row.put("bloodGroup", rs.getString("bg"));
            row.put("count", rs.getInt("total"));
            arr.put(row);
        }
        return arr;
    }

    /**
     * For Google Maps heatmap layer:
     * Return each bank as a point with:
     *   lat, lng, weight = SUM(max(0, safety_stock - units_available)) over all groups.
     */
    private JSONArray getDemandHeatmap(Connection conn) throws SQLException {
        String sql = "SELECT b.latitude, b.longitude, " +
                "SUM(GREATEST(0, s.safety_stock - s.units_available)) AS shortage " +
                "FROM blood_banks b " +
                "JOIN blood_stock s ON s.bank_id = b.id " +
                "WHERE b.status = 'APPROVED' " +
                "GROUP BY b.id, b.latitude, b.longitude";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        JSONArray arr = new JSONArray();
        while (rs.next()) {
            double shortage = rs.getDouble("shortage");
            if (shortage <= 0) {
                continue; // skip banks without shortage to keep heatmap clean
            }
            JSONObject point = new JSONObject();
            point.put("lat", rs.getDouble("latitude"));
            point.put("lng", rs.getDouble("longitude"));
            point.put("weight", shortage);
            arr.put(point);
        }
        return arr;
    }
}

