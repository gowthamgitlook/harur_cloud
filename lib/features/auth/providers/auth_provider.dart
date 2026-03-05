import 'package:flutter/foundation.dart';
import '../../../config/app_config.dart';
import '../../../shared/enums/user_role.dart';
import '../../../shared/models/user_model.dart';
import '../data/services/auth_service_interface.dart';
import '../data/services/mock_auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final IAuthService _authService;

  UserModel? _currentUser;
  AuthState _authState = AuthState.initial;
  String? _errorMessage;
  String? _lastSentOTPPhone;

  AuthProvider({IAuthService? authService})
      : _authService = authService ??
            (AppConfig.useMockServices ? MockAuthService() : MockAuthService());

  // Getters
  UserModel? get currentUser => _currentUser;
  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  String? get lastSentOTPPhone => _lastSentOTPPhone;
  bool get isAuthenticated => _authState == AuthState.authenticated && _currentUser != null;
  UserRole? get userRole => _currentUser?.role;

  // Initialize - Check if user is already logged in
  Future<void> initialize() async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        _authState = AuthState.authenticated;
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.sendOTP(phoneNumber);
      if (success) {
        _lastSentOTPPhone = phoneNumber;
        _authState = AuthState.unauthenticated;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.verifyOTP(phoneNumber, otp);
      _authState = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.loginWithGoogle();
      _authState = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _authState = AuthState.unauthenticated;
    _errorMessage = null;
    _lastSentOTPPhone = null;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      _currentUser = await _authService.updateUser(updatedUser);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user (simple method for immediate update)
  void updateUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
