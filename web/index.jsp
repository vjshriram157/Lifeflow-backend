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
        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            background: linear-gradient(135deg, rgba(15,23,42,0.95), rgba(15,23,42,0.85)), url('https://images.unsplash.com/photo-1615461066841-6116e61058f4?auto=format&fit=crop&q=80&w=2000') no-repeat center center;
            background-size: cover;
            color: white;
            text-align: center;
            overflow: hidden;
        }
        .hero-blob {
            position: absolute;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, var(--primary-crimson) 0%, transparent 70%);
            opacity: 0.15;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            border-radius: 50%;
            pointer-events: none;
            z-index: 1;
        }
        .hero-content {
            position: relative;
            z-index: 2;
            max-width: 800px;
            padding: 2rem;
        }
        .brand-text {
            font-size: 4.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            letter-spacing: -1.5px;
            line-height: 1.1;
        }
        .brand-text span {
            color: var(--primary-crimson);
            position: relative;
        }
        .tagline {
            font-size: 1.35rem;
            color: #cbd5e1;
            margin-bottom: 3rem;
            font-weight: 300;
            line-height: 1.6;
        }
        .action-cards {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-top: 4rem;
            flex-wrap: wrap;
        }
        .feature-card {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius-xl);
            padding: 2.5rem 2rem;
            min-width: 280px;
            flex: 1;
            transition: var(--transition-smooth);
            cursor: pointer;
            text-align: left;
        }
        .feature-card:hover {
            transform: translateY(-8px);
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(225, 29, 72, 0.4);
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }
        .feature-icon {
            font-size: 2.5rem;
            color: var(--primary-crimson);
            margin-bottom: 1.5rem;
        }
        .feature-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: white;
        }
        .feature-desc {
            color: #94a3b8;
            font-size: 0.95rem;
            margin: 0;
            font-family: 'Inter', sans-serif;
        }
        @media(max-width: 768px) {
            .brand-text { font-size: 3rem; }
            .action-cards { flex-direction: column; gap: 1rem; }
        }
    </style>
</head>
<body>

<div class="hero-section">
    <div class="hero-blob"></div>
    <div class="hero-content">
        <h1 class="brand-text fade-in-up">Life<span>Flow</span></h1>
        <p class="tagline fade-in-up delay-100">
            A state-of-the-art platform connecting life-saving donors with those in critical need. Experience seamless, ultra-fast blood bank management.
        </p>

        <div class="d-flex gap-3 justify-content-center fade-in-up delay-200">
            <a href="login.jsp" class="btn btn-premium rounded-pill px-5 py-3 fs-5">Sign In</a>
            <a href="register.jsp" class="btn btn-outline-light rounded-pill px-5 py-3 fs-5" style="border-width: 2px;">Register</a>
        </div>

        <div class="action-cards fade-in-up delay-300">
            <a href="findBloodBank.jsp" class="text-decoration-none">
                <div class="feature-card">
                    <i class="fa-solid fa-droplet feature-icon"></i>
                    <h5 class="feature-title">Find Blood Instantly</h5>
                    <p class="feature-desc">Locate the nearest active blood banks with real-time stock availability and automated distance radius tracking.</p>
                </div>
            </a>
            <a href="register.jsp" class="text-decoration-none">
                <div class="feature-card">
                    <i class="fa-solid fa-heart-pulse feature-icon"></i>
                    <h5 class="feature-title">Donate & Save Lives</h5>
                    <p class="feature-desc">Join our modern donor network. Schedule appointments, track your contribution history, and earn digital certificates.</p>
                </div>
            </a>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
