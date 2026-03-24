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
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "AdminApprovalServlet", urlPatterns = {"/AdminApprovalServlet"})
public class AdminApprovalServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔐 Admin session check
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String action = request.getParameter("action"); // approve | reject
        String idParam = request.getParameter("id");

        if (action == null || idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        long userId;
        try {
            userId = Long.parseLong(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID");
            return;
        }

        String newStatus = "approve".equalsIgnoreCase(action) ? "APPROVED" : "REJECTED";

        try (Connection conn = DBConnectionUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                // 1️⃣ Update user status
                PreparedStatement psUpdateUser =
                        conn.prepareStatement("UPDATE users SET status = ? WHERE id = ?");
                psUpdateUser.setString(1, newStatus);
                psUpdateUser.setLong(2, userId);
                psUpdateUser.executeUpdate();

                // 2️⃣ If approved BANK user → create blood bank
                if ("APPROVED".equalsIgnoreCase(newStatus)) {

                    PreparedStatement psFetch =
                            conn.prepareStatement(
                                    "SELECT full_name, role, email, phone, city FROM users WHERE id = ?");
                    psFetch.setLong(1, userId);
                    ResultSet rs = psFetch.executeQuery();

                    if (rs.next()) {
                        String role = rs.getString("role");

                        if ("BANK".equalsIgnoreCase(role)) {
                            String city = rs.getString("city");

                            // 🌍 Auto-geocode bank city
                            double[] coords = geocodeAddress(city);

                            double latitude = coords != null ? coords[0] : 0.0;
                            double longitude = coords != null ? coords[1] : 0.0;

                            PreparedStatement psBank =
                                    conn.prepareStatement(
                                            "INSERT INTO blood_banks " +
                                            "(bank_name, email, phone, city, status, latitude, longitude) " +
                                            "VALUES (?, ?, ?, ?, 'APPROVED', ?, ?)");

                            psBank.setString(1, rs.getString("full_name"));
                            psBank.setString(2, rs.getString("email"));
                            psBank.setString(3, rs.getString("phone"));
                            psBank.setString(4, city);
                            psBank.setDouble(5, latitude);
                            psBank.setDouble(6, longitude);

                            psBank.executeUpdate();
                        }
                    }
                }

                conn.commit();

            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Approval failed: " + e.getMessage()
            );
            return;
        }

        // 🔁 Back to approvals page
        response.sendRedirect(request.getContextPath() + "/adminPendingApprovals.jsp");
    }

    // 🌍 Geocode city using OpenStreetMap (Nominatim)
    private double[] geocodeAddress(String query) {
        try {
            String url =
                    "https://nominatim.openstreetmap.org/search?q=" +
                    URLEncoder.encode(query, "UTF-8") +
                    "&format=json&limit=1";

            try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
                HttpGet request = new HttpGet(url);
                request.setHeader("User-Agent", "LifeFlowBloodBank/1.0");

                try (CloseableHttpResponse response = httpClient.execute(request)) {
                    if (response.getCode() == 200) {
                        String jsonStr = EntityUtils.toString(response.getEntity());
                        JSONArray arr = new JSONArray(jsonStr);
                        if (arr.length() > 0) {
                            JSONObject obj = arr.getJSONObject(0);
                            return new double[]{
                                    obj.getDouble("lat"),
                                    obj.getDouble("lon")
                            };
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
