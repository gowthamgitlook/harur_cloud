import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harur_cloud_kitchen/core/theme/zomato_theme.dart';
import 'package:harur_cloud_kitchen/features/customer/home/providers/menu_provider.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final banners = menuProvider.banners;

    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('Manage Advertisements'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Active Banners', style: ZomatoTheme.bodyLarge),
          const SizedBox(height: 16),
          ...banners.map((url) => _buildBannerCard(url, menuProvider)),
          const SizedBox(height: 24),
          _buildAddBannerForm(menuProvider),
        ],
      ),
    );
  }

  Widget _buildBannerCard(String url, MenuProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ZomatoTheme.cardShadow,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              url,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(height: 120, color: Colors.grey[200]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(url, style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: ZomatoTheme.primaryRed),
                  onPressed: () {
                    provider.removeBanner(url);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner removed')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBannerForm(MenuProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZomatoTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New Banner', style: ZomatoTheme.bodyLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'Enter Image URL',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_urlController.text.isNotEmpty) {
                provider.addBanner(_urlController.text);
                _urlController.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner added successfully!')));
              }
            },
            child: const Text('Add Advertisement'),
          ),
        ],
      ),
    );
  }
}
