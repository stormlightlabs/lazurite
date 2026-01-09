import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/debug/application/debug_overlay_controller.dart';
import 'package:lazurite/src/features/debug/presentation/debug_overlay_host.dart';

void main() {
  group('DebugOverlayHost', () {
    group('in debug mode (kDebugMode)', () {
      testWidgets('overlay is hidden by default', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              builder: (context, child) =>
                  DebugOverlayHost(child: child ?? const SizedBox.shrink()),
              home: const Scaffold(body: Center(child: Text('Content'))),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Content'), findsOneWidget);
        expect(find.text('Debug Overlay'), findsNothing);
      });

      testWidgets('overlay can be shown via controller', (tester) async {
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              builder: (context, child) => DebugOverlayHost(
                drawerBuilder: (_) =>
                    const SizedBox(width: 320, height: 600, child: Text('Debug Overlay')),
                child: child ?? const SizedBox.shrink(),
              ),
              home: const Scaffold(body: Center(child: Text('Content'))),
            ),
          ),
        );
        await tester.pump();

        container.read(debugOverlayControllerProvider.notifier).show();
        await tester.pump();

        expect(find.text('Debug Overlay'), findsOneWidget);

        container.dispose();
      });

      testWidgets('tap outside dismisses overlay', (tester) async {
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              builder: (context, child) => DebugOverlayHost(
                drawerBuilder: (_) =>
                    const SizedBox(width: 320, height: 600, child: Text('Debug Overlay')),
                child: child ?? const SizedBox.shrink(),
              ),
              home: const Scaffold(body: Center(child: Text('Content'))),
            ),
          ),
        );
        await tester.pump();

        container.read(debugOverlayControllerProvider.notifier).show();
        await tester.pump();

        expect(find.text('Debug Overlay'), findsOneWidget);

        await tester.tapAt(const Offset(100, 300));
        await tester.pump();

        expect(find.text('Debug Overlay'), findsNothing);

        container.dispose();
      });

      testWidgets('hide() via controller dismisses overlay', (tester) async {
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              builder: (context, child) => DebugOverlayHost(
                drawerBuilder: (_) =>
                    const SizedBox(width: 320, height: 600, child: Text('Debug Overlay')),
                child: child ?? const SizedBox.shrink(),
              ),
              home: const Scaffold(body: Center(child: Text('Content'))),
            ),
          ),
        );
        await tester.pump();

        container.read(debugOverlayControllerProvider.notifier).show();
        await tester.pump();
        expect(find.text('Debug Overlay'), findsOneWidget);

        container.read(debugOverlayControllerProvider.notifier).hide();
        await tester.pump();
        expect(find.text('Debug Overlay'), findsNothing);

        container.dispose();
      });
    });
  });
}
