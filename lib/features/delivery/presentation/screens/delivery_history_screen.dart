import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/models/order_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/delivery_provider.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final deliveryProvider = context.read<DeliveryProvider>();

      if (authProvider.currentUser != null) {
        deliveryProvider.setPartnerId(authProvider.currentUser!.id);
        deliveryProvider.fetchDeliveryHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery History'),
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Stats Card
                Container(
                  margin: EdgeInsets.all(AppSizes.paddingMD),
                  padding: EdgeInsets.all(AppSizes.paddingLG),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: AppSizes.avatarLG,
                        backgroundColor: AppColors.secondaryWhite,
                        child: Icon(
                          Icons.delivery_dining,
                          size: AppSizes.iconXL,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingMD),
                      Text(
                        user?.name ?? 'Delivery Partner',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        user?.phone ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight.withOpacity(0.9),
                            ),
                      ),
                      SizedBox(height: AppSizes.spacingLG),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            'Deliveries',
                            '${provider.totalDeliveriesCompleted}',
                            Icons.check_circle,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            context,
                            'Earnings',
                            '₹${provider.totalEarnings.toStringAsFixed(0)}',
                            Icons.attach_money,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // History List
                if (provider.deliveryHistory.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(AppSizes.paddingXL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: AppSizes.spacingMD),
                        Text(
                          'No delivery history',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: AppSizes.spacingSM),
                        Text(
                          'Your completed deliveries will appear here',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...provider.getHistoryGroupedByDate().entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMD,
                            vertical: AppSizes.paddingSM,
                          ),
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                        ...entry.value.map((order) => _HistoryOrderCard(order: order)),
                      ],
                    );
                  }).toList(),

                // Logout Button
                Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLG),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(AppStrings.logout),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
        ),
      ],
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  final OrderModel order;

  const _HistoryOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingSM,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Icon(Icons.check_circle, color: Colors.green),
        ),
        title: Text(
          order.id,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${order.totalPrice.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${order.items.length} items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
