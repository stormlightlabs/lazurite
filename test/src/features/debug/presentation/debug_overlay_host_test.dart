import 'package:flutter/gestures.dart';
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
      testWidgets('2-finger long-press shows overlay', (tester) async {
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

        expect(find.text('Debug Overlay'), findsNothing);

        // Simulate 2-finger press
        final gesture1 = await tester.createGesture(kind: PointerDeviceKind.touch, pointer: 1);
        final gesture2 = await tester.createGesture(kind: PointerDeviceKind.touch, pointer: 2);

        await gesture1.down(const Offset(100, 100));
        await gesture2.down(const Offset(200, 200));
        await tester.pump();

        // Hold for required duration (2 seconds)
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Debug Overlay'), findsOneWidget);

        await gesture1.up();
        await gesture2.up();

        container.dispose();
      });

      testWidgets('1-finger long-press does NOT show overlay', (tester) async {
        final container = ProviderContainer();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              builder: (context, child) =>
                  DebugOverlayHost(child: child ?? const SizedBox.shrink()),
              home: const Scaffold(body: Center(child: Text('Content'))),
            ),
          ),
        );

        final gesture = await tester.createGesture(kind: PointerDeviceKind.touch);
        await gesture.down(const Offset(100, 100));
        await tester.pump(const Duration(seconds: 3));

        expect(find.text('Debug Overlay'), findsNothing);
        await gesture.up();
        container.dispose();
      });

      testWidgets('3-finger press does NOT show overlay', (tester) async {
        final container = ProviderContainer();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              builder: (context, child) =>
                  DebugOverlayHost(child: child ?? const SizedBox.shrink()),
              home: const Scaffold(body: Center(child: Text('Content'))),
            ),
          ),
        );

        final gesture1 = await tester.createGesture(kind: PointerDeviceKind.touch, pointer: 1);
        final gesture2 = await tester.createGesture(kind: PointerDeviceKind.touch, pointer: 2);
        final gesture3 = await tester.createGesture(kind: PointerDeviceKind.touch, pointer: 3);

        await gesture1.down(const Offset(100, 100));
        await gesture2.down(const Offset(110, 100));
        await gesture3.down(const Offset(120, 100));
        await tester.pump(const Duration(seconds: 3));

        expect(find.text('Debug Overlay'), findsNothing);

        await gesture1.up();
        await gesture2.up();
        await gesture3.up();
        container.dispose();
      });
    });
  });
}
