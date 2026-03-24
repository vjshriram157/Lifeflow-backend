package com.bloodbank.servlets;

import com.bloodbank.util.DBConnectionUtil;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "BloodBankLocatorServlet", urlPatterns = {"/api/locator"})
public class BloodBankLocatorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String latParam = request.getParameter("lat");
        String lngParam = request.getParameter("lng");
        String radiusParam = request.getParameter("radiusKm");
        String cityParam = request.getParameter("city");
        String pincodeParam = request.getParameter("pincode");

        double lat = 0.0;
        double lng = 0.0;
        boolean coordinatesFound = false;

        // 1. Try explicit coordinates first
        if (latParam != null && lngParam != null) {
            try {
                lat = Double.parseDouble(latParam);
                lng = Double.parseDouble(lngParam);
                coordinatesFound = true;
            } catch (NumberFormatException e) {
                // Ignore, try geocoding
            }
        }

        // 2. If no coords, try geocoding city/pincode
        if (!coordinatesFound) {
            String query = null;
            if (cityParam != null && !cityParam.trim().isEmpty()) {
                query = cityParam;
                if (pincodeParam != null && !pincodeParam.trim().isEmpty()) {
                    query += ", " + pincodeParam;
                }
            } else if (pincodeParam != null && !pincodeParam.trim().isEmpty()) {
                query = pincodeParam;
            }

            if (query != null) {
                double[] geocoded = geocodeAddress(query);
                if (geocoded != null) {
                    lat = geocoded[0];
                    lng = geocoded[1];
                    coordinatesFound = true;
                }
            }
        }

        if (!coordinatesFound) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Location not found or invalid coordinates provided.\"}");
            return;
        }

        double radiusKm = 25.0;
        try {
            if (radiusParam != null) {
                radiusKm = Double.parseDouble(radiusParam);
            }
        } catch (NumberFormatException e) {
            // Default 25
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

     String sql =
    "SELECT b.id, b.bank_name, b.city, " +
    "       b.latitude, b.longitude, " +
    "       ( 6371 * ACOS( " +
    "           LEAST(1, GREATEST(-1, " +
    "               COS(RADIANS(?)) * COS(RADIANS(b.latitude)) * " +
    "               COS(RADIANS(b.longitude) - RADIANS(?)) + " +
    "               SIN(RADIANS(?)) * SIN(RADIANS(b.latitude)) " +
    "           )) " +
    "       ) ) AS distance_km " +
    "FROM blood_banks b " +
    "WHERE b.status = 'APPROVED' " +
    "AND b.latitude IS NOT NULL " +
    "AND b.longitude IS NOT NULL " +
    "HAVING distance_km < ? " +
    "ORDER BY distance_km " +
    "LIMIT 20";


        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDouble(1, lat);
            ps.setDouble(2, lng);
            ps.setDouble(3, lat);
            ps.setDouble(4, radiusKm);

            ResultSet rs = ps.executeQuery();
            
            JSONObject result = new JSONObject();
            result.put("centerLat", lat);
            result.put("centerLng", lng);
            
            JSONArray banksArr = new JSONArray();
            while (rs.next()) {
                JSONObject bank = new JSONObject();
                bank.put("id", rs.getLong("id"));
                bank.put("name", rs.getString("bank_name"));
                bank.put("city", rs.getString("city"));
                bank.put("latitude", rs.getDouble("latitude"));
                bank.put("longitude", rs.getDouble("longitude"));
                bank.put("distanceKm", rs.getDouble("distance_km"));
                banksArr.put(bank);
            }
            result.put("banks", banksArr);

            PrintWriter out = response.getWriter();
            out.print(result.toString());
            out.flush();

        } catch (SQLException e) {
    e.printStackTrace(); // VERY IMPORTANT
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    response.setContentType("application/json");
    response.getWriter().write(
        "{\"error\": \"" + e.getMessage().replace("\"", "'") + "\"}"
    );
}

    }

    private double[] geocodeAddress(String query) {
        // Use OpenStreetMap Nominatim API (Free, requires User-Agent)
        String url;
        try {
            url = "https://nominatim.openstreetmap.org/search?q=" + URLEncoder.encode(query, "UTF-8") + "&format=json&limit=1";
            try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
                HttpGet request = new HttpGet(url);
                request.setHeader("User-Agent", "LifeFlowBloodBank/1.0"); // Nominatim requires User-Agent

                try (CloseableHttpResponse response = httpClient.execute(request)) {
                    if (response.getCode() == 200) {
                        String jsonStr = EntityUtils.toString(response.getEntity());
                        JSONArray jsonArr = new JSONArray(jsonStr);
                        if (jsonArr.length() > 0) {
                            JSONObject loc = jsonArr.getJSONObject(0);
                            double lat = loc.getDouble("lat");
                            double lon = loc.getDouble("lon");
                            return new double[]{lat, lon};
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}

