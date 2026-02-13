<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Donation Appointment | LifeFlow</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">

            <div class="card shadow">
                <div class="card-body">

                    <h3 class="mb-4 text-center">Book Donation Appointment</h3>

                    <form action="<%= request.getContextPath() %>/BookAppointmentServlet" method="post">

                        <!-- Blood Bank Dropdown -->
                        <div class="mb-3">
                            <label class="form-label">Select Blood Bank</label>

                            <select name="bankId" class="form-select" required>
                                <option value="">Select Blood Bank</option>

                                <%
                                    List<String[]> banks =
                                            (List<String[]>) request.getAttribute("banks");

                                    if (banks != null && !banks.isEmpty()) {
                                        for (String[] bank : banks) {
                                %>
                                            <option value="<%= bank[0] %>">
                                                <%= bank[1] %>
                                            </option>
                                <%
                                        }
                                    } else {
                                %>
                                        <option disabled>No Blood Banks Available</option>
                                <%
                                    }
                                %>
                            </select>
                        </div>

                        <!-- Date & Time -->
                        <div class="mb-3">
                            <label class="form-label">Select Date & Time</label>
                            <input type="datetime-local"
                                   name="appointmentTime"
                                   class="form-control"
                                   required>
                        </div>

                        <!-- Submit Button -->
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary">
                                Book Now
                            </button>
                        </div>

                    </form>

                    <!-- Back Button -->
                    <div class="text-center mt-3">
                        <a href="<%= request.getContextPath() %>/dashboard/donor/home.jsp"
                           class="text-decoration-none">
                            ← Back to Dashboard
                        </a>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

</body>
</html>
