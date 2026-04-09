import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Basic FCM emergency notification handler.
///
/// Expects payloads like:
/// {
///   "notification": { "title": "...", "body": "..." },
///   "data": {
///     "type": "EMERGENCY_ALERT",
///     "alertId": "...",
///     "bankId": "...",
///     "bloodGroup": "O+"
///   }
/// }
class EmergencyNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;
  // Provide userId and backend base URL at app level.
  int? userId;
  String apiBase = 'http://10.0.2.2:9090/blood-bank';

  EmergencyNotificationService({required this.navigatorKey});

  Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and save the device token + last known location (POST to /api/register-device)
    final token = await _messaging.getToken();
    if (token != null && userId != null) {
      await _registerDevice(token);
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedAppMessage);

    // Handle if app was opened from a terminated state by a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigationFromMessage(initialMessage);
    }
  }

  Future<void> _registerDevice(String token) async {
    try {
      double? lat;
      double? lng;

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        // ignore location failures for registration
      }

      final uri = Uri.parse('$apiBase/api/register-device');
      final body = {
        'userId': userId.toString(),
        'token': token,
        'platform': 'ANDROID', // or IOS, depending on current platform
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
      };

      await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
    } catch (e) {
      // best-effort; log if needed
      debugPrint('Device registration failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    if (message.data['type'] == 'EMERGENCY_ALERT') {
      final title = message.notification?.title ?? 'Emergency Alert';
      final body = message.notification?.body ?? 'A nearby blood bank needs your help.';

      showDialog<void>(
        context: ctx,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleNavigationFromMessage(message);
              },
              child: const Text('Respond now'),
            ),
          ],
        ),
      );
    }
  }

  void _handleOpenedAppMessage(RemoteMessage message) {
    _handleNavigationFromMessage(message);
  }

  void _handleNavigationFromMessage(RemoteMessage message) {
    final type = message.data['type'];
    if (type == 'EMERGENCY_ALERT') {
      final bankId = message.data['bankId'];
      // final alertId = message.data['alertId'];
      // final bloodGroup = message.data['bloodGroup'];

      // TODO: Navigate into your booking flow, ideally with the bankId.
      navigatorKey.currentState?.pushNamed(
        '/blood-bank-finder',
        arguments: {
          'preselectedBankId': bankId,
        },
      );
    }
  }
}

