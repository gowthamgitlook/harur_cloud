import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/cart_item_model.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel cartItem;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingSM),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              child: Container(
                width: AppSizes.imageSM,
                height: AppSizes.imageSM,
                color: AppColors.placeholder,
                child: Icon(
                  Icons.restaurant,
                  size: AppSizes.iconMD,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(width: AppSizes.spacingMD),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    cartItem.menuItem.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.spacingXS),

                  // Price
                  Text(
                    '₹${cartItem.menuItem.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),

                  // Addons
                  if (cartItem.selectedAddons.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spacingXS),
                    Text(
                      'Add-ons: ${cartItem.selectedAddons.map((a) => a.name).join(", ")}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Spice Level
                  SizedBox(height: AppSizes.spacingXS),
                  Row(
                    children: [
                      Text(
                        'Spice: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        cartItem.spiceLevel.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.spacingSM),

                  // Quantity Controls & Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              onPressed: onDecrease,
                              iconSize: AppSizes.iconSM,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingSM,
                              ),
                              child: Text(
                                '${cartItem.quantity}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: onIncrease,
                              iconSize: AppSizes.iconSM,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),

                      // Total Price
                      Text(
                        '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
              color: AppColors.error,
              iconSize: AppSizes.iconSM,
            ),
          ],
        ),
      ),
    );
  }
}
