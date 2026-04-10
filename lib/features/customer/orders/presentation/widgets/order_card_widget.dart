import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../shared/widgets/glass_card.dart';
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

    return GlassMorphism(
      blur: 15,
      opacity: 0.1,
      margin: EdgeInsets.only(bottom: AppSizes.paddingMD),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
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
                          'Order #${order.id.substring(0, 8)}',
                          style: GlassTheme.headlineLarge.copyWith(fontSize: 18),
                        ),
                        SizedBox(height: AppSizes.spacingXS),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: GlassTheme.labelSmall,
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
                style: GlassTheme.bodyMedium,
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
                        style: GlassTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: GlassTheme.primaryBlue,
                            ),
                      ),
                      Expanded(
                        child: Text(
                          item.menuItem.name,
                          style: GlassTheme.bodyMedium.copyWith(color: GlassTheme.textPrimary),
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
                  style: GlassTheme.labelSmall.copyWith(
                        color: GlassTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                ),

              SizedBox(height: AppSizes.spacingMD),

              const Divider(height: 1, color: Colors.white24),

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
                        style: GlassTheme.labelSmall,
                      ),
                      SizedBox(height: AppSizes.spacingXS),
                      Text(
                        '₹${order.totalPrice.toStringAsFixed(0)}',
                        style: GlassTheme.headlineLarge.copyWith(
                              color: GlassTheme.primaryBlue,
                            ),
                      ),
                    ],
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      if (isActive && order.status == OrderStatus.placed && onCancel != null)
                        TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: GlassTheme.errorRed,
                          ),
                          child: const Text('Cancel'),
                        ),

                      if (!isActive && onReorder != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: onReorder,
                          style: TextButton.styleFrom(
                            foregroundColor: GlassTheme.primaryBlue,
                          ),
                          child: const Text('Reorder'),
                        ),
                      ],

                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: GlassTheme.buttonGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Track',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
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
    Color color;
    IconData icon;

    switch (status) {
      case OrderStatus.placed:
        color = GlassTheme.infoBlue;
        icon = Icons.receipt;
        break;
      case OrderStatus.preparing:
        color = GlassTheme.warningYellow;
        icon = Icons.restaurant;
        break;
      case OrderStatus.outForDelivery:
        color = GlassTheme.primaryBlue;
        icon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        color = GlassTheme.successGreen;
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        color = GlassTheme.errorRed;
        icon = Icons.cancel;
        break;
    }

    return GlassStatusBadge(
      text: status.displayName,
      color: color,
      icon: icon,
    );
  }
}
