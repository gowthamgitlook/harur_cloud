import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harur_cloud_kitchen/core/theme/zomato_theme.dart';
import 'package:harur_cloud_kitchen/features/customer/cart/providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: ZomatoTheme.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        actions: [
          if (cartProvider.itemCount > 0)
            TextButton(
              onPressed: () => cartProvider.clearCart(),
              child: const Text('Clear', style: TextStyle(color: ZomatoTheme.primaryRed)),
            ),
        ],
      ),
      body: cartProvider.isEmpty ? _buildEmptyState(context) : _buildCartContent(context, cartProvider),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 24),
          Text('Your cart is empty', style: ZomatoTheme.headlineLarge.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          const Text('Add some items from the menu to get started!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final cartItem = cartProvider.items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: ZomatoTheme.cardShadow,
                ),
                child: CartItemWidget(
                  cartItem: cartItem,
                  onIncrease: () => cartProvider.increaseQuantity(cartItem.id),
                  onDecrease: () => cartProvider.decreaseQuantity(cartItem.id),
                  onRemove: () => cartProvider.removeItem(cartItem.id),
                ),
              );
            },
          ),
        ),
        _buildCheckoutSection(context, cartProvider),
      ],
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: ZomatoTheme.bodyLarge.copyWith(fontSize: 18)),
                Text('₹${cartProvider.total.toStringAsFixed(0)}', style: ZomatoTheme.headlineLarge.copyWith(color: ZomatoTheme.primaryRed)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/customer/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ZomatoTheme.primaryRed,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    );
  }
}
