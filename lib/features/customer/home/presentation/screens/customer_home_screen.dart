import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:harur_cloud_kitchen/core/theme/zomato_theme.dart';
import 'package:harur_cloud_kitchen/shared/enums/food_category.dart';
import 'package:harur_cloud_kitchen/shared/widgets/restaurant_card.dart';
import 'package:harur_cloud_kitchen/features/customer/home/providers/menu_provider.dart';
import 'package:harur_cloud_kitchen/features/customer/cart/providers/cart_provider.dart';
import 'package:harur_cloud_kitchen/features/customer/navigation/providers/navigation_provider.dart';
import '../widgets/banner_carousel.dart';
import 'restaurant_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<MenuProvider, bool>((p) => p.isLoading);
    final errorMessage = context.select<MenuProvider, String?>((p) => p.errorMessage);
    final banners = context.select<MenuProvider, List<String>>((p) => p.banners);
    final selectedCategory = context.select<MenuProvider, FoodCategory?>((p) => p.selectedCategory);
    final isSearchLoading = context.select<MenuProvider, bool>((p) => p.isSearchLoading);
    final filteredRestaurants = context.select<MenuProvider, List>((p) => p.filteredRestaurants);
    final vegOnly = context.select<MenuProvider, bool>((p) => p.vegOnly);
    final cartCount = context.select<CartProvider, int>((p) => p.itemCount);

    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: ZomatoTheme.primaryRed,
            onRefresh: () => context.read<MenuProvider>().initialize(),
            child: CustomScrollView(
              slivers: [
                // Premium Header with Search
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  expandedHeight: 140,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: [
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: ZomatoTheme.primaryRed, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Harur', style: ZomatoTheme.bodyLarge),
                                        const Icon(Icons.keyboard_arrow_down, size: 18),
                                      ],
                                    ),
                                    Text('Main Street, Dharmapuri...', 
                                      style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const CircleAvatar(
                                backgroundColor: ZomatoTheme.background,
                                child: Icon(Icons.person_outline, color: ZomatoTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => context.read<MenuProvider>().searchItems(value),
                          decoration: InputDecoration(
                            hintText: 'Search "Biryani" or "Pizza"',
                            prefixIcon: isSearchLoading 
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                )
                              : const Icon(Icons.search, color: ZomatoTheme.primaryRed),
                            suffixIcon: const Icon(Icons.mic_none, color: ZomatoTheme.primaryRed),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Banners Section
                if (banners.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: BannerCarousel(banners: banners),
                    ),
                  ),

                // Categories Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text('What\'s on your mind?', style: ZomatoTheme.headlineLarge.copyWith(fontSize: 18)),
                  ),
                ),

                // Categories Grid-like Scroll
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: FoodCategory.values.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildCategoryItem('All', Icons.restaurant_menu, selectedCategory == null, 
                            () => context.read<MenuProvider>().filterByCategory(null));
                        }
                        final category = FoodCategory.values[index - 1];
                        return _buildCategoryItem(category.displayName, category.icon, selectedCategory == category,
                            () => context.read<MenuProvider>().filterByCategory(category));
                      },
                    ),
                  ),
                ),

                // Veg Toggle + Count Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      children: [
                        Text('${filteredRestaurants.length} restaurants delivering to you',
                          style: ZomatoTheme.bodyLarge.copyWith(color: ZomatoTheme.textSecondary, fontSize: 14)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.read<MenuProvider>().toggleVegOnly(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: vegOnly ? Colors.green.withValues(alpha: 0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: vegOnly ? Colors.green : const Color(0xFFE8E8E8),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green, width: 1.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: vegOnly
                                      ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.green))
                                      : null,
                                ),
                                const SizedBox(width: 5),
                                Text('Pure Veg',
                                  style: ZomatoTheme.bodyMedium.copyWith(
                                    fontSize: 12,
                                    color: vegOnly ? Colors.green : ZomatoTheme.textSecondary,
                                    fontWeight: vegOnly ? FontWeight.bold : FontWeight.normal,
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                if (isLoading)
                  _buildShimmerList()
                else if (errorMessage != null)
                  _buildErrorState(errorMessage)
                else if (filteredRestaurants.isEmpty)
                  _buildEmptyState()
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final restaurant = filteredRestaurants[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: RestaurantCard(
                              restaurant: restaurant,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: filteredRestaurants.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // Floating View Cart Bar (Zomato-style)
          if (cartCount > 0)
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
      onTap: () => navProvider.setSelectedIndex(2), // Index 2 is Cart
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D8A39), // Zomato green for success/cart
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

  Widget _buildCategoryItem(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: isSelected ? ZomatoTheme.primaryRed.withValues(alpha: 0.1) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ZomatoTheme.primaryRed : const Color(0xFFF0F0F0),
                  width: 1.5,
                ),
                boxShadow: isSelected ? [BoxShadow(color: ZomatoTheme.primaryRed.withValues(alpha: 0.2), blurRadius: 8)] : null,
              ),
              child: Icon(icon, color: isSelected ? ZomatoTheme.primaryRed : ZomatoTheme.textSecondary, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: ZomatoTheme.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? ZomatoTheme.primaryRed : ZomatoTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.white,
            child: Container(
              height: 220,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: ZomatoTheme.primaryRed),
            const SizedBox(height: 16),
            Text(message, style: ZomatoTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<MenuProvider>().initialize(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 60, color: Color(0xFFE8E8E8)),
            const SizedBox(height: 16),
            Text('No results found', style: ZomatoTheme.bodyLarge.copyWith(color: ZomatoTheme.textTertiary)),
          ],
        ),
      ),
    );
  }
}
