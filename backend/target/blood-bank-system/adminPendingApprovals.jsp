<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.bloodbank.util.DBConnectionUtil" %>

<%
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
    <title>Pending Approvals | LifeFlow Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<nav class="navbar navbar-dark bg-dark mb-4">
    <div class="container-fluid">
        <span class="navbar-brand">LifeFlow – Admin Approvals</span>
        <a href="<%= request.getContextPath() %>/dashboard/admin/home.jsp"
           class="btn btn-outline-light btn-sm">Back</a>
    </div>
</nav>

<div class="container">

    <!-- DONOR APPROVALS -->
    <h4 class="mb-3">Pending Donors</h4>
    <table class="table table-bordered bg-white">
        <thead class="table-light">
        <tr>
            <th>Name</th>
            <th>Blood Group</th>
            <th>City</th>
            <th>Action</th>
        </tr>
        </thead>
        <tbody>

<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnectionUtil.getConnection();
        ps = conn.prepareStatement(
                "SELECT id, full_name, blood_group, city " +
                "FROM users WHERE status='PENDING' AND role='DONOR'");
        rs = ps.executeQuery();

        boolean hasRows = false;

        while (rs.next()) {
            hasRows = true;
%>
        <tr>
            <td><%= rs.getString("full_name") %></td>
            <td><%= rs.getString("blood_group") %></td>
            <td><%= rs.getString("city") %></td>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                    <input type="hidden" name="type" value="user">
                    <input type="hidden" name="id" value="<%= rs.getLong("id") %>">
                    <input type="hidden" name="action" value="approve">
                    <button class="btn btn-success btn-sm">Approve</button>
                </form>

                <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet"
                      class="d-inline ms-1">
                    <input type="hidden" name="type" value="user">
                    <input type="hidden" name="id" value="<%= rs.getLong("id") %>">
                    <input type="hidden" name="action" value="reject">
                    <button class="btn btn-outline-secondary btn-sm">Reject</button>
                </form>
            </td>
        </tr>
<%
        }

        if (!hasRows) {
%>
        <tr>
            <td colspan="4" class="text-center text-muted">No pending donors</td>
        </tr>
<%
        }

    } catch (Exception e) {
%>
        <tr>
            <td colspan="4" class="text-danger">Error: <%= e.getMessage() %></td>
        </tr>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>

        </tbody>
    </table>

    <hr class="my-4">

    <!-- BANK APPROVALS -->
    <h4 class="mb-3">Pending Blood Banks</h4>
    <table class="table table-bordered bg-white">
        <thead class="table-light">
        <tr>
            <th>Name</th>
            <th>City</th>
            <th>Action</th>
        </tr>
        </thead>
        <tbody>

<%
    Connection conn2 = null;
    PreparedStatement ps2 = null;
    ResultSet rs2 = null;

    try {
        conn2 = DBConnectionUtil.getConnection();
        ps2 = conn2.prepareStatement(
                "SELECT id, full_name, city FROM users WHERE status='PENDING' AND role='BANK'");
        rs2 = ps2.executeQuery();

        boolean hasRows2 = false;

        while (rs2.next()) {
            hasRows2 = true;
%>
        <tr>
            <td><%= rs2.getString("full_name") %></td>
            <td><%= rs2.getString("city") %></td>
            <td>
                <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                    <input type="hidden" name="type" value="user">
                    <input type="hidden" name="id" value="<%= rs2.getLong("id") %>">
                    <input type="hidden" name="action" value="approve">
                    <button class="btn btn-success btn-sm">Approve</button>
                </form>

                <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet"
                      class="d-inline ms-1">
                    <input type="hidden" name="type" value="user">
                    <input type="hidden" name="id" value="<%= rs2.getLong("id") %>">
                    <input type="hidden" name="action" value="reject">
                    <button class="btn btn-outline-secondary btn-sm">Reject</button>
                </form>
            </td>
        </tr>
<%
        }

        if (!hasRows2) {
%>
        <tr>
            <td colspan="3" class="text-center text-muted">No pending blood banks</td>
        </tr>
<%
        }

    } catch (Exception e) {
%>
        <tr>
            <td colspan="3" class="text-danger">Error: <%= e.getMessage() %></td>
        </tr>
<%
    } finally {
        try { if (rs2 != null) rs2.close(); } catch (Exception ignored) {}
        try { if (ps2 != null) ps2.close(); } catch (Exception ignored) {}
        try { if (conn2 != null) conn2.close(); } catch (Exception ignored) {}
    }
%>

        </tbody>
    </table>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
