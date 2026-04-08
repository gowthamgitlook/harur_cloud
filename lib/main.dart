import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'core/constants/app_colors.dart';
import 'features/customer/home/data/repositories/menu_repository.dart';
import 'features/customer/home/data/repositories/mock_menu_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Senior Approach: Global Error Handling for Production/Staging
  // This prevents the "Red Screen" on real devices
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primaryRed, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  };

  // 1. Dependency Injection Setup
  IMenuRepository menuRepository;

  // 2. Resilient Firebase Initialization
  if (!AppConfig.useMockServices) {
    try {
      await Firebase.initializeApp();
      // menuRepository = FirestoreMenuRepository(); // Implement when ready
      menuRepository = MockMenuRepository(); // Fallback for now
    } catch (e) {
      debugPrint('FIREBASE FAILED: Falling back to Mock Mode. Error: $e');
      menuRepository = MockMenuRepository();
    }
  } else {
    menuRepository = MockMenuRepository();
  }

  // 3. System Configuration
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Start App with Injected dependencies
  runApp(HarurCloudKitchenApp(menuRepository: menuRepository));
}
