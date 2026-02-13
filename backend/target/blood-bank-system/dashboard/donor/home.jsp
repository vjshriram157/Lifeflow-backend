<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,com.bloodbank.util.DBConnectionUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Donor Dashboard | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f1f5f9; }
        .card-elevated {
            border-radius: 1.25rem;
            border: none;
            box-shadow: 0 18px 45px rgba(15, 23, 42, 0.18);
        }
    </style>
</head>
<body>

<%
    Long userId = (Long) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (userId == null || role == null || !"DONOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">LifeFlow Donor</a>
    </div>
</nav>

<div class="container mb-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <div class="card card-elevated mb-4">
                <div class="card-body p-4">

                    <!-- 🔥 FIXED BOOK APPOINTMENT BUTTON -->
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h1 class="h4 mb-0">Your Donation History</h1>

                        <a href="<%= request.getContextPath() %>/BookAppointmentServlet"
                           class="btn btn-primary btn-sm">
                            + Book Appointment
                        </a>
                    </div>

                    <p class="text-muted mb-4" style="font-size: 0.9rem;">
                        View your past appointments. Once an appointment is marked as completed,
                        you can download a verified donation certificate.
                    </p>

                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Date & Time</th>
                                <th>Blood Bank</th>
                                <th>City</th>
                                <th>Status</th>
                                <th class="text-center">Certificate</th>
                            </tr>
                            </thead>
                            <tbody>

<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean any = false;

    try {
        conn = DBConnectionUtil.getConnection();

        String sql = "SELECT a.id, a.appointment_time, a.status, " +
                     "u.full_name AS bank_name " +
                     "FROM appointments a " +
                     "JOIN users u ON u.id = a.bank_id " +
                     "WHERE a.donor_id = ? " +
                     "ORDER BY a.appointment_time DESC";

        ps = conn.prepareStatement(sql);
        ps.setLong(1, userId);
        rs = ps.executeQuery();

        while (rs.next()) {
            any = true;
%>
                            <tr>
                                <td><%= rs.getTimestamp("appointment_time") %></td>
                                <td><%= rs.getString("bank_name") %></td>
                                <td>-</td>
                                <td>
                                    <%
                                        String st = rs.getString("status");
                                        String badgeClass = "secondary";
                                        if ("COMPLETED".equalsIgnoreCase(st)) badgeClass = "success";
                                        else if ("CONFIRMED".equalsIgnoreCase(st)) badgeClass = "primary";
                                        else if ("PENDING".equalsIgnoreCase(st)) badgeClass = "warning";
                                    %>
                                    <span class="badge bg-<%= badgeClass %>"><%= st %></span>
                                </td>
                                <td class="text-center">
                                    <%
                                        long appointmentId = rs.getLong("id");
                                        if ("COMPLETED".equalsIgnoreCase(st)) {
                                    %>
                                    <a class="btn btn-sm btn-outline-primary"
                                       href="<%= request.getContextPath() %>/certificate?appointmentId=<%= appointmentId %>"
                                       target="_blank">
                                        Download Certificate
                                    </a>
                                    <%
                                        } else {
                                    %>
                                    <span class="text-muted" style="font-size: 0.8rem;">
                                        Available after completion
                                    </span>
                                    <%
                                        }
                                    %>
                                </td>
                            </tr>
<%
        }

        if (!any) {
%>
                            <tr>
                                <td colspan="5" class="text-center text-muted py-4">
                                    No appointments found yet.
                                </td>
                            </tr>
<%
        }

    } catch (Exception e) {
%>
                            <tr>
                                <td colspan="5" class="text-danger py-4">
                                    Error loading appointments
                                </td>
                            </tr>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
