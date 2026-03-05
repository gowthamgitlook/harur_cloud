import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _orderUpdates = true;
  bool _promotionalOffers = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),
            _buildSettingTile(
              context,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                  _showComingSoonSnackBar(context);
                },
                activeColor: AppColors.primaryOrange,
              ),
            ),

            Divider(height: 1, color: AppColors.divider),

            // Notifications Section
            _buildSectionHeader(context, 'Notifications'),
            _buildSettingTile(
              context,
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Enable push notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  if (!value) {
                    setState(() {
                      _orderUpdates = false;
                      _promotionalOffers = false;
                    });
                  }
                },
                activeColor: AppColors.primaryOrange,
              ),
            ),

            _buildSettingTile(
              context,
              icon: Icons.shopping_bag,
              title: 'Order Updates',
              subtitle: 'Get notified about order status',
              trailing: Switch(
                value: _orderUpdates,
                onChanged: _notificationsEnabled
                    ? (value) => setState(() => _orderUpdates = value)
                    : null,
                activeColor: AppColors.primaryOrange,
              ),
              enabled: _notificationsEnabled,
            ),

            _buildSettingTile(
              context,
              icon: Icons.local_offer,
              title: 'Promotional Offers',
              subtitle: 'Receive offers and discounts',
              trailing: Switch(
                value: _promotionalOffers,
                onChanged: _notificationsEnabled
                    ? (value) => setState(() => _promotionalOffers = value)
                    : null,
                activeColor: AppColors.primaryOrange,
              ),
              enabled: _notificationsEnabled,
            ),

            _buildSettingTile(
              context,
              icon: Icons.volume_up,
              title: 'Notification Sound',
              subtitle: 'Play sound for notifications',
              trailing: Switch(
                value: _soundEnabled,
                onChanged: _notificationsEnabled
                    ? (value) => setState(() => _soundEnabled = value)
                    : null,
                activeColor: AppColors.primaryOrange,
              ),
              enabled: _notificationsEnabled,
            ),

            Divider(height: 1, color: AppColors.divider),

            // App Preferences Section
            _buildSectionHeader(context, 'App Preferences'),
            _buildSettingTile(
              context,
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English (Default)',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => _showComingSoonSnackBar(context),
            ),

            _buildSettingTile(
              context,
              icon: Icons.location_city,
              title: 'Default Location',
              subtitle: 'Harur, Tamil Nadu',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => _showComingSoonSnackBar(context),
            ),

            Divider(height: 1, color: AppColors.divider),

            // Data & Privacy Section
            _buildSectionHeader(context, 'Data & Privacy'),
            _buildSettingTile(
              context,
              icon: Icons.storage,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => _showClearCacheDialog(context),
            ),

            _buildSettingTile(
              context,
              icon: Icons.download,
              title: 'Download Data',
              subtitle: 'Download your order history',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => _showComingSoonSnackBar(context),
            ),

            _buildSettingTile(
              context,
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => _showDeleteAccountDialog(context),
              textColor: AppColors.error,
            ),

            Divider(height: 1, color: AppColors.divider),

            // Legal Section
            _buildSectionHeader(context, 'Legal'),
            _buildSettingTile(
              context,
              icon: Icons.description,
              title: 'Terms & Conditions',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => _showComingSoonSnackBar(context),
            ),

            _buildSettingTile(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => _showComingSoonSnackBar(context),
            ),

            _buildSettingTile(
              context,
              icon: Icons.gavel,
              title: 'Licenses',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: AppStrings.appName,
                  applicationVersion: '1.0.0',
                );
              },
            ),

            SizedBox(height: AppSizes.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingLG,
        AppSizes.paddingLG,
        AppSizes.paddingLG,
        AppSizes.paddingSM,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
    Color? textColor,
  }) {
    return ListTile(
      enabled: enabled,
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(AppSizes.paddingSM),
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primaryOrange).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        child: Icon(
          icon,
          color: textColor ?? AppColors.primaryOrange,
          size: AppSizes.iconMD,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: enabled ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.5),
              ),
            )
          : null,
      trailing: trailing,
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon!')),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear temporary data and free up storage space. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion - Contact support'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
