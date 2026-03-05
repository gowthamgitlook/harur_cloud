import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/widgets/animated_background.dart';
import '../../../../../shared/widgets/glass_card.dart';
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
      body: AnimatedBackground(
        colors: const [
          Color(0xFF0066FF),
          Color(0xFF00D4FF),
          Color(0xFF7B2CBF),
        ],
        showParticles: false,
        child: SafeArea(
          child: Column(
            children: [
              // Glass App Bar
              GlassCard(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Menu Management', style: GlassTheme.headlineLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        context.read<AdminMenuProvider>().fetchMenuItems();
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Category Tabs
              GlassCard(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: GlassTheme.secondaryBlue,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: [
                    const Tab(text: 'All'),
                    ...FoodCategory.values.map((category) => Tab(text: category.displayName)),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              // Content
              Expanded(
                child:
                Consumer<AdminMenuProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: GlassTheme.primaryBlue.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
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
          backgroundColor: GlassTheme.primaryBlue,
        ),
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
            const Icon(Icons.restaurant_menu, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'No menu items found',
              style: GlassTheme.displayMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add items',
              style: GlassTheme.bodyMedium.copyWith(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuItemCard(item: item)
            .animate()
            .fadeIn(duration: 400.ms, delay: (50 * index).ms)
            .slideX(begin: 0.2, end: 0);
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;

  const _MenuItemCard({required this.item});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GlassTheme.darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Menu Item', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<AdminMenuProvider>();
      final success = await provider.deleteMenuItem(item.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '${item.name} deleted successfully'
                  : 'Failed to delete ${item.name}',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.category.color.withOpacity(0.3),
                      item.category.color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.category.icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

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
                            style: GlassTheme.headlineLarge.copyWith(fontSize: 18),
                          ),
                        ),
                        if (item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Popular',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: GlassTheme.labelSmall.copyWith(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: item.category.color.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            item.category.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: GlassTheme.headlineLarge.copyWith(
                            fontSize: 18,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white24, height: 24),

          // Actions Row
          Row(
            children: [
              // Availability Toggle
              Expanded(
                child: Row(
                  children: [
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
                      activeColor: Colors.greenAccent,
                    ),
                    Text(
                      item.isAvailable ? 'Available' : 'Unavailable',
                      style: GlassTheme.labelSmall.copyWith(
                        color: item.isAvailable ? Colors.greenAccent : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Button
              IconButton(
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
                icon: const Icon(Icons.edit, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: GlassTheme.primaryBlue.withOpacity(0.3),
                ),
              ),

              const SizedBox(width: 8),

              // Delete Button
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
