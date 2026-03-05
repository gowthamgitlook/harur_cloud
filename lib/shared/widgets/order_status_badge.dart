import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../enums/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool showIcon;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        border: Border.all(
          color: status.color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              status.icon,
              size: AppSizes.iconXS,
              color: status.color,
            ),
            SizedBox(width: AppSizes.spacingXS),
          ],
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
