import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/order_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/delivery_provider.dart';

class AvailableDeliveriesScreen extends StatefulWidget {
  const AvailableDeliveriesScreen({super.key});

  @override
  State<AvailableDeliveriesScreen> createState() => _AvailableDeliveriesScreenState();
}

class _AvailableDeliveriesScreenState extends State<AvailableDeliveriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final deliveryProvider = context.read<DeliveryProvider>();

      if (authProvider.currentUser != null) {
        deliveryProvider.setPartnerId(authProvider.currentUser!.id);
        deliveryProvider.fetchAssignedOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Deliveries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DeliveryProvider>().fetchAssignedOrders();
            },
          ),
        ],
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.paddingMD),
                color: Colors.blue.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: AppSizes.spacingSM),
                    Expanded(
                      child: Text(
                        'Orders assigned to you by admin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue[900],
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Orders List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.assignedOrders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delivery_dining,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: AppSizes.spacingMD),
                                Text(
                                  'No deliveries available',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: AppSizes.spacingSM),
                                Text(
                                  'Check back later for new orders',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => provider.fetchAssignedOrders(),
                            child: ListView.builder(
                              padding: EdgeInsets.all(AppSizes.paddingMD),
                              itemCount: provider.assignedOrders.length,
                              itemBuilder: (context, index) {
                                final order = provider.assignedOrders[index];
                                return _DeliveryCard(order: order);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final OrderModel order;

  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.spacingMD),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Assigned',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizes.spacingSM),

            // Delivery Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        order.deliveryAddress.fullAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (order.deliveryAddress.landmark != null)
                        Text(
                          'Landmark: ${order.deliveryAddress.landmark}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(height: AppSizes.spacingMD),

            // Order Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      '${order.items.length} items',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      '₹${order.totalPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(order.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
