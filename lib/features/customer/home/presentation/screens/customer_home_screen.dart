import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/widgets/food_item_card.dart';
import '../../../../../shared/widgets/loading_indicator.dart';
import '../../providers/menu_provider.dart';
import '../../../cart/providers/cart_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/banner_carousel.dart';

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
    // Initialize menu
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
    return Scaffold(
      body: SafeArea(
        child: Consumer<MenuProvider>(
          builder: (context, menuProvider, child) {
            if (menuProvider.isLoading) {
              return const LoadingIndicator(message: 'Loading menu...');
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  title: const Text(AppStrings.appName),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                  ],
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMD),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for food...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  menuProvider.searchItems('');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        menuProvider.searchItems(value);
                      },
                    ),
                  ),
                ),

                // Banner Carousel
                if (menuProvider.searchQuery.isEmpty &&
                    menuProvider.selectedCategory == null)
                  SliverToBoxAdapter(
                    child: BannerCarousel(banners: menuProvider.banners),
                  ),

                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMD,
                      vertical: AppSizes.paddingSM,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.categories,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: AppSizes.spacingSM),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CategoryChip(
                                label: 'All',
                                isSelected: menuProvider.selectedCategory == null,
                                onTap: () => menuProvider.filterByCategory(null),
                              ),
                              ...FoodCategory.values.map((category) {
                                return CategoryChip(
                                  label: category.displayName,
                                  icon: category.icon,
                                  isSelected: menuProvider.selectedCategory == category,
                                  onTap: () => menuProvider.filterByCategory(category),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Popular Items (only when no search/filter)
                if (menuProvider.searchQuery.isEmpty &&
                    menuProvider.selectedCategory == null &&
                    menuProvider.popularItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.popularItems,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: AppSizes.spacingSM),
                        ],
                      ),
                    ),
                  ),

                if (menuProvider.searchQuery.isEmpty &&
                    menuProvider.selectedCategory == null &&
                    menuProvider.popularItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: AppSizes.foodCardHeight + 20,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMD,
                        ),
                        itemCount: menuProvider.popularItems.length,
                        itemBuilder: (context, index) {
                          final item = menuProvider.popularItems[index];
                          return Padding(
                            padding: EdgeInsets.only(right: AppSizes.paddingSM),
                            child: FoodItemCard(
                              item: item,
                              onTap: () {
                                // TODO: Navigate to food detail
                                _showFoodDetail(context, item);
                              },
                              onAddToCart: () {
                                _quickAddToCart(context, item);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // All Items / Filtered Items
                SliverPadding(
                  padding: EdgeInsets.all(AppSizes.paddingMD),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      menuProvider.selectedCategory != null
                          ? menuProvider.selectedCategory!.displayName
                          : menuProvider.searchQuery.isNotEmpty
                              ? 'Search Results'
                              : 'All Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),

                // Grid of Items
                if (menuProvider.filteredItems.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: AppSizes.iconXXL,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: AppSizes.spacingMD),
                          Text(
                            'No items found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = menuProvider.filteredItems[index];
                          return FoodItemCard(
                            item: item,
                            onTap: () {
                              _showFoodDetail(context, item);
                            },
                            onAddToCart: () {
                              _quickAddToCart(context, item);
                            },
                          );
                        },
                        childCount: menuProvider.filteredItems.length,
                      ),
                    ),
                  ),

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.spacingXL),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFoodDetail(BuildContext context, item) {
    Navigator.of(context).pushNamed(
      '/customer/food-detail',
      arguments: item,
    );
  }

  void _quickAddToCart(BuildContext context, item) {
    context.read<CartProvider>().addItem(menuItem: item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            // Switch to cart tab
            // This will be handled by the parent navigation
          },
        ),
      ),
    );
  }
}
