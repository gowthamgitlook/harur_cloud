import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../models/menu_item_model.dart';

class FoodItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: SizedBox(
          width: AppSizes.foodCardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusMD),
                    ),
                    child: Container(
                      height: AppSizes.foodImageHeight,
                      width: double.infinity,
                      color: AppColors.placeholder,
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : Image.asset(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            ),
                    ),
                  ),
                  // Popular Badge
                  if (item.isPopular)
                    Positioned(
                      top: AppSizes.paddingSM,
                      left: AppSizes.paddingSM,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSM,
                          vertical: AppSizes.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: Text(
                          'Popular',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  // Availability Badge
                  if (!item.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.overlay,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSizes.radiusMD),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMD,
                              vertical: AppSizes.paddingSM,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                            ),
                            child: Text(
                              'Not Available',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Item Details
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSM,
                  vertical: AppSizes.paddingXS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.spacingXS),
                    // Category
                    Text(
                      item.category.displayName,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.spacingXS),
                    // Rating (if available)
                    if (item.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: AppSizes.iconXS,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: AppSizes.spacingXS),
                          Text(
                            item.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (item.reviewCount != null)
                            Text(
                              ' (${item.reviewCount})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    SizedBox(height: AppSizes.spacingSM),
                    // Price and Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (onAddToCart != null && item.isAvailable)
                          GestureDetector(
                            onTap: onAddToCart,
                            child: Container(
                              padding: EdgeInsets.all(AppSizes.paddingXS),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                              ),
                              child: Icon(
                                Icons.add,
                                size: AppSizes.iconSM,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.placeholder,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: AppSizes.iconXL,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
