import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/enums/order_status.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_timeline_widget.dart';
import '../../../../../shared/widgets/live_tracking_map.dart';
import '../../../../../core/utils/permissions_handler.dart';

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
    // Provider might be already disposed
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
        title: Text('Track Order #${_currentOrder.id.substring(0, 8)}'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Full Screen Map Background
          Positioned.fill(
            bottom: 300, // Show map mostly at the top
            child: LiveTrackingMap(
              customerLat: _currentOrder.deliveryAddress.latitude,
              customerLng: _currentOrder.deliveryAddress.longitude,
              deliveryPartnerName: _currentOrder.deliveryPartnerName ?? 'Delivery Partner',
            ),
          ),

          // Modern Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status Header
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
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _getStatusMessage(_currentOrder.status),
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_currentOrder.status == OrderStatus.outForDelivery) ...[
                      const SizedBox(height: 20),
                      _buildDeliveryPartnerCard(),
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Timeline
                    const Text('Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    OrderTimelineWidget(order: _currentOrder),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Address
                    const Text('Delivery Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primaryRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_currentOrder.deliveryAddress.label}: ${_currentOrder.deliveryAddress.fullAddress}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Items Summary
                    Text('Items (${_currentOrder.items.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ..._currentOrder.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text('${item.quantity} x ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                          Expanded(child: Text(item.menuItem.name)),
                          Text('₹${item.totalPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    )),
                    
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

  Widget _buildDeliveryPartnerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryRed,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOrder.deliveryPartnerName ?? 'Rahul (Partner)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Arriving in 5 mins', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => PermissionsHandler.makePhoneCall('9876543210'),
            icon: const Icon(Icons.call, color: Colors.green),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(OrderStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case OrderStatus.placed: icon = Icons.receipt; color = Colors.blue; break;
      case OrderStatus.preparing: icon = Icons.restaurant; color = Colors.orange; break;
      case OrderStatus.outForDelivery: icon = Icons.delivery_dining; color = AppColors.primaryRed; break;
      case OrderStatus.delivered: icon = Icons.check_circle; color = Colors.green; break;
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
      case OrderStatus.placed: return 'Confirmed';
      case OrderStatus.preparing: return 'Kitchen is busy';
      case OrderStatus.outForDelivery: return 'On the way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed: return 'Restaurant has accepted your order';
      case OrderStatus.preparing: return 'Chef is preparing your delicious meal';
      case OrderStatus.outForDelivery: return 'Rahul is bringing your order';
      case OrderStatus.delivered: return 'Enjoy your hot food!';
      case OrderStatus.cancelled: return 'Order was not completed';
    }
  }
}
