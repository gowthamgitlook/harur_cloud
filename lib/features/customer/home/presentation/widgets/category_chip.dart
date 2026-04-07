import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppSizes.paddingSM),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMD,
            vertical: AppSizes.paddingSM,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryRed
                : AppColors.primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryRed
                  : AppColors.primaryRed.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppSizes.iconSM,
                  color: isSelected ? AppColors.textLight : AppColors.primaryRed,
                ),
                SizedBox(width: AppSizes.spacingXS),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppColors.textLight : AppColors.primaryRed,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
