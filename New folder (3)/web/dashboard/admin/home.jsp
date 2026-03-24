<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,com.bloodbank.util.DBConnectionUtil"%>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int totalDonors = 0, totalBanks = 0, pendingApprovals = 0, activeAlerts = 0;
    Connection conn = null; Statement st = null; ResultSet rs = null;

    try {
        conn = DBConnectionUtil.getConnection();
        st = conn.createStatement();
        rs = st.executeQuery("SELECT COUNT(*) FROM users WHERE role='DONOR' AND status='APPROVED'");
        if (rs.next()) totalDonors = rs.getInt(1);
        rs = st.executeQuery("SELECT COUNT(*) FROM blood_banks WHERE status='APPROVED'");
        if (rs.next()) totalBanks = rs.getInt(1);
        rs = st.executeQuery("SELECT COUNT(*) FROM users WHERE status='PENDING'");
        if (rs.next()) pendingApprovals = rs.getInt(1);
        rs = st.executeQuery("SELECT COUNT(*) FROM emergency_alerts");
        if (rs.next()) activeAlerts = rs.getInt(1);
    } catch (Exception e) {} finally {
        try { if(rs!=null) rs.close(); }catch(Exception e){}
        try { if(st!=null) st.close(); }catch(Exception e){}
        try { if(conn!=null) conn.close(); }catch(Exception e){}
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
<link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>
<body>
<div class="d-flex">

    <!-- SIDEBAR -->
    <div class="sidebar p-4">
        <a href="<%=request.getContextPath()%>/index.jsp" class="brand mb-5 text-decoration-none">
            <i class="fa-solid fa-droplet text-danger"></i> Life<span class="text-white">Flow</span>
            <span class="badge bg-danger ms-2 fs-6 rounded-pill" style="font-family:'Inter'; letter-spacing:0">Admin</span>
        </a>
        <ul class="nav flex-column gap-2 mt-4">
            <li><a href="home.jsp" class="nav-link active"><i class="fa-solid fa-border-all"></i> Dashboard</a></li>
            <li><a href="<%=request.getContextPath()%>/adminPendingApprovals.jsp" class="nav-link"><i class="fa-solid fa-user-check"></i> Approvals</a></li>
            <li><a href="emergencyBroadcast.jsp" class="nav-link"><i class="fa-solid fa-tower-broadcast"></i> Emergencies</a></li>
            <li><a href="analytics.jsp" class="nav-link"><i class="fa-solid fa-chart-line"></i> Analytics</a></li>
        </ul>
        <div class="mt-auto pt-5 pb-3">
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="btn btn-outline-light btn-sm w-100 rounded-pill"><i class="fa-solid fa-right-from-bracket me-2"></i>Sign Out</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Overview Dashboard <span class="badge badge-soft-danger align-middle fs-6">Live</span></h2>
                <p class="text-muted">Welcome back, Administrator. Here's what's happening today.</p>
            </div>
        </div>

        <!-- STATS -->
        <div class="row g-4 mb-5 fade-in-up delay-100">
            <div class="col-md-3">
                <div class="card card-modern h-100">
                    <div class="card-body p-4 d-flex align-items-center gap-3">
                        <div class="bg-primary bg-opacity-10 text-primary p-3 rounded-circle fs-3"><i class="fa-solid fa-users"></i></div>
                        <div>
                            <div class="text-muted text-uppercase fw-bold" style="font-size:0.75rem; letter-spacing:1px">Total Donors</div>
                            <h2 class="fw-bold mb-0 text-dark"><%= totalDonors %></h2>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-modern h-100">
                    <div class="card-body p-4 d-flex align-items-center gap-3">
                        <div class="bg-info bg-opacity-10 text-info p-3 rounded-circle fs-3"><i class="fa-solid fa-hospital"></i></div>
                        <div>
                            <div class="text-muted text-uppercase fw-bold" style="font-size:0.75rem; letter-spacing:1px">Blood Banks</div>
                            <h2 class="fw-bold mb-0 text-dark"><%= totalBanks %></h2>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-modern h-100">
                    <div class="card-body p-4 d-flex align-items-center gap-3">
                        <div class="bg-warning bg-opacity-10 text-warning p-3 rounded-circle fs-3"><i class="fa-solid fa-user-clock"></i></div>
                        <div>
                            <div class="text-muted text-uppercase fw-bold" style="font-size:0.75rem; letter-spacing:1px">Pending Approvals</div>
                            <h2 class="fw-bold mb-0 text-dark"><%= pendingApprovals %></h2>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-modern h-100">
                    <div class="card-body p-4 d-flex align-items-center gap-3">
                        <div class="bg-danger bg-opacity-10 text-danger p-3 rounded-circle fs-3"><i class="fa-solid fa-tower-broadcast"></i></div>
                        <div>
                            <div class="text-muted text-uppercase fw-bold" style="font-size:0.75rem; letter-spacing:1px">Emergency Alerts</div>
                            <h2 class="fw-bold mb-0 text-dark"><%= activeAlerts %></h2>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row fade-in-up delay-200">
            <!-- RECENT ACTIVITY -->
            <div class="col-md-8">
                <div class="card card-modern mb-4">
                    <div class="card-body p-4">
                        <h5 class="fw-bold mb-4"><i class="fa-solid fa-clock-rotate-left text-danger me-2"></i> Latest Registrations</h5>
                        <div class="table-responsive">
                            <table class="table table-modern align-middle mb-0">
                                <thead class="bg-light">
                                    <tr>
                                        <th>User Details</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Registered</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <%
                                Connection c2=null; PreparedStatement ps2=null; ResultSet rs2=null;
                                try {
                                    c2 = DBConnectionUtil.getConnection();
                                    ps2 = c2.prepareStatement("SELECT full_name, role, status, created_at FROM users ORDER BY created_at DESC LIMIT 5");
                                    rs2 = ps2.executeQuery();
                                    while (rs2.next()) {
                                        String stat = rs2.getString("status");
                                        String badgeCls = "badge-soft-success";
                                        if ("PENDING".equals(stat)) badgeCls = "badge-soft-warning";
                                        if ("REJECTED".equals(stat)) badgeCls = "badge-soft-danger";
                                %>
                                    <tr>
                                        <td><div class="fw-bold text-dark"><%= rs2.getString("full_name") %></div></td>
                                        <td><span class="badge badge-soft-info"><%= rs2.getString("role") %></span></td>
                                        <td><span class="badge <%=badgeCls%>"><%= stat %></span></td>
                                        <td class="text-muted" style="font-size:0.85rem;"><i class="fa-regular fa-calendar me-1"></i> <%= rs2.getTimestamp("created_at") %></td>
                                    </tr>
                                <%  }
                                } catch(Exception e) { out.print("<tr><td colspan='4'>Error: "+e.getMessage()+"</td></tr>"); }
                                finally { try{if(rs2!=null)rs2.close();}catch(Exception e){} try{if(ps2!=null)ps2.close();}catch(Exception e){} try{if(c2!=null)c2.close();}catch(Exception e){} }
                                %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- QUICK ACTIONS -->
            <div class="col-md-4">
                <div class="card card-modern bg-danger text-white border-0 overflow-hidden" style="background: linear-gradient(135deg, var(--primary-crimson), var(--primary-dark)) !important;">
                    <div class="card-body p-4 position-relative z-1">
                        <h5 class="fw-bold text-white mb-4"><i class="fa-solid fa-bolt me-2"></i> Quick Actions</h5>
                        <div class="d-flex flex-column gap-3">
                            <a href="<%=request.getContextPath()%>/adminPendingApprovals.jsp" class="btn btn-light text-danger fw-bold rounded-pill p-3 text-start shadow-sm">
                                <i class="fa-solid fa-user-check me-2"></i> Verify Pending Users
                            </a>
                            <a href="emergencyBroadcast.jsp" class="btn btn-outline-light fw-bold rounded-pill p-3 text-start">
                                <i class="fa-solid fa-satellite-dish me-2"></i> Broadcast Emergency Alert
                            </a>
                            <a href="<%=request.getContextPath()%>/ExportReport" class="btn btn-outline-light fw-bold rounded-pill p-3 text-start">
                                <i class="fa-solid fa-file-csv me-2"></i> Export System Report
                            </a>
                        </div>
                    </div>
                    <i class="fa-solid fa-hand-holding-medical position-absolute text-white opacity-10" style="font-size: 15rem; bottom: -2rem; right: -2rem; z-index:0"></i>
                </div>
            </div>
        </div>

    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
