class AppRoutes {
  AppRoutes._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection = '/role-selection';

  // Customer Routes
  static const String customerHome = '/customer/home';
  static const String customerMain = '/customer/main';
  static const String foodDetail = '/customer/food-detail';
  static const String categoryItems = '/customer/category-items';
  static const String cart = '/customer/cart';
  static const String checkout = '/customer/checkout';
  static const String payment = '/customer/payment';
  static const String paymentSuccess = '/customer/payment-success';
  static const String orders = '/customer/orders';
  static const String orderTracking = '/customer/order-tracking';
  static const String orderDetails = '/customer/order-details';
  static const String profile = '/customer/profile';
  static const String editProfile = '/customer/edit-profile';
  static const String manageAddresses = '/customer/manage-addresses';
  static const String addAddress = '/customer/add-address';
  static const String editAddress = '/customer/edit-address';
  static const String settings = '/customer/settings';

  // Admin Routes
  static const String adminMain = '/admin/main';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminAnalytics = '/admin/analytics';
  static const String orderManagement = '/admin/order-management';
  static const String orderAction = '/admin/order-action';
  static const String menuManagement = '/admin/menu-management';
  static const String addMenuItem = '/admin/add-menu-item';
  static const String editMenuItem = '/admin/edit-menu-item';
  static const String categoryManagement = '/admin/category-management';
  static const String deliveryAssignment = '/admin/delivery-assignment';

  // Delivery Routes
  static const String deliveryMain = '/delivery/main';
  static const String deliveryDashboard = '/delivery/dashboard';
  static const String deliveryRequest = '/delivery/request';
  static const String deliveryNavigation = '/delivery/navigation';
  static const String deliveryHistory = '/delivery/history';

  // Common Routes
  static const String aboutUs = '/about-us';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String shareApp = '/share-app';
}
