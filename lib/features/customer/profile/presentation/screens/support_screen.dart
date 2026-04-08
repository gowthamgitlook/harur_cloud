import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/utils/permissions_handler.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            _buildSupportCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Chat with us',
              subtitle: 'Average response time: 2 mins',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat system initializing...'))
                );
              },
            ),
            
            _buildSupportCard(
              context,
              icon: Icons.call_outlined,
              title: 'Call Support',
              subtitle: 'Available 24/7 for urgent issues',
              onTap: () => PermissionsHandler.makePhoneCall('1800-123-456'),
            ),
            
            _buildSupportCard(
              context,
              icon: Icons.email_outlined,
              title: 'Email us',
              subtitle: 'support@harurcloud.com',
              onTap: () {
                // TODO: Launch email
              },
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildFaqItem('How do I cancel my order?', 'You can cancel your order within 60 seconds of placing it...'),
            _buildFaqItem('My payment was deducted twice', 'Don\'t worry! Duplicate payments are automatically refunded within 3-5 business days...'),
            _buildFaqItem('How to change delivery address?', 'Once an order is confirmed, address changes are only possible through our chat support...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primaryRed),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ),
      ],
    );
  }
}
