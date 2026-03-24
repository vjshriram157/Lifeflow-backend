<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,com.bloodbank.util.DBConnectionUtil" %>
<%
    Long userId = (Long) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null || role == null || !"DONOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Donor Dashboard | LifeFlow</title>
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
            <span class="badge bg-danger ms-2 fs-6 rounded-pill" style="font-family:'Inter'; letter-spacing:0">Donor</span>
        </a>
        <ul class="nav flex-column gap-2 mt-4">
            <li><a href="<%=request.getContextPath()%>/dashboard/donor/home.jsp" class="nav-link active"><i class="fa-solid fa-clock-rotate-left"></i> My History</a></li>
            <li><a href="<%=request.getContextPath()%>/BookAppointmentServlet" class="nav-link"><i class="fa-regular fa-calendar-plus"></i> Donate Blood</a></li>
        </ul>
        <div class="mt-auto pt-5 pb-3">
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="btn btn-outline-light btn-sm w-100 rounded-pill"><i class="fa-solid fa-right-from-bracket me-2"></i>Sign Out</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Donor Dashboard</h2>
                <p class="text-muted">Track your life-saving contributions and manage upcoming appointments.</p>
            </div>
            <a href="<%= request.getContextPath() %>/BookAppointmentServlet" class="btn btn-premium rounded-pill px-4 shadow-sm">
                <i class="fa-solid fa-heart-pulse me-2"></i> Book Appointment
            </a>
        </div>

        <div class="card card-modern fade-in-up delay-100 mb-4">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-clock-rotate-left text-danger me-2"></i> Donation History</h4>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-light">
                        <tr>
                            <th>Date & Time</th>
                            <th>Partnering Blood Bank</th>
                            <th>Status</th>
                            <th class="text-center">Recognition</th>
                        </tr>
                        </thead>
                        <tbody>
<%
    Connection conn = null; PreparedStatement ps = null; ResultSet rs = null; boolean any = false;
    try {
        conn = DBConnectionUtil.getConnection();
        String sql = "SELECT a.id, a.appointment_time, a.status, u.full_name AS bank_name " +
                     "FROM appointments a JOIN users u ON u.id = a.bank_id " +
                     "WHERE a.donor_id = ? ORDER BY a.appointment_time DESC";
        ps = conn.prepareStatement(sql);
        ps.setLong(1, userId);
        rs = ps.executeQuery();

        while (rs.next()) {
            any = true;
            String st = rs.getString("status");
            String badgeClass = "secondary";
            if ("COMPLETED".equalsIgnoreCase(st)) badgeClass = "badge-soft-success";
            else if ("CONFIRMED".equalsIgnoreCase(st)) badgeClass = "badge-soft-primary";
            else if ("PENDING".equalsIgnoreCase(st)) badgeClass = "badge-soft-warning";
            else if ("CANCELLED".equalsIgnoreCase(st)) badgeClass = "badge-soft-danger";
%>
                        <tr>
                            <td><div class="fw-bold text-dark"><i class="fa-regular fa-calendar me-2 text-muted"></i><%= rs.getTimestamp("appointment_time") %></div></td>
                            <td class="text-muted"><i class="fa-solid fa-building-user me-1 border p-1 rounded"></i> <%= rs.getString("bank_name") %></td>
                            <td><span class="badge <%= badgeClass %> px-3 rounded-pill fs-6"><%= st %></span></td>
                            <td class="text-center">
                                <% if ("COMPLETED".equalsIgnoreCase(st)) { %>
                                <a class="btn btn-sm btn-outline-danger rounded-pill fw-bold" href="<%= request.getContextPath() %>/certificate?appointmentId=<%= rs.getLong("id") %>" target="_blank">
                                    <i class="fa-solid fa-award me-1"></i> Certificate
                                </a>
                                <% } else { %>
                                <span class="text-muted" style="font-size: 0.8rem;"><i class="fa-solid fa-hourglass-empty me-1"></i> Pending Verification</span>
                                <% } %>
                            </td>
                        </tr>
<%
        }
        if (!any) { out.print("<tr><td colspan='4' class='text-center text-muted py-5'><i class='fa-solid fa-notes-medical fs-1 text-light mb-3'></i><br>No donation appointments recorded on your profile yet.</td></tr>"); }
    } catch (Exception e) { out.print("<tr><td colspan='4' class='text-danger py-4'>Error loading appointments: " + e.getMessage() + "</td></tr>"); }
    finally { try{if(rs!=null)rs.close();}catch(Exception e){} try{if(ps!=null)ps.close();}catch(Exception e){} try{if(conn!=null)conn.close();}catch(Exception e){} }
%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
