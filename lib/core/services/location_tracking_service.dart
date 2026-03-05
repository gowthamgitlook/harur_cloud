import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Service for real-time location tracking
/// Tracks delivery partner location and broadcasts to all listeners
class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  // Stream controller for broadcasting location updates
  final _locationStreamController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationStreamController.stream;

  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  Position? _lastKnownPosition;

  bool get isTracking => _isTracking;
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Start tracking location (for delivery partners)
  Future<bool> startTracking() async {
    if (_isTracking) {
      debugPrint('Location tracking already started');
      return true;
    }

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        return false;
      }

      // Start location stream
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _lastKnownPosition = position;
        _locationStreamController.add(position);
        debugPrint('Location updated: ${position.latitude}, ${position.longitude}');
      });

      _isTracking = true;
      debugPrint('Location tracking started');

      // Get initial position
      final position = await Geolocator.getCurrentPosition();
      _lastKnownPosition = position;
      _locationStreamController.add(position);

      return true;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop tracking location
  Future<void> stopTracking() async {
    if (!_isTracking) {
      return;
    }

    await _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    debugPrint('Location tracking stopped');
  }

  /// Get current location once (without tracking)
  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      _lastKnownPosition = position;
      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Dispose service
  void dispose() {
    _positionStream?.cancel();
    _locationStreamController.close();
    _isTracking = false;
  }
}
