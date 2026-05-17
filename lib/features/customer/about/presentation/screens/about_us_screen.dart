import 'package:flutter/material.dart';
import '../../../../../core/theme/zomato_theme.dart';
import '../../../../../config/app_config.dart';
import '../../../../../core/utils/permissions_handler.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: ZomatoTheme.primaryRed,
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_queue, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Harur Cloud Kitchen',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConfig.appVersion}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Delivering happiness, one meal at a time.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _buildSection(
              context,
              title: 'OUR STORY',
              children: [
                _buildInfoTile(
                  icon: Icons.storefront_outlined,
                  title: 'Harur Cloud Kitchen',
                  subtitle: 'Born in Harur, Tamil Nadu, we bring authentic local flavours to your doorstep. From Biryani to Parotta, every dish is crafted with love.',
                ),
              ],
            ),

            _buildSection(
              context,
              title: 'WHY CHOOSE US',
              children: [
                _buildInfoTile(icon: Icons.timer_outlined, title: 'Fast Delivery', subtitle: 'Average delivery time of 30 minutes within Harur.'),
                _buildInfoTile(icon: Icons.star_outline, title: 'Quality Assured', subtitle: 'Every dish is prepared fresh with high-quality ingredients.'),
                _buildInfoTile(icon: Icons.support_agent_outlined, title: '24/7 Support', subtitle: 'Our support team is always available to help you.'),
                _buildInfoTile(icon: Icons.currency_rupee, title: 'Best Prices', subtitle: 'Affordable pricing without compromising on taste or quality.'),
              ],
            ),

            _buildSection(
              context,
              title: 'CONTACT US',
              children: [
                _buildContactTile(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '1800-123-456 (Toll Free)',
                  onTap: () => PermissionsHandler.makePhoneCall('1800123456'),
                ),
                _buildContactTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'support@harurcloud.com',
                  onTap: () => PermissionsHandler.launchEmail(Uri(
                    scheme: 'mailto',
                    path: 'support@harurcloud.com',
                  )),
                ),
                _buildContactTile(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  subtitle: 'Main Street, Harur, Dharmapuri\nTamil Nadu 636 903',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              '© 2025 Harur Cloud Kitchen. All rights reserved.',
              style: ZomatoTheme.bodyMedium.copyWith(
                fontSize: 11,
                color: ZomatoTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: ZomatoTheme.bodyMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: ZomatoTheme.textSecondary,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ZomatoTheme.primaryRed.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: ZomatoTheme.primaryRed, size: 22),
      ),
      title: Text(title, style: ZomatoTheme.bodyLarge),
      subtitle: Text(subtitle, style: ZomatoTheme.bodyMedium.copyWith(color: ZomatoTheme.textSecondary, height: 1.4)),
    );
  }

  Widget _buildContactTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ZomatoTheme.primaryRed.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: ZomatoTheme.primaryRed, size: 22),
      ),
      title: Text(title, style: ZomatoTheme.bodyLarge),
      subtitle: Text(subtitle, style: ZomatoTheme.bodyMedium.copyWith(color: ZomatoTheme.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}
