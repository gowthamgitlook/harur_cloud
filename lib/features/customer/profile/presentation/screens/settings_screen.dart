import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harur_cloud_kitchen/core/theme/zomato_theme.dart';
import 'package:harur_cloud_kitchen/core/theme/theme_provider.dart';
import 'package:harur_cloud_kitchen/core/constants/app_routes.dart';

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
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              _buildSectionHeader('Appearance'),
              _buildSettingTile(
                Icons.dark_mode_outlined,
                'Dark Mode',
                'Switch between light and dark theme',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (v) => themeProvider.toggleTheme(),
                  activeColor: ZomatoTheme.primaryRed,
                ),
              ),
              
              _buildSectionHeader('Notifications'),
              _buildSettingTile(
                Icons.notifications_none_outlined,
                'Order Updates',
                'Get real-time tracking alerts',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeColor: ZomatoTheme.primaryRed,
                ),
              ),

              _buildSectionHeader('Account & Privacy'),
              _buildSettingTile(Icons.location_on_outlined, 'Manage Addresses', 'Your delivery locations', 
                onTap: () => Navigator.pushNamed(context, AppRoutes.manageAddresses)),
              _buildSettingTile(Icons.security_outlined, 'Privacy Settings', 'Control your account visibility', onTap: () {}),

              _buildSectionHeader('Help & Support'),
              _buildSettingTile(Icons.help_outline, 'Help Center', 'FAQs and troubleshooting', 
                onTap: () => Navigator.pushNamed(context, AppRoutes.support)),
              _buildSettingTile(Icons.chat_bubble_outline, 'Customer Support', 'Chat with our team', 
                onTap: () => Navigator.pushNamed(context, AppRoutes.support)),

              const SizedBox(height: 40),
              Center(
                child: Text('Harur Cloud v1.7.0', style: TextStyle(color: ZomatoTheme.textTertiary, fontSize: 12)),
              ),
              const SizedBox(height: 20),
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
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: ZomatoTheme.bodyLarge.copyWith(fontSize: 15)),
        subtitle: Text(subtitle, style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }
}
