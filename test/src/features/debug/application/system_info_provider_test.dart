import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/debug/application/system_info_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('systemInfoProvider', () {
    testProvider('returns valid SystemInfo with mocked PackageInfo', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Lazurite Test',
        packageName: 'com.example.lazurite',
        version: '1.2.3',
        buildNumber: '456',
        buildSignature: '',
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final systemInfoRaw = container.read(systemInfoProvider.future);
      final systemInfo = await systemInfoRaw;

      expect(systemInfo.appVersion, '1.2.3');
      expect(systemInfo.buildNumber, '456');
      expect(systemInfo.gitVersion, isNull);
      expect(systemInfo.flutterVersion, isNotEmpty);
      expect(systemInfo.platform, isNotEmpty);
    });
  });
}

void testProvider(String description, Future<void> Function() body) {
  test(description, body);
}
