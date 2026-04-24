import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/settings/presentation/privacy_policy_screen.dart';
import 'package:lazurite/features/settings/presentation/terms_of_service_screen.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> canLaunch(String url) async => true;
}

void main() {
  late _FakeUrlLauncher fakeUrlLauncher;

  setUp(() {
    fakeUrlLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
  });

  group('PrivacyPolicyScreen', () {
    testWidgets('renders title and core sections', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
      await tester.pump();

      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.text('What the app stores on your device'), findsOneWidget);
      expect(find.text('How your data is used'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Contact'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('contact links launch expected URLs', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Stormlight Labs'), 300);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stormlight Labs'));
      await tester.pump();
      await tester.tap(find.text('info@stormlightlabs.org'));
      await tester.pump();

      expect(fakeUrlLauncher.launchedUrls, contains('https://stormlightlabs.org'));
      expect(fakeUrlLauncher.launchedUrls, contains('mailto:info@stormlightlabs.org'));
    });
  });

  group('TermsOfServiceScreen', () {
    testWidgets('renders title and core sections', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TermsOfServiceScreen()));
      await tester.pump();

      expect(find.text('Terms of Service'), findsWidgets);
      expect(find.text('What Lazurite is'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Acceptable use'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Acceptable use'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Contact'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('contact links launch expected URLs', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TermsOfServiceScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Stormlight Labs'), 300);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stormlight Labs'));
      await tester.pump();
      await tester.tap(find.text('info@stormlightlabs.org'));
      await tester.pump();

      expect(fakeUrlLauncher.launchedUrls, contains('https://stormlightlabs.org'));
      expect(fakeUrlLauncher.launchedUrls, contains('mailto:info@stormlightlabs.org'));
    });
  });
}
