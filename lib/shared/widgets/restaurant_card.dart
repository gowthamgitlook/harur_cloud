import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/glass_theme.dart';
import '../models/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassMorphism(
        blur: 15,
        opacity: 0.1,
        margin: EdgeInsets.only(bottom: AppSizes.paddingMD),
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusLG),
                  ),
                  child: Image.network(
                    restaurant.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GlassTheme.primaryBlue.withValues(alpha: 0.1),
                            GlassTheme.secondaryBlue.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.restaurant, size: 50, color: GlassTheme.primaryBlue),
                    ),
                  ),
                ),
                // Discount/Offer Overlay (Simulated)
                Positioned(
                  bottom: 10,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: GlassTheme.buttonGradient,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: const Text(
                      '₹125 OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Rating Overlay
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GlassMorphism(
                    blur: 10,
                    opacity: 0.2,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Text(
                          restaurant.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: GlassTheme.textPrimary),
                        ),
                        const Icon(Icons.star, color: GlassTheme.warningYellow, size: 16),
                        Text(
                          ' (${restaurant.reviewCount}+)',
                          style: const TextStyle(fontSize: 10, color: GlassTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info Section
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        restaurant.name,
                        style: GlassTheme.headlineLarge.copyWith(fontSize: 18),
                      ),
                      Text(
                        restaurant.deliveryTime,
                        style: GlassTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: GlassTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: GlassTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTime} • ₹${restaurant.priceForTwo.toInt()} for two',
                        style: GlassTheme.bodyMedium.copyWith(color: GlassTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(1, 1),
      end: const Offset(1.02, 1.02),
    ).then().scale(begin: const Offset(1.02, 1.02), end: const Offset(1, 1));
  }
}
