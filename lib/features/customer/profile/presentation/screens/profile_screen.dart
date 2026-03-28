import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../orders/providers/order_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user orders for statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<OrderProvider>().fetchOrders(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.paddingLG),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryOrange,
                      AppColors.primaryOrange.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingXS),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textLight,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: AppSizes.avatarLG,
                        backgroundColor: AppColors.textLight,
                        child: Icon(
                          Icons.person,
                          size: AppSizes.iconXXL,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSizes.spacingMD),

                    // User Name
                    Text(
                      user?.name ?? 'Guest User',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    SizedBox(height: AppSizes.spacingXS),

                    // Phone Number
                    Text(
                      user?.phone ?? '',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textLight.withValues(alpha: 0.9),
                          ),
                    ),

                    SizedBox(height: AppSizes.spacingLG),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          context,
                          icon: Icons.shopping_bag,
                          label: 'Orders',
                          value: '${orderProvider.orders.length}',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.textLight.withValues(alpha: 0.3),
                        ),
                        _buildStatItem(
                          context,
                          icon: Icons.currency_rupee,
                          label: 'Spent',
                          value: orderProvider.getTotalSpent().toStringAsFixed(0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.spacingLG),

              // Menu Items
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.edit,
                      title: AppStrings.editProfile,
                      subtitle: 'Update your personal information',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.editProfile);
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.location_on,
                      title: AppStrings.manageAddresses,
                      subtitle: 'Add or edit delivery addresses',
                      trailing: Text(
                        '${user?.addresses.length ?? 0}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.manageAddresses);
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Order History',
                      subtitle: 'View all your past orders',
                      onTap: () {
                        // Switch to orders tab (index 1)
                        // This will be handled by parent
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.favorite,
                      title: 'Favorites',
                      subtitle: 'Your favorite dishes',
                      badge: 'Soon',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feature coming soon!')),
                        );
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      title: AppStrings.settings,
                      subtitle: 'App preferences and settings',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.settings);
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help with your orders',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contact: +91 9876543210')),
                        );
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About Us',
                      subtitle: 'Learn more about Harur Cloud Kitchen',
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),

                    SizedBox(height: AppSizes.spacingLG),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text(AppStrings.logout),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMD,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSizes.spacingXL),

                    // App Version
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                    SizedBox(height: AppSizes.spacingLG),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textLight,
          size: AppSizes.iconMD,
        ),
        SizedBox(height: AppSizes.spacingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight.withValues(alpha: 0.9),
              ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingSM),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(AppSizes.paddingSM),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryOrange,
            size: AppSizes.iconMD,
          ),
        ),
        title: Row(
          children: [
            Text(title),
            if (badge != null) ...[
              SizedBox(width: AppSizes.spacingSM),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 10,
                      ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.restaurant,
              color: AppColors.primaryOrange,
              size: AppSizes.iconLG,
            ),
            SizedBox(width: AppSizes.spacingSM),
            const Text(AppStrings.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your favorite cloud kitchen in Harur, Tamil Nadu. We serve delicious Biryani, Fried Rice, Parotta, Grills, and more!',
            ),
            SizedBox(height: AppSizes.spacingMD),
            Text(
              'Contact Us:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: AppSizes.spacingXS),
            const Text('Phone: +91 9876543210'),
            const Text('Location: Harur, Tamil Nadu'),
            SizedBox(height: AppSizes.spacingMD),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
