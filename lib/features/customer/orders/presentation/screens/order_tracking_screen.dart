import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../../shared/enums/order_status.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_timeline_widget.dart';
import '../../../../../shared/widgets/live_tracking_map.dart';
import '../../../../../shared/widgets/animated_background.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Track Order #${_currentOrder.id.substring(0, 8)}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBackground(
        child: Stack(
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
              return GlassMorphism(
                blur: 20,
                opacity: 0.1,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                padding: EdgeInsets.zero,
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
                          color: Colors.white.withValues(alpha: 0.3),
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
                                style: GlassTheme.headlineLarge,
                              ),
                              Text(
                                _getStatusMessage(_currentOrder.status),
                                style: GlassTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideX(begin: -0.1, end: 0),

                    if (_currentOrder.status == OrderStatus.outForDelivery) ...[
                      const SizedBox(height: 20),
                      _buildDeliveryPartnerCard().animate().fadeIn().scale(),
                    ],

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Timeline
                    Text('Order Status', style: GlassTheme.headlineLarge.copyWith(fontSize: 18)),
                    const SizedBox(height: 16),
                    OrderTimelineWidget(order: _currentOrder).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Address
                    Text('Delivery Location', style: GlassTheme.headlineLarge.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: GlassTheme.primaryBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_currentOrder.deliveryAddress.label}: ${_currentOrder.deliveryAddress.fullAddress}',
                            style: GlassTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Items Summary
                    Text('Items (${_currentOrder.items.length})', style: GlassTheme.headlineLarge.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    ..._currentOrder.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text('${item.quantity} x ', style: const TextStyle(fontWeight: FontWeight.bold, color: GlassTheme.primaryBlue)),
                          Expanded(child: Text(item.menuItem.name, style: GlassTheme.bodyMedium)),
                          Text('₹${item.totalPrice.toStringAsFixed(0)}', style: GlassTheme.bodyMedium),
                        ],
                      ),
                    )).toList().animate(interval: 50.ms).fadeIn(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ],
      ),),
    );
  }

  Widget _buildDeliveryPartnerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: GlassTheme.primaryBlue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOrder.deliveryPartnerName ?? 'Rahul (Partner)',
                  style: GlassTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text('Arriving in 5 mins', style: TextStyle(fontSize: 12, color: GlassTheme.successGreen, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => PermissionsHandler.makePhoneCall('9876543210'),
            icon: const Icon(Icons.call, color: GlassTheme.successGreen),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(OrderStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case OrderStatus.placed: icon = Icons.receipt; color = GlassTheme.infoBlue; break;
      case OrderStatus.preparing: icon = Icons.restaurant; color = GlassTheme.warningYellow; break;
      case OrderStatus.outForDelivery: icon = Icons.delivery_dining; color = GlassTheme.primaryBlue; break;
      case OrderStatus.delivered: icon = Icons.check_circle; color = GlassTheme.successGreen; break;
      case OrderStatus.cancelled: icon = Icons.cancel; color = GlassTheme.errorRed; break;
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
