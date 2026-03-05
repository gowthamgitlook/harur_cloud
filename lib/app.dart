import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/customer/home/providers/menu_provider.dart';
import 'features/customer/cart/providers/cart_provider.dart';
import 'features/customer/orders/providers/order_provider.dart';
import 'features/admin/order_management/providers/admin_order_provider.dart';
import 'features/admin/menu_management/providers/admin_menu_provider.dart';
import 'features/delivery/providers/delivery_provider.dart';

class HarurCloudKitchenApp extends StatelessWidget {
  const HarurCloudKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // Menu Provider
        ChangeNotifierProvider(
          create: (_) => MenuProvider(),
        ),

        // Cart Provider
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),

        // Order Provider
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),

        // Admin Order Provider
        ChangeNotifierProvider(
          create: (_) => AdminOrderProvider(),
        ),

        // Admin Menu Provider
        ChangeNotifierProvider(
          create: (_) => AdminMenuProvider(),
        ),

        // Delivery Provider
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Harur Cloud Kitchen',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: DarkTheme.darkTheme,
        themeMode: ThemeMode.light, // TODO: Make this dynamic based on user preference

        // Routing
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
