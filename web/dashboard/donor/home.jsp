<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List" %>
<%
    String userId = (String) session.getAttribute("userId");
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

        <div class="card card-modern border-warning border-2 fade-in-up delay-100 mb-4 bg-light">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4 text-warning-emphasis"><i class="fa-solid fa-bell text-warning me-2"></i> Critical Blood Demands Near You</h4>
                
                <div class="row g-3">
<%
    boolean anyAlerts = false;
    try {
        Firestore db = FirebaseConfig.getFirestore();
        
        // 1. Get Donor's Blood Group
        DocumentSnapshot userDoc = db.collection("users").document(userId).get().get();
        String myBloodGroup = userDoc.getString("blood_group");
        
        if (myBloodGroup != null && !myBloodGroup.isEmpty()) {
            // 2. Fetch Active Emergency Alerts for this blood group
            ApiFuture<QuerySnapshot> alertFuture = db.collection("emergency_alerts")
                    .whereEqualTo("blood_group", myBloodGroup).get();
            List<QueryDocumentSnapshot> alerts = new java.util.ArrayList<QueryDocumentSnapshot>(alertFuture.get().getDocuments());
            
            // Sort by time descending
            java.util.Collections.sort(alerts, new java.util.Comparator<QueryDocumentSnapshot>() {
                public int compare(QueryDocumentSnapshot d1, QueryDocumentSnapshot d2) {
                    String t1 = d1.getString("created_at");
                    String t2 = d2.getString("created_at");
                    if (t1 == null) return 1;
                    if (t2 == null) return -1;
                    return t2.compareTo(t1);
                }
            });

            for (QueryDocumentSnapshot alert : alerts) {
                anyAlerts = true;
                String bankId = alert.getString("bank_id");
                String msg = alert.getString("message");
                Double radius = alert.getDouble("radius_km");
                String time = alert.getString("created_at");

                String bName = "Local Facility";
                if (bankId != null) {
                    DocumentSnapshot bDoc = db.collection("blood_banks").document(bankId).get().get();
                    if (bDoc.exists() && bDoc.getString("bank_name") != null) {
                        bName = bDoc.getString("bank_name");
                    }
                }
%>
                    <div class="col-md-6">
                        <div class="p-3 border rounded bg-white shadow-sm position-relative overflow-hidden">
                            <div class="position-absolute top-0 start-0 w-100 bg-warning" style="height: 4px;"></div>
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold text-dark mb-0"><i class="fa-solid fa-hospital-user text-danger me-1"></i> <%= bName %></h6>
                                <span class="badge bg-danger rounded-pill"><%= myBloodGroup %> Needed</span>
                            </div>
                            <p class="text-muted small mb-2"><i class="fa-solid fa-satellite-dish me-1"></i> <%= radius != null ? radius : 10.0 %>km Alert Radius</p>
                            <p class="mb-3 fw-medium text-dark"><%= msg != null ? msg : "Urgent requirement dispatched." %></p>
                            <div class="d-flex justify-content-between align-items-center">
                                <small class="text-muted"><i class="fa-regular fa-clock me-1"></i> <%= time %></small>
                                <a href="<%= request.getContextPath() %>/BookAppointmentServlet?prefillBankId=<%= bankId %>" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">
                                    Respond Now <i class="fa-solid fa-arrow-right ms-1"></i>
                                </a>
                            </div>
                        </div>
                    </div>
<%
            }
        }
        if (!anyAlerts) {
%>
                    <div class="col-12 text-center py-4">
                        <div class="d-inline-flex bg-success bg-opacity-10 text-success p-3 rounded-circle mb-3">
                            <i class="fa-solid fa-check fs-2"></i>
                        </div>
                        <h6 class="text-muted fw-bold">No critical emergencies for <%= myBloodGroup != null ? myBloodGroup : "your blood type" %> in your area right now.</h6>
                    </div>
<%
        }
    } catch (Exception e) {
%>
                    <div class="col-12 text-danger">Failed to load alerts: <%= e.getMessage() %></div>
<%
    }
%>
                </div>
            </div>
        </div>

        <div class="card card-modern fade-in-up delay-200 mb-4">
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
    boolean any = false;
    try {
        Firestore db = FirebaseConfig.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection("appointments").whereEqualTo("donor_id", userId).get();
        List<QueryDocumentSnapshot> docs = new java.util.ArrayList<QueryDocumentSnapshot>(future.get().getDocuments());

        // Sort appointments by time descending
        java.util.Collections.sort(docs, new java.util.Comparator<QueryDocumentSnapshot>() {
            public int compare(QueryDocumentSnapshot d1, QueryDocumentSnapshot d2) {
                String t1 = d1.getString("appointment_time");
                String t2 = d2.getString("appointment_time");
                if (t1 == null) return 1;
                if (t2 == null) return -1;
                return t2.compareTo(t1);
            }
        });

        for (QueryDocumentSnapshot doc : docs) {
            any = true;
            String st = doc.getString("status");
            String apptTime = doc.getString("appointment_time");
            String bankId = doc.getString("bank_id");
            String appId = doc.getId();

            String bankName = "Unknown Bank";
            if (bankId != null) {
                DocumentSnapshot bankDoc = db.collection("users").document(bankId).get().get();
                if (bankDoc.exists() && bankDoc.getString("full_name") != null) {
                    bankName = bankDoc.getString("full_name");
                } else {
                    DocumentSnapshot bankDoc2 = db.collection("blood_banks").document(bankId).get().get();
                    if (bankDoc2.exists() && bankDoc2.getString("bank_name") != null) {
                        bankName = bankDoc2.getString("bank_name");
                    }
                }
            }

            String badgeClass = "secondary";
            if ("COMPLETED".equalsIgnoreCase(st)) badgeClass = "badge-soft-success";
            else if ("CONFIRMED".equalsIgnoreCase(st)) badgeClass = "badge-soft-primary";
            else if ("PENDING".equalsIgnoreCase(st)) badgeClass = "badge-soft-warning";
            else if ("CANCELLED".equalsIgnoreCase(st)) badgeClass = "badge-soft-danger";
%>
                        <tr>
                            <td><div class="fw-bold text-dark"><i class="fa-regular fa-calendar me-2 text-muted"></i><%= apptTime != null ? apptTime : "" %></div></td>
                            <td class="text-muted"><i class="fa-solid fa-building-user me-1 border p-1 rounded"></i> <%= bankName %></td>
                            <td><span class="badge <%= badgeClass %> px-3 rounded-pill fs-6"><%= st != null ? st : "" %></span></td>
                            <td class="text-center">
                                <% if ("COMPLETED".equalsIgnoreCase(st)) { %>
                                <a class="btn btn-sm btn-outline-danger rounded-pill fw-bold" href="<%= request.getContextPath() %>/certificate?appointmentId=<%= appId %>" target="_blank">
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
