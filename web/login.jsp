<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign in | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: #0f172a;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #0f172a;
        }
        .card-elevated {
            border-radius: 1.25rem;
            border: none;
            box-shadow: 0 24px 70px rgba(15, 23, 42, 0.55);
        }
        .brand-text span {
            color: #f97373;
            font-weight: 700;
        }
        .btn-crimson {
            background: linear-gradient(135deg, #b91c1c, #fb7185);
            border: none;
        }
        .btn-crimson:hover {
            background: linear-gradient(135deg, #991b1b, #f97373);
        }
    </style>
</head>
<body>
<div class="container">
    <div class="row justify-content-center">
        <div class="col-lg-5">
            <div class="card card-elevated">
                <div class="card-body p-4 p-md-5">
                    <div class="mb-4 text-center">
                        <div class="brand-text h4 mb-1 text-dark">Welcome back to <span>LifeFlow</span></div>
                        <p class="text-muted mb-0" style="font-size: 0.9rem;">
                            Sign in as Admin, Blood Bank, or Donor using your approved account.
                        </p>
                    </div>

                    <%
                        String error = (String) request.getAttribute("error");
                        String registered = request.getParameter("registered");
                        if (registered != null) {
                    %>
                    <div class="alert alert-success">
                        Registration successful. Your account is pending admin approval.
                    </div>
                    <%
                        }
                        if (error != null) {
                    %>
                    <div class="alert alert-danger"><%= error %></div>
                    <%
                        }
                    %>

                    <form method="post" action="<%= request.getContextPath() %>/LoginServlet" novalidate>
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" name="email" required autofocus>
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="form-text">
                                New donor?
                                <a href="<%= request.getContextPath() %>/register.jsp">Create account</a>
                            </div>
                        </div>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-crimson text-white">
                                Sign in
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

