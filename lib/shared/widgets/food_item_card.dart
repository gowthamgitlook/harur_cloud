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
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.paddingMD),
        padding: EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Veg/Non-Veg Indicator
                  _buildDietaryIndicator(),
                  SizedBox(height: AppSizes.spacingXS),
                  // Name
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.spacingXS),
                  // Rating Badge
                  if (item.rating != null) _buildRatingBadge(context),
                  SizedBox(height: AppSizes.spacingSM),
                  // Price
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  // Description
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.paddingMD),
            // Right side: Image and Add Button
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  child: Container(
                    height: AppSizes.foodImageSizeWide,
                    width: AppSizes.foodImageSizeWide,
                    color: AppColors.placeholder,
                    child: item.imageUrl.startsWith('http')
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : Image.asset(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          ),
                  ),
                ),
                // Add Button (Positioned over the bottom center of the image)
                if (item.isAvailable && onAddToCart != null)
                  Positioned(
                    bottom: -15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 80,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                            border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'ADD',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Not Available Overlay
                if (!item.isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      child: Center(
                        child: Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryIndicator() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          color: item.isVeg ? Colors.green : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Container(
        height: 8,
        width: 8,
        decoration: BoxDecoration(
          color: item.isVeg ? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.rating!.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.star, color: Colors.white, size: 10),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.placeholder,
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
