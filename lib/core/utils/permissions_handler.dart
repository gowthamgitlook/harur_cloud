import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class PermissionsHandler {
  PermissionsHandler._();

  /// Senior Approach: Explain WHY before asking
  static Future<bool> requestLocationPermissionWithDialog(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    if (!context.mounted) return false;

    // Trending UX: Pre-permission dialog
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLG)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primaryRed),
            SizedBox(width: 10),
            Text('Use Location?'),
          ],
        ),
        content: const Text(
          'Allowing location access helps us provide accurate delivery times and find the nearest restaurants for you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NOT NOW', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('ALLOW'),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Location Error: $e');
      return null;
    }
  }

  /// Pick image helper
  static Future<XFile?> showImagePicker(BuildContext context) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryRed),
              title: const Text('Take a photo'),
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.camera);
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryRed),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.gallery);
                if (context.mounted) Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
