<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,com.bloodbank.util.DBConnectionUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Blood Bank Dashboard | LifeFlow</title>
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

    if (userId == null || role == null || !"BANK".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">LifeFlow Blood Bank</a>
        <span class="navbar-text">Bank Dashboard</span>
    </div>
</nav>

<div class="container mb-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">

            <div class="card card-elevated mb-4">
                <div class="card-body p-4">
                    <h1 class="h4 mb-3">Welcome to Blood Bank Dashboard</h1>
                    <p class="text-muted mb-4" style="font-size: 0.9rem;">
                        Manage donor appointments and mark completed donations.
                    </p>

                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Appointment ID</th>
                                <th>Donor ID</th>
                                <th>Date & Time</th>
                                <th>Status / Action</th>
                            </tr>
                            </thead>
                            <tbody>

<%
    Connection conn = null;
    PreparedStatement psBank = null;
    PreparedStatement psAppt = null;
    ResultSet rsBank = null;
    ResultSet rs = null;
    boolean any = false;

    try {
        conn = DBConnectionUtil.getConnection();

        psBank = conn.prepareStatement(
            "SELECT id FROM blood_banks WHERE email = (SELECT email FROM users WHERE id = ?)"
        );
        psBank.setLong(1, userId);
        rsBank = psBank.executeQuery();

        long bankId = -1;
        if (rsBank.next()) bankId = rsBank.getLong("id");

        if (bankId == -1) {
%>
                            <tr>
                                <td colspan="4" class="text-center text-muted py-4">
                                    Bank profile not found.
                                </td>
                            </tr>
<%
        } else {
            psAppt = conn.prepareStatement(
                "SELECT id, donor_id, appointment_time, status " +
                "FROM appointments WHERE bank_id=? ORDER BY appointment_time DESC"
            );
            psAppt.setLong(1, bankId);
            rs = psAppt.executeQuery();

            while (rs.next()) {
                any = true;
                String st = rs.getString("status");
                String badge = "secondary";
                if ("COMPLETED".equals(st)) badge = "success";
                else if ("PENDING".equals(st)) badge = "warning";
%>
                            <tr>
                                <td><%= rs.getLong("id") %></td>
                                <td><%= rs.getLong("donor_id") %></td>
                                <td><%= rs.getTimestamp("appointment_time") %></td>
                                <td>

                                    <% if ("PENDING".equals(st)) { %>

                                        <span class="badge bg-warning">PENDING</span>

                                        <form action="<%= request.getContextPath() %>/CompleteAppointmentServlet"
                                              method="post"
                                              style="display:inline;">
                                            <input type="hidden"
                                                   name="appointmentId"
                                                   value="<%= rs.getLong("id") %>">
                                            <button type="submit"
                                                    class="btn btn-sm btn-success ms-2">
                                                Mark as Completed
                                            </button>
                                        </form>

                                    <% } else { %>

                                        <span class="badge bg-success">COMPLETED</span>

                                    <% } %>

                                </td>
                            </tr>
<%
            }

            if (!any) {
%>
                            <tr>
                                <td colspan="4" class="text-center text-muted py-4">
                                    No appointments found.
                                </td>
                            </tr>
<%
            }
        }
    } catch (Exception e) {
%>
                            <tr>
                                <td colspan="4" class="text-danger py-4">
                                    <%= e.getMessage() %>
                                </td>
                            </tr>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (rsBank != null) rsBank.close(); } catch (Exception e) {}
        try { if (psAppt != null) psAppt.close(); } catch (Exception e) {}
        try { if (psBank != null) psBank.close(); } catch (Exception e) {}
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
