import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class BloodBankFinderScreen extends StatefulWidget {
  const BloodBankFinderScreen({Key? key}) : super(key: key);

  @override
  State<BloodBankFinderScreen> createState() => _BloodBankFinderScreenState();
}

class _BloodBankFinderScreenState extends State<BloodBankFinderScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  LatLng? _currentLatLng;
  bool _loading = false;
  String? _error;

  static const _initialCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629), // Center on India by default
    zoom: 4.5,
  );

  @override
  void initState() {
    super.initState();
    _initLocationAndSearch();
  }

  Future<void> _initLocationAndSearch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await _determinePosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLatLng = latLng;
      });
      await _moveCamera(latLng);
      await _fetchNearbyBanks();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _moveCamera(LatLng target) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 13),
      ),
    );
  }

  Future<void> _fetchNearbyBanks({String? bloodGroup}) async {
    if (_currentLatLng == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

      // Use 10.0.2.2 for Android Emulator to access host localhost
      final uri = Uri.parse(
        'http://10.0.2.2:9090/blood-bank/api/locator',
      ).replace(queryParameters: {
        'lat': _currentLatLng!.latitude.toString(),
        'lng': _currentLatLng!.longitude.toString(),
        'radiusKm': '25',
        if (bloodGroup != null && bloodGroup.isNotEmpty) 'bloodGroup': bloodGroup,
      });

      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('Server responded with ${resp.statusCode}');
      }

      // Backend returns a JSON List directly
      final List<dynamic> data = json.decode(resp.body);
      final banks = data.cast<Map<String, dynamic>>();

      final markers = <Marker>{};

      // Current user marker
      markers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: _currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );

      for (final bank in banks) {
        final id = bank['id'].toString();
        // Backend key is 'bankName', formatted for frontend
        final name = bank['bankName'] as String? ?? 'Blood Bank'; 
        final lat = (bank['latitude'] as num).toDouble();
        final lng = (bank['longitude'] as num).toDouble();
        // Backend returns distanceKm as a number or string depending on format
        final distanceKm = double.tryParse(bank['distanceKm'].toString()) ?? 0.0;

        markers.add(
          Marker(
            markerId: MarkerId('bank_$id'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: name,
              snippet: '≈ ${distanceKm.toStringAsFixed(1)} km away',
              onTap: () {
                // In a real app, navigate to your Book Appointment screen with this bankId.
                _showBookDialog(context, id, name);
              },
            ),
          ),
        );
      }

      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showBookDialog(BuildContext context, String bankId, String name) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Book at $name'),
        content: const Text(
          'This would open the Book Appointment flow prefilled with this blood bank.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Navigate to your booking route with bankId.
            },
            child: const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Nearby Blood Bank'),
      ),
      body: Column(
        children: [
          if (_loading)
            const LinearProgressIndicator(
              minHeight: 2,
            ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: theme.colorScheme.error.withOpacity(0.06),
              padding: const EdgeInsets.all(8),
              child: Text(
                _error!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Filter by blood group',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      value: null,
                      items: const [
                        DropdownMenuItem(value: 'A+', child: Text('A+')),
                        DropdownMenuItem(value: 'A-', child: Text('A-')),
                        DropdownMenuItem(value: 'B+', child: Text('B+')),
                        DropdownMenuItem(value: 'B-', child: Text('B-')),
                        DropdownMenuItem(value: 'O+', child: Text('O+')),
                        DropdownMenuItem(value: 'O-', child: Text('O-')),
                        DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                        DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      ],
                      onChanged: (value) {
                        _fetchNearbyBanks(bloodGroup: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Recenter',
                    onPressed: () async {
                      if (_currentLatLng != null) {
                        await _moveCamera(_currentLatLng!);
                      } else {
                        await _initLocationAndSearch();
                      }
                    },
                    icon: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              onMapCreated: (controller) => _mapController.complete(controller),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _fetchNearbyBanks(),
        icon: const Icon(Icons.search),
        label: const Text('Refresh Nearby'),
      ),
    );
  }
}

