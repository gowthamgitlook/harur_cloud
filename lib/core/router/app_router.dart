import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/customer/navigation/customer_main_screen.dart';
import '../../features/customer/home/presentation/screens/food_detail_screen.dart';
import '../../features/customer/cart/presentation/screens/checkout_screen.dart';
import '../../features/customer/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/customer/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/customer/profile/presentation/screens/manage_addresses_screen.dart';
import '../../features/customer/profile/presentation/screens/settings_screen.dart';
import '../../features/admin/navigation/admin_main_screen.dart';
import '../../features/delivery/navigation/delivery_main_screen.dart';
import '../../shared/models/menu_item_model.dart';
import '../../shared/models/order_model.dart';
import '../constants/app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.otpVerification:
        final phoneNumber = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(phoneNumber: phoneNumber),
        );

      // Customer Routes
      case AppRoutes.customerMain:
        return MaterialPageRoute(builder: (_) => const CustomerMainScreen());

      case AppRoutes.foodDetail:
        final menuItem = settings.arguments as MenuItemModel;
        return MaterialPageRoute(
          builder: (_) => FoodDetailScreen(menuItem: menuItem),
        );

      case AppRoutes.checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      case AppRoutes.orderTracking:
        final order = settings.arguments as OrderModel;
        return MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(order: order),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.manageAddresses:
        return MaterialPageRoute(builder: (_) => const ManageAddressesScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      // Admin Routes
      case AppRoutes.adminMain:
        return MaterialPageRoute(builder: (_) => const AdminMainScreen());

      // Delivery Routes
      case AppRoutes.deliveryMain:
        return MaterialPageRoute(builder: (_) => const DeliveryMainScreen());

      // Default - 404
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
