import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum OrderStatus {
  placed,
  preparing,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.placed:
        return AppColors.orderPlaced;
      case OrderStatus.preparing:
        return AppColors.orderPreparing;
      case OrderStatus.outForDelivery:
        return AppColors.orderOutForDelivery;
      case OrderStatus.delivered:
        return AppColors.orderDelivered;
      case OrderStatus.cancelled:
        return AppColors.orderCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.placed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return OrderStatus.placed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'outfordelivery':
      case 'out for delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }
}
