<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Find Blood Bank | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
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
        .btn-locator {
            border: 1px solid rgba(225, 29, 72, 0.3);
            color: var(--primary-crimson);
            background: rgba(225, 29, 72, 0.05);
            transition: var(--transition-smooth);
        }
        .btn-locator:hover {
            background: var(--primary-crimson);
            color: white;
        }
        .distance-chip {
            background: var(--surface-main);
            color: var(--text-muted);
            border: 1px solid #e2e8f0;
            padding: 4px 12px;
            border-radius: 50rem;
            font-size: 0.8rem;
            font-weight: 600;
        }
    </style>
</head>
<body>

    <nav class="navbar navbar-expand-lg navbar-dark bg-dark py-3" style="background: var(--sidebar-bg) !important;">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center gap-2" href="<%=request.getContextPath()%>/index.jsp">
                <i class="fa-solid fa-droplet text-danger"></i>
                <span style="font-family: 'Poppins'; font-weight: 700;">Life<span class="text-danger">Flow</span> Network</span>
            </a>
            <div>
                <a href="login.jsp" class="btn btn-outline-light btn-sm rounded-pill px-3">Sign In</a>
            </div>
        </div>
    </nav>

    <div class="page-header">
        <div class="container fade-in-up">
            <div class="accent-pill mb-3"><i class="fa-solid fa-location-dot me-2"></i> Locator</div>
            <h1 class="brand-font display-5 fw-bold mb-3">Find a Nearby Blood Bank</h1>
            <p class="lead text-white-50 mx-auto" style="max-width: 600px;">
                Search, compare, and instantly map routes to authorized blood banks in your vicinity.
            </p>
        </div>
    </div>

    <main class="main-container pb-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10 fade-in-up delay-100">
                    <div class="card card-modern p-2 p-md-4">
                        <div class="card-body">
                            
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4 pb-3 border-bottom border-light">
                                <h5 class="mb-0 fw-bold"><i class="fa-solid fa-magnifying-glass me-2 text-danger"></i> Search Criteria</h5>
                                <button id="btnUseLocation" class="btn btn-locator rounded-pill btn-sm fw-bold px-3 py-2">
                                    <i class="fa-solid fa-location-crosshairs me-1"></i> Use My GPS
                                </button>
                            </div>

                            <form id="searchForm" class="row g-3 align-items-end mb-4">
                                <div class="col-md-5">
                                    <label for="city" class="form-label">City / Region</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-0"><i class="fa-solid fa-city text-muted"></i></span>
                                        <input type="text" class="form-control form-control-modern bg-light border-0" id="city" placeholder="e.g., Manhattan">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label for="pincode" class="form-label">Postal Code</label>
                                    <input type="text" class="form-control form-control-modern bg-light border-0" id="pincode" placeholder="10001">
                                </div>
                                <div class="col-md-4">
                                    <label for="bloodGroup" class="form-label">Blood Group</label>
                                    <select id="bloodGroup" class="form-select form-control-modern bg-light border-0">
                                        <option value="">Any Available</option>
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
                                <div class="col-12 text-end mt-4">
                                    <button type="button" id="btnSearch" class="btn btn-premium px-5 rounded-pill">
                                        Search Facilities <i class="fa-solid fa-arrow-right ms-2"></i>
                                    </button>
                                </div>
                            </form>

                            <div id="resultsMeta" class="d-flex justify-content-between align-items-center mb-3 mt-5" style="display:none !important;">
                                <h6 class="fw-bold mb-0">Results Found: <span id="resultCount" class="text-danger"></span></h6>
                                <span class="text-muted" style="font-size: 0.8rem;"><i class="fa-solid fa-satellite me-1"></i> Calculated via Haversine 25km radius</span>
                            </div>

                            <div class="table-responsive">
                                <table class="table table-modern align-middle mb-0">
                                    <thead class="bg-light">
                                        <tr>
                                            <th>Facility Details</th>
                                            <th>Location</th>
                                            <th>Est. Distance</th>
                                            <th class="text-center">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="resultsBody">
                                        <tr id="noResultsRow">
                                            <td colspan="4" class="text-center text-muted py-5">
                                                <i class="fa-solid fa-map-location-dot h2 text-light mb-3"></i><br>
                                                Start searching by city, pin code, or your device GPS.
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        const apiBase = '<%= request.getContextPath() %>/api/locator';

        function createDirectionsUrl(lat, lng, label) {
            const encodedLabel = encodeURIComponent(label || 'Blood Bank');
            return `https://www.google.com/maps/dir/?api=1&destination=\${lat},\${lng}&destination_place_id=\${encodedLabel}`;
        }

        function renderResults(banks) {
            const body = document.getElementById('resultsBody');
            const meta = document.getElementById('resultsMeta');
            const countEl = document.getElementById('resultCount');
            body.innerHTML = '';

            if (!banks || banks.length === 0) {
                meta.style.setProperty('display', 'none', 'important');
                const row = document.createElement('tr');
                row.innerHTML = '<td colspan="4" class="text-center text-muted py-5 bg-light rounded"><i class="fa-solid fa-magnifying-glass-location h2 text-secondary mb-3"></i><br>No approved blood banks found matching the criteria.</td>';
                body.appendChild(row);
                return;
            }

            meta.style.setProperty('display', 'flex', 'important');
            countEl.textContent = banks.length;

            banks.forEach((bank, index) => {
                const row = document.createElement('tr');
                row.classList.add('fade-in-up');
                row.style.animationDelay = `\${index * 50}ms`;
                row.innerHTML = `
            <td>
                <div class="fw-bold text-dark">\${bank.name}</div>
                <div class="text-muted" style="font-size: 0.8rem;"><i class="fa-solid fa-id-badge me-1"></i> ID #\${bank.id}</div>
            </td>
            <td>
                <div class="text-dark">\${bank.addressLine1 || '-'}</div>
                <div class="text-muted" style="font-size: 0.85rem;">\${bank.city || ''} \${bank.pincode || ''}</div>
            </td>
            <td>
                <span class="distance-chip">
                    <i class="fa-solid fa-route me-1 text-danger"></i> ~\${bank.distanceKm.toFixed(1)} km
                </span>
            </td>
            <td class="text-center">
                <a href="\${createDirectionsUrl(bank.latitude, bank.longitude, bank.name)}"
                   target="_blank"
                   class="btn btn-outline-dark btn-sm rounded-pill px-3 me-2">
                    <i class="fa-solid fa-diamond-turn-right"></i> Maps
                </a>
                <button type="button"
                        class="btn btn-premium btn-sm rounded-pill px-3"
                        onclick="onBookAppointment(\${bank.id})">
                    Book <i class="fa-solid fa-calendar-check ms-1"></i>
                </button>
            </td>
        `;
                body.appendChild(row);
            });
        }

        function onBookAppointment(bankId) {
            alert('To book an appointment at ID ' + bankId + ', please Sign In via the Donor Dashboard.');
            window.location.href = '<%=request.getContextPath()%>/login.jsp';
        }

        async function searchByLocation(lat, lng) {
            const bloodGroup = document.getElementById('bloodGroup').value;
            const url = new URL(apiBase, window.location.origin);
            url.searchParams.set('lat', lat);
            url.searchParams.set('lng', lng);
            url.searchParams.set('radiusKm', '50'); // Increased radius
            if (bloodGroup) url.searchParams.set('bloodGroup', bloodGroup);

            setLoading();
            try {
                const resp = await fetch(url.toString());
                const data = await resp.json();
                renderResults(data.banks || []);
            } catch (e) {
                setError();
            }
        }

        document.getElementById('btnUseLocation').addEventListener('click', () => {
            if (!navigator.geolocation) {
                alert('Geolocation is not supported by your browser.');
                return;
            }
            document.getElementById('btnUseLocation').innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Locating...';
            navigator.geolocation.getCurrentPosition(
                (pos) => {
                    document.getElementById('btnUseLocation').innerHTML = '<i class="fa-solid fa-location-crosshairs me-1"></i> Use My GPS';
                    searchByLocation(pos.coords.latitude, pos.coords.longitude);
                },
                () => {
                    document.getElementById('btnUseLocation').innerHTML = '<i class="fa-solid fa-location-crosshairs me-1"></i> Use My GPS';
                    alert('Unable to access location. Ensure tracking is permitted or manually search City/Pin.');
                },
                { enableHighAccuracy: true, timeout: 10000 }
            );
        });

        async function searchByAddress(city, pincode) {
            const bloodGroup = document.getElementById('bloodGroup').value;
            const url = new URL(apiBase, window.location.origin);
            if (city) url.searchParams.set('city', city);
            if (pincode) url.searchParams.set('pincode', pincode);
            url.searchParams.set('radiusKm', '50');
            if (bloodGroup) url.searchParams.set('bloodGroup', bloodGroup);

            setLoading();
            try {
                const resp = await fetch(url.toString());
                const data = await resp.json();
                if (data.error) {
                    const body = document.getElementById('resultsBody');
                    body.innerHTML = `<tr><td colspan="4" class="text-center text-danger py-5">\${data.error}</td></tr>`;
                    return;
                }
                renderResults(data.banks || []);
            } catch (e) {
                setError();
            }
        }

        document.getElementById('btnSearch').addEventListener('click', () => {
            const city = document.getElementById('city').value.trim();
            const pincode = document.getElementById('pincode').value.trim();

            if (!city && !pincode) {
                alert('Please enter a City or Postal Code to search by address.');
                return;
            }
            searchByAddress(city, pincode);
        });

        function setLoading() {
            document.getElementById('resultsBody').innerHTML = `
            <tr>
                <td colspan="4" class="text-center py-5">
                    <div class="spinner-border text-danger" role="status"></div>
                    <div class="mt-2 text-muted fw-bold">Querying Data...</div>
                </td>
            </tr>`;
        }
        function setError() {
            document.getElementById('resultsBody').innerHTML = `
            <tr>
                <td colspan="4" class="text-center text-danger py-5 fw-bold">
                    <i class="fa-solid fa-triangle-exclamation h3"></i><br>
                    Network failure extracting resources.
                </td>
            </tr>`;
        }
    </script>
</body>
</html>