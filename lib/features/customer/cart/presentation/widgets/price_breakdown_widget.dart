import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../providers/cart_provider.dart';

class PriceBreakdownWidget extends StatelessWidget {
  final CartProvider cartProvider;

  const PriceBreakdownWidget({
    super.key,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            context,
            AppStrings.subtotal,
            cartProvider.subtotal,
          ),
          SizedBox(height: AppSizes.spacingSM),
          _buildPriceRow(
            context,
            AppStrings.deliveryFee,
            cartProvider.deliveryFee,
          ),
          SizedBox(height: AppSizes.spacingSM),
          _buildPriceRow(
            context,
            '${AppStrings.tax} (5%)',
            cartProvider.tax,
          ),
          if (cartProvider.discount > 0) ...[
            SizedBox(height: AppSizes.spacingSM),
            _buildPriceRow(
              context,
              AppStrings.discount,
              -cartProvider.discount,
              color: AppColors.success,
            ),
          ],
          Divider(height: AppSizes.spacingLG),
          _buildPriceRow(
            context,
            AppStrings.total,
            cartProvider.total,
            isBold: true,
            color: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                color: color ?? (amount < 0 ? AppColors.success : null),
              ),
        ),
      ],
    );
  }
}
