import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'features/customer/home/data/repositories/menu_repository.dart';
import 'features/customer/home/data/repositories/mock_menu_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
