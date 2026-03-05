import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/enums/order_status.dart';
import 'package:intl/intl.dart';

class OrderTimelineWidget extends StatelessWidget {
  final OrderModel order;

  const OrderTimelineWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    // Define timeline steps
    final steps = [
      TimelineStep(
        status: OrderStatus.placed,
        title: 'Order Placed',
        subtitle: 'We have received your order',
        time: order.createdAt,
      ),
      TimelineStep(
        status: OrderStatus.preparing,
        title: 'Preparing',
        subtitle: 'Our kitchen is preparing your food',
        time: order.status.index >= OrderStatus.preparing.index
            ? order.createdAt.add(const Duration(seconds: 30))
            : null,
      ),
      TimelineStep(
        status: OrderStatus.outForDelivery,
        title: 'Out for Delivery',
        subtitle: 'Your order is on the way',
        time: order.status.index >= OrderStatus.outForDelivery.index
            ? order.createdAt.add(const Duration(seconds: 60))
            : null,
      ),
      TimelineStep(
        status: OrderStatus.delivered,
        title: 'Delivered',
        subtitle: 'Order delivered successfully',
        time: order.status == OrderStatus.delivered
            ? order.createdAt.add(const Duration(seconds: 90))
            : null,
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        final isCompleted = order.status.index >= step.status.index;
        final isCurrent = order.status == step.status;
        final isCancelled = order.status == OrderStatus.cancelled;

        return _buildTimelineItem(
          context,
          step: step,
          isCompleted: isCompleted && !isCancelled,
          isCurrent: isCurrent && !isCancelled,
          isLast: isLast,
          timeFormat: timeFormat,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required TimelineStep step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required DateFormat timeFormat,
  }) {
    final color = isCompleted || isCurrent
        ? AppColors.primaryOrange
        : AppColors.textSecondary.withOpacity(0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              // Circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? AppColors.primaryOrange
                      : AppColors.secondaryWhite,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.textLight,
                        )
                      : isCurrent
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.textLight,
                              ),
                            )
                          : null,
                ),
              ),

              // Connecting line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: AppSizes.spacingXS),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primaryOrange
                          : AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: AppSizes.spacingMD),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSizes.spacingLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                              color: isCompleted || isCurrent
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                      ),
                      if (step.time != null)
                        Text(
                          timeFormat.format(step.time!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingXS),
                  Text(
                    step.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (isCurrent) ...[
                    SizedBox(height: AppSizes.spacingSM),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSM,
                        vertical: AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryOrange,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingSM),
                          Text(
                            'In Progress',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineStep {
  final OrderStatus status;
  final String title;
  final String subtitle;
  final DateTime? time;

  TimelineStep({
    required this.status,
    required this.title,
    required this.subtitle,
    this.time,
  });
}
