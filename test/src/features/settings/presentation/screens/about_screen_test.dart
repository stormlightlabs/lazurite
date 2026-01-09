import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/debug/application/debug_overlay_controller.dart';
import 'package:lazurite/src/features/debug/application/system_info_provider.dart';
import 'package:lazurite/src/features/settings/presentation/screens/about_screen.dart';

void main() {
  Widget buildTestWidget({SystemInfo? systemInfo}) {
    final info =
        systemInfo ??
        const SystemInfo(
          flutterVersion: '3.0.0',
          buildMode: 'Debug',
          platform: 'TestOS',
          osVersion: '1.0',
          screenSize: Size.zero,
          pixelRatio: 1.0,
          safeAreaInsets: EdgeInsets.zero,
          appVersion: '1.0.0',
          buildNumber: '1',
          gitVersion: null,
        );

    return ProviderScope(
      overrides: [systemInfoProvider.overrideWith((ref) => Future.value(info))],
      child: const MaterialApp(home: AboutScreen()),
    );
  }

  group('AboutScreen', () {
    testWidgets('renders header with app name and version', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Lazurite'), findsOneWidget);
      expect(find.text('1.0.0 (Build 1)'), findsOneWidget);
      expect(find.text('Tap version to copy'), findsOneWidget);
    });

    testWidgets('renders git version if available', (tester) async {
      const info = SystemInfo(
        flutterVersion: '3.0.0',
        buildMode: 'Debug',
        platform: 'TestOS',
        osVersion: '1.0',
        screenSize: Size.zero,
        pixelRatio: 1.0,
        safeAreaInsets: EdgeInsets.zero,
        appVersion: '1.0.0',
        buildNumber: '1',
        gitVersion: 'v1.0.0-g123456',
      );

      await tester.pumpWidget(buildTestWidget(systemInfo: info));
      await tester.pumpAndSettle();

      expect(find.text('1.0.0 (Build 1)\nv1.0.0-g123456'), findsOneWidget);
    });

    testWidgets('shows snackbar when version is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('1.0.0 (Build 1)'));
      await tester.pumpAndSettle();

      expect(find.text('Version copied to clipboard'), findsOneWidget);
    });

    testWidgets('displays links section with all links', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('LINKS'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('GitHub Repo'), findsOneWidget);
      expect(find.text('Tangled Repo'), findsOneWidget);
      expect(find.text('Report Issues'), findsOneWidget);
    });

    testWidgets('displays credits section with attributions', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('CREDITS'), findsOneWidget);
      expect(find.text('Powered by Bluesky'), findsOneWidget);
      expect(find.text('AT Protocol social network'), findsOneWidget);
      expect(find.text('Built with Flutter'), findsOneWidget);
      expect(find.text('Cross-platform UI framework'), findsOneWidget);
      expect(find.text('Typography inspiration'), findsOneWidget);
      expect(find.text('Anisota by Dame.is (@dame.is)'), findsOneWidget);
      expect(find.text('Community reference'), findsOneWidget);
      expect(find.text('Witchsky by jollywhoppers.com'), findsOneWidget);
    });

    testWidgets('displays legal section with stubs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('LEGAL'), findsOneWidget);
      expect(find.text('Open Source Licenses'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('displays footer with copyright', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('© 2026 Stormlight Labs'), findsOneWidget);
      expect(find.text('Material You Bluesky Client'), findsOneWidget);
    });

    testWidgets('shows coming soon for legal items when tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Source Licenses'));
      await tester.pumpAndSettle();

      expect(find.text('Open Source Licenses - Coming soon'), findsOneWidget);
    });

    testWidgets('legal tiles have chevron icons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final licenseTile = find.ancestor(
        of: find.text('Open Source Licenses'),
        matching: find.byType(ListTile),
      );
      expect(licenseTile, findsOneWidget);

      final tile = tester.widget<ListTile>(licenseTile);
      expect(tile.trailing, isA<Icon>());
      final icon = tile.trailing! as Icon;
      expect(icon.icon, Icons.chevron_right);
    });

    testWidgets('link tiles have external link icons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final websiteTile = find.ancestor(of: find.text('Website'), matching: find.byType(ListTile));
      expect(websiteTile, findsOneWidget);

      final tile = tester.widget<ListTile>(websiteTile);
      expect(tile.trailing, isA<Icon>());
      final icon = tile.trailing! as Icon;
      expect(icon.icon, Icons.open_in_new);
    });

    testWidgets('all sections are rendered in correct order', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      expect(find.text('Lazurite'), findsOneWidget);
      expect(find.text('LINKS'), findsOneWidget);

      await tester.drag(listView, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('CREDITS'), findsOneWidget);

      await tester.drag(listView, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('LEGAL'), findsOneWidget);

      await tester.drag(listView, const Offset(0, -300));
      await tester.pumpAndSettle();
    });

    testWidgets('triple tap on logo toggles debug overlay', (tester) async {
      final mockController = MockDebugOverlayController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [debugOverlayControllerProvider.overrideWith(() => mockController)],
          child: const MaterialApp(home: AboutScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find logo. It's the first SvgPicture in the list (Header).
      final logoFinder = find.byType(SvgPicture).first;

      await tester.tap(logoFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(logoFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(logoFinder);
      await tester.pump();

      // Verify toggle was called (mock controller manually tracks calls or we check state change if implementation updates state)
      expect(mockController.toggleCalled, isTrue);
    });
  });
}

class MockDebugOverlayController extends DebugOverlayController {
  bool toggleCalled = false;

  @override
  DebugOverlayState build() => const DebugOverlayState();

  @override
  void toggle() {
    toggleCalled = true;
    state = state.copyWith(isVisible: !state.isVisible);
  }

  // Stubs for other members to satisfy interface if needed, or stick to what's used.
  @override
  void show() {}
  @override
  void hide() {}
  @override
  void setTab(int index) {}
}
