import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../home/presentation/screens/customer_home_screen.dart';
import '../cart/providers/cart_provider.dart';
import '../cart/presentation/screens/cart_screen.dart';
import '../orders/presentation/screens/orders_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const OrdersScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryOrange,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: AppStrings.home,
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                label: AppStrings.orders,
              ),
              BottomNavigationBarItem(
                icon: cartProvider.itemCount > 0
                    ? badges.Badge(
                        badgeContent: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                          ),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: AppColors.error,
                        ),
                        child: const Icon(Icons.shopping_cart),
                      )
                    : const Icon(Icons.shopping_cart),
                label: AppStrings.cart,
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: AppStrings.profile,
              ),
            ],
          );
        },
      ),
    );
  }
}
