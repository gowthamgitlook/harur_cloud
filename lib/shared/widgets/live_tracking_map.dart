import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_tracking_service.dart';
import '../../core/theme/glass_theme.dart';

/// Live tracking map widget - Shows real-time delivery partner location
class LiveTrackingMap extends StatefulWidget {
  final double? customerLat;
  final double? customerLng;
  final String deliveryPartnerName;
  final bool showCustomerMarker;

  const LiveTrackingMap({
    super.key,
    this.customerLat,
    this.customerLng,
    this.deliveryPartnerName = 'Delivery Partner',
    this.showCustomerMarker = true,
  });

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  GoogleMapController? _mapController;
  final LocationTrackingService _locationService = LocationTrackingService();
  StreamSubscription<Position>? _locationSubscription;

  Position? _deliveryPartnerPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Default location (Harur, Tamil Nadu)
  static const LatLng _defaultLocation = LatLng(12.0535, 78.4840);

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    // Listen to location updates
    _locationSubscription = _locationService.locationStream.listen((position) {
      if (mounted) {
        setState(() {
          _deliveryPartnerPosition = position;
          _updateMarkers();
          _updatePolyline();
        });

        // Move camera to new position
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    });

    // Get initial position if available
    final lastPosition = _locationService.lastKnownPosition;
    if (lastPosition != null) {
      setState(() {
        _deliveryPartnerPosition = lastPosition;
        _updateMarkers();
        _updatePolyline();
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Add delivery partner marker
    if (_deliveryPartnerPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('delivery_partner'),
          position: LatLng(
            _deliveryPartnerPosition!.latitude,
            _deliveryPartnerPosition!.longitude,
          ),
          infoWindow: InfoWindow(
            title: widget.deliveryPartnerName,
            snippet: 'On the way',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add customer marker
    if (widget.showCustomerMarker &&
        widget.customerLat != null &&
        widget.customerLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: LatLng(widget.customerLat!, widget.customerLng!),
          infoWindow: const InfoWindow(
            title: 'Delivery Location',
            snippet: 'Your location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  void _updatePolyline() {
    _polylines.clear();

    // Draw line between delivery partner and customer
    if (_deliveryPartnerPosition != null &&
        widget.customerLat != null &&
        widget.customerLng != null) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(
              _deliveryPartnerPosition!.latitude,
              _deliveryPartnerPosition!.longitude,
            ),
            LatLng(widget.customerLat!, widget.customerLng!),
          ],
          color: GlassTheme.primaryBlue,
          width: 4,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
        ),
      );
    }
  }

  String _calculateDistance() {
    if (_deliveryPartnerPosition == null ||
        widget.customerLat == null ||
        widget.customerLng == null) {
      return 'Calculating...';
    }

    final distance = _locationService.calculateDistance(
      _deliveryPartnerPosition!.latitude,
      _deliveryPartnerPosition!.longitude,
      widget.customerLat!,
      widget.customerLng!,
    );

    if (distance < 1000) {
      return '${distance.toInt()} m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km away';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine initial camera position
    LatLng initialPosition = _defaultLocation;
    if (_deliveryPartnerPosition != null) {
      initialPosition = LatLng(
        _deliveryPartnerPosition!.latitude,
        _deliveryPartnerPosition!.longitude,
      );
    } else if (widget.customerLat != null && widget.customerLng != null) {
      initialPosition = LatLng(widget.customerLat!, widget.customerLng!);
    }

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 15,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            _updateMarkers();
            _updatePolyline();
          },
        ),

        // Distance Card
        if (_deliveryPartnerPosition != null &&
            widget.customerLat != null &&
            widget.customerLng != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: GlassTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delivery_dining,
                        color: GlassTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.deliveryPartnerName,
                            style: TextStyle(
                              color: GlassTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateDistance(),
                            style: TextStyle(
                              color: GlassTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Live',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Loading indicator
        if (_deliveryPartnerPosition == null)
          Center(
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GlassTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Locating delivery partner...',
                      style: TextStyle(
                        color: GlassTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
