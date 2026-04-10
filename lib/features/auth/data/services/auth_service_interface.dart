import '../../../../shared/models/user_model.dart';
import '../../../../shared/enums/user_role.dart';

abstract class IAuthService {
  /// Login with email and password
  Future<UserModel> loginWithEmail(String email, String password);

  /// Register with email and password
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  });

  /// Send OTP to the given phone number
  Future<bool> sendOTP(String phoneNumber);

  /// Verify OTP and login/signup the user
  Future<UserModel> verifyOTP(String phoneNumber, String otp);

  /// Login with Google
  Future<UserModel> loginWithGoogle();

  /// Logout the current user
  Future<void> logout();

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Save user data locally
  Future<void> saveUser(UserModel user);

  /// Update user profile
  Future<UserModel> updateUser(UserModel user);
}
