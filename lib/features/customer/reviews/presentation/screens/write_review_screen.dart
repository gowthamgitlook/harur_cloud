import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/zomato_theme.dart';
import '../../../../../shared/models/order_model.dart';

class WriteReviewScreen extends StatefulWidget {
  final OrderModel order;

  const WriteReviewScreen({super.key, required this.order});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _foodRating = 4;
  double _deliveryRating = 4;
  double _packagingRating = 4;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('Rate Your Order'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ZomatoTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ZomatoTheme.primaryRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long, color: ZomatoTheme.primaryRed),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #${widget.order.id.substring(0, 8)}',
                            style: ZomatoTheme.bodyLarge),
                        Text('${widget.order.items.length} items · ₹${widget.order.totalPrice.toStringAsFixed(0)}',
                            style: ZomatoTheme.bodyMedium.copyWith(color: ZomatoTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildRatingSection(
              label: 'Food Quality',
              icon: Icons.restaurant,
              rating: _foodRating,
              onRatingUpdate: (r) => setState(() => _foodRating = r),
            ),
            const SizedBox(height: 20),
            _buildRatingSection(
              label: 'Delivery Speed',
              icon: Icons.delivery_dining,
              rating: _deliveryRating,
              onRatingUpdate: (r) => setState(() => _deliveryRating = r),
            ),
            const SizedBox(height: 20),
            _buildRatingSection(
              label: 'Packaging',
              icon: Icons.inventory_2_outlined,
              rating: _packagingRating,
              onRatingUpdate: (r) => setState(() => _packagingRating = r),
            ),

            const SizedBox(height: 24),

            Text('Your Review (Optional)', style: ZomatoTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ZomatoTheme.primaryRed),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),

            const SizedBox(height: 12),

            // Quick tag chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Tasty food', 'Fast delivery', 'Good packaging',
                'Hot & fresh', 'Portion was big', 'Value for money',
              ].map((tag) => _QuickTagChip(label: tag)).toList(),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZomatoTheme.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('SUBMIT REVIEW',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection({
    required String label,
    required IconData icon,
    required double rating,
    required void Function(double) onRatingUpdate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZomatoTheme.cardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, color: ZomatoTheme.primaryRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ZomatoTheme.bodyLarge),
                const SizedBox(height: 6),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 28,
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: onRatingUpdate,
                ),
              ],
            ),
          ),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 60),
            const SizedBox(height: 16),
            Text('Thank You!', style: ZomatoTheme.headlineLarge.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              'Your review helps other customers make better choices.',
              textAlign: TextAlign.center,
              style: ZomatoTheme.bodyMedium.copyWith(color: ZomatoTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('DONE', style: TextStyle(color: ZomatoTheme.primaryRed)),
          ),
        ],
      ),
    );
  }
}

class _QuickTagChip extends StatefulWidget {
  final String label;
  const _QuickTagChip({required this.label});

  @override
  State<_QuickTagChip> createState() => _QuickTagChipState();
}

class _QuickTagChipState extends State<_QuickTagChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _selected ? ZomatoTheme.primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected ? ZomatoTheme.primaryRed : const Color(0xFFE8E8E8),
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _selected ? Colors.white : ZomatoTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
