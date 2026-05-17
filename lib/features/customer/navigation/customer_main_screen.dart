import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../../core/theme/zomato_theme.dart';
import '../home/presentation/screens/customer_home_screen.dart';
import '../cart/providers/cart_provider.dart';
import '../cart/presentation/screens/cart_screen.dart';
import '../orders/presentation/screens/orders_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import 'providers/navigation_provider.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    CustomerHomeScreen(),
    OrdersScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Sync PageController with initial provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navProvider = context.read<NavigationProvider>();
      _pageController.jumpToPage(navProvider.selectedIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        // Sync PageController if index changed externally
        if (_pageController.hasClients && _pageController.page?.toInt() != navProvider.selectedIndex) {
          _pageController.jumpToPage(navProvider.selectedIndex);
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
            onPageChanged: (index) {
              if (navProvider.selectedIndex != index) {
                navProvider.setSelectedIndex(index);
              }
            },
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return BottomNavigationBar(
                  currentIndex: navProvider.selectedIndex,
                  onTap: (index) {
                    navProvider.setSelectedIndex(index);
                    _pageController.jumpToPage(index);
                  },
                  backgroundColor: Colors.white,
                  selectedItemColor: ZomatoTheme.primaryRed,
                  unselectedItemColor: ZomatoTheme.textTertiary,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Delivery',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_outlined),
                      activeIcon: Icon(Icons.receipt),
                      label: 'History',
                    ),
                    BottomNavigationBarItem(
                      icon: cartProvider.itemCount > 0
                          ? badges.Badge(
                              badgeContent: Text(
                                '${cartProvider.itemCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                              badgeStyle: const badges.BadgeStyle(badgeColor: ZomatoTheme.primaryRed),
                              child: const Icon(Icons.shopping_cart_outlined),
                            )
                          : const Icon(Icons.shopping_cart_outlined),
                      activeIcon: const Icon(Icons.shopping_cart),
                      label: 'Cart',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: 'Account',
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
