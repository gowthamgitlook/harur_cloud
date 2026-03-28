import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
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
    final success = await authProvider.sendOTP(_phoneController.text.trim());

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Navigate to OTP screen
      Navigator.of(context).pushNamed(
        AppRoutes.otpVerification,
        arguments: _phoneController.text.trim(),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Navigate to customer home
      Navigator.of(context).pushReplacementNamed(AppRoutes.customerMain);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSizes.spacingXL),
                // Logo
                Center(
                  child: Container(
                    width: AppSizes.imageLG,
                    height: AppSizes.imageLG,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: AppSizes.iconXXL,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingLG),
                // App Name
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.spacingSM),
                // Tagline
                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.spacingXL),
                // Login Title
                Text(
                  AppStrings.login,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: AppSizes.spacingSM),
                Text(
                  'Enter your phone number to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                SizedBox(height: AppSizes.spacingLG),
                // Phone Input
                CustomTextField(
                  controller: _phoneController,
                  label: AppStrings.phoneNumber,
                  hint: '+91 9876543210',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (!value.startsWith('+91')) {
                      return 'Phone number must start with +91';
                    }
                    if (value.length != 13) {
                      return 'Invalid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.spacingLG),
                // Send OTP Button
                CustomButton(
                  text: 'Send OTP',
                  onPressed: _isLoading ? null : _sendOTP,
                  isLoading: _isLoading,
                ),
                SizedBox(height: AppSizes.spacingLG),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: AppSizes.spacingLG),
                // Google Login
                CustomButton(
                  text: AppStrings.loginWithGoogle,
                  onPressed: _isLoading ? null : _loginWithGoogle,
                  isOutlined: true,
                  icon: Icons.g_mobiledata,
                ),
                SizedBox(height: AppSizes.spacingXL),
                // Info
                Container(
                  padding: EdgeInsets.all(AppSizes.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Accounts:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: AppSizes.spacingSM),
                      _buildTestAccount('Customer', '+919876543210'),
                      _buildTestAccount('Admin', '+919876543211'),
                      _buildTestAccount('Delivery', '+919876543212'),
                      SizedBox(height: AppSizes.spacingSM),
                      Text(
                        'OTP: 123456',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestAccount(String role, String phone) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingXS),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: AppColors.info),
          SizedBox(width: AppSizes.spacingSM),
          Text(
            '$role: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            phone,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.info,
                ),
          ),
        ],
      ),
    );
  }
}
