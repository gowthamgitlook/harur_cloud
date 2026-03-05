import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/enums/order_status.dart';
import 'package:intl/intl.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReorder;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.onTap,
    this.onCancel,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final isActive = order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: AppSizes.spacingXS),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, order.status),
                ],
              ),

              SizedBox(height: AppSizes.spacingMD),

              // Order Items Summary
              Text(
                '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              SizedBox(height: AppSizes.spacingXS),

              // Show first 2 items
              ...order.items.take(2).map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.spacingXS),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Expanded(
                        child: Text(
                          item.menuItem.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Show more indicator
              if (order.items.length > 2)
                Text(
                  '+${order.items.length - 2} more item${order.items.length - 2 > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                ),

              SizedBox(height: AppSizes.spacingMD),

              Divider(height: 1, color: AppColors.divider),

              SizedBox(height: AppSizes.spacingMD),

              // Total and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      SizedBox(height: AppSizes.spacingXS),
                      Text(
                        '₹${order.totalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryOrange,
                            ),
                      ),
                    ],
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      if (isActive && order.status == OrderStatus.placed && onCancel != null)
                        OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Cancel'),
                        ),

                      if (!isActive && onReorder != null) ...[
                        SizedBox(width: AppSizes.spacingSM),
                        ElevatedButton(
                          onPressed: onReorder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: AppColors.textLight,
                          ),
                          child: const Text('Reorder'),
                        ),
                      ],

                      SizedBox(width: AppSizes.spacingSM),
                      OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryOrange,
                          side: const BorderSide(color: AppColors.primaryOrange),
                        ),
                        child: const Text('Track'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case OrderStatus.placed:
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        icon = Icons.receipt;
        break;
      case OrderStatus.preparing:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        icon = Icons.restaurant;
        break;
      case OrderStatus.outForDelivery:
        backgroundColor = AppColors.primaryOrange.withOpacity(0.1);
        textColor = AppColors.primaryOrange;
        icon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSizes.iconXS,
            color: textColor,
          ),
          SizedBox(width: AppSizes.spacingXS),
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
