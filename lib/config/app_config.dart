class AppConfig {
  AppConfig._();

  // Toggle between mock and real services
  static const bool useMockServices = true;

  // API Configuration (for future Firebase integration)
  static const String apiBaseUrl = '';
  static const String firebaseProjectId = '';

  // App Version
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Delivery Configuration
  static const double deliveryFeeFlat = 30.0;
  static const double taxPercentage = 5.0; // 5% tax
  static const double minimumOrderAmount = 100.0;
  static const double deliveryRadiusKm = 15.0; // 15km from Harur

  // Mock Configuration
  static const String mockOTP = '123456';
  static const Duration otpTimeout = Duration(minutes: 2);
  static const Duration orderStatusUpdateInterval = Duration(minutes: 5);

  // Harur Location (approximate coordinates)
  static const double harurLatitude = 12.0540;
  static const double harurLongitude = 78.4822;
}
