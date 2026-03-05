import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/models/address_model.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../widgets/add_edit_address_dialog.dart';

class ManageAddressesScreen extends StatelessWidget {
  const ManageAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final addresses = user?.addresses ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageAddresses),
      ),
      body: addresses.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: EdgeInsets.all(AppSizes.paddingMD),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _buildAddressCard(context, address, authProvider);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(context),
        backgroundColor: AppColors.primaryOrange,
        icon: const Icon(Icons.add, color: AppColors.textLight),
        label: const Text(
          'Add Address',
          style: TextStyle(color: AppColors.textLight),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: AppSizes.iconXXL * 2,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSizes.spacingLG),
            Text(
              'No Addresses Added',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSizes.spacingSM),
            Text(
              'Add a delivery address to place orders',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingXL),
            ElevatedButton.icon(
              onPressed: () => _showAddAddressDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel address,
    AuthProvider authProvider,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMD),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSM,
                    vertical: AppSizes.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                  ),
                  child: Text(
                    address.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditAddressDialog(context, address),
                      color: AppColors.primaryOrange,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _showDeleteConfirmation(
                        context,
                        address,
                        authProvider,
                      ),
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSizes.spacingMD),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: AppSizes.iconMD,
                  color: AppColors.primaryOrange,
                ),
                SizedBox(width: AppSizes.spacingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.fullAddress,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (address.landmark != null) ...[
                        SizedBox(height: AppSizes.spacingXS),
                        Text(
                          'Landmark: ${address.landmark}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditAddressDialog(),
    );
  }

  void _showEditAddressDialog(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AddEditAddressDialog(address: address),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AddressModel address,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address?'),
        content: Text('Are you sure you want to delete "${address.label}" address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final user = authProvider.currentUser;
              if (user != null) {
                final updatedAddresses = List<AddressModel>.from(user.addresses)
                  ..removeWhere((a) => a.id == address.id);
                final updatedUser = user.copyWith(addresses: updatedAddresses);
                authProvider.updateUser(updatedUser);
              }

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
