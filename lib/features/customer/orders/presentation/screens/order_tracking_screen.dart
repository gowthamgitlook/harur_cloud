import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/theme/zomato_theme.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/enums/order_status.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_timeline_widget.dart';
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
    context.read<OrderProvider>().addListener(_onOrderUpdated);
  }

  void _onOrderUpdated() {
    final orderProvider = context.read<OrderProvider>();
    final updatedOrder = orderProvider.orders.cast<OrderModel?>().firstWhere(
          (o) => o?.id == _currentOrder.id,
          orElse: () => null,
        );

    if (updatedOrder != null && updatedOrder.status != _currentOrder.status) {
      if (mounted) setState(() => _currentOrder = updatedOrder);
    }
  }

  @override
  void dispose() {
    try {
      context.read<OrderProvider>().removeListener(_onOrderUpdated);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track Order', style: ZomatoTheme.bodyLarge),
            Text('#${_currentOrder.id.substring(0, 8)}', style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map Section
          Positioned.fill(
            bottom: 350,
            child: LiveTrackingMap(
              customerLat: _currentOrder.deliveryAddress.latitude,
              customerLng: _currentOrder.deliveryAddress.longitude,
              deliveryPartnerName: _currentOrder.deliveryPartnerName ?? 'Delivery Partner',
            ),
          ),

          // Zomato-style Details Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Status Message
                    Row(
                      children: [
                        _buildStatusIcon(_currentOrder.status),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusTitle(_currentOrder.status),
                                style: ZomatoTheme.headlineLarge.copyWith(fontSize: 20),
                              ),
                              Text(
                                _getStatusMessage(_currentOrder.status),
                                style: ZomatoTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // Delivery Partner Card
                    if (_currentOrder.status == OrderStatus.outForDelivery)
                      _buildPartnerCard(),

                    // Timeline
                    Text('Order Status', style: ZomatoTheme.bodyLarge),
                    const SizedBox(height: 16),
                    OrderTimelineWidget(order: _currentOrder),

                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // Address
                    Text('Delivery Address', style: ZomatoTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: ZomatoTheme.primaryRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentOrder.deliveryAddress.fullAddress,
                            style: ZomatoTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    // Rate Order button for delivered orders
                    if (_currentOrder.status == OrderStatus.delivered) ...[
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.writeReview,
                            arguments: _currentOrder,
                          ),
                          icon: const Icon(Icons.star_outline, color: Colors.white),
                          label: const Text('Rate this order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ZomatoTheme.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.delivery_dining, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOrder.deliveryPartnerName ?? 'Rahul',
                  style: ZomatoTheme.bodyLarge,
                ),
                Text('Your delivery partner', style: ZomatoTheme.bodyMedium.copyWith(fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(OrderStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case OrderStatus.placed: icon = Icons.check_circle; color = Colors.green; break;
      case OrderStatus.preparing: icon = Icons.restaurant; color = Colors.orange; break;
      case OrderStatus.outForDelivery: icon = Icons.delivery_dining; color = Colors.blue; break;
      case OrderStatus.delivered: icon = Icons.home; color = Colors.green; break;
      case OrderStatus.cancelled: icon = Icons.cancel; color = Colors.red; break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 28),
    );
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.preparing: return 'Preparing your food';
      case OrderStatus.outForDelivery: return 'On the way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed: return 'Wait while we confirm with the restaurant';
      case OrderStatus.preparing: return 'The chef is working their magic';
      case OrderStatus.outForDelivery: return 'Our partner is bringing your meal';
      case OrderStatus.delivered: return 'Enjoy your meal!';
      case OrderStatus.cancelled: return 'Order was cancelled';
    }
  }
}
