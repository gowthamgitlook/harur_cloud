import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../shared/enums/spice_level.dart';
import '../../../../../shared/models/addon_model.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/widgets/animated_background.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../../auth/providers/auth_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final MenuItemModel menuItem;

  const FoodDetailScreen({
    super.key,
    required this.menuItem,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final List<AddonModel> _selectedAddons = [];
  SpiceLevel _selectedSpiceLevel = SpiceLevel.medium;
  final _instructionsController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double basePrice = widget.menuItem.price * _quantity;
    double addonsPrice = _selectedAddons.fold(0.0, (sum, addon) => sum + addon.price) * _quantity;
    return basePrice + addonsPrice;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isFav = user?.favoriteItemIds.contains(widget.menuItem.id) ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        child: CustomScrollView(
          slivers: [
            // App Bar with Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey[700],
                    ),
                    onPressed: () {
                      if (user == null) return;
                      final updatedIds = List<String>.from(user.favoriteItemIds);
                      if (isFav) {
                        updatedIds.remove(widget.menuItem.id);
                      } else {
                        updatedIds.add(widget.menuItem.id);
                      }
                      authProvider.updateUser(user.copyWith(favoriteItemIds: updatedIds));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isFav ? 'Removed from favourites' : 'Added to favourites'),
                        duration: const Duration(seconds: 1),
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: GlassTheme.primaryBlue.withValues(alpha: 0.1),
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: AppSizes.iconXXL * 2,
                      color: GlassTheme.primaryBlue.withValues(alpha: 0.3),
                    ).animate().scale(duration: 1000.ms, curve: Curves.elasticOut),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLG),
                child: GlassMorphism(
                  blur: 20,
                  opacity: 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: widget.menuItem.isVeg ? Colors.green : Colors.red,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: widget.menuItem.isVeg ? Colors.green : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        widget.menuItem.name,
                                        style: GlassTheme.displayMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSizes.spacingXS),
                                Text(
                                  widget.menuItem.category.displayName,
                                  style: GlassTheme.bodyLarge.copyWith(
                                        color: GlassTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.menuItem.isPopular)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingSM,
                                vertical: AppSizes.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                gradient: GlassTheme.buttonGradient,
                                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Popular',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ).animate().shimmer(duration: 2.seconds),
                        ],
                      ),

                      SizedBox(height: AppSizes.spacingMD),

                      // Rating
                      if (widget.menuItem.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 20,
                              color: GlassTheme.warningYellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.menuItem.rating!.toStringAsFixed(1),
                              style: GlassTheme.headlineLarge,
                            ),
                            if (widget.menuItem.reviewCount != null)
                              Text(
                                ' (${widget.menuItem.reviewCount} reviews)',
                                style: GlassTheme.bodyMedium,
                              ),
                          ],
                        ),

                      SizedBox(height: AppSizes.spacingLG),

                      // Description
                      Text(
                        AppStrings.description,
                        style: GlassTheme.headlineLarge,
                      ),
                      SizedBox(height: AppSizes.spacingSM),
                      Text(
                        widget.menuItem.description,
                        style: GlassTheme.bodyLarge.copyWith(
                              color: GlassTheme.textSecondary,
                              height: 1.5,
                            ),
                      ),

                      SizedBox(height: AppSizes.spacingLG),

                      // Spice Level
                      Text(
                        AppStrings.spiceLevel,
                        style: GlassTheme.headlineLarge,
                      ),
                      SizedBox(height: AppSizes.spacingSM),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: SpiceLevel.values.map((level) {
                            final isSelected = _selectedSpiceLevel == level;
                            return Padding(
                              padding: EdgeInsets.only(right: AppSizes.paddingSM),
                              child: ChoiceChip(
                                label: Text('${level.emoji} ${level.displayName}'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() => _selectedSpiceLevel = level);
                                },
                                selectedColor: GlassTheme.primaryBlue,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : GlassTheme.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Addons
                      if (widget.menuItem.addons.isNotEmpty) ...[
                        SizedBox(height: AppSizes.spacingLG),
                        Text(
                          AppStrings.addons,
                          style: GlassTheme.headlineLarge,
                        ),
                        SizedBox(height: AppSizes.spacingSM),
                        ...widget.menuItem.addons.map((addon) {
                          final isSelected = _selectedAddons.contains(addon);
                          return CheckboxListTile(
                            title: Text(addon.name, style: GlassTheme.bodyLarge),
                            subtitle: Text('+ ₹${addon.price.toStringAsFixed(0)}', style: GlassTheme.bodyMedium),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedAddons.add(addon);
                                } else {
                                  _selectedAddons.remove(addon);
                                }
                              });
                            },
                            activeColor: GlassTheme.primaryBlue,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                      ],

                      SizedBox(height: AppSizes.spacingLG),

                      // Special Instructions
                      Text(
                        'Special Instructions (Optional)',
                        style: GlassTheme.headlineLarge,
                      ),
                      SizedBox(height: AppSizes.spacingSM),
                      TextField(
                        controller: _instructionsController,
                        style: const TextStyle(color: GlassTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Any special requests?',
                          hintStyle: TextStyle(color: GlassTheme.textSecondary.withValues(alpha: 0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                        ),
                        maxLines: 3,
                      ),

                      SizedBox(height: AppSizes.spacingXL),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              ),
            ),
          ],
        ),
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMD),
                child: Row(
                  children: [
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: GlassTheme.textPrimary),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSM),
                            child: Text(
                              '$_quantity',
                              style: GlassTheme.headlineLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: GlassTheme.textPrimary),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: AppSizes.spacingMD),

                    // Add to Cart Button
                    Expanded(
                      child: GlassButton(
                        text: 'Add to Cart - ₹${_totalPrice.toStringAsFixed(0)}',
                        onPressed: widget.menuItem.isAvailable ? _addToCart : () {},
                        icon: Icons.shopping_cart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(
          menuItem: widget.menuItem,
          quantity: _quantity,
          selectedAddons: _selectedAddons,
          spiceLevel: _selectedSpiceLevel,
          specialInstructions: _instructionsController.text.isNotEmpty
              ? _instructionsController.text
              : null,
        );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.menuItem.name} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.of(context).pop();
            // The parent screen should handle switching to cart tab
          },
        ),
      ),
    );

    Navigator.of(context).pop();
  }
}
