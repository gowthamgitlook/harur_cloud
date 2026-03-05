import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../providers/admin_menu_provider.dart';

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
            onPressed: () {
              context.read<AdminMenuProvider>().fetchMenuItems();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add menu item feature - Coming soon in full version'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: AppColors.primaryOrange,
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
            Icon(Icons.restaurant_menu, size: 64, color: AppColors.textSecondary),
            SizedBox(height: AppSizes.spacingMD),
            Text(
              'No menu items found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingMD),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuItemCard(item: item);
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
      margin: EdgeInsets.only(bottom: AppSizes.spacingMD),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Icon(
                item.category.icon,
                size: 40,
                color: AppColors.primaryOrange,
              ),
            ),

            SizedBox(width: AppSizes.spacingMD),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (item.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Popular',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: item.category.color,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: AppSizes.spacingMD),

            // Actions
            Column(
              children: [
                // Availability Toggle
                Switch(
                  value: item.isAvailable,
                  onChanged: (value) async {
                    final provider = context.read<AdminMenuProvider>();
                    final success = await provider.toggleAvailability(item.id, value);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? '${item.name} is now available'
                                : '${item.name} is now unavailable',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  activeColor: Colors.green,
                ),
                Text(
                  item.isAvailable ? 'Available' : 'Unavailable',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
