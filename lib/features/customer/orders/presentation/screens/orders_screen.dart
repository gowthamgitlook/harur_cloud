import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/zomato_theme.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../providers/order_provider.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../widgets/order_card_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<OrderProvider>().fetchOrders(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
      ),
      body: orderProvider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: ZomatoTheme.primaryRed))
        : orderProvider.orders.isEmpty 
          ? _buildEmptyState()
          : _buildOrdersList(orderProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No orders yet', style: ZomatoTheme.headlineLarge.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          const Text('Your delicious meals will appear here.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        final order = provider.orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ZomatoTheme.cardShadow,
          ),
          child: Column(
            children: [
              OrderCardWidget(
                order: order,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.orderTracking,
                    arguments: order,
                  );
                },
              ),
              if (order.status.index < 3) // If not delivered/cancelled
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ZomatoTheme.primaryRed,
                      side: const BorderSide(color: ZomatoTheme.primaryRed),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('TRACK ORDER'),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
