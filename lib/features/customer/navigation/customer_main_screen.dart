import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../home/presentation/screens/customer_home_screen.dart';
import '../cart/providers/cart_provider.dart';
import '../cart/presentation/screens/cart_screen.dart';
import '../orders/presentation/screens/orders_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import 'providers/navigation_provider.dart';

class CustomerMainScreen extends StatelessWidget {
  const CustomerMainScreen({super.key});

  final List<Widget> _screens = const [
    CustomerHomeScreen(),
    OrdersScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: _screens[navProvider.selectedIndex],
          bottomNavigationBar: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return BottomNavigationBar(
                currentIndex: navProvider.selectedIndex,
                onTap: (index) => navProvider.setSelectedIndex(index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primaryRed,
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
      },
    );
  }
}
