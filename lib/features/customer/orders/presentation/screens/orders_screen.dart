import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/widgets/loading_indicator.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_card_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch orders on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<OrderProvider>().fetchOrders(user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myOrders),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryOrange,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading orders...');
          }

          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppSizes.iconXXL,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSizes.spacingMD),
                  Text(
                    orderProvider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.spacingMD),
                  TextButton(
                    onPressed: () {
                      final user = context.read<AuthProvider>().currentUser;
                      if (user != null) {
                        orderProvider.fetchOrders(user.id);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Active Orders Tab
              _buildActiveOrdersList(orderProvider),

              // Order History Tab
              _buildOrderHistoryList(orderProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveOrdersList(OrderProvider orderProvider) {
    if (!orderProvider.hasActiveOrders) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: AppSizes.iconXXL * 2,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSizes.spacingLG),
            Text(
              'No active orders',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSizes.spacingSM),
            Text(
              'Your active orders will appear here',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().currentUser;
        if (user != null) {
          await orderProvider.fetchOrders(user.id);
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        itemCount: orderProvider.activeOrders.length,
        itemBuilder: (context, index) {
          final order = orderProvider.activeOrders[index];
          return OrderCardWidget(
            order: order,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/customer/order-tracking',
                arguments: order,
              );
            },
            onCancel: () => _showCancelDialog(context, order.id),
          );
        },
      ),
    );
  }

  Widget _buildOrderHistoryList(OrderProvider orderProvider) {
    if (!orderProvider.hasOrderHistory) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: AppSizes.iconXXL * 2,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSizes.spacingLG),
            Text(
              'No order history',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSizes.spacingSM),
            Text(
              'Your completed orders will appear here',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().currentUser;
        if (user != null) {
          await orderProvider.fetchOrders(user.id);
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        itemCount: orderProvider.orderHistory.length,
        itemBuilder: (context, index) {
          final order = orderProvider.orderHistory[index];
          return OrderCardWidget(
            order: order,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/customer/order-tracking',
                arguments: order,
              );
            },
            onReorder: () => _handleReorder(context, order),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await context.read<OrderProvider>().cancelOrder(orderId);

              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order cancelled successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot cancel order. It\'s already being prepared.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReorder(BuildContext context, order) async {
    final orderProvider = context.read<OrderProvider>();

    final newOrder = await orderProvider.reorder(order);

    if (!context.mounted) return;

    if (newOrder != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${newOrder.id} placed successfully'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/customer/order-tracking',
                arguments: newOrder,
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reorder. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
