import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/enums/payment_method.dart';
import '../../../../../shared/models/address_model.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../widgets/price_breakdown_widget.dart';
import '../../../orders/providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  AddressModel? _selectedAddress;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    // Set default address
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && user.addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = user.addresses.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.checkout),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Section
                  Text(
                    AppStrings.deliveryAddress,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),

                  if (user == null || user.addresses.isEmpty)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingMD),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off,
                              size: AppSizes.iconLG,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSizes.spacingSM),
                            Text(
                              'No delivery address found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: AppSizes.spacingSM),
                            TextButton.icon(
                              onPressed: () {
                                // TODO: Navigate to add address
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Add address - Coming soon!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text(AppStrings.addAddress),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...user.addresses.map((address) {
                      final isSelected = _selectedAddress?.id == address.id;
                      return Card(
                        color: isSelected
                            ? AppColors.primaryOrange.withOpacity(0.1)
                            : null,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAddress = address;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(AppSizes.paddingMD),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Radio<String>(
                                  value: address.id,
                                  groupValue: _selectedAddress?.id,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAddress = address;
                                    });
                                  },
                                  activeColor: AppColors.primaryOrange,
                                ),
                                SizedBox(width: AppSizes.spacingSM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSizes.paddingSM,
                                              vertical: AppSizes.paddingXS,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryOrange,
                                              borderRadius: BorderRadius.circular(
                                                AppSizes.radiusXS,
                                              ),
                                            ),
                                            child: Text(
                                              address.label,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.textLight,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppSizes.spacingSM),
                                      Text(
                                        address.fullAddress,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      if (address.landmark != null) ...[
                                        SizedBox(height: AppSizes.spacingXS),
                                        Text(
                                          'Landmark: ${address.landmark}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  SizedBox(height: AppSizes.spacingLG),

                  // Payment Method Section
                  Text(
                    AppStrings.paymentMethod,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),

                  ...PaymentMethod.values.map((method) {
                    final isSelected = _selectedPaymentMethod == method;
                    return Card(
                      color: isSelected
                          ? AppColors.primaryOrange.withOpacity(0.1)
                          : null,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.paddingMD),
                          child: Row(
                            children: [
                              Radio<PaymentMethod>(
                                value: method,
                                groupValue: _selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                                activeColor: AppColors.primaryOrange,
                              ),
                              Icon(
                                method.icon,
                                size: AppSizes.iconMD,
                                color: isSelected
                                    ? AppColors.primaryOrange
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(width: AppSizes.spacingMD),
                              Text(
                                method.displayName,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: AppSizes.spacingLG),

                  // Order Summary
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  PriceBreakdownWidget(cartProvider: cartProvider),

                  SizedBox(height: AppSizes.spacingXL),
                ],
              ),
            ),
          ),

          // Place Order Button
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
                child: CustomButton(
                  text: 'Place Order - ₹${cartProvider.total.toStringAsFixed(0)}',
                  onPressed: _selectedAddress != null && !_isPlacingOrder
                      ? _placeOrder
                      : null,
                  isLoading: _isPlacingOrder,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final user = context.read<AuthProvider>().currentUser;

    if (user == null) {
      setState(() => _isPlacingOrder = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please login again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Create order using order provider
    final order = await orderProvider.createOrder(
      userId: user.id,
      items: cartProvider.items,
      subtotal: cartProvider.subtotal,
      deliveryFee: cartProvider.deliveryFee,
      tax: cartProvider.tax,
      discount: cartProvider.discount,
      totalPrice: cartProvider.total,
      paymentMethod: _selectedPaymentMethod,
      deliveryAddress: _selectedAddress!,
      promoCode: cartProvider.promoCode,
    );

    setState(() => _isPlacingOrder = false);

    if (!mounted) return;

    if (order == null) {
      // Order creation failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Order created successfully - clear cart
    cartProvider.clearCart();

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: AppSizes.iconXXL * 2,
              color: AppColors.success,
            ),
            SizedBox(height: AppSizes.spacingLG),
            Text(
              AppStrings.orderPlacedSuccess,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingSM),
            Text(
              'Order #${order.id}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingXS),
            Text(
              'Your order has been placed successfully!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
              Navigator.of(context).pop(); // Go to home (so user can check Orders tab)
            },
            child: const Text('View Orders'),
          ),
        ],
      ),
    );
  }
}
