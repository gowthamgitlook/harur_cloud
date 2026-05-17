import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/theme/zomato_theme.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../home/providers/menu_provider.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../cart/providers/cart_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final allItems = context.watch<MenuProvider>().allItems;
    final favoriteIds = user?.favoriteItemIds ?? [];
    final favorites = allItems.where((item) => favoriteIds.contains(item.id)).toList();

    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('My Favourites'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? _buildEmpty(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return _FavoriteItemCard(item: favorites[index])
                    .animate()
                    .fadeIn(delay: (index * 80).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No favourites yet',
            style: ZomatoTheme.headlineLarge.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any dish to save it here.',
            style: ZomatoTheme.bodyMedium.copyWith(color: ZomatoTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.customerMain, (r) => false),
            style: ElevatedButton.styleFrom(backgroundColor: ZomatoTheme.primaryRed),
            child: const Text('Browse Menu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final MenuItemModel item;
  const _FavoriteItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isFav = user?.favoriteItemIds.contains(item.id) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZomatoTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: ZomatoTheme.primaryRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.category.icon, color: ZomatoTheme.primaryRed, size: 36),
        ),
        title: Text(item.name, style: ZomatoTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹${item.price.toStringAsFixed(0)}',
                style: ZomatoTheme.bodyMedium.copyWith(color: ZomatoTheme.primaryRed, fontWeight: FontWeight.bold)),
            if (item.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(item.rating!.toStringAsFixed(1), style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12)),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: ZomatoTheme.primaryRed),
              onPressed: () {
                if (user == null) return;
                final updatedIds = List<String>.from(user.favoriteItemIds);
                if (isFav) {
                  updatedIds.remove(item.id);
                } else {
                  updatedIds.add(item.id);
                }
                authProvider.updateUser(user.copyWith(favoriteItemIds: updatedIds));
              },
            ),
            ElevatedButton(
              onPressed: item.isAvailable
                  ? () {
                      context.read<CartProvider>().addItem(menuItem: item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to cart'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ZomatoTheme.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('ADD', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.foodDetail, arguments: item),
      ),
    );
  }
}
