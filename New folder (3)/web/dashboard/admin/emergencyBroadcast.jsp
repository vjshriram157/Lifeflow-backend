<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        Firestore db = FirebaseConfig.getFirestore();
        // Fetch all stock that has units < 5
        ApiFuture<QuerySnapshot> stockFuture = db.collection("blood_stock").whereLessThan("units", 5L).get();
        List<QueryDocumentSnapshot> lowStockDocs = stockFuture.get().getDocuments();

        for (QueryDocumentSnapshot sDoc : lowStockDocs) {
            String bankId = sDoc.getString("blood_bank_id");
            if (bankId == null) continue;

            DocumentSnapshot bankDoc = db.collection("blood_banks").document(bankId).get().get();
            if (!bankDoc.exists() || !"APPROVED".equalsIgnoreCase(bankDoc.getString("status"))) {
                continue;
            }

            any = true;
            String bankName = bankDoc.getString("bank_name");
            String city = bankDoc.getString("city");
            String bloodGroup = sDoc.getString("blood_group");
            Long units = sDoc.getLong("units");
            long safetyStock = 5;
%>
                            <tr>
                                <td>
                                    <div class="fw-bold text-dark"><%= bankName != null ? bankName : "Unknown Bank" %></div>
                                </td>
                                <td class="text-muted"><i class="fa-solid fa-location-dot me-1 text-danger"></i> <%= city != null ? city : "N/A" %></td>
                                <td>
                                    <span class="badge bg-danger rounded-pill px-3 fs-6 shadow-sm"><i class="fa-solid fa-droplet me-1"></i> <%= bloodGroup %></span>
                                </td>
                                <td>
                                    <h5 class="fw-bold mb-0 text-dark">
                                        <%= units != null ? units : 0 %> <span class="text-muted fs-6 fw-normal">/ <%= safetyStock %> Required</span>
                                    </h5>
                                </td>
                                <td class="text-end">
                                    <button class="btn btn-premium btn-sm rounded-pill px-4 fw-bold shadow-sm"
                                            onclick="sendBroadcast('<%= bankId %>', '<%= bankName != null ? bankName.replace("'", "\\'") : "" %>', '<%= bloodGroup != null ? bloodGroup : "" %>')">
                                        <i class="fa-solid fa-podcast me-1"></i> Dispatch Request
                                    </button>
                                </td>
                            </tr>
<%
        }
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
    function sendBroadcast(bankId, bankName, bloodGroup) {
        if (!confirm("Dispatch high-priority push notification for " + bloodGroup + " donors near " + bankName + "?")) {
            return;
        }

        const btn = event.currentTarget;
        const originalHtml = btn.innerHTML;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Dispatching...';
        btn.disabled = true;

        const formData = new URLSearchParams();
        formData.append("bankId", bankId);
        formData.append("bloodGroup", bloodGroup);
        formData.append("radiusKm", "10");

        fetch("<%= request.getContextPath() %>/api/emergency-broadcast", {
            method: "POST",
            body: formData,
            headers: { "Content-Type": "application/x-www-form-urlencoded" }
        })
        .then(response => response.json().then(data => ({ status: response.status, body: data })))
        .then(res => {
            if (res.status === 200) {
                alert("Success!\nAlert ID: " + res.body.alertId + "\nDonors Notified: " + res.body.notifiedCount);
            } else {
                alert("Error: " + (res.body.error || "Failed to dispatch request"));
            }
        })
        .catch(err => {
            alert("Network error: Could not connect to dispatch server.");
            console.error(err);
        })
        .finally(() => {
            btn.innerHTML = originalHtml;
            btn.disabled = false;
        });
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>