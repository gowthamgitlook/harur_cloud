import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/widgets/animated_background.dart';
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
    return AnimatedBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Menu Management',
            style: GlassTheme.headlineLarge.copyWith(color: GlassTheme.darkBlue),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: GlassTheme.darkBlue),
              onPressed: () => context.read<AdminMenuProvider>().fetchMenuItems(),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
        body: Column(
          children: [
            // 1. Stats Bar
            _buildStatsBar().animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

            // 2. Search & Filter Section
            _buildSearchAndFilters().animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

            // 3. Menu List
            Expanded(
              child: Consumer<AdminMenuProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.menuItems.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = provider.filteredMenuItems;

                  if (items.isEmpty) {
                    return _buildEmptyState(provider.searchQuery.isNotEmpty)
                        .animate()
                        .fadeIn();
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.fetchMenuItems(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _MenuItemCard(item: items[index])
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideY(begin: 0.2, curve: Curves.easeOutQuad);
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
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('New Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: GlassTheme.primaryBlue,
          elevation: 8,
        ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Consumer<AdminMenuProvider>(
      builder: (context, provider, _) => GlassMorphism(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(16),
        opacity: 0.1,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlassTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassMorphism(
            padding: EdgeInsets.zero,
            opacity: 0.05,
            borderRadius: BorderRadius.circular(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => context.read<AdminMenuProvider>().setSearchQuery(v),
              style: const TextStyle(color: GlassTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(color: GlassTheme.textSecondary.withValues(alpha: 0.6)),
                prefixIcon: const Icon(Icons.search_rounded, color: GlassTheme.primaryBlue),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: Consumer<AdminMenuProvider>(
            builder: (context, provider, _) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip(null, 'All', provider.categoryFilter == null),
                ...FoodCategory.values.map((c) => _buildCategoryChip(c, c.displayName, provider.categoryFilter == c)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(FoodCategory? category, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) => context.read<AdminMenuProvider>().filterByCategory(v ? category : null),
        selectedColor: GlassTheme.primaryBlue,
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : GlassTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: isSelected ? GlassTheme.primaryBlue : Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: GlassMorphism(
        padding: const EdgeInsets.all(32),
        borderRadius: BorderRadius.circular(32),
        opacity: 0.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.restaurant_menu_rounded,
              size: 80,
              color: GlassTheme.primaryBlue.withValues(alpha: 0.2),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No results found' : 'Menu is empty',
              style: GlassTheme.headlineLarge.copyWith(color: GlassTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching ? 'Try searching something else' : 'Start by adding a new item',
              style: GlassTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassMorphism(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Image Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: item.imageUrl.startsWith('http')
                      ? Image.network(item.imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.white,
                          child: Icon(item.category.icon, color: GlassTheme.primaryBlue, size: 32),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Enhanced Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildVegIcon(item.isVeg),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: GlassTheme.headlineLarge.copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: GlassTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: GlassTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Switch
              Column(
                children: [
                  Switch.adaptive(
                    value: item.isAvailable,
                    onChanged: (v) async {
                      final success = await context.read<AdminMenuProvider>().toggleAvailability(item.id, v);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Availability updated' : 'Failed to update'),
                            backgroundColor: success ? GlassTheme.successGreen : GlassTheme.errorRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    activeColor: GlassTheme.successGreen,
                  ),
                  Text(
                    item.isAvailable ? 'LIVE' : 'OUT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: item.isAvailable ? GlassTheme.successGreen : GlassTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GlassTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.category.displayName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: GlassTheme.primaryBlue,
                  ),
                ),
              ),
              if (item.isPopular) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _buildActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Edit',
                color: GlassTheme.primaryBlue,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditMenuItemScreen(menuItem: item)),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: GlassTheme.errorRed,
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildVegIcon(bool isVeg) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: isVeg ? GlassTheme.successGreen : GlassTheme.errorRed, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.circle, size: 8, color: isVeg ? GlassTheme.successGreen : GlassTheme.errorRed),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete Item?'),
        content: const Text('This item will be permanently removed from the menu. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL', style: TextStyle(color: GlassTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context.read<AdminMenuProvider>().deleteMenuItem(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Item deleted successfully' : 'Failed to delete item'),
                    backgroundColor: success ? GlassTheme.successGreen : GlassTheme.errorRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassTheme.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
