<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.bloodbank.util.DBConnectionUtil" %>
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
    <title>Emergency Broadcast | Admin | LifeFlow</title>
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
            <li><a href="home.jsp" class="nav-link"><i class="fa-solid fa-border-all"></i> Dashboard</a></li>
            <li><a href="<%=request.getContextPath()%>/adminPendingApprovals.jsp" class="nav-link"><i class="fa-solid fa-user-check"></i> Approvals</a></li>
            <li><a href="emergencyBroadcast.jsp" class="nav-link active"><i class="fa-solid fa-tower-broadcast"></i> Emergencies</a></li>
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
                <h2 class="fw-bold mb-1">Emergency Operations Center</h2>
                <p class="text-muted">Broadcast critical alerts instantly to registered donors within range.</p>
            </div>
        </div>
        
        <div class="card card-modern border-0 mb-4 fade-in-up delay-100">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                    <h4 class="fw-bold mb-0 text-danger"><i class="fa-solid fa-triangle-exclamation me-2"></i> Critical Low Stocks Action Required</h4>
                    <span class="badge badge-soft-danger fs-6 border border-danger">Safety Limit &lt; 5</span>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-light">
                            <tr>
                                <th>Facility Details</th>
                                <th>City / Area</th>
                                <th>Crit. Blood Group</th>
                                <th>Current Stock Vol.</th>
                                <th class="text-end">Rapid Action</th>
                            </tr>
                        </thead>
                        <tbody>

<%
    boolean any = false;
    try {
        Connection conn = DBConnectionUtil.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT b.id AS bank_id, b.bank_name, b.city, " +
            "s.blood_group, s.units AS units, 5 AS safety_stock " +
            "FROM blood_banks b " +
            "JOIN blood_stock s ON s.blood_bank_id = b.id " +
            "WHERE b.status='APPROVED' AND s.units < 5"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            any = true;
%>
                            <tr>
                                <td>
                                    <div class="fw-bold text-dark"><%= rs.getString("bank_name") %></div>
                                </td>
                                <td class="text-muted"><i class="fa-solid fa-location-dot me-1 text-danger"></i> <%= rs.getString("city") %></td>
                                <td>
                                    <span class="badge bg-danger rounded-pill px-3 fs-6 shadow-sm"><i class="fa-solid fa-droplet me-1"></i> <%= rs.getString("blood_group") %></span>
                                </td>
                                <td>
                                    <h5 class="fw-bold mb-0 text-dark">
                                        <%= rs.getInt("units") %> <span class="text-muted fs-6 fw-normal">/ <%= rs.getInt("safety_stock") %> Required</span>
                                    </h5>
                                </td>
                                <td class="text-end">
                                    <button class="btn btn-premium btn-sm rounded-pill px-4 fw-bold shadow-sm"
                                            onclick="sendBroadcast('<%= rs.getString("bank_name") %>', '<%= rs.getString("blood_group") %>')">
                                        <i class="fa-solid fa-podcast me-1"></i> Dispatch Request
                                    </button>
                                </td>
                            </tr>
<%
        }
        rs.close(); ps.close(); conn.close();
    } catch (Exception e) {
        out.print("<tr><td colspan='5' class='text-danger text-center py-5'><strong>Error loading critical data:</strong> " + e.getMessage() + "</td></tr>");
    }

    if (!any) {
%>
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5">
                                    <i class="fa-solid fa-shield-heart fs-1 text-success mb-3 opacity-50"></i>
                                    <h5 class="fw-bold">All Supplies Stable</h5>
                                    <p class="mb-0">No blood groups are reporting levels beneath the safety stock threshold.</p>
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
</div>

<script>
    function sendBroadcast(bankName, bloodGroup) {
        alert(
            "Emergency Action Activated!\n\n" +
            "Broadcasting a high-priority push notification for " + bloodGroup + " donors near " + bankName + ".\n" +
            "The LifeFlow network is dispatching notifications now."
        );
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>