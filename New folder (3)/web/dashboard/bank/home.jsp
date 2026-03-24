<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,com.bloodbank.util.DBConnectionUtil" %>
<%
    Long userId = (Long) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null || role == null || !"BANK".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bank Dashboard | LifeFlow</title>
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
            <span class="badge bg-danger ms-2 fs-6 rounded-pill" style="font-family:'Inter'; letter-spacing:0">Bank</span>
        </a>
        <ul class="nav flex-column gap-2 mt-4">
            <li><a href="<%=request.getContextPath()%>/dashboard/bank/home.jsp" class="nav-link active"><i class="fa-solid fa-calendar-check"></i> Appointments</a></li>
        </ul>
        <div class="mt-auto pt-5 pb-3">
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="btn btn-outline-light btn-sm w-100 rounded-pill"><i class="fa-solid fa-right-from-bracket me-2"></i>Sign Out</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Facility Operations</h2>
                <p class="text-muted">Process incoming donor appointments and accurately track completed donations.</p>
            </div>
            <button class="btn btn-outline-secondary rounded-pill px-4" onclick="window.location.reload()"><i class="fa-solid fa-rotate-right me-2"></i>Refresh Queue</button>
        </div>

        <div class="card card-modern border-0 fade-in-up delay-100 mb-4">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-clipboard-list text-danger me-2"></i> Daily Appointments Queue</h4>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-light">
                            <tr>
                                <th>Booking ID</th>
                                <th>Donor Overview</th>
                                <th>Blood Group</th>
                                <th>Scheduled Time</th>
                                <th class="text-end">Fulfillment Action</th>
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
    psBank = conn.prepareStatement("SELECT id FROM blood_banks WHERE email = (SELECT email FROM users WHERE id = ?)");
    psBank.setLong(1, userId);
    rsBank = psBank.executeQuery();

    long bankId = -1;
    if (rsBank.next()) bankId = rsBank.getLong("id");

    if (bankId == -1) {
%>
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5 text-danger">
                                    <i class="fa-solid fa-circle-exclamation fs-1 mb-3"></i><br>
                                    Bank profile not found or linked. Please contact the administrator.
                                </td>
                            </tr>
<%
    } else {
        psAppt = conn.prepareStatement(
            "SELECT a.id, a.donor_id, u.full_name AS donor_name, u.blood_group, u.phone, a.appointment_time, a.status " +
            "FROM appointments a JOIN users u ON a.donor_id = u.id " +
            "WHERE a.bank_id=? ORDER BY a.status DESC, a.appointment_time ASC"
        );
        psAppt.setLong(1, bankId);
        rs = psAppt.executeQuery();

        while (rs.next()) {
            any = true;
            String st = rs.getString("status");
%>
                            <tr>
                                <td><span class="text-muted fw-bold">#<%= String.format("%05d", rs.getLong("id")) %></span></td>
                                <td>
                                    <div class="fw-bold text-dark"><i class="fa-solid fa-user text-muted me-1"></i> <%= rs.getString("donor_name") %></div>
                                    <div class="text-muted" style="font-size: 0.85rem;"><i class="fa-solid fa-phone me-1"></i> <%= rs.getString("phone") %></div>
                                </td>
                                <td>
                                    <span class="badge badge-soft-danger px-3 shadow-sm" style="font-size: 0.9rem;">
                                        <%= rs.getString("blood_group") %>
                                    </span>
                                </td>
                                <td class="text-muted fw-bold"><i class="fa-regular fa-clock me-1"></i> <%= rs.getTimestamp("appointment_time") %></td>
                                <td class="text-end">
                                    <% if ("PENDING".equals(st)) { %>
                                    <form action="<%= request.getContextPath() %>/CompleteAppointmentServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="appointmentId" value="<%= rs.getLong("id") %>">
                                        <button type="submit" class="btn btn-premium btn-sm rounded-pill px-3 shadow-sm">
                                            <i class="fa-solid fa-check me-1"></i> Mark Donated
                                        </button>
                                    </form>
                                    <% } else { %>
                                        <span class="badge bg-success rounded-pill px-3 fs-6"><i class="fa-solid fa-check-double me-1"></i> Completed</span>
                                    <% } %>
                                </td>
                            </tr>
<%
        }
        if (!any) {
%>
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5">
                                    <i class="fa-solid fa-calendar-xmark fs-1 text-light mb-3"></i><br>
                                    No incoming appointments found for this facility.
                                </td>
                            </tr>
<%
        }
    }
} catch (Exception e) {
%>
                            <tr>
                                <td colspan="5" class="text-danger py-4 text-center">
                                    <strong>Database Error:</strong> <%= e.getMessage() %>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>