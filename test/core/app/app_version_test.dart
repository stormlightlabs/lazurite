import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/app/app_version.dart';

import '../../helpers/fixtures/package_info.dart';

void main() {
  group('AppVersion', () {
    test('shows current prerelease label for platform-safe numeric versions', () {
      final label = AppVersion.displayLabelFor(testPackageInfo());

      expect(label, equals('Lazurite v1.0.0 alpha 6'));
    });

    test('uses app name from package metadata', () {
      final label = AppVersion.displayLabelFor(
        testPackageInfo(appName: 'Lazurite Nightly', packageName: 'org.stormlightlabs.lazurite.nightly'),
      );

      expect(label, equals('Lazurite Nightly v1.0.0 alpha 6'));
    });

    test('falls back to Lazurite when package app name is empty', () {
      final label = AppVersion.displayLabelFor(testPackageInfo(appName: ' '));

      expect(label, equals('Lazurite v1.0.0 alpha 6'));
    });

    test('shows prerelease channel and build number together', () {
      final label = AppVersion.displayLabelFor(testPackageInfo(version: '1.0.0-alpha.6'));

      expect(label, equals('Lazurite v1.0.0 alpha 6'));
    });

    test('uses build number as prerelease number when version has only the channel', () {
      final label = AppVersion.displayLabelFor(testPackageInfo(version: '1.0.0-alpha'));

      expect(label, equals('Lazurite v1.0.0 alpha 6'));
    });

    test('shows native build separately when prerelease number differs', () {
      final label = AppVersion.displayLabelFor(testPackageInfo(version: '1.0.0-alpha.6', buildNumber: '42'));

      expect(label, equals('Lazurite v1.0.0 alpha 6 (build 42)'));
    });

    test('shows build number for stable versions', () {
      final label = AppVersion.displayLabelFor(testPackageInfo(buildNumber: '42'), prereleaseLabel: null);

      expect(label, equals('Lazurite v1.0.0 (build 42)'));
    });

    test('omits duplicate iOS build number fallback', () {
      final label = AppVersion.displayLabelFor(testPackageInfo(buildNumber: '1.0.0'), prereleaseLabel: null);

      expect(label, equals('Lazurite v1.0.0'));
    });
  });
}
