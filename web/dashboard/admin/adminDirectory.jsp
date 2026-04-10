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
    <title>Directory Management | LifeFlow Admin</title>
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
            <li><a href="<%=request.getContextPath()%>/adminPendingApprovals.jsp" class="nav-link"><i class="fa-solid fa-user-check"></i> Approvals</a></li>
            <li><a href="<%=request.getContextPath()%>/dashboard/admin/emergencyBroadcast.jsp" class="nav-link"><i class="fa-solid fa-tower-broadcast"></i> Emergencies</a></li>
            <li><a href="<%=request.getContextPath()%>/dashboard/admin/analytics.jsp" class="nav-link"><i class="fa-solid fa-chart-line"></i> Analytics</a></li>
            <li><a href="<%=request.getContextPath()%>/dashboard/admin/adminDirectory.jsp" class="nav-link active"><i class="fa-solid fa-address-book"></i> User Directory</a></li>
        </ul>
        <div class="mt-auto pt-5 pb-3">
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="btn btn-outline-light btn-sm w-100 rounded-pill"><i class="fa-solid fa-right-from-bracket me-2"></i>Sign Out</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">User Directory Console</h2>
                <p class="text-muted">Edit or securely remove active verified profiles across your platform.</p>
            </div>
        </div>

        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <div class="alert alert-danger fade-in-up delay-100"><i class="fa-solid fa-triangle-exclamation me-2"></i> <%= error %></div>
        <%
            }
            if (success != null) {
        %>
            <div class="alert alert-success fade-in-up delay-100"><i class="fa-solid fa-circle-check me-2"></i> <%= success %></div>
        <%
            }
        %>

        <!-- ACTIVE DONORS -->
        <div class="card card-modern fade-in-up delay-100 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-users text-danger me-2"></i> Active Donors</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-light">
                        <tr>
                            <th>Name</th>
                            <th>Blood Group</th>
                            <th>Contact / Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> donors = db.collection("users")
                                    .whereEqualTo("status", "APPROVED")
                                    .whereEqualTo("role", "DONOR").get().get().getDocuments();
                                boolean hasRows = false;
                                for (QueryDocumentSnapshot doc : donors) {
                                    hasRows = true;
                                    String id = doc.getId();
                                    String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
                                    String bg = doc.getString("blood_group") != null ? doc.getString("blood_group") : "";
                                    String city = doc.getString("city") != null ? doc.getString("city") : "";
                                    String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
                                    String email = doc.getString("email") != null ? doc.getString("email") : "";
                        %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-dark"><%= name %></div>
                                        <div class="text-muted" style="font-size:0.8rem;"><%= email %></div>
                                    </td>
                                    <td><span class="badge badge-soft-danger fs-6"><%= bg %></span></td>
                                    <td class="text-muted">
                                        <div><i class="fa-solid fa-phone me-1"></i> <%= phone %></div>
                                        <div style="font-size:0.8rem;"><i class="fa-solid fa-location-dot me-1"></i> <%= city %></div>
                                    </td>
                                    <td class="text-end">
                                        <button class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold me-2" data-bs-toggle="modal" data-bs-target="#editModal<%= id %>"><i class="fa-solid fa-pen me-1"></i> Edit</button>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminUserManagementServlet" class="d-inline" onsubmit="return confirm('Are you sure you want to permanently delete this donor?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="userId" value="<%= id %>">
                                            <input type="hidden" name="role" value="DONOR">
                                            <input type="hidden" name="email" value="<%= email %>">
                                            <button class="btn btn-outline-danger btn-sm rounded-pill px-3 fw-bold"><i class="fa-solid fa-trash me-1"></i> Remove</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows) { out.print("<tr><td colspan='4' class='text-center text-muted py-5'><i class='fa-solid fa-folder-open mb-2 fs-2 text-light'></i><br>No active donors.</td></tr>"); }
                            } catch (Exception e) { out.print("<tr><td colspan='4' class='text-danger'>Error: " + e.getMessage() + "</td></tr>"); }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ACTIVE BLOOD BANKS -->
        <div class="card card-modern fade-in-up delay-200 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-hospital text-danger me-2"></i> Active Blood Banks</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-light">
                        <tr>
                            <th>Facility Name</th>
                            <th>Contact Info</th>
                            <th>City/Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> banks = db.collection("users")
                                    .whereEqualTo("status", "APPROVED")
                                    .whereEqualTo("role", "BANK").get().get().getDocuments();
                                boolean hasRows2 = false;
                                for (QueryDocumentSnapshot doc : banks) {
                                    hasRows2 = true;
                                    String id = doc.getId();
                                    String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
                                    String city = doc.getString("city") != null ? doc.getString("city") : "";
                                    String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
                                    String email = doc.getString("email") != null ? doc.getString("email") : "";
                        %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-dark"><%= name %></div>
                                        <div class="text-muted" style="font-size:0.8rem;"><%= id.length() > 8 ? id.substring(0,8) : id %>...</div>
                                    </td>
                                    <td class="text-muted">
                                        <div><i class="fa-solid fa-envelope me-1"></i> <%= email %></div>
                                        <div style="font-size:0.8rem;"><i class="fa-solid fa-phone me-1"></i> <%= phone %></div>
                                    </td>
                                    <td class="text-muted"><i class="fa-solid fa-location-dot me-1"></i> <%= city %></td>
                                    <td class="text-end">
                                        <button class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold me-2" data-bs-toggle="modal" data-bs-target="#editModal<%= id %>"><i class="fa-solid fa-pen me-1"></i> Edit</button>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminUserManagementServlet" class="d-inline" onsubmit="return confirm('WARNING: Removing a blood bank will also erase them from the spatial locator map! Proceed?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="userId" value="<%= id %>">
                                            <input type="hidden" name="role" value="BANK">
                                            <input type="hidden" name="email" value="<%= email %>">
                                            <button class="btn btn-danger btn-sm rounded-pill px-3 fw-bold shadow-sm"><i class="fa-solid fa-trash me-1"></i> Remove</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows2) { out.print("<tr><td colspan='4' class='text-center text-muted py-5'><i class='fa-solid fa-folder-open mb-2 fs-2 text-light'></i><br>No active blood banks.</td></tr>"); }
                            } catch (Exception e) { out.print("<tr><td colspan='4' class='text-danger'>Error: " + e.getMessage() + "</td></tr>"); }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- DONOR MODALS -->
<%
    try {
        Firestore db = FirebaseConfig.getFirestore();
        List<QueryDocumentSnapshot> donors = db.collection("users")
            .whereEqualTo("status", "APPROVED")
            .whereEqualTo("role", "DONOR").get().get().getDocuments();
        for (QueryDocumentSnapshot doc : donors) {
            String id = doc.getId();
            String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
            String bg = doc.getString("blood_group") != null ? doc.getString("blood_group") : "";
            String city = doc.getString("city") != null ? doc.getString("city") : "";
            String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
            String email = doc.getString("email") != null ? doc.getString("email") : "";
%>
    <div class="modal fade" id="editModal<%= id %>" tabindex="-1" aria-labelledby="editLabel<%= id %>" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 1.5rem;">
                <form action="<%= request.getContextPath() %>/AdminUserManagementServlet" method="post">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold" id="editLabel<%= id %>">Edit Donor Profile</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="userId" value="<%= id %>">
                        <input type="hidden" name="role" value="DONOR">
                        <input type="hidden" name="email" value="<%= email %>">
                        
                        <div class="mb-3">
                            <label class="form-label text-muted small text-uppercase fw-bold">Full Name</label>
                            <input type="text" class="form-control form-control-modern" name="fullName" value="<%= name %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small text-uppercase fw-bold">Blood Group</label>
                            <select class="form-select form-control-modern" name="bloodGroup">
                                <option value="A+" <%= "A+".equals(bg)?"selected":"" %>>A+</option>
                                <option value="A-" <%= "A-".equals(bg)?"selected":"" %>>A-</option>
                                <option value="B+" <%= "B+".equals(bg)?"selected":"" %>>B+</option>
                                <option value="B-" <%= "B-".equals(bg)?"selected":"" %>>B-</option>
                                <option value="O+" <%= "O+".equals(bg)?"selected":"" %>>O+</option>
                                <option value="O-" <%= "O-".equals(bg)?"selected":"" %>>O-</option>
                                <option value="AB+" <%= "AB+".equals(bg)?"selected":"" %>>AB+</option>
                                <option value="AB-" <%= "AB-".equals(bg)?"selected":"" %>>AB-</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small text-uppercase fw-bold">Phone Number</label>
                            <input type="text" class="form-control form-control-modern" name="phone" value="<%= phone %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small text-uppercase fw-bold">City / Area</label>
                            <input type="text" class="form-control form-control-modern" name="city" value="<%= city %>" required>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-premium rounded-pill px-4 shadow-sm">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
<%
        }
    } catch (Exception e) {}
%>

<!-- BANK MODALS -->
<%
    try {
        Firestore db = FirebaseConfig.getFirestore();
        List<QueryDocumentSnapshot> banks = db.collection("users")
            .whereEqualTo("status", "APPROVED")
            .whereEqualTo("role", "BANK").get().get().getDocuments();
        for (QueryDocumentSnapshot doc : banks) {
            String id = doc.getId();
            String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
            String city = doc.getString("city") != null ? doc.getString("city") : "";
            String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
            String email = doc.getString("email") != null ? doc.getString("email") : "";
%>
    <div class="modal fade" id="editModal<%= id %>" tabindex="-1" aria-labelledby="editLabel<%= id %>" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 1.5rem;">
                <form action="<%= request.getContextPath() %>/AdminUserManagementServlet" method="post">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold" id="editLabel<%= id %>">Edit Blood Bank</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="userId" value="<%= id %>">
                        <input type="hidden" name="role" value="BANK">
                        <input type="hidden" name="email" value="<%= email %>">
                        
                        <div class="mb-3">
                            <label class="form-label text-muted small text-uppercase fw-bold">Facility Name</label>
                            <input type="text" class="form-control form-control-modern" name="fullName" value="<%= name %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small text-uppercase fw-bold">Phone Number</label>
                            <input type="text" class="form-control form-control-modern" name="phone" value="<%= phone %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small text-uppercase fw-bold">City / Area</label>
                            <input type="text" class="form-control form-control-modern" name="city" value="<%= city %>" required>
                        </div>
                        <p class="text-danger small mt-3"><i class="fa-solid fa-triangle-exclamation me-1"></i> Saving changes will auto-sync their map coordinates if they are connected to the spatial index.</p>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-premium rounded-pill px-4 shadow-sm">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
<%
        }
    } catch (Exception e) {}
%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
