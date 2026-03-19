<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
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
    <title>Book Donation | LifeFlow</title>
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
            <li><a href="<%=request.getContextPath()%>/dashboard/donor/home.jsp" class="nav-link"><i class="fa-solid fa-clock-rotate-left"></i> My History</a></li>
            <li><a href="<%=request.getContextPath()%>/BookAppointmentServlet" class="nav-link active"><i class="fa-regular fa-calendar-plus"></i> Donate Blood</a></li>
        </ul>
        <div class="mt-auto pt-5 pb-3">
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="btn btn-outline-light btn-sm w-100 rounded-pill"><i class="fa-solid fa-right-from-bracket me-2"></i>Sign Out</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Book a Donation Appointment</h2>
                <p class="text-muted">Select a partnered blood bank and a convenient schedule block to donate.</p>
            </div>
        </div>

        <div class="row justify-content-center">
            <div class="col-xl-6 col-lg-8 fade-in-up delay-100">
                <div class="card card-modern p-4 p-md-5 border-0">
                    <div class="card-body">
                        <div class="text-center mb-5">
                            <div class="d-inline-flex bg-danger bg-opacity-10 text-danger p-3 rounded-circle mb-3 border border-danger border-opacity-25" style="border-width: 2px !important">
                                <i class="fa-solid fa-hand-holding-droplet fs-1"></i>
                            </div>
                            <h3 class="fw-bold">Schedule Visit</h3>
                        </div>

                        <form action="<%= request.getContextPath() %>/BookAppointmentServlet" method="post">
                            <div class="mb-4">
                                <label class="form-label fw-bold"><i class="fa-solid fa-hospital-user text-danger me-2"></i> Select Partnering Facility</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-0"><i class="fa-solid fa-map-pin text-muted"></i></span>
                                    <select name="bankId" class="form-select form-control-modern bg-light border-0 py-3" required>
                                        <option value="">Select an Approved Blood Bank</option>
                                        <%
                                            List<String[]> banks = (List<String[]>) request.getAttribute("banks");
                                            if (banks != null && !banks.isEmpty()) {
                                                for (String[] bank : banks) {
                                        %>
                                                    <option value="<%= bank[0] %>"><%= bank[1] %></option>
                                        <%
                                                }
                                            } else {
                                        %>
                                                <option disabled>No Blood Banks Active or Approved Presently</option>
                                        <%
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-5">
                                <label class="form-label fw-bold"><i class="fa-regular fa-clock text-danger me-2"></i> Reservation Date &amp; Time</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-0"><i class="fa-solid fa-calendar text-muted"></i></span>
                                    <input type="datetime-local" name="appointmentTime" class="form-control form-control-modern bg-light border-0 py-3" required>
                                </div>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-premium btn-lg rounded-pill fw-bold">
                                    Establish Appointment <i class="fa-solid fa-arrow-right ms-2"></i>
                                </button>
                                <a href="<%= request.getContextPath() %>/dashboard/donor/home.jsp" class="btn btn-light rounded-pill py-2 text-muted fw-bold">
                                    ← Cancel &amp; Back to Dashboard
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
