import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../config/app_config.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _secondsRemaining = 120; // 2 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 6-digit OTP'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOTP(
      widget.phoneNumber,
      _otpController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Navigate based on user role
      _navigateToRoleBasedHome(authProvider.userRole!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Invalid OTP'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _otpController.clear();
    }
  }

  void _navigateToRoleBasedHome(UserRole role) {
    switch (role) {
      case UserRole.customer:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.customerMain,
          (route) => false,
        );
        break;
      case UserRole.admin:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.adminMain,
          (route) => false,
        );
        break;
      case UserRole.delivery:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.deliveryMain,
          (route) => false,
        );
        break;
      case UserRole.restaurantOwner:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.adminMain, // Default to admin main for now
          (route) => false,
        );
        break;
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _secondsRemaining = 120;
      _otpController.clear();
    });

    _timer?.cancel();
    _startTimer();

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOTP(widget.phoneNumber);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _timerText {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(AppStrings.verifyOTP, style: TextStyle(color: GlassTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: GlassTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBackground(
        showParticles: true,
        colors: [
          GlassTheme.primaryBlue.withValues(alpha: 0.1),
          GlassTheme.secondaryBlue.withValues(alpha: 0.05),
          Colors.white,
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSizes.spacingXL),
                // Icon
                Center(
                  child: Container(
                    width: AppSizes.imageLG,
                    height: AppSizes.imageLG,
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
                      Icons.mark_email_read_outlined,
                      size: AppSizes.iconXXL,
                      color: GlassTheme.primaryBlue,
                    ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                SizedBox(height: AppSizes.spacingLG),
                // Title
                Text(
                  AppStrings.enterOTP,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GlassTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                SizedBox(height: AppSizes.spacingSM),
                // Description
                Text(
                  'We sent a code to',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GlassTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                SizedBox(height: AppSizes.spacingXS),
                Text(
                  widget.phoneNumber,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GlassTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),
                SizedBox(height: AppSizes.spacingXL),
                
                GlassMorphism(
                  padding: EdgeInsets.all(AppSizes.paddingLG),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // OTP Input
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.scale,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white.withValues(alpha: 0.2),
                          inactiveFillColor: Colors.white.withValues(alpha: 0.1),
                          selectedFillColor: Colors.white.withValues(alpha: 0.3),
                          activeColor: GlassTheme.primaryBlue,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                          selectedColor: GlassTheme.primaryBlue,
                        ),
                        cursorColor: GlassTheme.primaryBlue,
                        enableActiveFill: true,
                        onCompleted: (value) => _verifyOTP(),
                        onChanged: (value) {},
                      ),
                      SizedBox(height: AppSizes.spacingLG),
                      // Timer
                      if (_secondsRemaining > 0)
                        Text(
                          'Code expires in $_timerText',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: GlassTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: AppSizes.spacingMD),
                      // Resend OTP
                      Center(
                        child: TextButton(
                          onPressed: _secondsRemaining == 0 ? _resendOTP : null,
                          child: Text(
                            _secondsRemaining == 0
                                ? AppStrings.resendOTP
                                : 'Resend OTP in $_timerText',
                            style: TextStyle(
                              color: _secondsRemaining == 0 
                                ? GlassTheme.primaryBlue 
                                : GlassTheme.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingLG),
                      // Verify Button
                      GlassButton(
                        text: AppStrings.verifyOTP,
                        onPressed: _isLoading ? () {} : _verifyOTP,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                
                if (AppConfig.useMockServices || kDebugMode) ...[
                  SizedBox(height: AppSizes.spacingLG),
                  GlassMorphism(
                    padding: EdgeInsets.all(AppSizes.paddingMD),
                    opacity: 0.1,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: GlassTheme.primaryBlue,
                          size: AppSizes.iconSM,
                        ),
                        SizedBox(width: AppSizes.spacingSM),
                        Expanded(
                          child: Text(
                            'Testing mode — use OTP: ${AppConfig.mockOTP}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: GlassTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
