import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:harur_cloud_kitchen/core/theme/zomato_theme.dart';
import 'package:harur_cloud_kitchen/shared/models/restaurant_model.dart';
import 'package:harur_cloud_kitchen/shared/widgets/food_item_card.dart';
import 'package:harur_cloud_kitchen/features/customer/home/providers/menu_provider.dart';
import 'package:harur_cloud_kitchen/features/customer/cart/providers/cart_provider.dart';
import 'package:harur_cloud_kitchen/features/customer/navigation/providers/navigation_provider.dart';
import 'food_detail_screen.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final cartProvider = context.watch<CartProvider>();
    final restaurantItems = menuProvider.allItems.where((item) => item.restaurantId == restaurant.id).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Premium Header
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite_border, color: Colors.black, size: 20),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.share_outlined, color: Colors.black, size: 20),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              // Restaurant Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: ZomatoTheme.headlineLarge.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.cuisine,
                        style: ZomatoTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  restaurant.rating.toString(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const Icon(Icons.star, color: Colors.white, size: 12),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${restaurant.reviewCount} Dining Reviews',
                            style: ZomatoTheme.bodyMedium.copyWith(decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(restaurant.deliveryTime, style: ZomatoTheme.bodyMedium),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('1.2 km', style: ZomatoTheme.bodyMedium),
                        ],
                      ),
                      const Divider(height: 40, color: Color(0xFFF0F0F0)),
                      Text(
                        'Full Menu',
                        style: ZomatoTheme.headlineLarge.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Menu Items List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = restaurantItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: FoodItemCard(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodDetailScreen(menuItem: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: restaurantItems.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Persistent View Cart Bar
          if (cartProvider.itemCount > 0)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _buildViewCartBar(context),
            ),
        ],
      ),
    );
  }

  Widget _buildViewCartBar(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final navProvider = context.read<NavigationProvider>();
    
    return GestureDetector(
      onTap: () {
        navProvider.setSelectedIndex(2); // Index 2 is Cart
        Navigator.pop(context); // Go back to Main Screen
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D8A39),
          borderRadius: BorderRadius.circular(12),
          boxShadow: ZomatoTheme.cardShadow,
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cartProvider.itemCount} ITEM', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('₹${cartProvider.total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
            const Spacer(),
            const Text('VIEW CART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_right, color: Colors.white),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0),
    );
  }
}
