<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Blog | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { padding-top: 0; }
        .page-header {
            background: linear-gradient(135deg, rgba(15,23,42,1) 0%, rgba(15,23,42,0.85) 100%), url('https://images.unsplash.com/photo-1615461066841-6116e61058f4?auto=format&fit=crop&q=80') center/cover;
            padding: 4rem 0;
            color: white;
            text-align: center;
        }
        .main-container {
            margin-top: -3rem;
            position: relative;
            z-index: 5;
        }
        .accent-pill {
            background: rgba(225, 29, 72, 0.15);
            color: #ff4d6d;
            border-radius: 999px;
            padding: 6px 16px;
            font-size: 0.8rem;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            font-weight: 700;
            display: inline-block;
        }
        /* Blog Cards */
        .card-blog {
            border: none;
            border-radius: 12px;
            overflow: hidden;
            background: #fff;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
            height: 100%;
        }
        .card-blog:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        }
        .blog-img-wrapper {
            height: 200px;
            overflow: hidden;
        }
        .blog-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }
        .card-blog:hover .blog-img {
            transform: scale(1.05);
        }
        .blog-meta {
            font-size: 0.85rem;
            color: #888;
            margin-bottom: 10px;
        }
        .blog-title {
            font-weight: 700;
            color: var(--brand-dark);
            margin-bottom: 15px;
            font-size: 1.25rem;
        }
        .blog-preview {
            color: #555;
            font-size: 0.95rem;
            line-height: 1.6;
        }
        .read-more {
            color: var(--brand-orange);
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.85rem;
            text-decoration: none;
        }
        .read-more:hover { color: var(--primary-crimson); }
        
        /* Nav & Footer */
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
        .footer-social .social-icon { display: inline-flex; width: 40px; height: 40px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.1); align-items: center; justify-content: center; color: #fff; margin: 0 5px; text-decoration: none; }
        .footer-social .social-icon:hover { background: var(--brand-orange); border-color: var(--brand-orange); }
        .footer-bottom { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid rgba(255,255,255,0.05); }
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
        <button class="navbar-toggler text-white bg-dark" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav">
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
        <a href="register.jsp" class="donate-btn-nav text-decoration-none">BECOME A DONOR</a>
    </div>
</nav>

<div class="page-header">
    <div class="container fade-in-up">
        <div class="accent-pill mb-3"><i class="fa-solid fa-book-open me-2"></i> Journal</div>
        <h1 class="display-4 fw-bold mb-3" style="font-family:'Poppins';">LifeFlow Insights</h1>
        <p class="lead text-white-50 mx-auto" style="max-width: 600px;">
            The latest news in healthcare, donor tips, and updates on the evolving blood supply chain network.
        </p>
    </div>
</div>

<main class="main-container pb-5">
    <div class="container fade-in-up delay-100">
        <div class="row g-4">
            
            <div class="col-md-4">
                <div class="card-blog">
                    <div class="blog-img-wrapper">
                        <img src="https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80" class="blog-img" alt="Blog Image">
                    </div>
                    <div class="p-4">
                        <div class="blog-meta"><i class="fa-regular fa-calendar-days me-1"></i> Oct 12, 2026 &nbsp;&bull;&nbsp; <i class="fa-regular fa-heart me-1"></i> Health</div>
                        <h3 class="blog-title">The Lifesaving Power of Platelet Donation</h3>
                        <p class="blog-preview">While whole blood donations are what most people think of, platelets play an essential role for cancer patients undergoing chemotherapy. Learn why we need more active platelet donors immediately.</p>
                        <a href="#" class="read-more">Read Article <i class="fa-solid fa-arrow-right ms-1"></i></a>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-blog">
                    <div class="blog-img-wrapper">
                        <img src="https://images.unsplash.com/photo-1631549916768-4119b2e5f926?auto=format&fit=crop&q=80" class="blog-img" alt="Blog Image">
                    </div>
                    <div class="p-4">
                        <div class="blog-meta"><i class="fa-regular fa-calendar-days me-1"></i> Oct 05, 2026 &nbsp;&bull;&nbsp; <i class="fa-solid fa-flask-vial me-1"></i> Technology</div>
                        <h3 class="blog-title">How LifeFlow's New Smart Locator Works</h3>
                        <p class="blog-preview">We have completely revamped our locator engine to use dynamic dependent geospatial data streams. This ensures you find the exact nearest blood unit with up-to-the-minute stock verification.</p>
                        <a href="#" class="read-more">Read Article <i class="fa-solid fa-arrow-right ms-1"></i></a>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-blog">
                    <div class="blog-img-wrapper">
                        <img src="https://images.unsplash.com/photo-1542884748-2b87b36c6b90?auto=format&fit=crop&q=80" class="blog-img" alt="Blog Image">
                    </div>
                    <div class="p-4">
                        <div class="blog-meta"><i class="fa-regular fa-calendar-days me-1"></i> Sep 28, 2026 &nbsp;&bull;&nbsp; <i class="fa-solid fa-bowl-food me-1"></i> Nutrition</div>
                        <h3 class="blog-title">What to Eat Before Your First Donation</h3>
                        <p class="blog-preview">Donating blood is simple, but feeling optimal afterwards heavily depends on what you consumed 24 hours prior. Here's our top 5 iron-rich meals designed expressly for incoming lifesavers.</p>
                        <a href="#" class="read-more">Read Article <i class="fa-solid fa-arrow-right ms-1"></i></a>
                    </div>
                </div>
            </div>

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
