import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../shared/widgets/animated_background.dart';
import '../../../../../shared/widgets/glass_morphism.dart';
import '../../../../../shared/widgets/restaurant_card.dart';
import '../../domain/entities/food_category.dart';
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
    // Senior Approach: Select only what is needed to avoid full-screen rebuilds
    final isLoading = context.select<MenuProvider, bool>((p) => p.isLoading);
    final errorMessage = context.select<MenuProvider, String?>((p) => p.errorMessage);
    final banners = context.select<MenuProvider, List<String>>((p) => p.banners);
    final selectedCategory = context.select<MenuProvider, FoodCategory?>((p) => p.selectedCategory);
    final isSearchLoading = context.select<MenuProvider, bool>((p) => p.isSearchLoading);
    final filteredRestaurants = context.select<MenuProvider, List>((p) => p.filteredRestaurants);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        child: RefreshIndicator(
          onRefresh: () => context.read<MenuProvider>().initialize(),
          child: CustomScrollView(
            slivers: [
              // Search Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.paddingMD,
                      AppSizes.paddingLG + 20,
                      AppSizes.paddingMD,
                      AppSizes.paddingSM,
                    ),
                    child: GlassMorphism(
                      blur: 15,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(16),
                      padding: EdgeInsets.zero,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => context.read<MenuProvider>().searchItems(value),
                        style: const TextStyle(color: GlassTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search for food or restaurants',
                          hintStyle: TextStyle(color: GlassTheme.textSecondary.withValues(alpha: 0.7)),
                          prefixIcon: isSearchLoading 
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                width: 20,
                                height: 20,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search, color: GlassTheme.primaryBlue),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
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
                      Widget chip;
                      if (index == 0) {
                        chip = CategoryChip(
                          label: 'All',
                          isSelected: selectedCategory == null,
                          onTap: () => context.read<MenuProvider>().filterByCategory(null),
                        );
                      } else {
                        final category = FoodCategory.values[index - 1];
                        chip = CategoryChip(
                          label: category.displayName,
                          icon: category.icon,
                          isSelected: selectedCategory == category,
                          onTap: () => context.read<MenuProvider>().filterByCategory(category),
                        );
                      }
                      return chip.animate().fadeIn(delay: (index * 50).ms).scale(delay: (index * 50).ms);
                    },
                  ),
                ),
              ),

              // Banners
              if (banners.isNotEmpty)
                SliverToBoxAdapter(
                  child: BannerCarousel(banners: banners)
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                ),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMD),
                  child: Text(
                    'Restaurants to explore',
                    style: GlassTheme.headlineLarge,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
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
                        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
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
          childCount: 5,
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
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16)),
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
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No restaurants found for this category',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
