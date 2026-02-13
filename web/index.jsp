<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LifeFlow - Blood Bank Management System</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: #0f172a;
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .hero-section {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 2rem;
            background: radial-gradient(circle at center, #1e293b 0%, #0f172a 100%);
        }
        .brand-text {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 0.5rem;
        }
        .brand-text span {
            color: #f97373;
        }
        .tagline {
            font-size: 1.25rem;
            color: #94a3b8;
            margin-bottom: 2.5rem;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .btn-crimson {
            background: linear-gradient(135deg, #b91c1c, #fb7185);
            border: none;
            padding: 0.75rem 2rem;
            font-weight: 600;
            transition: transform 0.2s;
        }
        .btn-crimson:hover {
            background: linear-gradient(135deg, #991b1b, #f97373);
            transform: translateY(-2px);
        }
        .btn-outline-light {
            padding: 0.75rem 2rem;
            font-weight: 600;
            transition: transform 0.2s;
        }
        .btn-outline-light:hover {
            transform: translateY(-2px);
        }
        .action-cards {
            margin-top: 3rem;
            display: flex;
            gap: 1.5rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        .card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            color: white;
            min-width: 250px;
        }
        .card:hover {
            background: rgba(255, 255, 255, 0.1);
        }
    </style>
</head>
<body>

<div class="hero-section">
    <div>
        <h1 class="brand-text">Life<span>Flow</span></h1>
        <p class="tagline">
            Connecting donors with those in need. efficient, and life-saving blood bank management.
        </p>

        <div class="d-flex gap-3 justify-content-center">
            <a href="login.jsp" class="btn btn-crimson text-white rounded-pill">Sign In</a>
            <a href="register.jsp" class="btn btn-outline-light rounded-pill">Register</a>
        </div>

        <div class="action-cards">
            <a href="findBloodBank.jsp" class="text-decoration-none text-white">
                <div class="card p-4 text-center">
                    <div class="h3 mb-2">🩸</div>
                    <h5 class="mb-1">Find Blood</h5>
                    <small class="text-muted">Locate nearest blood banks</small>
                </div>
            </a>
            <a href="register.jsp" class="text-decoration-none text-white">
                <div class="card p-4 text-center">
                    <div class="h3 mb-2">❤️</div>
                    <h5 class="mb-1">Donate Now</h5>
                    <small class="text-muted">Register as a donor</small>
                </div>
            </a>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
