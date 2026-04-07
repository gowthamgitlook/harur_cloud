import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/restaurant_model.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/widgets/food_item_card.dart';
import '../providers/menu_provider.dart';
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
    final restaurantItems = menuProvider.allItems.where((item) => item.restaurantId == restaurant.id).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Restaurant Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.rating} (${restaurant.reviewCount}+ ratings)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    'Menu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = restaurantItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
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
        ],
      ),
    );
  }
}
