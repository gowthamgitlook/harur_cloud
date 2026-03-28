import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/enums/order_status.dart';
import '../../../../../shared/enums/user_role.dart';
import '../../../../../shared/models/order_model.dart';
import '../../../../auth/data/services/mock_auth_service.dart';
import '../../providers/admin_order_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderProvider>().fetchAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminOrderProvider>().fetchAllOrders();
            },
          ),
        ],
      ),
      body: Consumer<AdminOrderProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter Chips
              _buildFilterChips(provider),

              // Orders List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.filteredOrders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: AppSizes.spacingMD),
                                Text(
                                  'No orders found',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => provider.fetchAllOrders(),
                            child: ListView.builder(
                              padding: EdgeInsets.all(AppSizes.paddingMD),
                              itemCount: provider.filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = provider.filteredOrders[index];
                                return _AdminOrderCard(order: order);
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

  Widget _buildFilterChips(AdminOrderProvider provider) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: provider.statusFilter == null,
            onTap: () => provider.clearFilter(),
          ),
          ...OrderStatus.values.map((status) {
            return _buildFilterChip(
              label: status.displayName,
              isSelected: provider.statusFilter == status,
              onTap: () => provider.filterByStatus(status),
              color: status.color,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: AppSizes.spacingSM),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[200],
        selectedColor: color ?? AppColors.primaryOrange,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const _AdminOrderCard({required this.order});

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        order.status.icon,
                        size: 16,
                        color: order.status.color,
                      ),
                      SizedBox(width: 4),
                      Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: order.status.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(height: AppSizes.spacingMD),

            // Order Details
            Text(
              '${order.items.length} items • ₹${order.totalPrice.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (order.deliveryPartnerName != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.delivery_dining, size: 16, color: AppColors.primaryOrange),
                  SizedBox(width: 4),
                  Text(
                    order.deliveryPartnerName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryOrange,
                        ),
                  ),
                ],
              ),
            ],

            SizedBox(height: AppSizes.spacingMD),

            // Action Buttons
            Row(
              children: [
                if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateStatusDialog(context, order),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Update Status'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                if (order.status == OrderStatus.outForDelivery && order.deliveryPartnerId == null) ...[
                  SizedBox(width: AppSizes.spacingSM),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignDeliveryDialog(context, order),
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Assign'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            final isCurrentStatus = order.status == status;
            return ListTile(
              leading: Icon(
                status.icon,
                color: status.color,
              ),
              title: Text(status.displayName),
              trailing: isCurrentStatus
                  ? Icon(Icons.check_circle, color: status.color)
                  : null,
              onTap: isCurrentStatus
                  ? null
                  : () async {
                      final provider = context.read<AdminOrderProvider>();
                      final success = await provider.updateOrderStatus(order.id, status);

                      if (context.mounted) {
                        Navigator.pop(context);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order status updated to ${status.displayName}'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Auto-show assign delivery if status is outForDelivery
                          if (status == OrderStatus.outForDelivery && order.deliveryPartnerId == null) {
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (context.mounted) {
                                _showAssignDeliveryDialog(context, order);
                              }
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update order status'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAssignDeliveryDialog(BuildContext context, OrderModel order) {
    // Get delivery partners from MockAuthService
    final deliveryPartners = MockAuthService.mockUsers
        .where((user) => user.role == UserRole.delivery)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Delivery Partner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: deliveryPartners.map((partner) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryOrange,
                child: Icon(Icons.delivery_dining, color: Colors.white),
              ),
              title: Text(partner.name),
              subtitle: Text(partner.phone),
              onTap: () async {
                final provider = context.read<AdminOrderProvider>();
                final success = await provider.assignDeliveryPartner(
                  orderId: order.id,
                  partnerId: partner.id,
                  partnerName: partner.name,
                  partnerPhone: partner.phone,
                );

                if (context.mounted) {
                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Assigned to ${partner.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to assign delivery partner'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
