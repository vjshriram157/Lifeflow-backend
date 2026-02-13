<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.bloodbank.util.DBConnectionUtil" %>

<%
    // Ensure user is logged in and is ADMIN
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Emergency Broadcast | Admin | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { background: #f8fafc; }
        .badge-critical { background-color: #dc2626; }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-danger mb-4">
    <div class="container-fluid">
        <a class="navbar-brand"
           href="<%= request.getContextPath() %>/dashboard/admin/home.jsp">
            LifeFlow Admin – Emergency Center
        </a>
    </div>
</nav>

<div class="container mb-5">
    <h1 class="h4 mb-3">Critical Low Stocks</h1>
    <p class="text-muted mb-4" style="font-size:0.9rem;">
        Blood groups below safety stock at approved blood banks.
    </p>

    <div class="card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Blood Bank</th>
                            <th>City</th>
                            <th>Blood Group</th>
                            <th>Units / Safety</th>
                            <th class="text-center">Broadcast</th>
                        </tr>
                    </thead>
                    <tbody>

<%
    boolean any = false;
    try {
        Connection conn = DBConnectionUtil.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT b.id AS bank_id, b.bank_name, b.city, " +
            "s.blood_group, s.units_available, s.safety_stock " +
            "FROM blood_banks b " +
            "JOIN blood_stock s ON s.bank_id = b.id " +
            "WHERE b.status='APPROVED' AND s.units_available < s.safety_stock"
        );

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            any = true;
%>
                        <tr>
                            <td><%= rs.getString("bank_name") %></td>
                            <td><%= rs.getString("city") %></td>
                            <td>
                                <span class="badge badge-critical text-white">
                                    <%= rs.getString("blood_group") %>
                                </span>
                            </td>
                            <td>
                                <strong><%= rs.getInt("units_available") %></strong>
                                <span class="text-muted">
                                    / <%= rs.getInt("safety_stock") %>
                                </span>
                            </td>
                            <td class="text-center">
                                <button class="btn btn-sm btn-danger"
                                        onclick="sendBroadcast('<%= rs.getString("bank_name") %>',
                                                               '<%= rs.getString("blood_group") %>')">
                                    Emergency Broadcast
                                </button>
                            </td>
                        </tr>
<%
        }

        rs.close();
        ps.close();
        conn.close();

    } catch (Exception e) {
%>
                        <tr>
                            <td colspan="5" class="text-danger text-center py-4">
                                Error loading data: <%= e.getMessage() %>
                            </td>
                        </tr>
<%
    }

    if (!any) {
%>
                        <tr>
                            <td colspan="5" class="text-center text-muted py-4">
                                No blood groups are currently below safety stock.
                            </td>
                        </tr>
<%
    }
%>

                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    function sendBroadcast(bankName, bloodGroup) {
        alert(
            "Emergency Broadcast Sent!\n\n" +
            "Blood Bank: " + bankName + "\n" +
            "Blood Group: " + bloodGroup + "\n\n" +
            "Targeted donors will be notified."
        );
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
