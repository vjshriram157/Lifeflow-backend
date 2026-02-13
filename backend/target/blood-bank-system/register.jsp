<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Register as Donor | LifeFlow</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background: radial-gradient(circle at top left, #fee2e2, #f9fafb 55%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .card-elevated {
                border-radius: 1.25rem;
                border: none;
                box-shadow: 0 20px 60px rgba(15, 23, 42, 0.25);
            }

            .brand-text span {
                color: #b91c1c;
                font-weight: 700;
            }

            .btn-crimson {
                background: linear-gradient(135deg, #b91c1c, #f97373);
                border: none;
            }

            .btn-crimson:hover {
                background: linear-gradient(135deg, #991b1b, #fb7185);
            }
        </style>
    </head>

    <body>
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-6">
                    <div class="card card-elevated">
                        <div class="card-body p-4 p-md-5">
                            <div class="mb-4 text-center">
                                <div class="brand-text h4 mb-0">Join <span>LifeFlow</span></div>
                                <p class="text-muted mb-0" style="font-size: 0.9rem;">
                                    Create your donor profile. An admin will approve your account before first login.
                                </p>
                            </div>

                            <% String error=(String) request.getAttribute("error"); if (error !=null) { %>
                                <div class="alert alert-danger">
                                    <%= error %>
                                </div>
                                <% } %>

                                    <form method="post" action="<%= request.getContextPath() %>/RegisterServlet"
                                        novalidate>
                                        <div class="mb-3">
                                            <label for="fullName" class="form-label">Full Name</label>
                                            <input type="text" class="form-control" id="fullName" name="fullName"
                                                required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="email" class="form-label">Email</label>
                                            <input type="email" class="form-control" id="email" name="email" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="phone" class="form-label">Phone</label>
                                            <input type="text" class="form-control" id="phone" name="phone">
                                        </div>
                                        <div class="row">
                                            <div class="col-md-6 mb-3">
                                                <label for="password" class="form-label">Password</label>
                                                <input type="password" class="form-control" id="password"
                                                    name="password" required minlength="6">
                                            </div>
                                            <div class="col-md-6 mb-3">
                                                <label for="confirmPassword" class="form-label">Confirm Password</label>
                                                <input type="password" class="form-control" id="confirmPassword"
                                                    name="confirmPassword" required minlength="6">
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-6 mb-3">
                                                <label for="bloodGroup" class="form-label">Blood Group</label>
                                                <select class="form-select" id="bloodGroup" name="bloodGroup">
                                                    <option value="">Select</option>
                                                    <option value="A+">A+</option>
                                                    <option value="A-">A-</option>
                                                    <option value="B+">B+</option>
                                                    <option value="B-">B-</option>
                                                    <option value="O+">O+</option>
                                                    <option value="O-">O-</option>
                                                    <option value="AB+">AB+</option>
                                                    <option value="AB-">AB-</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6 mb-3">
                                                <label for="role" class="form-label">Account Type</label>
                                                <select class="form-select" id="role" name="role" required>
                                                    <option value="DONOR">Donor</option>
                                                    <option value="BANK">Blood Bank (Admin Approval Required)</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-12 mb-3">
                                                <label for="city" class="form-label">City</label>
                                                <input type="text" class="form-control" id="city" name="city">
                                            </div>
                                        </div>
                                        <div class="d-grid mt-3">
                                            <button type="submit" class="btn btn-crimson text-white">
                                                Create donor account
                                            </button>
                                        </div>
                                    </form>

                                    <div class="text-center mt-3" style="font-size: 0.9rem;">
                                        Already registered?
                                        <a href="<%= request.getContextPath() %>/login.jsp">Sign in</a>
                                    </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>