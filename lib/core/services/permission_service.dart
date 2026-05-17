import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  PermissionService._();

  static Future<void> requestInitialPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.camera,
        Permission.microphone,
        Permission.notification,
      ].request();
      
      statuses.forEach((permission, status) {
        debugPrint('Permission $permission: $status');
      });
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  static Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }
}
