<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List" %>

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
            <li><a href="<%=request.getContextPath()%>/dashboard/admin/home.jsp" class="nav-link"><i class="fa-solid fa-border-all"></i> Dashboard</a></li>
            <li><a href="<%=request.getContextPath()%>/adminPendingApprovals.jsp" class="nav-link active"><i class="fa-solid fa-user-check"></i> Approvals</a></li>
            <li><a href="<%=request.getContextPath()%>/dashboard/admin/emergencyBroadcast.jsp" class="nav-link"><i class="fa-solid fa-tower-broadcast"></i> Emergencies</a></li>
            <li><a href="<%=request.getContextPath()%>/dashboard/admin/analytics.jsp" class="nav-link"><i class="fa-solid fa-chart-line"></i> Analytics</a></li>
        </ul>
        <div class="mt-auto pt-5 pb-3">
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="btn btn-outline-light btn-sm w-100 rounded-pill"><i class="fa-solid fa-right-from-bracket me-2"></i>Sign Out</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Verify Pending Registrations</h2>
                <p class="text-muted">Review and approve new donors and blood banks to grant them system access.</p>
            </div>
        </div>

        <!-- DONOR APPROVALS -->
        <div class="card card-modern fade-in-up delay-100 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-users text-danger me-2"></i> Pending Donors</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-light">
                        <tr>
                            <th>Applicant Name</th>
                            <th>Blood Group</th>
                            <th>City/Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> donors = db.collection("users")
                                    .whereEqualTo("status", "PENDING")
                                    .whereEqualTo("role", "DONOR").get().get().getDocuments();
                                boolean hasRows = false;
                                for (QueryDocumentSnapshot doc : donors) {
                                    hasRows = true;
                        %>
                                <tr>
                                    <td><div class="fw-bold text-dark"><%= doc.getString("full_name") %></div></td>
                                    <td><span class="badge badge-soft-danger fs-6"><%= doc.getString("blood_group") %></span></td>
                                    <td class="text-muted"><i class="fa-solid fa-location-dot me-1"></i> <%= doc.getString("city") %></td>
                                    <td class="text-end">
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="approve">
                                            <button class="btn btn-success btn-sm rounded-pill px-3 fw-bold me-2"><i class="fa-solid fa-check me-1"></i> Approve</button>
                                        </form>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="reject">
                                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3 fw-bold"><i class="fa-solid fa-xmark me-1"></i> Reject</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows) { out.print("<tr><td colspan='4' class='text-center text-muted py-5'><i class='fa-solid fa-clipboard-check mb-2 fs-2 text-light'></i><br>No pending donors. All caught up!</td></tr>"); }
                            } catch (Exception e) { out.print("<tr><td colspan='4' class='text-danger'>Error: " + e.getMessage() + "</td></tr>"); }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- BANK APPROVALS -->
        <div class="card card-modern fade-in-up delay-200">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-hospital text-danger me-2"></i> Pending Blood Banks</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-light">
                        <tr>
                            <th>Facility Name</th>
                            <th>City/Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> banks = db.collection("users")
                                    .whereEqualTo("status", "PENDING")
                                    .whereEqualTo("role", "BANK").get().get().getDocuments();
                                boolean hasRows2 = false;
                                for (QueryDocumentSnapshot doc : banks) {
                                    hasRows2 = true;
                        %>
                                <tr>
                                    <td><div class="fw-bold text-dark"><%= doc.getString("full_name") %></div></td>
                                    <td class="text-muted"><i class="fa-solid fa-location-dot me-1"></i> <%= doc.getString("city") %></td>
                                    <td class="text-end">
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="approve">
                                            <button class="btn btn-success btn-sm rounded-pill px-3 fw-bold me-2"><i class="fa-solid fa-check me-1"></i> Approve</button>
                                        </form>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="reject">
                                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3 fw-bold"><i class="fa-solid fa-xmark me-1"></i> Reject</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows2) { out.print("<tr><td colspan='3' class='text-center text-muted py-5'><i class='fa-solid fa-clipboard-check mb-2 fs-2 text-light'></i><br>No pending blood banks. All caught up!</td></tr>"); }
                            } catch (Exception e) { out.print("<tr><td colspan='3' class='text-danger'>Error: " + e.getMessage() + "</td></tr>"); }
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
