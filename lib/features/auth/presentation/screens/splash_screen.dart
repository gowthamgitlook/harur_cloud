import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/enums/user_role.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Check authentication status and navigate
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Use addPostFrameCallback to avoid calling setState during build
    await Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();

      // Wait for animation to complete
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      if (authProvider.isAuthenticated && authProvider.userRole != null) {
        // Navigate based on user role
        _navigateToRoleBasedHome(authProvider.userRole!);
      } else {
        // Navigate to login
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  void _navigateToRoleBasedHome(UserRole role) {
    switch (role) {
      case UserRole.customer:
        Navigator.of(context).pushReplacementNamed(AppRoutes.customerMain);
        break;
      case UserRole.admin:
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminMain);
        break;
      case UserRole.delivery:
        Navigator.of(context).pushReplacementNamed(AppRoutes.deliveryMain);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (placeholder icon for now)
                  Container(
                    width: AppSizes.imageXL,
                    height: AppSizes.imageXL,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryWhite,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: AppSizes.iconXXL,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingLG),
                  // App Name
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.spacingSM),
                  // Tagline
                  Text(
                    AppStrings.appTagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight.withValues(alpha: 0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.spacingXL),
                  // Loading indicator
                  SizedBox(
                    width: AppSizes.loaderSM,
                    height: AppSizes.loaderSM,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textLight,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
