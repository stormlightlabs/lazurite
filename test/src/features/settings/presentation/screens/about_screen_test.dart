import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/presentation/screens/about_screen.dart';

void main() {
  Widget buildTestWidget() {
    return const MaterialApp(home: AboutScreen());
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

    testWidgets('shows snackbar when version is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('1.0.0 (Build 1)'));
      await tester.pumpAndSettle();

      expect(find.text('Version copied to clipboard'), findsOneWidget);
    });

    testWidgets('displays links section with all links', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('LINKS'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('GitHub Repository'), findsOneWidget);
      expect(find.text('Tangled Project'), findsOneWidget);
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
      expect(find.text('© 2026 Stormlight Labs'), findsOneWidget);
    });
  });
}
