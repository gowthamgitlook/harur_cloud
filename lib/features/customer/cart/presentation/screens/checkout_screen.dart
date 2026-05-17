import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/payment_service.dart';
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
  final _promoController = TextEditingController();
  String? _promoError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && user.addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = user.addresses.first;
        });
      }
      // Pre-fill promo code if already applied
      final cartProvider = context.read<CartProvider>();
      if (cartProvider.promoCode != null) {
        _promoController.text = cartProvider.promoCode!;
      }
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
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
                                Navigator.pushNamed(context, '/customer/add-address');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text(AppStrings.addAddress),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    RadioGroup<String>(
                      groupValue: _selectedAddress?.id,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedAddress = user.addresses.firstWhere((a) => a.id == val);
                          });
                        }
                      },
                      child: Column(
                        children: user.addresses.map((address) {
                          final isSelected = _selectedAddress?.id == address.id;
                          return Card(
                            color: isSelected
                                ? AppColors.primaryRed.withValues(alpha: 0.1)
                                : null,
                            child: InkWell(
                              onTap: () => setState(() => _selectedAddress = address),
                              child: Padding(
                                padding: EdgeInsets.all(AppSizes.paddingMD),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Radio<String>(
                                      value: address.id,
                                      fillColor: WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(WidgetState.selected)) return AppColors.primaryRed;
                                        return null;
                                      }),
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
                                                  color: AppColors.primaryRed,
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
                                            ],
                                          ),
                                          SizedBox(height: AppSizes.spacingSM),
                                          Text(address.fullAddress, style: Theme.of(context).textTheme.bodyMedium),
                                          if (address.landmark != null) ...[
                                            SizedBox(height: AppSizes.spacingXS),
                                            Text(
                                              'Landmark: ${address.landmark}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
                        }).toList(),
                      ),
                    ),

                  SizedBox(height: AppSizes.spacingLG),

                  // Payment Method Section
                  Text(
                    AppStrings.paymentMethod,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),

                  RadioGroup<PaymentMethod>(
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPaymentMethod = val);
                    },
                    child: Column(
                      children: PaymentMethod.values.map((method) {
                        final isSelected = _selectedPaymentMethod == method;
                        return Card(
                          color: isSelected ? AppColors.primaryRed.withValues(alpha: 0.1) : null,
                          child: InkWell(
                            onTap: () => setState(() => _selectedPaymentMethod = method),
                            child: Padding(
                              padding: EdgeInsets.all(AppSizes.paddingMD),
                              child: Row(
                                children: [
                                  Radio<PaymentMethod>(
                                    value: method,
                                    fillColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) return AppColors.primaryRed;
                                      return null;
                                    }),
                                  ),
                                  Icon(
                                    method.icon,
                                    size: AppSizes.iconMD,
                                    color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
                                  ),
                                  SizedBox(width: AppSizes.spacingMD),
                                  Text(
                                    method.displayName,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: AppSizes.spacingLG),

                  // Promo Code Section
                  Text(
                    'Promo Code',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  Consumer<CartProvider>(
                    builder: (ctx, cart, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cart.promoCode != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer, color: AppColors.success, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${cart.promoCode} applied!',
                                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      cart.removePromoCode();
                                      _promoController.clear();
                                      setState(() => _promoError = null);
                                    },
                                    child: const Text('Remove', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _promoController,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      hintText: 'Enter promo code (e.g. FIRST50)',
                                      errorText: _promoError,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    final code = _promoController.text.trim();
                                    if (code.isEmpty) return;
                                    final applied = cart.applyPromoCode(code);
                                    setState(() {
                                      _promoError = applied ? null : 'Invalid or ineligible promo code';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                  ),
                                  child: const Text('APPLY', style: TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ['FIRST50', 'BIRYANI20', 'FREESHIP'].map((code) => ActionChip(
                              label: Text(code, style: const TextStyle(fontSize: 11)),
                              onPressed: cart.promoCode == null ? () {
                                _promoController.text = code;
                                final applied = cart.applyPromoCode(code);
                                setState(() => _promoError = applied ? null : 'Not eligible for this order');
                              } : null,
                            )).toList(),
                          ),
                        ],
                      );
                    },
                  ),

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

    // Process Payment if not COD
    if (_selectedPaymentMethod != PaymentMethod.cashOnDelivery) {
      final paymentService = PaymentService();
      await paymentService.initiateUpiPayment(
        payeeVpa: 'merchant@upi',
        payeeName: 'Harur Cloud Kitchen',
        amount: cartProvider.total,
        transactionNote: 'Order payment for Harur Cloud Kitchen',
      );
    } else {
      // Simulate payment processing for COD
      await Future.delayed(const Duration(seconds: 2));
    }

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
