import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../providers/admin_menu_provider.dart';
import 'add_edit_menu_item_screen.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: FoodCategory.values.length + 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMenuProvider>().fetchMenuItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminMenuProvider>().fetchMenuItems(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            const Tab(text: 'All'),
            ...FoodCategory.values.map((category) => Tab(text: category.displayName)),
          ],
        ),
      ),
      body: Consumer<AdminMenuProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMenuList(provider, null),
              ...FoodCategory.values.map((category) => _buildMenuList(provider, category)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditMenuItemScreen(),
            ),
          );
          if (result == true && context.mounted) {
            context.read<AdminMenuProvider>().fetchMenuItems();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildMenuList(AdminMenuProvider provider, FoodCategory? category) {
    final items = category == null
        ? provider.menuItems
        : provider.getItemsByCategory(category);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No menu items found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _MenuItemCard(item: items[index]);
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMD),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          children: [
            Row(
              children: [
                // Item Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppColors.placeholder,
                    child: item.imageUrl.startsWith('http')
                        ? Image.network(item.imageUrl, fit: BoxFit.cover)
                        : Icon(item.category.icon, size: 40, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMD),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          const Spacer(),
                          if (item.isPopular)
                            const Badge(
                              label: Text('Popular'),
                              backgroundColor: Colors.orange,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Switch(
                  value: item.isAvailable,
                  onChanged: (value) {
                    context.read<AdminMenuProvider>().toggleAvailability(item.id, value);
                  },
                ),
                const Text('Available'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditMenuItemScreen(menuItem: item),
                      ),
                    );
                    if (result == true && context.mounted) {
                      context.read<AdminMenuProvider>().fetchMenuItems();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AdminMenuProvider>().deleteMenuItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
