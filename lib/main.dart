import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'features/customer/home/data/repositories/menu_repository.dart';
import 'features/customer/home/data/repositories/mock_menu_repository.dart';

/// Harur Cloud Kitchen - Senior Dev Entry Point
/// Implements zoned error handling and resilient service initialization
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('🚀 [SYSTEM] HarurCloud Booting up...');

    // 1. Production-Grade Error Screen
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.primaryRed, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Initialization Error',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please restart the app. If the issue persists, contact support.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 20),
                Text(
                  details.exception.toString(),
                  style: const TextStyle(color: Colors.red, fontSize: 10),
                ),
              ]
            ],
          ),
        ),
      );
    };

    // 2. Resilient Dependency Injection
    IMenuRepository menuRepository;

    if (!AppConfig.useMockServices) {
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        debugPrint('✅ [FIREBASE] Live connection established');
        menuRepository = MockMenuRepository(); // Fallback for now, replace with FirestoreRepository later
      } catch (e) {
        debugPrint('⚠️ [FIREBASE] Initialization failed. Defaulting to Mock Mode. Error: $e');
        menuRepository = MockMenuRepository();
      }
    } else {
      debugPrint('📦 [SYSTEM] Running in isolated MOCK mode');
      menuRepository = MockMenuRepository();
    }

    // 3. System UI Configuration
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // 4. Launch Application
    runApp(HarurCloudKitchenApp(menuRepository: menuRepository));
    
  }, (error, stack) {
    debugPrint('❌ [CRITICAL ERROR] Uncaught: $error');
    debugPrint(stack.toString());
  });
}
