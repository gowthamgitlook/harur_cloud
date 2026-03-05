import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/models/address_model.dart';
import '../../../../shared/models/user_model.dart';
import 'auth_service_interface.dart';

class MockAuthService implements IAuthService {
  static const String _userKey = 'current_user';

  // Mock users for testing
  static final List<UserModel> _mockUsers = [
    UserModel(
      id: '1',
      name: 'Test Customer',
      phone: '+919876543210',
      email: 'customer@harur.com',
      role: UserRole.customer,
      addresses: [
        AddressModel(
          id: 'addr1',
          label: 'Home',
          fullAddress: 'Main Street, Harur, Dharmapuri, Tamil Nadu 636903',
          landmark: 'Near Bus Stand',
          latitude: AppConfig.harurLatitude,
          longitude: AppConfig.harurLongitude,
        ),
      ],
    ),
    UserModel(
      id: '2',
      name: 'Admin User',
      phone: '+919876543211',
      email: 'admin@harur.com',
      role: UserRole.admin,
    ),
    UserModel(
      id: '3',
      name: 'Delivery Partner',
      phone: '+919876543212',
      email: 'delivery@harur.com',
      role: UserRole.delivery,
    ),
  ];

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if phone number exists in mock users
    final user = _mockUsers.firstWhere(
      (u) => u.phone == phoneNumber,
      orElse: () => throw Exception('Phone number not registered. Use: +919876543210, +919876543211, or +919876543212'),
    );

    // In mock mode, always return true
    print('Mock OTP sent to ${user.phone}: ${AppConfig.mockOTP}');
    return true;
  }

  @override
  Future<UserModel> verifyOTP(String phoneNumber, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Verify OTP
    if (otp != AppConfig.mockOTP) {
      throw Exception('Invalid OTP. Use: ${AppConfig.mockOTP}');
    }

    // Find user by phone number
    final user = _mockUsers.firstWhere(
      (u) => u.phone == phoneNumber,
      orElse: () => throw Exception('User not found'),
    );

    // Save user locally
    await saveUser(user);

    return user;
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // For mock, return a default customer user
    final user = UserModel(
      id: 'google_user_1',
      name: 'Google User',
      phone: '+919999999999',
      email: 'googleuser@gmail.com',
      role: UserRole.customer,
    );

    await saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) {
      return null;
    }

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Save updated user
    await saveUser(user);
    return user;
  }
}
