import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../order_management/providers/admin_order_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminOrderProvider>();
      provider.fetchAllOrders();
      provider.loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = context.read<AdminOrderProvider>();
              provider.fetchAllOrders();
              provider.loadDashboardStats();
            },
          ),
        ],
      ),
      body: Consumer<AdminOrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.dashboardStats;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchAllOrders();
              provider.loadDashboardStats();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSizes.spacingMD,
                    mainAxisSpacing: AppSizes.spacingMD,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        title: 'Today Orders',
                        value: '${stats['todayOrders'] ?? 0}',
                        icon: Icons.shopping_bag,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        title: 'Today Revenue',
                        value: '₹${(stats['todayRevenue'] ?? 0.0).toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      _StatCard(
                        title: 'Active Orders',
                        value: '${stats['activeOrders'] ?? 0}',
                        icon: Icons.pending_actions,
                        color: AppColors.primaryRed,
                        isLive: true,
                      ),
                      _StatCard(
                        title: 'Month Revenue',
                        value: '₹${(stats['monthRevenue'] ?? 0.0).toStringAsFixed(0)}',
                        icon: Icons.calendar_month,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.spacingLG),

                  // Revenue Metrics
                  _buildSectionHeader('Revenue Breakdown'),
                  SizedBox(height: AppSizes.spacingSM),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMD),
                      child: Column(
                        children: [
                          _buildRevenueRow('Today', stats['todayRevenue'] ?? 0.0, stats['todayOrders'] ?? 0),
                          Divider(height: AppSizes.spacingMD),
                          _buildRevenueRow('This Week', stats['weekRevenue'] ?? 0.0, stats['weekOrders'] ?? 0),
                          Divider(height: AppSizes.spacingMD),
                          _buildRevenueRow('This Month', stats['monthRevenue'] ?? 0.0, stats['monthOrders'] ?? 0),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizes.spacingLG),

                  // Popular Items
                  if (stats['popularItems'] != null && (stats['popularItems'] as List).isNotEmpty) ...[
                    _buildSectionHeader('Popular Items'),
                    SizedBox(height: AppSizes.spacingSM),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (stats['popularItems'] as List).length,
                        itemBuilder: (context, index) {
                          final item = (stats['popularItems'] as List)[index];
                          return _PopularItemCard(
                            name: item['menuItem'].name,
                            count: item['count'],
                            revenue: item['revenue'],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildRevenueRow(String period, double revenue, int orders) {
    final avgOrder = orders > 0 ? revenue / orders : 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              period,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '$orders orders',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${revenue.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Avg: ₹${avgOrder.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularItemCard extends StatelessWidget {
  final String name;
  final int count;
  final double revenue;

  const _PopularItemCard({
    required this.name,
    required this.count,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: AppSizes.spacingMD),
      child: Container(
        width: 160,
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count orders',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                ),
                Text(
                  '₹${revenue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
