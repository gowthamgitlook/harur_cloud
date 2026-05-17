import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/zomato_theme.dart';
import '../../../../shared/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/services/permission_service.dart';

class SplashScreenGlass extends StatefulWidget {
  const SplashScreenGlass({super.key});

  @override
  State<SplashScreenGlass> createState() => _SplashScreenGlassState();
}

class _SplashScreenGlassState extends State<SplashScreenGlass> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await PermissionService.requestInitialPermissions();
    if (!mounted) return;

    // Capture provider before any async gap to satisfy use_build_context_synchronously
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    if (authProvider.isAuthenticated && authProvider.userRole != null) {
      _navigateToRoleBasedHome(authProvider.userRole!);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _navigateToRoleBasedHome(UserRole role) {
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
      backgroundColor: ZomatoTheme.primaryRed,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 60,
                color: ZomatoTheme.primaryRed,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).then().shimmer(duration: 1200.ms),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
