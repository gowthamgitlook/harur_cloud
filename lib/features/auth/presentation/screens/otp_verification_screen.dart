import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/widgets/custom_button.dart';
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
          backgroundColor: AppColors.error,
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
      // Navigate based on user role
      _navigateToRoleBasedHome(authProvider.userRole!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Invalid OTP'),
          backgroundColor: AppColors.error,
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
        backgroundColor: AppColors.success,
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
      appBar: AppBar(
        title: const Text(AppStrings.verifyOTP),
      ),
      body: SafeArea(
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
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.message,
                    size: AppSizes.iconXXL,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.spacingLG),
              // Title
              Text(
                AppStrings.enterOTP,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spacingSM),
              // Description
              Text(
                'We sent a code to',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spacingXS),
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spacingXL),
              // OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor: AppColors.surfaceLight,
                  inactiveFillColor: AppColors.surfaceLight,
                  selectedFillColor: AppColors.surfaceLight,
                  activeColor: AppColors.primaryRed,
                  inactiveColor: AppColors.divider,
                  selectedColor: AppColors.primaryRed,
                ),
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
                        color: AppColors.textSecondary,
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
                  ),
                ),
              ),
              SizedBox(height: AppSizes.spacingLG),
              // Verify Button
              CustomButton(
                text: AppStrings.verifyOTP,
                onPressed: _isLoading ? null : _verifyOTP,
                isLoading: _isLoading,
              ),
              SizedBox(height: AppSizes.spacingLG),
              // Hint
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: AppSizes.iconSM,
                    ),
                    SizedBox(width: AppSizes.spacingSM),
                    Expanded(
                      child: Text(
                        'For testing, use OTP: 123456',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
