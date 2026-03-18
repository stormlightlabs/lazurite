import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/settings/presentation/about_screen.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  Widget buildSubject() => const MaterialApp(home: AboutScreen());

  group('AboutScreen', () {
    testWidgets('renders app bar with About title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('About'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders Lazurite headline', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Lazurite'), findsOneWidget);
    });

    testWidgets('renders Stormlight Labs description', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.textContaining('Stormlight Labs'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders Owais as a tappable link', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Owais'), findsOneWidget);
    });

    testWidgets('renders GitHub and contribution text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.textContaining('GitHub'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders version string', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.textContaining('Lazurite v'), findsOneWidget);
    });

    testWidgets('renders email icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('tapping Owais launches LinkedIn URL', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.text('Owais'));
      await tester.pump();

      expect(fakeUrlLauncher.launchedUrls, contains('https://linkedin.com/in/owais-jamil'));
    });

    testWidgets('tapping email icon launches mailto URL', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.email_outlined));
      await tester.pump();

      expect(fakeUrlLauncher.launchedUrls, contains('mailto:info@stormlightlabs.org'));
    });

    testWidgets('renders three link icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // GitHub SVG, Tangled SVG, email icon — wrapped in _LinkIcon (InkWell)
      expect(find.byType(InkWell), findsNWidgets(3));
    });
  });
}
