import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';

class SplashScreenGlass extends StatefulWidget {
  const SplashScreenGlass({super.key});

  @override
  State<SplashScreenGlass> createState() => _SplashScreenGlassState();
}

class _SplashScreenGlassState extends State<SplashScreenGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _controller.forward();

    // Check authentication and navigate
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 3000));

      if (!mounted) return;

      if (authProvider.isAuthenticated && authProvider.userRole != null) {
        _navigateToRoleBasedHome(authProvider.userRole!);
      } else {
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
      default:
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
      body: AnimatedBackground(
        colors: const [
          Color(0xFF0066FF),
          Color(0xFF00D4FF),
          Color(0xFF7B2CBF),
        ],
        showParticles: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glass Logo Container
              GlassMorphism(
                blur: 20,
                opacity: 0.3,
                borderRadius: BorderRadius.circular(40),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Logo Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: GlassTheme.buttonGradient,
                        boxShadow: [
                          BoxShadow(
                            color: GlassTheme.primaryBlue.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: Colors.white,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          duration: 2000.ms,
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          duration: 2000.ms,
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(0.8, 0.8),
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 30),

                    // App Name
                    Text(
                      AppStrings.appName,
                      style: GlassTheme.displayLarge,
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 400.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 800.ms,
                          delay: 400.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 16),

                    // Tagline with shimmer effect
                    Text(
                      AppStrings.appTagline,
                      style: GlassTheme.bodyLarge.copyWith(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 800.ms)
                        .shimmer(
                          duration: 2000.ms,
                          delay: 1200.ms,
                          color: Colors.white70,
                        ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 60),

              // Loading Indicator with glass effect
              GlassMorphism(
                blur: 15,
                opacity: 0.2,
                borderRadius: BorderRadius.circular(50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth: 3,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 1000.ms),
                    const SizedBox(width: 16),
                    Text(
                      'Loading...',
                      style: GlassTheme.bodyLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 800.ms)
                        .then()
                        .fadeOut(duration: 800.ms),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 1400.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    delay: 1400.ms,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
