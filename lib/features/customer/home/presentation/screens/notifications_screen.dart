import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/theme/zomato_theme.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../orders/providers/order_provider.dart';
import '../../../../../shared/enums/order_status.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<OrderProvider>().fetchOrders(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final notifications = _buildNotifications(orderProvider);

    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {},
              child: const Text('Clear all', style: TextStyle(color: ZomatoTheme.primaryRed)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _NotificationCard(notification: n, index: index);
              },
            ),
    );
  }

  List<_NotificationData> _buildNotifications(OrderProvider orderProvider) {
    final notifications = <_NotificationData>[];

    for (final order in orderProvider.orders.take(20)) {
      switch (order.status) {
        case OrderStatus.placed:
          notifications.add(_NotificationData(
            icon: Icons.check_circle,
            color: Colors.blue,
            title: 'Order Confirmed',
            body: 'Your order #${order.id.substring(0, 8)} has been placed successfully.',
            time: order.createdAt,
            orderId: order.id,
          ));
          break;
        case OrderStatus.preparing:
          notifications.add(_NotificationData(
            icon: Icons.restaurant,
            color: Colors.orange,
            title: 'Order Being Prepared',
            body: 'The kitchen is preparing your order. Sit tight!',
            time: order.updatedAt ?? order.createdAt,
            orderId: order.id,
          ));
          break;
        case OrderStatus.outForDelivery:
          notifications.add(_NotificationData(
            icon: Icons.delivery_dining,
            color: Colors.green,
            title: 'Out for Delivery',
            body: '${order.deliveryPartnerName ?? 'Your delivery partner'} is on the way!',
            time: order.updatedAt ?? order.createdAt,
            orderId: order.id,
          ));
          break;
        case OrderStatus.delivered:
          notifications.add(_NotificationData(
            icon: Icons.home,
            color: ZomatoTheme.primaryRed,
            title: 'Order Delivered',
            body: 'Your order was delivered. Hope you enjoy the meal!',
            time: order.updatedAt ?? order.createdAt,
            orderId: order.id,
          ));
          break;
        case OrderStatus.cancelled:
          notifications.add(_NotificationData(
            icon: Icons.cancel,
            color: Colors.red,
            title: 'Order Cancelled',
            body: 'Your order #${order.id.substring(0, 8)} was cancelled.',
            time: order.updatedAt ?? order.createdAt,
            orderId: order.id,
          ));
          break;
      }
    }

    // Add a promotional notification at the top
    if (notifications.isEmpty) {
      notifications.add(_NotificationData(
        icon: Icons.local_offer,
        color: ZomatoTheme.primaryRed,
        title: 'Special Offer!',
        body: 'Use code FIRST50 to get 50% off on your first order.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        orderId: null,
      ));
    }

    notifications.sort((a, b) => b.time.compareTo(a.time));
    return notifications;
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: ZomatoTheme.headlineLarge.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Order something to see updates here.',
              style: ZomatoTheme.bodyMedium.copyWith(color: ZomatoTheme.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.customerMain, (r) => false),
            style: ElevatedButton.styleFrom(backgroundColor: ZomatoTheme.primaryRed),
            child: const Text('Order Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _NotificationData {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final DateTime time;
  final String? orderId;

  _NotificationData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.orderId,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData notification;
  final int index;

  const _NotificationCard({required this.notification, required this.index});

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(notification.time);
    final timeStr = diff.inMinutes < 60
        ? '${diff.inMinutes}m ago'
        : diff.inHours < 24
            ? '${diff.inHours}h ago'
            : '${diff.inDays}d ago';

    return GestureDetector(
      onTap: notification.orderId != null
          ? () {
              final order = context
                  .read<OrderProvider>()
                  .orders
                  .where((o) => o.id == notification.orderId)
                  .firstOrNull;
              if (order != null) {
                Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: order);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: ZomatoTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notification.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(notification.icon, color: notification.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: ZomatoTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(notification.body,
                      style: ZomatoTheme.bodyMedium.copyWith(
                        color: ZomatoTheme.textSecondary,
                        height: 1.4,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(timeStr,
                style: ZomatoTheme.bodyMedium.copyWith(
                  fontSize: 11,
                  color: ZomatoTheme.textTertiary,
                )),
          ],
        ),
      ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.05, end: 0),
    );
  }
}
