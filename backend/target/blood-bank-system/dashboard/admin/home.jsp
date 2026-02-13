<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,com.bloodbank.util.DBConnectionUtil"%>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int totalDonors = 0;
    int totalBanks = 0;
    int pendingApprovals = 0;

    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    try {
        conn = DBConnectionUtil.getConnection();
        st = conn.createStatement();

        rs = st.executeQuery(
            "SELECT COUNT(*) FROM users WHERE role='DONOR' AND status='APPROVED'");
        if (rs.next()) totalDonors = rs.getInt(1);

        rs = st.executeQuery(
            "SELECT COUNT(*) FROM blood_banks WHERE status='APPROVED'");
        if (rs.next()) totalBanks = rs.getInt(1);

        rs = st.executeQuery(
            "SELECT COUNT(*) FROM users WHERE status='PENDING'");
        if (rs.next()) pendingApprovals = rs.getInt(1);

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e){}
        try { if (st != null) st.close(); } catch(Exception e){}
        try { if (conn != null) conn.close(); } catch(Exception e){}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Dashboard | LifeFlow</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
body { background:#f1f5f9; }
.sidebar { background:#0f172a; color:white; min-height:100vh; width:250px; }
.sidebar .nav-link { color:#94a3b8; }
.sidebar .nav-link.active, .sidebar .nav-link:hover {
    background:rgba(255,255,255,.1);
    color:white;
    border-radius:.5rem;
}
.card-stat { border:none; border-radius:1rem; transition:.2s; }
.card-stat:hover { transform:translateY(-5px); }
</style>
</head>

<body>
<div class="d-flex">

<!-- SIDEBAR -->
<div class="sidebar p-3">
    <div class="fs-4 fw-bold text-danger">LifeFlow <span class="badge bg-secondary">Admin</span></div>
    <hr>
    <ul class="nav nav-pills flex-column">
        <li><a href="home.jsp" class="nav-link active"><i class="fas fa-home me-2"></i>Dashboard</a></li>
        <li><a href="<%=request.getContextPath()%>/adminPendingApprovals.jsp" class="nav-link">
            <i class="fas fa-user-check me-2"></i>Approvals</a></li>
        <li><a href="emergencyBroadcast.jsp" class="nav-link">
            <i class="fas fa-broadcast-tower me-2"></i>Emergency Alert</a></li>
    </ul>
</div>

<!-- MAIN CONTENT -->
<div class="container-fluid p-4">
<h2 class="mb-4">Dashboard Overview</h2>

<!-- STATS -->
<div class="row g-4 mb-4">
    <div class="col-md-3">
        <div class="card card-stat bg-white shadow-sm">
            <div class="card-body">
                <h6 class="text-muted text-uppercase">Total Donors</h6>
                <h2 class="fw-bold"><%= totalDonors %></h2>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card card-stat bg-white shadow-sm">
            <div class="card-body">
                <h6 class="text-muted text-uppercase">Blood Banks</h6>
                <h2 class="fw-bold"><%= totalBanks %></h2>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card card-stat bg-white shadow-sm">
            <div class="card-body">
                <h6 class="text-muted text-uppercase">Pending Approvals</h6>
                <h2 class="fw-bold text-warning"><%= pendingApprovals %></h2>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card card-stat bg-white shadow-sm">
            <div class="card-body">
                <h6 class="text-muted text-uppercase">Emergency Alerts</h6>
                <h2 class="fw-bold text-danger">0</h2>
            </div>
        </div>
    </div>
</div>

<!-- RECENT ACTIVITY -->
<div class="row">
<div class="col-md-8">
<div class="card shadow-sm border-0">
<div class="card-header bg-white"><h5 class="mb-0">Recent Activity</h5></div>
<div class="card-body p-0">
<div class="list-group list-group-flush">

<%
Connection c2=null;
PreparedStatement ps2=null;
ResultSet rs2=null;

try {
    c2 = DBConnectionUtil.getConnection();
    ps2 = c2.prepareStatement(
        "SELECT full_name, role, status, created_at " +
        "FROM users ORDER BY created_at DESC LIMIT 5"
    );
    rs2 = ps2.executeQuery();

    while (rs2.next()) {
%>
<div class="list-group-item px-4 py-3">
    <div class="d-flex justify-content-between">
        <h6 class="mb-1">
            <%= rs2.getString("full_name") %> (<%= rs2.getString("role") %>)
        </h6>
        <small class="text-muted"><%= rs2.getTimestamp("created_at") %></small>
    </div>
    <small class="text-muted">Status: <%= rs2.getString("status") %></small>
</div>
<%
    }
} catch(Exception e) {
%>
<div class="list-group-item text-danger px-4 py-3">
    Unable to load activity
</div>
<%
} finally {
    try { if (rs2!=null) rs2.close(); } catch(Exception e){}
    try { if (ps2!=null) ps2.close(); } catch(Exception e){}
    try { if (c2!=null) c2.close(); } catch(Exception e){}
}
%>

</div>
</div>
</div>
</div>

<!-- QUICK ACTIONS -->
<div class="col-md-4">
<div class="card text-white shadow-sm"
     style="background:linear-gradient(135deg,#ef4444,#b91c1c)">
<div class="card-body">
<h5><i class="fas fa-bolt me-2"></i> Quick Actions</h5>
<hr>
<a href="<%=request.getContextPath()%>/adminPendingApprovals.jsp"
   class="btn btn-light text-danger w-100 mb-2">
   Verify Users
</a>

<a href="emergencyBroadcast.jsp"
   class="btn btn-outline-light w-100 mb-2">
   Broadcast Alert
</a>

<a href="<%=request.getContextPath()%>/ExportReport"
   class="btn btn-outline-light w-100">
   Export Reports
</a>
</div>
</div>
</div>
</div>

</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
