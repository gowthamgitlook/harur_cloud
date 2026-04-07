import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/widgets/restaurant_card.dart';
import '../providers/menu_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_chip.dart';
import 'restaurant_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _searchController = TextEditingController();

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
    // Senior Approach: Select only what is needed to avoid full-screen rebuilds
    final isLoading = context.select<MenuProvider, bool>((p) => p.isLoading);
    final errorMessage = context.select<MenuProvider, String?>((p) => p.errorMessage);
    final banners = context.select<MenuProvider, List<String>>((p) => p.banners);
    final selectedCategory = context.select<MenuProvider, FoodCategory?>((p) => p.selectedCategory);
    final filteredRestaurants = context.select<MenuProvider, List>((p) => p.filteredRestaurants);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<MenuProvider>().initialize(),
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 80,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.paddingMD,
                    AppSizes.paddingMD,
                    AppSizes.paddingMD,
                    AppSizes.paddingSM,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => context.read<MenuProvider>().searchItems(value),
                    decoration: InputDecoration(
                      hintText: 'Search for food or restaurants',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                  itemCount: FoodCategory.values.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CategoryChip(
                        label: 'All',
                        isSelected: selectedCategory == null,
                        onTap: () => context.read<MenuProvider>().filterByCategory(null),
                      );
                    }
                    final category = FoodCategory.values[index - 1];
                    return CategoryChip(
                      label: category.displayName,
                      icon: category.icon,
                      isSelected: selectedCategory == category,
                      onTap: () => context.read<MenuProvider>().filterByCategory(category),
                    );
                  },
                ),
              ),
            ),

            // Banners
            if (banners.isNotEmpty)
              SliverToBoxAdapter(
                child: BannerCarousel(banners: banners),
              ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMD),
                child: Text(
                  'Restaurants to explore',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            // Loading State (Shimmer)
            if (isLoading)
              _buildShimmerList()
            
            // Error State
            else if (errorMessage != null)
              _buildErrorState(errorMessage)

            // Empty State
            else if (filteredRestaurants.isEmpty)
              _buildEmptyState()

            // Success State (List)
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final restaurant = filteredRestaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailScreen(
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filteredRestaurants.length,
                  ),
                ),
              ),
            
            // Bottom Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
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
            const Icon(Icons.error_outline, color: AppColors.primaryRed, size: 60),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<MenuProvider>().initialize(),
              child: const Text('Try Again'),
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
            Icon(Icons.search_off_rounded, color: Colors.grey[400], size: 80),
            const SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
