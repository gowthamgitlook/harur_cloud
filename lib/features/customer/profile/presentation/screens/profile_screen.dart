import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harur_cloud_kitchen/core/theme/zomato_theme.dart';
import 'package:harur_cloud_kitchen/core/constants/app_routes.dart';
import 'package:harur_cloud_kitchen/features/auth/providers/auth_provider.dart';
import 'package:harur_cloud_kitchen/shared/enums/user_role.dart';
import 'package:harur_cloud_kitchen/features/customer/orders/providers/order_provider.dart';
import 'package:harur_cloud_kitchen/features/customer/navigation/providers/navigation_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
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
    final user = authProvider.currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Brief Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: ZomatoTheme.primaryRed.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 40, color: ZomatoTheme.primaryRed),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Guest User', style: ZomatoTheme.headlineLarge.copyWith(fontSize: 20)),
                        Text(user?.phone ?? '', style: ZomatoTheme.bodyMedium),
                        Text(user?.email ?? '', style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: ZomatoTheme.primaryRed),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Stats Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  final totalOrders = orderProvider.orders.length;
                  final totalSpent = orderProvider.getTotalSpent();
                  final user = context.watch<AuthProvider>().currentUser;
                  final favCount = user?.favoriteItemIds.length ?? 0;
                  return Row(
                    children: [
                      _buildStatItem(context, '$totalOrders', 'Orders'),
                      _buildDivider(),
                      _buildStatItem(context, '₹${totalSpent.toStringAsFixed(0)}', 'Spent'),
                      _buildDivider(),
                      _buildStatItem(context, '$favCount', 'Favourites'),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Settings Group
            _buildSectionTitle('FAVORITES & ORDERS'),
            _buildSettingsItem(Icons.favorite_border, 'Favourites', 'View your liked dishes', () {
              Navigator.pushNamed(context, AppRoutes.favorites);
            }),
            _buildSettingsItem(Icons.receipt_long_outlined, 'Order History', 'Check your past orders', () {
              context.read<NavigationProvider>().setSelectedIndex(1);
              Navigator.pop(context);
            }),
            _buildSettingsItem(Icons.location_on_outlined, 'Manage Addresses', 'Add or edit saved addresses', () {
              Navigator.pushNamed(context, AppRoutes.manageAddresses);
            }),
            
            const SizedBox(height: 12),

            if (isAdmin) ...[
              _buildSectionTitle('ADMIN PANEL'),
              _buildSettingsItem(Icons.ad_units_outlined, 'Manage Banners', 'Edit app advertisements', () {
                Navigator.pushNamed(context, AppRoutes.adminBanners);
              }),
              _buildSettingsItem(Icons.restaurant_menu, 'Manage Menu', 'Update items and prices', () {
                Navigator.pushNamed(context, AppRoutes.adminMain);
              }),
              const SizedBox(height: 12),
            ],

            _buildSectionTitle('SUPPORT & SETTINGS'),
            _buildSettingsItem(Icons.chat_bubble_outline, 'Customer Support', 'Chat with our help center', () {
              Navigator.pushNamed(context, AppRoutes.support);
            }),
            _buildSettingsItem(Icons.settings_outlined, 'App Settings', 'Themes and notifications', () {
              Navigator.pushNamed(context, AppRoutes.settings);
            }),
            _buildSettingsItem(Icons.info_outline, 'About Us', 'Learn more about Harur Cloud', () {
              Navigator.pushNamed(context, AppRoutes.aboutUs);
            }),

            const SizedBox(height: 24),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () => _handleLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZomatoTheme.error,
                  side: const BorderSide(color: ZomatoTheme.error),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LOGOUT'),
              ),
            ),

            const SizedBox(height: 40),
            Text('Version 1.7.0 Gold', style: ZomatoTheme.bodyMedium.copyWith(fontSize: 10)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: ZomatoTheme.headlineLarge.copyWith(fontSize: 20, color: ZomatoTheme.primaryRed)),
          const SizedBox(height: 2),
          Text(label, style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12, color: ZomatoTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 32, color: const Color(0xFFE8E8E8));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: ZomatoTheme.bodyMedium.copyWith(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: ZomatoTheme.bodyLarge.copyWith(fontSize: 15)),
        subtitle: Text(subtitle, style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to leave?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
            child: const Text('LOGOUT', style: TextStyle(color: ZomatoTheme.error)),
          ),
        ],
      ),
    );
  }
}
