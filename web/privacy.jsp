<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Privacy Policy | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { padding-top: 0; }
        .page-header { background: linear-gradient(135deg, rgba(15,23,42,1) 0%, rgba(15,23,42,0.85) 100%); padding: 4rem 0; color: white; text-align: center; }
        .main-container { margin-top: 2rem; min-height: 40vh;}
        /* Shared UI Snippets */
        .top-header { background: #1e293b; color: white; padding: 10px 0; font-size: 0.9rem; }
        .top-header .brand-logo-text { font-size: 1.2rem; font-weight: 800; display:flex; align-items:center; gap:8px;}
        .top-header .brand-logo-text i { color: #e11d48; }
        .top-header span { font-weight: 400; font-size: 0.85rem; color: #cbd5e1; }
        .btn-outline-white { border: 1px solid rgba(255,255,255,0.2); color: white; border-radius: 50px; font-weight: 600; font-size: 0.8rem; padding: 6px 16px; margin-left:10px;}
        .btn-orange { background: var(--brand-orange); color: white; border-radius: 50px; font-weight: 600; font-size: 0.8rem; padding: 6px 16px;}
        .navbar-custom { background: white !important; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding-top: 15px; padding-bottom: 15px;}
        .navbar-custom .nav-link { font-weight: 600; font-size: 0.9rem; color: var(--brand-dark) !important; padding: 10px 20px !important; }
        .navbar-custom .nav-link:hover { color: var(--brand-orange) !important; }
        .donate-btn-nav { background: #fee2e2; color: #e11d48; font-weight: 700; border-radius: 50px; padding: 10px 25px; font-size: 0.9rem; border: 1px solid #fecaca; }
        footer { background-color: var(--brand-dark); color: #a0a8b3; padding: 60px 0 20px 0; }
        footer h5 { color: #fff; font-weight: 600; margin-bottom: 25px; }
        footer ul { list-style: none; padding: 0; }
        footer ul li { margin-bottom: 12px; }
        footer ul li a { color: #a0a8b3; text-decoration: none; transition: 0.3s; }
        footer ul li a:hover { color: var(--brand-orange); }
    </style>
</head>
<body>

<div class="top-header">
    <div class="container d-flex justify-content-between align-items-center">
        <div class="brand-logo-text">
            <i class="fa-solid fa-heart-pulse"></i>
            <div>LifeFlow <span>Premium Blood Bank Management</span></div>
        </div>
        <div class="d-flex align-items-center">
            <a href="register.jsp" class="btn btn-orange"><i class="fa-solid fa-user"></i> REGISTER</a>
            <a href="login.jsp" class="btn btn-outline-white"><i class="fa-solid fa-lock"></i> LOGIN</a>
        </div>
    </div>
</div>

<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container d-flex justify-content-between">
        <button class="navbar-toggler text-white bg-dark" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav"><i class="fa-solid fa-bars"></i></button>
        <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="index.jsp">HOME</a></li>
                <li class="nav-item"><a class="nav-link" href="findBloodBank.jsp">FIND BLOOD</a></li>
                <li class="nav-item"><a class="nav-link" href="blog.jsp">BLOG</a></li>
                <li class="nav-item"><a class="nav-link" href="register.jsp">DONATE BLOOD</a></li>
                <li class="nav-item"><a class="nav-link" href="login.jsp">LOGIN</a></li>
            </ul>
        </div>
        <a href="register.jsp" class="donate-btn-nav text-decoration-none">BECOME A DONOR</a>
    </div>
</nav>

<div class="page-header">
    <div class="container fade-in-up">
        <h1 class="display-4 fw-bold mb-3" style="font-family:'Poppins';">Privacy Policy</h1>
        <p class="lead text-white-50 mx-auto" style="max-width: 600px;">How we protect your medical and personal data.</p>
    </div>
</div>

<main class="main-container container pb-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <h2 class="text-danger mt-5"><i class="fa-solid fa-shield-halved"></i> Data Security Standard</h2>
            <p class="text-muted mt-3">All medical records and donor identities are encrypted using AES-256 standard encryption before being transmitted to our secure Firestore databases.</p>
        </div>
    </div>
</main>

<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-4">
                <div class="brand-logo-text mb-3" style="font-size:1.5rem; font-weight:800; color:white;">
                    <i class="fa-solid fa-heart-pulse text-danger"></i> LifeFlow <span style="font-size:0.9rem; font-weight:400; color:#ddd;">Premium Blood Bank</span>
                </div>
                <h4 class="text-white mt-4 fw-bold">Pioneering Health<br>Tech Solutions</h4>
            </div>
            <div class="col-md-2 col-6 mb-4">
                <h5>Platform</h5>
                <ul>
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="findBloodBank.jsp">Find Blood</a></li>
                    <li><a href="login.jsp">Login</a></li>
                    <li><a href="register.jsp">Register</a></li>
                </ul>
            </div>
            <div class="col-md-2 col-6 mb-4">
                <h5>Features</h5>
                <ul>
                    <li><a href="features.jsp">Instant Search</a></li>
                    <li><a href="features.jsp">Stock Management</a></li>
                    <li><a href="features.jsp">SMS Alerts</a></li>
                    <li><a href="features.jsp">Firebase Realtime</a></li>
                </ul>
            </div>
            <div class="col-md-4 mb-4">
                <h5>Support</h5>
                <ul>
                    <li><a href="contact.jsp">Contact Admin</a></li>
                    <li><a href="privacy.jsp">Privacy Policy</a></li>
                    <li><a href="terms.jsp">Terms of Service</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p class="mb-0">Copyright © 2026. Designed & Developed by <span style="color:var(--brand-orange)">Vj</span></p>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
