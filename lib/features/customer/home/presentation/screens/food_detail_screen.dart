import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/enums/spice_level.dart';
import '../../../../../shared/models/addon_model.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../cart/providers/cart_provider.dart';

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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryRed.withValues(alpha: 0.1),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: AppSizes.iconXXL * 2,
                    color: AppColors.primaryRed.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingLG),
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
                            Text(
                              widget.menuItem.name,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            SizedBox(height: AppSizes.spacingXS),
                            Text(
                              widget.menuItem.category.displayName,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
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
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: AppSizes.iconXS,
                                color: AppColors.textLight,
                              ),
                              SizedBox(width: AppSizes.spacingXS),
                              Text(
                                'Popular',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: AppSizes.spacingMD),

                  // Rating
                  if (widget.menuItem.rating != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: AppSizes.iconSM,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: AppSizes.spacingXS),
                        Text(
                          widget.menuItem.rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (widget.menuItem.reviewCount != null)
                          Text(
                            ' (${widget.menuItem.reviewCount} reviews)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                      ],
                    ),

                  SizedBox(height: AppSizes.spacingLG),

                  // Description
                  Text(
                    AppStrings.description,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  Text(
                    widget.menuItem.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),

                  SizedBox(height: AppSizes.spacingLG),

                  // Spice Level
                  Text(
                    AppStrings.spiceLevel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  Row(
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
                          selectedColor: AppColors.primaryRed,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Addons
                  if (widget.menuItem.addons.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spacingLG),
                    Text(
                      AppStrings.addons,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: AppSizes.spacingSM),
                    ...widget.menuItem.addons.map((addon) {
                      final isSelected = _selectedAddons.contains(addon);
                      return CheckboxListTile(
                        title: Text(addon.name),
                        subtitle: Text('+ ₹${addon.price.toStringAsFixed(0)}'),
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
                        activeColor: AppColors.primaryRed,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],

                  SizedBox(height: AppSizes.spacingLG),

                  // Special Instructions
                  Text(
                    'Special Instructions (Optional)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  TextField(
                    controller: _instructionsController,
                    decoration: InputDecoration(
                      hintText: 'Any special requests?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    maxLines: 3,
                  ),

                  SizedBox(height: AppSizes.spacingXL),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingMD),
            child: Row(
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSM),
                        child: Text(
                          '$_quantity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppSizes.spacingMD),

                // Add to Cart Button
                Expanded(
                  child: CustomButton(
                    text: 'Add to Cart - ₹${_totalPrice.toStringAsFixed(0)}',
                    onPressed: widget.menuItem.isAvailable ? _addToCart : null,
                    icon: Icons.shopping_cart,
                  ),
                ),
              ],
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
