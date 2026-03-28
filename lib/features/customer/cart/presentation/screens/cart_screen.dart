import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/price_breakdown_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoController = TextEditingController();
  bool _isApplyingPromo = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myCart),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isEmpty) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  _showClearCartDialog(context);
                },
                child: const Text(AppStrings.clearCart),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: AppSizes.iconXXL * 2,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSizes.spacingLG),
                  Text(
                    AppStrings.emptyCart,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  Text(
                    'Add items to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(AppSizes.paddingMD),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.items[index];
                    return CartItemWidget(
                      cartItem: cartItem,
                      onIncrease: () {
                        cartProvider.increaseQuantity(cartItem.id);
                      },
                      onDecrease: () {
                        cartProvider.decreaseQuantity(cartItem.id);
                      },
                      onRemove: () {
                        cartProvider.removeItem(cartItem.id);
                      },
                    );
                  },
                ),
              ),

              // Bottom Section
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMD),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Promo Code
                        if (cartProvider.promoCode == null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _promoController,
                                  hint: 'Enter promo code',
                                  prefixIcon: const Icon(Icons.local_offer),
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                              SizedBox(width: AppSizes.spacingSM),
                              CustomButton(
                                text: 'Apply',
                                onPressed: _isApplyingPromo ? null : _applyPromoCode,
                                isLoading: _isApplyingPromo,
                                width: 100,
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizes.spacingSM),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.all(AppSizes.paddingMD),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: AppSizes.iconSM,
                                ),
                                SizedBox(width: AppSizes.spacingSM),
                                Expanded(
                                  child: Text(
                                    'Promo code "${cartProvider.promoCode}" applied',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    cartProvider.removePromoCode();
                                    _promoController.clear();
                                  },
                                  color: AppColors.success,
                                  iconSize: AppSizes.iconSM,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSizes.spacingSM),
                        ],

                        // Price Breakdown
                        PriceBreakdownWidget(cartProvider: cartProvider),

                        SizedBox(height: AppSizes.spacingMD),

                        // Minimum Order Warning
                        if (!cartProvider.meetsMinimumOrder)
                          Container(
                            padding: EdgeInsets.all(AppSizes.paddingSM),
                            margin: EdgeInsets.only(bottom: AppSizes.spacingSM),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                              border: Border.all(color: AppColors.warning),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.warning,
                                  size: AppSizes.iconSM,
                                ),
                                SizedBox(width: AppSizes.spacingSM),
                                Expanded(
                                  child: Text(
                                    'Add ₹${cartProvider.amountNeededForMinimum.toStringAsFixed(0)} more to place order',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.warning,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Checkout Button
                        CustomButton(
                          text: 'Proceed to Checkout (₹${cartProvider.total.toStringAsFixed(0)})',
                          onPressed: cartProvider.meetsMinimumOrder
                              ? () {
                                  Navigator.of(context).pushNamed('/customer/checkout');
                                }
                              : null,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _applyPromoCode() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingPromo = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final cartProvider = context.read<CartProvider>();
    final success = cartProvider.applyPromoCode(code);

    setState(() => _isApplyingPromo = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.promoApplied),
          backgroundColor: AppColors.success,
        ),
      );
      _promoController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.invalidPromo),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
