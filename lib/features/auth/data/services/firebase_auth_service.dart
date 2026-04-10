import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/enums/user_role.dart';
import 'auth_service_interface.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userKey = 'current_user';
  String? _verificationId;

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) throw Exception('Login failed');

      // You should fetch additional user data from Firestore here
      final userModel = UserModel(
        id: user.uid,
        name: user.displayName ?? email.split('@')[0],
        email: user.email,
        phone: user.phoneNumber ?? '',
        role: UserRole.customer,
      );
      
      await saveUser(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during login');
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) throw Exception('Registration failed');

      await user.updateDisplayName(name);

      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
      );

      // Save additional user info to Firestore here
      
      await saveUser(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during registration');
    }
  }

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
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> verifyOTP(String phoneNumber, String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID is missing. Please request OTP again.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user == null) throw Exception('Verification failed');

      // Fetch user data from Firestore or create new profile
      final userModel = UserModel(
        id: user.uid,
        name: user.displayName ?? 'New User',
        phone: phoneNumber,
        email: user.email,
        role: UserRole.customer,
      );

      await saveUser(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Invalid OTP');
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
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
