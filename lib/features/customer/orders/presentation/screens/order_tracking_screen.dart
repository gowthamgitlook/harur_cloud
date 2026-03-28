import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/enums/order_status.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_timeline_widget.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/live_tracking_map.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _startOrderTracking();
  }

  void _startOrderTracking() {
    // Listen to order updates
    final orderProvider = context.read<OrderProvider>();
    orderProvider.addListener(_onOrderUpdated);
  }

  void _onOrderUpdated() {
    final orderProvider = context.read<OrderProvider>();
    final updatedOrder = orderProvider.orders.cast<OrderModel?>().firstWhere(
          (o) => o?.id == _currentOrder.id,
          orElse: () => null,
        );

    if (updatedOrder != null && updatedOrder.status != _currentOrder.status) {
      setState(() {
        _currentOrder = updatedOrder;
      });
    }
  }

  @override
  void dispose() {
    context.read<OrderProvider>().removeListener(_onOrderUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final showMap = _currentOrder.status == OrderStatus.outForDelivery;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Tracking Map (only when Out for Delivery)
            if (showMap)
              SizedBox(
                height: 300,
                child: LiveTrackingMap(
                  customerLat: _currentOrder.deliveryAddress.latitude,
                  customerLng: _currentOrder.deliveryAddress.longitude,
                  deliveryPartnerName: _currentOrder.deliveryPartnerName ?? 'Delivery Partner',
                ),
              ),

            // Order Status Header
            if (!showMap)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.paddingLG),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryOrange,
                    AppColors.primaryOrange.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${_currentOrder.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: AppSizes.spacingXS),
                  Text(
                    dateFormat.format(_currentOrder.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight.withValues(alpha: 0.9),
                        ),
                  ),
                  SizedBox(height: AppSizes.spacingMD),
                  Row(
                    children: [
                      _buildStatusIcon(_currentOrder.status),
                      SizedBox(width: AppSizes.spacingMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(_currentOrder.status),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: AppSizes.spacingXS),
                            Text(
                              _getStatusMessage(_currentOrder.status),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textLight.withValues(alpha: 0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Order Timeline
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Timeline',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: AppSizes.spacingMD),
                  OrderTimelineWidget(order: _currentOrder),
                ],
              ),
            ),

            SizedBox(height: AppSizes.spacingLG),

            // Delivery Address
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMD),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.primaryOrange,
                            size: AppSizes.iconMD,
                          ),
                          SizedBox(width: AppSizes.spacingMD),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentOrder.deliveryAddress.label,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                SizedBox(height: AppSizes.spacingXS),
                                Text(
                                  _currentOrder.deliveryAddress.fullAddress,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                if (_currentOrder.deliveryAddress.landmark != null) ...[
                                  SizedBox(height: AppSizes.spacingXS),
                                  Text(
                                    'Landmark: ${_currentOrder.deliveryAddress.landmark}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.spacingLG),

            // Order Items
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items (${_currentOrder.items.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  Card(
                    child: Column(
                      children: _currentOrder.items.map((item) {
                        return Padding(
                          padding: EdgeInsets.all(AppSizes.paddingMD),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.quantity}x',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryOrange,
                                        ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizes.spacingMD),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menuItem.name,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (item.selectedAddons.isNotEmpty) ...[
                                      SizedBox(height: AppSizes.spacingXS),
                                      Text(
                                        'Addons: ${item.selectedAddons.map((a) => a.name).join(', ')}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                    if (item.specialInstructions != null) ...[
                                      SizedBox(height: AppSizes.spacingXS),
                                      Text(
                                        'Note: ${item.specialInstructions}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '₹${item.totalPrice.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.spacingLG),

            // Price Breakdown
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMD),
                      child: Column(
                        children: [
                          _buildPriceRow(context, 'Subtotal', _currentOrder.subtotal),
                          SizedBox(height: AppSizes.spacingSM),
                          _buildPriceRow(context, 'Delivery Fee', _currentOrder.deliveryFee),
                          SizedBox(height: AppSizes.spacingSM),
                          _buildPriceRow(context, 'Tax', _currentOrder.tax),
                          if (_currentOrder.discount > 0) ...[
                            SizedBox(height: AppSizes.spacingSM),
                            _buildPriceRow(
                              context,
                              'Discount${_currentOrder.promoCode != null ? ' (${_currentOrder.promoCode})' : ''}',
                              -_currentOrder.discount,
                              isDiscount: true,
                            ),
                          ],
                          Divider(height: AppSizes.spacingLG, color: AppColors.divider),
                          _buildPriceRow(
                            context,
                            'Total',
                            _currentOrder.totalPrice,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.spacingXL * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(OrderStatus status) {
    IconData icon;
    switch (status) {
      case OrderStatus.placed:
        icon = Icons.receipt;
        break;
      case OrderStatus.preparing:
        icon = Icons.restaurant;
        break;
      case OrderStatus.outForDelivery:
        icon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.textLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Icon(
        icon,
        size: AppSizes.iconLG,
        color: AppColors.textLight,
      ),
    );
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.preparing:
        return 'Preparing Your Food';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Your order has been received';
      case OrderStatus.preparing:
        return 'We are preparing your delicious food';
      case OrderStatus.outForDelivery:
        return 'Your order is on the way';
      case OrderStatus.delivered:
        return 'Enjoy your meal!';
      case OrderStatus.cancelled:
        return 'This order has been cancelled';
    }
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
                color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              ),
        ),
        Text(
          '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                color: isDiscount
                    ? AppColors.success
                    : (isTotal ? AppColors.primaryOrange : AppColors.textPrimary),
              ),
        ),
      ],
    );
  }
}
