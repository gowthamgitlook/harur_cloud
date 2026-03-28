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
  Timer? _simulationTimer;
  bool _isTracking = false;
  bool _isSimulation = false;
  Position? _lastKnownPosition;

  bool get isTracking => _isTracking;
  bool get isSimulation => _isSimulation;
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Start mock simulation (for testing live tracking)
  void startSimulation() {
    if (_isSimulation) return;

    _isSimulation = true;
    _isTracking = true;

    // Simulate path around Harur
    final path = [
      _createMockPosition(12.0540, 78.4822), // Start (Harur)
      _createMockPosition(12.0545, 78.4828),
      _createMockPosition(12.0550, 78.4835),
      _createMockPosition(12.0555, 78.4842),
      _createMockPosition(12.0560, 78.4850),
      _createMockPosition(12.0565, 78.4858), // Moving East
      _createMockPosition(12.0570, 78.4865),
      _createMockPosition(12.0575, 78.4872),
      _createMockPosition(12.0580, 78.4880), // End
    ];

    int index = 0;
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (index >= path.length) {
        index = 0; // Loop path
      }

      final position = path[index];
      _lastKnownPosition = position;
      _locationStreamController.add(position);
      debugPrint('Mock location updated: ${position.latitude}, ${position.longitude}');

      index++;
    });

    debugPrint('Location simulation started');
  }

  /// Stop simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isSimulation = false;
    _isTracking = false;
    debugPrint('Location simulation stopped');
  }

  Position _createMockPosition(double lat, double lng) {
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 10.0, // moving at 10m/s (36km/h)
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

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
