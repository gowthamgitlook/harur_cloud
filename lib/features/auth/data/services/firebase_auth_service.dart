import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/enums/user_role.dart';
import 'auth_service_interface.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userKey = 'current_user';

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Check local storage if Firebase session is gone but we have a saved user
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        try {
          return UserModel.fromJson(jsonDecode(userJson));
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // In a real app, you would fetch additional user data (like role) from Firestore
    return UserModel(
      id: user.uid,
      phone: user.phoneNumber ?? '',
      name: user.displayName ?? 'User',
      email: user.email,
      role: UserRole.customer, // Default to customer
      addresses: [],
    );
  }

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    // Note: Phone auth requires real device and Firebase configuration
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          // You would need to store verificationId to verify the OTP later
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> verifyOTP(String phoneNumber, String otp) async {
    // This requires the verificationId from sendOTP
    throw UnimplementedError('OTP verification needs verificationId from sendOTP');
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    // This requires google_sign_in package
    throw UnimplementedError('Google login not implemented yet');
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await currentUser.updateDisplayName(user.name);
      // Update email if changed (requires verification)
    }
    await saveUser(user);
    return user;
  }
}
