import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';

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

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    // Prepend +91 if not present for the actual service call
    final fullPhoneNumber = '+91${_phoneController.text.trim()}';
    final success = await authProvider.sendOTP(fullPhoneNumber);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: fullPhoneNumber,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _fillTestAccount(String phone) {
    // Remove +91 for the controller
    final displayPhone = phone.replaceFirst('+91', '');
    _phoneController.text = displayPhone;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        showParticles: true,
        colors: [
          GlassTheme.primaryBlue.withValues(alpha: 0.1),
          GlassTheme.secondaryBlue.withValues(alpha: 0.05),
          Colors.white,
        ],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.paddingLG),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: GlassTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: GlassTheme.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 50,
                          color: GlassTheme.primaryBlue,
                        ),
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    SizedBox(height: AppSizes.spacingLG),
                    Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: GlassTheme.primaryBlue,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    SizedBox(height: AppSizes.spacingSM),
                    Text(
                      AppStrings.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GlassTheme.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                    SizedBox(height: AppSizes.spacingXXL),
                    GlassMorphism(
                      padding: EdgeInsets.all(AppSizes.paddingLG),
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login or Signup',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: GlassTheme.primaryBlue,
                                ),
                          ),
                          SizedBox(height: AppSizes.spacingSM),
                          Text(
                            'We will send you an OTP on this mobile number',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: GlassTheme.textSecondary,
                                ),
                          ),
                          SizedBox(height: AppSizes.spacingLG),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: AppStrings.phoneNumber,
                              hintText: '98765 43210',
                              prefixIcon: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                child: const Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: GlassTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (value.length != 10) {
                                return 'Enter 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSizes.spacingLG),
                          GlassButton(
                            text: _isLoading ? 'Sending...' : 'Continue',
                            onPressed: _sendOTP,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppSizes.spacingLG),
                    // Test Accounts Quick Select
                    GlassMorphism(
                      padding: EdgeInsets.all(AppSizes.paddingMD),
                      opacity: 0.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bug_report_outlined, size: 16, color: GlassTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Quick Test Accounts (Click to fill)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: GlassTheme.primaryBlue.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildQuickFill('Customer', '+919876543210'),
                              _buildQuickFill('Admin', '+919876543211'),
                              _buildQuickFill('Delivery', '+919876543212'),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFill(String label, String phone) {
    return InkWell(
      onTap: () => _fillTestAccount(phone),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GlassTheme.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: GlassTheme.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
