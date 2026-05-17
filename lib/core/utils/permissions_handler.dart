import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/glass_theme.dart';

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

  /// Make phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error making phone call: $e');
      return false;
    }
  }

  /// Launch email
  static Future<bool> launchEmail(Uri emailUri) async {
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error launching email: $e');
      return false;
    }
  }

  /// Pick image helper
  static Future<XFile?> showImagePicker(BuildContext context) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => GlassMorphism(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Select Source',
                style: GlassTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final file = await picker.pickImage(source: ImageSource.camera);
                      if (context.mounted) Navigator.pop(context, file);
                    },
                  ),
                  _buildPickerOption(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (context.mounted) Navigator.pop(context, file);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GlassTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: GlassTheme.primaryBlue, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GlassTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: GlassTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
