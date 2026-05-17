import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../data/services/firestore_user_service.dart';
import 'auth_service_interface.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreUserService _userService = FirestoreUserService();
  static const String _userKey = 'current_user';
  String? _verificationId;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    // clientId comes from google-services.json (Android) / GoogleService-Info.plist (iOS)
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;
      if (user == null) throw Exception('Login failed');
      final userModel =
          await _userService.getUser(user.uid) ?? _defaultUser(user);
      await saveUser(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login error');
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
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;
      if (user == null) throw Exception('Registration failed');
      await user.updateDisplayName(name);
      final userModel = UserModel(
          id: user.uid, name: name, email: email, phone: phone, role: role);
      await _userService.createUser(userModel);
      await saveUser(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration error');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_userKey);
      if (json != null) {
        try {
          return UserModel.fromJson(jsonDecode(json));
        } catch (_) {}
      }
      return null;
    }
    // Try Firestore first for full profile (role, addresses, favourites)
    try {
      final userModel = await _userService.getUser(firebaseUser.uid);
      if (userModel != null) {
        await saveUser(userModel);
        return userModel;
      }
    } catch (_) {}
    // Fallback: SharedPreferences cached copy
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json != null) {
      try {
        return UserModel.fromJson(jsonDecode(json));
      } catch (_) {}
    }
    return _defaultUser(firebaseUser);
  }

  @override
  Future<bool> sendOTP(String phoneNumber) async {
    final completer = Completer<bool>();
    try {
      _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          // Auto-verified on some Android devices — sign in immediately
          await _auth.signInWithCredential(cred);
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(Exception(e.message ?? 'Phone verification failed'));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      return await completer.future;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserModel> verifyOTP(String phoneNumber, String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID missing. Please request OTP again.');
      }
      final cred = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);
      final result = await _auth.signInWithCredential(cred);
      final user = result.user;
      if (user == null) throw Exception('Verification failed');

      final authUser = UserModel(
        id: user.uid,
        name: user.displayName ?? 'User',
        phone: phoneNumber,
        email: user.email,
        role: UserRole.customer,
      );

      UserModel existing;
      try {
        final stored = await _userService.getUser(user.uid);
        if (stored != null) {
          existing = stored;
        } else {
          existing = authUser;
          await _userService.createUser(existing);
        }
      } catch (_) {
        existing = authUser;
      }

      await saveUser(existing);
      return existing;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Invalid OTP');
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      User? firebaseUser;

      if (kIsWeb) {
        // On web: use Firebase's signInWithPopup — no separate Google SDK needed
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        final result = await _auth.signInWithPopup(provider);
        firebaseUser = result.user;
      } else {
        // On mobile: use google_sign_in package (v7.x singleton API)
        await _ensureGoogleInitialized();
        final googleUser = await GoogleSignIn.instance.authenticate();
        final idToken = googleUser.authentication.idToken;
        final cred = GoogleAuthProvider.credential(idToken: idToken);
        final result = await _auth.signInWithCredential(cred);
        firebaseUser = result.user;
      }

      if (firebaseUser == null) throw Exception('Google sign-in failed');

      // Build a user from Firebase Auth data — used as fallback if Firestore is unavailable
      final authUser = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email,
        phone: firebaseUser.phoneNumber ?? '',
        role: UserRole.customer,
      );

      UserModel existing;
      try {
        final stored = await _userService.getUser(firebaseUser.uid);
        if (stored != null) {
          existing = stored;
        } else {
          existing = authUser;
          await _userService.createUser(existing);
        }
      } catch (_) {
        // Firestore unavailable (database not created yet, or offline)
        // Use Firebase Auth data directly so login still succeeds
        existing = authUser;
      }

      await saveUser(existing);
      return existing;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        throw Exception('Google Sign-In is not enabled in Firebase Console.');
      }
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        throw Exception('Sign-in was cancelled.');
      }
      throw Exception(e.message ?? 'Google sign-in failed');
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    if (!kIsWeb && _googleInitialized) {
      await GoogleSignIn.instance.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.updateDisplayName(user.name);
    }
    await _userService.updateUser(user);
    await saveUser(user);
    return user;
  }

  UserModel _defaultUser(User user) => UserModel(
        id: user.uid,
        name: user.displayName ?? 'User',
        email: user.email,
        phone: user.phoneNumber ?? '',
        role: UserRole.customer,
      );
}
