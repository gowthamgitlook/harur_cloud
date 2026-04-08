class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';

  // Customer
  static const String customerMain = '/customer/main';
  static const String home = '/customer/home';
  static const String search = '/customer/search';
  static const String cart = '/customer/cart';
  static const String profile = '/customer/profile';
  static const String notifications = '/customer/notifications';
  static const String foodDetail = '/customer/food-detail';
  static const String checkout = '/customer/checkout';
  static const String orderTracking = '/customer/order-tracking';
  static const String editProfile = '/customer/edit-profile';
  static const String manageAddresses = '/customer/manage-addresses';
  static const String addAddress = '/customer/add-address';
  static const String settings = '/customer/settings';
  static const String support = '/customer/support';
  static const String feedback = '/customer/feedback';

  // Admin
  static const String adminMain = '/admin/main';
  static const String adminOrders = '/admin/orders';
  static const String adminMenu = '/admin/menu';

  // Delivery
  static const String deliveryMain = '/delivery/main';
  static const String deliveryOrders = '/delivery/orders';
}
