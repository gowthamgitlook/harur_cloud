import 'package:flutter_test/flutter_test.dart';
import 'package:harur_cloud_kitchen/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('production mode is active', () {
      expect(AppConfig.useMockServices, isFalse);
    });

    test('app version is set', () {
      expect(AppConfig.appVersion.isNotEmpty, isTrue);
    });

    test('build number is positive', () {
      expect(AppConfig.buildNumber, greaterThan(0));
    });
  });
}
