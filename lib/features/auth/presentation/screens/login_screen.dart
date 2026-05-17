import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:harur_cloud_kitchen/core/theme/zomato_theme.dart';
import 'package:harur_cloud_kitchen/core/constants/app_routes.dart';
import 'package:harur_cloud_kitchen/core/constants/app_strings.dart';
import 'package:harur_cloud_kitchen/config/app_config.dart';
import 'package:harur_cloud_kitchen/shared/enums/user_role.dart';
import 'package:harur_cloud_kitchen/features/auth/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = '+91${_phoneController.text.trim()}';

    if (AppConfig.useMockServices) {
      // Mock: auto-verify with hardcoded OTP
      _performLogin(phone);
      return;
    }

    // Production: send OTP then navigate to OTP screen
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.sendOTP(phone);
      if (!mounted) return;
      if (success) {
        Navigator.pushNamed(context, AppRoutes.otpVerification, arguments: phone);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send OTP. Check your number.'),
            backgroundColor: ZomatoTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: ZomatoTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Used only in mock mode for quick role-testing buttons
  Future<void> _performLogin(String phone) async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.sendOTP(phone);
      if (success) {
        final verified = await authProvider.verifyOTP(phone, AppConfig.mockOTP);
        if (!mounted) return;
        if (verified && authProvider.currentUser != null) {
          _navigateToRoleHome(authProvider.currentUser!.role);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: ZomatoTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _navigateToRoleHome(authProvider.userRole ?? UserRole.customer);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Login Failed'), backgroundColor: ZomatoTheme.error),
      );
    }
  }

  void _navigateToRoleHome(UserRole role) {
    switch (role) {
      case UserRole.admin:
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminMain);
        break;
      case UserRole.delivery:
        Navigator.of(context).pushReplacementNamed(AppRoutes.deliveryMain);
        break;
      default:
        Navigator.of(context).pushReplacementNamed(AppRoutes.customerMain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Header
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1000'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.appName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    Text(AppStrings.appTagline, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Log in or sign up', style: ZomatoTheme.headlineLarge.copyWith(fontSize: 20)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Padding(padding: EdgeInsets.all(14), child: Text('+91', style: TextStyle(fontWeight: FontWeight.bold))),
                        hintText: 'Phone Number',
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Phone number is required';
                        if (value.trim().length != 10) return 'Enter a valid 10-digit mobile number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text('Continue'),
                    ),
                    const SizedBox(height: 24),
                    const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR')), Expanded(child: Divider())]),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _handleGoogleSignIn,
                      icon: const Icon(Icons.g_mobiledata, size: 30),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
                    ),
                    
                    // Quick Role Testing — only visible in mock/debug mode
                    if (AppConfig.useMockServices || kDebugMode) ...[
                      const SizedBox(height: 40),
                      Text('Quick Role Testing (Auto-Login)', style: ZomatoTheme.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRoleButton('Customer', Icons.person, '+919876543210'),
                          _buildRoleButton('Admin', Icons.admin_panel_settings, '+919876543211'),
                          _buildRoleButton('Delivery', Icons.delivery_dining, '+919876543212'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String label, IconData icon, String phone) {
    return InkWell(
      onTap: () => _performLogin(phone),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: ZomatoTheme.background, shape: BoxShape.circle, border: Border.all(color: ZomatoTheme.border)),
            child: Icon(icon, color: ZomatoTheme.primaryRed),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
