import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../config/app_config.dart';

class TrackingService {
  static Future<void> initializeTracking(String orderId) async {
    try {
      final service = FlutterBackgroundService();
      
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
          foregroundServiceNotificationId: 888,
          initialNotificationTitle: 'Delivery in Progress',
          initialNotificationContent: 'Tracking your location for order #$orderId',
        ),
        iosConfiguration: IosConfiguration(
          onForeground: onStart,
          autoStart: true,
        ),
      );
      
      service.startService();
      debugPrint('TRACKING_SERVICE: Initialized for order $orderId');
    } catch (e) {
      debugPrint('TRACKING_SERVICE_ERROR: $e');
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // 1. Initialize Firebase in the background isolate if not in mock mode
    if (!AppConfig.useMockServices) {
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint('TRACKING_SERVICE_FIREBASE_ERROR: $e');
      }
    }

    // 2. Start location stream with safety
    try {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        debugPrint('TRACKING_SERVICE_LOCATION: ${position.latitude}, ${position.longitude}');
        
        if (!AppConfig.useMockServices) {
          FirebaseFirestore.instance
              .collection('deliveries')
              .doc('live_tracking') // Use a shared doc or dynamic ID
              .set({
            'lat': position.latitude,
            'lng': position.longitude,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      debugPrint('TRACKING_SERVICE_STREAM_ERROR: $e');
    }
  }
}
