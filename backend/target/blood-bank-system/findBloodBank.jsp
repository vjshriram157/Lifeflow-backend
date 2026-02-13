<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Find Blood Bank | LifeFlow</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background: #f9fafb;
                font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            }

            .navbar-brand span {
                color: #b71c1c;
                font-weight: 700;
            }

            .card-elevated {
                border-radius: 1rem;
                border: none;
                box-shadow: 0 18px 45px rgba(15, 23, 42, 0.12);
            }

            .accent-pill {
                background: rgba(183, 28, 28, 0.08);
                color: #b71c1c;
                border-radius: 999px;
                padding: 4px 14px;
                font-size: 0.75rem;
                letter-spacing: 0.08em;
                text-transform: uppercase;
                font-weight: 600;
            }

            .bank-row:hover {
                background: #f1f5f9;
                transition: background 0.18s ease-out;
            }

            .badge-stock-safe {
                background-color: #22c55e;
            }

            .badge-stock-low {
                background-color: #f59e0b;
            }

            .badge-stock-critical {
                background-color: #dc2626;
            }

            .btn-crimson {
                background: linear-gradient(135deg, #b71c1c, #e11d48);
                border: none;
                color: #fff;
            }

            .btn-crimson:hover {
                background: linear-gradient(135deg, #991b1b, #be123c);
                color: #fff;
            }

            .distance-chip {
                font-size: 0.8rem;
                padding: 4px 10px;
                border-radius: 999px;
                background: #e5e7eb;
            }
        </style>
    </head>

    <body>
        <nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom sticky-top">
            <div class="container">
                <a class="navbar-brand" href="#">
                    <span>LifeFlow</span> Blood Network
                </a>
            </div>
        </nav>

        <main class="py-5">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-10">
                        <div class="card card-elevated">
                            <div class="card-body p-4 p-md-5">
                                <div class="d-flex justify-content-between align-items-start mb-4 flex-wrap gap-2">
                                    <div>
                                        <div class="accent-pill mb-2">
                                            Find a Nearby Blood Bank
                                        </div>
                                        <h1 class="h4 mb-1">Search, Compare &amp; Navigate in Seconds</h1>
                                        <p class="text-muted mb-0">
                                            Enter your city/pin or share your location to see approved blood banks
                                            ranked by distance and availability.
                                        </p>
                                    </div>
                                    <div class="text-md-end">
                                        <button id="btnUseLocation" class="btn btn-outline-danger btn-sm">
                                            Use my location
                                        </button>
                                        <small class="d-block text-muted mt-1" style="font-size: 0.75rem;">
                                            We only use your location for this search.
                                        </small>
                                    </div>
                                </div>

                                <form id="searchForm" class="row g-3 align-items-end mb-4">
                                    <div class="col-md-4">
                                        <label for="city" class="form-label">City / Area</label>
                                        <input type="text" class="form-control" id="city"
                                            placeholder="e.g., Pune, Andheri">
                                    </div>
                                    <div class="col-md-3">
                                        <label for="pincode" class="form-label">Pin Code</label>
                                        <input type="text" class="form-control" id="pincode" placeholder="411001">
                                    </div>
                                    <div class="col-md-3">
                                        <label for="bloodGroup" class="form-label">Blood Group (optional)</label>
                                        <select id="bloodGroup" class="form-select">
                                            <option value="">Any Group</option>
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
                                    <div class="col-md-2 d-grid">
                                        <button type="button" id="btnSearch" class="btn btn-crimson">
                                            Search
                                        </button>
                                    </div>
                                </form>

                                <div id="resultsMeta" class="d-flex justify-content-between align-items-center mb-2"
                                    style="display:none;">
                                    <span class="text-muted" id="resultCount"></span>
                                    <span class="text-muted" style="font-size: 0.8rem;">
                                        Distances are approximate using the Haversine formula.
                                    </span>
                                </div>

                                <div class="table-responsive">
                                    <table class="table align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Blood Bank</th>
                                                <th>Location</th>
                                                <th>Distance</th>
                                                <th class="text-center">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody id="resultsBody">
                                            <tr id="noResultsRow">
                                                <td colspan="4" class="text-center text-muted py-4">
                                                    Start by searching with your city/pin or using your current
                                                    location.
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
                    meta.style.display = 'none';
                    const row = document.createElement('tr');
                    row.innerHTML = '<td colspan="4" class="text-center text-muted py-4">No approved blood banks found near this location.</td>';
                    body.appendChild(row);
                    return;
                }

                meta.style.display = 'flex';
                countEl.textContent = `\${banks.length} blood bank(s) found`;


                banks.forEach(bank => {
                    const row = document.createElement('tr');
                    row.classList.add('bank-row');
                    row.innerHTML = `
                <td>
                    <div class="fw-semibold">\${bank.name}</div>
                    <div class="text-muted" style="font-size: 0.85rem;">ID: \${bank.id}</div>
                </td>
                <td>
                    <div>\${bank.addressLine1 || ''}</div>
                    <div class="text-muted" style="font-size: 0.85rem;">\${bank.city || ''} \${bank.pincode || ''}</div>
                </td>
                <td>
                    <span class="distance-chip">
                        ~\${bank.distanceKm.toFixed(1)} km
                    </span>
                </td>
                <td class="text-center">
                    <div class="btn-group btn-group-sm" role="group">
                        <a href="\${createDirectionsUrl(bank.latitude, bank.longitude, bank.name)}"
                           target="_blank"
                           class="btn btn-outline-secondary">
                            Get Directions
                        </a>
                        <button type="button"
                                class="btn btn-crimson"
                                onclick="onBookAppointment(\${bank.id})">
                            Book Appointment
                        </button>
                    </div>
                </td>
            `;

                    body.appendChild(row);
                });
            }

            function onBookAppointment(bankId) {
                // Placeholder: wire into your booking flow
                alert('Redirecting to booking flow for bank ID: ' + bankId);
            }

            async function searchByLocation(lat, lng) {
                const bloodGroup = document.getElementById('bloodGroup').value;
                const url = new URL(apiBase, window.location.origin);
                url.searchParams.set('lat', lat);
                url.searchParams.set('lng', lng);
                url.searchParams.set('radiusKm', '25');
                if (bloodGroup) {
                    url.searchParams.set('bloodGroup', bloodGroup);
                }

                const body = document.getElementById('resultsBody');
                body.innerHTML = `
            <tr>
                <td colspan="4" class="text-center py-4">
                    <div class="spinner-border text-danger" role="status" style="width: 1.75rem; height: 1.75rem;">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </td>
            </tr>
        `;

                try {
                    const resp = await fetch(url.toString());
                    const data = await resp.json();
                    renderResults(data.banks || []);
                } catch (e) {
                    body.innerHTML = `
                <tr>
                    <td colspan="4" class="text-center text-danger py-4">
                        Something went wrong while fetching results.
                    </td>
                </tr>
            `;
                }
            }

            document.getElementById('btnUseLocation').addEventListener('click', () => {
                if (!navigator.geolocation) {
                    alert('Geolocation is not supported by this browser.');
                    return;
                }
                navigator.geolocation.getCurrentPosition(
                    (pos) => {
                        searchByLocation(pos.coords.latitude, pos.coords.longitude);
                    },
                    () => {
                        alert('Unable to access your location. Please allow location permission or search by city/pin.');
                    },
                    { enableHighAccuracy: true, timeout: 10000 }
                );
            });


            async function searchByAddress(city, pincode) {
                const bloodGroup = document.getElementById('bloodGroup').value;
                const url = new URL(apiBase, window.location.origin);
                if (city) url.searchParams.set('city', city);
                if (pincode) url.searchParams.set('pincode', pincode);
                url.searchParams.set('radiusKm', '25');
                if (bloodGroup) url.searchParams.set('bloodGroup', bloodGroup);

                const body = document.getElementById('resultsBody');
                body.innerHTML = `
            <tr>
                <td colspan="4" class="text-center py-4">
                    <div class="spinner-border text-danger" role="status" style="width: 1.75rem; height: 1.75rem;">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </td>
            </tr>
        `;

                try {
                    const resp = await fetch(url.toString());
                    const data = await resp.json();

                    if (data.error) {
                        body.innerHTML = `
                    <tr><td colspan="4" class="text-center text-danger py-4">\${data.error}</td></tr>
                `;
                        return;
                    }

                    renderResults(data.banks || []);
                } catch (e) {
                    body.innerHTML = `
                <tr>
                    <td colspan="4" class="text-center text-danger py-4">
                        Something went wrong while fetching results.
                    </td>
                </tr>
            `;
                }
            }

            document.getElementById('btnSearch').addEventListener('click', () => {
                const city = document.getElementById('city').value.trim();
                const pincode = document.getElementById('pincode').value.trim();

                if (!city && !pincode) {
                    alert('Please enter a City or Pincode to search.');
                    return;
                }

                searchByAddress(city, pincode);
            });

        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>