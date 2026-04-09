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

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMenuProvider>().fetchMenuItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<AdminMenuProvider>().fetchMenuItems(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Stats Bar (Senior approach: Overview first)
          _buildStatsBar(),

          // 2. Search & Filter Section
          _buildSearchAndFilters(),

          // 3. Menu List
          Expanded(
            child: Consumer<AdminMenuProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.menuItems.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = provider.filteredMenuItems;

                if (items.isEmpty) {
                  return _buildEmptyState(provider.searchQuery.isNotEmpty);
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchMenuItems(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _MenuItemCard(item: items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditMenuItemScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Item'),
        backgroundColor: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildStatsBar() {
    return Consumer<AdminMenuProvider>(
      builder: (context, provider, _) => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        color: Colors.white,
        child: Row(
          children: [
            _buildStatItem('Total', provider.menuItems.length.toString(), Colors.blue),
            const SizedBox(width: 12),
            _buildStatItem('Live', provider.availableItemsCount.toString(), Colors.green),
            const SizedBox(width: 12),
            _buildStatItem('Out', provider.outOfStockCount.toString(), Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => context.read<AdminMenuProvider>().setSearchQuery(v),
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: Consumer<AdminMenuProvider>(
              builder: (context, provider, _) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(null, 'All', provider.categoryFilter == null),
                  ...FoodCategory.values.map((c) => _buildCategoryChip(c, c.displayName, provider.categoryFilter == c)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(FoodCategory? category, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) => context.read<AdminMenuProvider>().filterByCategory(v ? category : null),
        selectedColor: AppColors.primaryRed.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryRed : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? AppColors.primaryRed : Colors.grey[300]!),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSearching ? Icons.search_off_rounded : Icons.restaurant_menu_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No results found' : 'Menu is empty',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[100],
                    child: item.imageUrl.startsWith('http')
                        ? Image.network(item.imageUrl, fit: BoxFit.cover)
                        : Icon(item.category.icon, color: Colors.grey[400]),
                  ),
                ),
                const SizedBox(width: 12),
                // Core Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildVegIcon(item.isVeg),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                // Quick Status Toggle
                Column(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: item.isAvailable,
                        onChanged: (v) => context.read<AdminMenuProvider>().toggleAvailability(item.id, v),
                        activeColor: Colors.green,
                      ),
                    ),
                    Text(
                      item.isAvailable ? 'LIVE' : 'OUT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Text(
                  item.category.displayName,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                ),
                if (item.isPopular) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('POPULAR', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditMenuItemScreen(menuItem: item)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(visualDensity: VisualSize.compact),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteDialog(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  style: IconButton.styleFrom(visualDensity: VisualSize.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVegIcon(bool isVeg) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1), borderRadius: BorderRadius.circular(2)),
      child: Icon(Icons.circle, size: 8, color: isVeg ? Colors.green : Colors.red),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item?'),
        content: const Text('This item will be permanently removed from the menu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep it')),
          TextButton(
            onPressed: () {
              context.read<AdminMenuProvider>().deleteMenuItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
