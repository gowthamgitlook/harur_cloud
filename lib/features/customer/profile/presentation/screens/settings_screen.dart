import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../../core/utils/permissions_handler.dart';
import 'support_screen.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              _buildSectionHeader('Support & Feedback'),
              _buildSettingTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'FAQs, Chat and Call support',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())),
              ),
              _buildSettingTile(
                context,
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Tell us how we can improve',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen())),
              ),

              _buildSectionHeader('App Settings'),
              _buildSettingTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Toggle app theme',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (v) => themeProvider.toggleTheme(),
                  activeColor: AppColors.primaryRed,
                ),
              ),
              _buildSettingTile(
                context,
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Manage app alerts',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeColor: AppColors.primaryRed,
                ),
              ),

              _buildSectionHeader('Permissions'),
              _buildSettingTile(
                context,
                icon: Icons.location_on_outlined,
                title: 'Location Access',
                subtitle: 'Manage location permissions',
                onTap: () => PermissionsHandler.openAppSettings(),
              ),
              _buildSettingTile(
                context,
                icon: Icons.camera_alt_outlined,
                title: 'Camera Access',
                subtitle: 'Used for QR and profile photos',
                onTap: () => PermissionsHandler.openAppSettings(),
              ),

              _buildSectionHeader('More'),
              _buildSettingTile(
                context,
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.0.0 (Staging)',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: AppStrings.appName,
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.restaurant_menu, color: AppColors.primaryRed, size: 40),
                  );
                },
              ),
              
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {required IconData icon, required String title, required String subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryRed, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
    );
  }
}
