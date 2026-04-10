<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LifeFlow - Premium Blood Bank Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <!-- FontAwesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        /* LifeFlow Branding Override */
        :root {
            --brand-orange: #e11d48; /* LifeFlow Crimson */
            --brand-dark: #0f172a;   /* LifeFlow Slate */
        }
        body {
            background-color: #fff;
            color: #333;
        }
        .top-header {
            background-color: var(--brand-dark);
            color: #fff;
            padding: 10px 0;
            font-size: 0.9rem;
        }
        .top-header a {
            color: #fff;
            text-decoration: none;
        }
        .top-header .btn-orange {
            background-color: var(--brand-orange);
            color: #fff;
            border: none;
            padding: 8px 20px;
            font-weight: 500;
        }
        .top-header .btn-outline-white {
            border: 1px solid #fff;
            color: #fff;
            background: transparent;
            padding: 8px 20px;
            font-weight: 500;
            margin-left: 10px;
        }
        .navbar-custom {
            background-color: var(--brand-orange);
            padding: 0;
        }
        .navbar-custom .nav-link {
            color: #fff;
            font-weight: 500;
            padding: 15px 20px;
            text-transform: uppercase;
            font-size: 0.85rem;
        }
        .navbar-custom .nav-link:hover {
            background-color: rgba(0,0,0,0.1);
        }
        .donate-btn-nav {
            background-color: rgba(0,0,0,0.15);
            color: #fff;
            font-weight: bold;
            padding: 15px 30px;
            text-transform: uppercase;
            height: 100%;
            display: flex;
            align-items: center;
        }
        
        .hero-banner {
            background: url('https://images.unsplash.com/photo-1615461066841-6116e61058f4?auto=format&fit=crop&q=80&w=2000') no-repeat center center;
            background-size: cover;
            position: relative;
            min-height: 500px;
            display: flex;
            align-items: center;
        }
        .hero-overlay {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.6); /* Darker overlay for LifeFlow */
        }
        .hero-content {
            position: relative;
            z-index: 2;
            width: 100%;
        }
        .search-pill-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.4);
            border-radius: 50rem;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.4), 0 0 0 8px rgba(255,255,255,0.1);
            max-width: 1050px;
            width: 100%;
            margin: 0 auto;
            position: relative;
            z-index: 10;
        }
        .custom-select-clean {
            border: none;
            background: transparent;
            font-weight: 600;
            color: #334155;
            flex-grow: 1;
            font-size: 0.95rem;
            cursor: pointer;
            outline: none !important;
            padding: 0;
            margin: 0;
            width: 100%;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
        }
        /* Custom chevron down for select */
        .search-field.is-select::after {
            content: '\f107';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            position: absolute;
            right: 15px;
            color: #94a3b8;
            pointer-events: none;
            transition: transform 0.3s ease;
        }
        .search-field.is-select:hover::after {
            color: var(--brand-orange);
            transform: translateY(2px);
        }
        .search-field {
            transition: all 0.3s;
            border-radius: 20px;
        }
        .search-field:hover {
            background: rgba(225, 29, 72, 0.05); /* Slight crimson tint */
        }
        .btn-search-pill {
            border-radius: 50rem;
            padding: 12px 32px;
            font-weight: 700;
            letter-spacing: 1px;
            font-size: 1rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background: linear-gradient(135deg, var(--brand-orange), #be123c);
            box-shadow: 0 10px 20px rgba(225, 29, 72, 0.3);
            border: none;
            color: white;
            display: flex;
            align-items: center;
        }
        .btn-search-pill:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 25px rgba(225, 29, 72, 0.5);
            color: white;
        }
        .hero-title {
            color: #fff;
            font-weight: 800;
            font-size: 3.5rem;
            margin-bottom: 0.5rem;
            letter-spacing: -1px;
            text-shadow: 0 4px 15px rgba(0,0,0,0.5);
        }
        .hero-title span {
            font-weight: 400;
        }
        @media (max-width: 991px) {
            .search-pill-container { border-radius: 20px; padding: 10px 0; }
            .search-pill-container form { flex-direction: column; gap: 10px; }
            .search-field { width: 100%; border-right: none !important; padding: 15px !important; }
            .btn-search-pill { width: 100%; justify-content: center; }
            .search-button-wrapper { width: 100%; margin-top: 10px; padding: 0 15px; }
        }
        .circle-action {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(5px);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: #fff;
            text-align: center;
            text-decoration: none;
            transition: all 0.3s;
            margin: 0 auto;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .circle-action:hover {
            background: rgba(255,255,255,0.25);
            color: #fff;
        }
        .circle-action i {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        .circle-action span {
            font-weight: 500;
            font-size: 1.1rem;
        }
        
        .promo-strip {
            display: flex;
        }
        .promo-item {
            flex: 1;
            padding: 30px;
            text-align: center;
            color: #fff;
            font-weight: bold;
            font-size: 1.2rem;
            text-transform: uppercase;
        }
        .promo-item:nth-child(1) { background: #e11d48; }
        .promo-item:nth-child(2) { background: #be123c; }
        .promo-item:nth-child(3) { background: #9f1239; }
        
        .why-donate-section {
            padding: 80px 0;
            background: #fff;
        }
        .why-donate-img {
            max-width: 100%;
            height: auto;
        }
        .why-donate-title {
            color: #333;
            font-weight: 700;
            margin-bottom: 20px;
        }
        .why-donate-text {
            color: #777;
            line-height: 1.8;
            margin-bottom: 30px;
        }
        .btn-outline-dark-custom {
            border: 2px solid #ddd;
            color: #333;
            border-radius: 50px;
            padding: 10px 30px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .stats-section {
            padding: 60px 0;
            text-align: center;
            border-top: 1px solid #eee;
        }
        .stats-title {
            font-weight: 700;
            color: #222;
        }
        .stats-subtitle {
            color: #777;
            margin-bottom: 40px;
        }
        .stats-subtitle span {
            color: var(--brand-orange);
        }
        .stat-circle {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            border: 2px solid #eee;
            margin: 0 auto 15px auto;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: var(--brand-orange);
            font-weight: 600;
            transition: all 0.3s;
        }
        .stat-circle:hover {
            border-color: var(--brand-orange);
            color: #fff;
            background: var(--brand-orange);
        }
        .stat-label {
            font-weight: 500;
            color: #444;
            font-size: 0.95rem;
        }
        .see-more-link {
            color: #333;
            font-weight: bold;
            text-transform: uppercase;
            text-decoration: none;
            border-bottom: 2px solid var(--brand-orange);
            padding-bottom: 5px;
            display: inline-block;
            margin-top: 40px;
        }
        
        footer {
            background-color: var(--brand-dark);
            color: #a0a8b3;
            padding: 60px 0 20px 0;
        }
        footer h5 {
            color: #fff;
            font-weight: 600;
            margin-bottom: 25px;
        }
        footer ul {
            list-style: none;
            padding: 0;
        }
        footer ul li {
            margin-bottom: 12px;
        }
        footer ul li a {
            color: #a0a8b3;
            text-decoration: none;
            transition: 0.3s;
        }
        footer ul li a:hover {
            color: var(--brand-orange);
        }
        .footer-social .social-icon {
            display: inline-flex;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 1px solid rgba(255,255,255,0.1);
            align-items: center;
            justify-content: center;
            color: #fff;
            margin: 0 5px;
            text-decoration: none;
        }
        .footer-social .social-icon:hover {
            background: var(--brand-orange);
            border-color: var(--brand-orange);
        }
        .footer-bottom {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid rgba(255,255,255,0.05);
        }
        .footer-bottom h3 {
            color: #fff;
            font-weight: 700;
            margin-bottom: 5px;
        }
        .brand-logo-text {
            color: #fff;
            font-size: 1.5rem;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .brand-logo-text i {
            color: var(--brand-orange);
            font-size: 2rem;
        }
        .brand-logo-text span {
            display: block;
            font-size: 0.7rem;
            font-weight: normal;
            color: #aaa;
        }
    </style>
</head>
<body>

<!-- Top Header -->
<div class="top-header">
    <div class="container d-flex justify-content-between align-items-center">
        <div class="brand-logo-text">
            <i class="fa-solid fa-heart-pulse"></i>
            <div>
                LifeFlow <span>Premium Blood Bank Management</span>
            </div>
        </div>
        <div class="d-flex align-items-center">
            <a href="register.jsp" class="btn btn-orange"><i class="fa-solid fa-user"></i> REGISTER</a>
            <a href="login.jsp" class="btn btn-outline-white"><i class="fa-solid fa-lock"></i> LOGIN</a>
        </div>
    </div>
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container d-flex justify-content-between">
        <button class="navbar-toggler text-white" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav">
            <i class="fa-solid fa-bars"></i>
        </button>
        <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="index.jsp">HOME</a></li>
                <li class="nav-item"><a class="nav-link" href="findBloodBank.jsp">FIND BLOOD</a></li>
                <li class="nav-item"><a class="nav-link" href="blog.jsp">BLOG</a></li>
                <li class="nav-item"><a class="nav-link" href="register.jsp">DONATE BLOOD</a></li>
                <li class="nav-item"><a class="nav-link" href="login.jsp">LOGIN</a></li>
            </ul>
        </div>
        <a href="register.jsp" class="donate-btn-nav text-decoration-none">
            BECOME A DONOR
        </a>
    </div>
</nav>

<!-- Hero Section -->
<div class="hero-banner">
    <div class="hero-overlay"></div>
    <div class="container hero-content py-5 d-flex flex-column align-items-center text-center">
        
        <!-- Redesigned Hero Title -->
        <div class="mb-5 fade-in-up">
            <h1 class="hero-title">LifeFlow <span style="color: var(--brand-orange)">Connects</span> Donors & Hospitals</h1>
            <p class="text-light fs-5 mx-auto opacity-75" style="max-width: 700px; text-shadow: 0 2px 10px rgba(0,0,0,0.5);">
                Experience a completely modern seamless approach to finding the blood your patients need. Instant updates. Real-time availability.
            </p>
        </div>
        
        <!-- Trendy Dynamic Search Component -->
        <div class="search-pill-container fade-in-up" style="animation-delay: 200ms;">
            <form action="findBloodBank.jsp" method="get" class="d-flex flex-wrap p-2 w-100 align-items-center justify-content-between">
                
                <div class="search-field is-select position-relative px-3 py-3 py-lg-2 flex-grow-1 align-items-center d-flex border-end border-secondary border-opacity-25 border-end-sm">
                    <i class="fa-solid fa-droplet text-danger me-3 fs-5"></i>
                    <select class="custom-select-clean" name="bloodGroup" aria-label="Blood Group">
                        <option value="" selected disabled>Blood Group</option>
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

                <div class="search-field is-select position-relative px-3 py-3 py-lg-2 flex-grow-1 align-items-center d-flex border-end border-secondary border-opacity-25 border-end-sm">
                    <i class="fa-solid fa-map text-secondary me-3 fs-5" style="opacity: 0.7;"></i>
                    <select class="custom-select-clean" id="stateSelect" aria-label="State">
                        <option value="" selected disabled>Select State</option>
                    </select>
                </div>

                <div class="search-field is-select position-relative px-3 py-3 py-lg-2 flex-grow-1 align-items-center d-flex border-end border-secondary border-opacity-25 border-end-sm">
                    <i class="fa-solid fa-city text-secondary me-3 fs-5" style="opacity: 0.7;"></i>
                    <select class="custom-select-clean" id="districtSelect" name="city" aria-label="District" required>
                        <option value="" selected disabled>Select District</option>
                    </select>
                    <input type="hidden" name="pincode" value="">
                </div>

                <div class="search-button-wrapper px-2">
                    <button type="submit" class="btn btn-search-pill text-nowrap">
                        <i class="fa-solid fa-magnifying-glass me-2"></i> SEARCH
                    </button>
                </div>
                
            </form>
        </div>
        
        <div class="d-flex justify-content-center mt-5 pt-3 gap-5 fade-in-up" style="animation-delay: 400ms;">
            <a href="findBloodBank.jsp" class="circle-action">
                <i class="fa-solid fa-heart-pulse" style="color:white;"></i>
                <span>Explore<br>Clinics</span>
            </a>
            <a href="register.jsp" class="circle-action">
                <i class="fa-solid fa-hand-holding-heart" style="color:white;"></i>
                <span>Become<br>Donor</span>
            </a>
        </div>
        
    </div>
</div>

<!-- Promo Strip -->
<div class="promo-strip">
    <div class="promo-item">DONOR NETWORK</div>
    <div class="promo-item">HOSPITALS</div>
    <div class="promo-item">BLOOD BANKS</div>
</div>

<!-- Why Donate Section -->
<div class="container why-donate-section">
    <div class="row align-items-center">
        <div class="col-md-5 text-center mb-4 mb-md-0">
            <img src="<%=request.getContextPath()%>/assets/img/hold_heart_blood.png" alt="Why Donate" class="why-donate-img">
        </div>
        <div class="col-md-7 px-md-5">
            <h2 class="why-donate-title">Save Lives with LifeFlow</h2>
            <p class="why-donate-text">
                LifeFlow is a modern platform that helps hospitals and blood banks seamlessly connect with active donors. Thousands of units are required daily, and continuous supply relies entirely on voluntary donors like you.<br><br>
                Become a registered donor on LifeFlow to get regular updates on local emergencies, track your contributions, and receive official certificates for every successful donation. Join our life-saving community today.
            </p>
            <a href="register.jsp" class="btn btn-outline-dark-custom btn-outline-dark">BE A DONOR</a>
        </div>
    </div>
</div>

<!-- Stats Section -->
<div class="container-fluid stats-section">
    <h2 class="stats-title">LifeFlow Network</h2>
    <p class="stats-subtitle fs-5">Technology <span>empowering</span> life savers</p>
    
    <p class="text-muted mb-5 mx-auto" style="max-width: 800px;">
        Our integrated modern database ensures zero delays during emergency blood demands through instant SMS tracking and real-time dashboard updates across all integrated clinics.
    </p>

    <div class="container">
        <div class="row text-center mb-4 g-2 justify-content-center">
            <div class="col-6 col-md-2 mb-4">
                <a href="register.jsp" class="text-decoration-none text-dark">
                    <div class="stat-circle mx-auto"><i class="fa-solid fa-user-plus"></i></div>
                    <div class="stat-label mt-2">Donor Registration</div>
                </a>
            </div>
            <div class="col-6 col-md-2 mb-4">
                <a href="findBloodBank.jsp" class="text-decoration-none text-dark">
                    <div class="stat-circle mx-auto"><i class="fa-solid fa-magnifying-glass"></i></div>
                    <div class="stat-label mt-2">Clinic Search</div>
                </a>
            </div>
            <div class="col-6 col-md-2 mb-4">
                <a href="login.jsp" class="text-decoration-none text-dark">
                    <div class="stat-circle mx-auto"><i class="fa-solid fa-bell"></i></div>
                    <div class="stat-label mt-2">Emergency Alerts</div>
                </a>
            </div>
            <div class="col-6 col-md-2 mb-4">
                <a href="login.jsp" class="text-decoration-none text-dark">
                    <div class="stat-circle mx-auto"><i class="fa-solid fa-file-contract"></i></div>
                    <div class="stat-label mt-2">Certificates</div>
                </a>
            </div>
            <div class="col-6 col-md-2 mb-4">
                <a href="login.jsp" class="text-decoration-none text-dark">
                    <div class="stat-circle mx-auto"><i class="fa-solid fa-chart-line"></i></div>
                    <div class="stat-label mt-2">Analytics Dashboard</div>
                </a>
            </div>
        </div>
        <a href="login.jsp" class="see-more-link">LOGIN TO DASHBOARD</a>
    </div>
</div>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-4">
                <div class="brand-logo-text mb-3">
                    <i class="fa-solid fa-heart-pulse"></i>
                    <div>LifeFlow <span>Premium Blood Bank</span></div>
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
            <div class="footer-social mb-4">
                <a href="#" class="social-icon"><i class="fa-brands fa-github"></i></a>
                <a href="#" class="social-icon"><i class="fa-brands fa-twitter"></i></a>
                <a href="#" class="social-icon"><i class="fa-brands fa-linkedin-in"></i></a>
            </div>
            <h3>LifeFlow</h3>
            <p class="mb-0 text-muted" style="font-size: 0.85rem;">Copyright © 2026. All Rights Reserved.<br>Designed & Developed by <span style="color:var(--brand-orange)">Vj</span></p>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", async function() {
        const stateSelect = document.getElementById("stateSelect");
        const districtSelect = document.getElementById("districtSelect");
        let locationData = null;

        try {
            const response = await fetch("https://raw.githubusercontent.com/sab99r/Indian-States-And-Districts/master/states-and-districts.json");
            locationData = await response.json();
            
            if (locationData && locationData.states) {
                locationData.states.forEach(stateObj => {
                    const option = document.createElement("option");
                    option.value = stateObj.state;
                    option.textContent = stateObj.state;
                    stateSelect.appendChild(option);
                });
            }
        } catch(e) {
            console.error("Could not load India static data", e);
            stateSelect.innerHTML = '<option value="" disabled selected>Error loading geography</option>';
        }

        stateSelect.addEventListener("change", function() {
            districtSelect.innerHTML = '<option value="" selected disabled>Select District</option>';
            const selectedState = this.value;
            if(!locationData || !locationData.states) return;
            
            const stateObj = locationData.states.find(s => s.state === selectedState);
            if(stateObj && stateObj.districts) {
                stateObj.districts.forEach(district => {
                    const option = document.createElement("option");
                    option.value = district; // API uses this as city arg
                    option.textContent = district;
                    districtSelect.appendChild(option);
                });
            }
        });
    });
</script>
</body>
</html>
