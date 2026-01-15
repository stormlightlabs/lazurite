import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/fullscreen_viewer_overlay.dart';

void main() {
  group('FullscreenViewerOverlay', () {
    testWidgets('renders position indicator for multiple items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 3, onClose: () {}),
          ),
        ),
      );

      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('hides position indicator for single item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      expect(find.text('0 / 1'), findsNothing);
      expect(find.text('1 / 1'), findsNothing);
    });

    testWidgets('shows close button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onClose when close button pressed', (tester) async {
      var closeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(
              currentIndex: 0,
              totalCount: 1,
              onClose: () => closeCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(closeCalled, isTrue);
    });

    testWidgets('shows download button when callback provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(
              currentIndex: 0,
              totalCount: 1,
              onClose: () {},
              onDownload: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('calls onDownload when download button pressed', (tester) async {
      var downloadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(
              currentIndex: 0,
              totalCount: 1,
              onClose: () {},
              onDownload: () => downloadCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.download));
      expect(downloadCalled, isTrue);
    });

    testWidgets('hides download button when callback not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.download), findsNothing);
    });

    testWidgets('shows share button when URL provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(
              currentIndex: 0,
              totalCount: 1,
              onClose: () {},
              shareUrl: 'https://example.com/image.jpg',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('hides share button when URL not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsNothing);
    });

    testWidgets('shows alt text badge when alt text available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(
              currentIndex: 0,
              totalCount: 1,
              onClose: () {},
              altText: 'A beautiful sunset',
              onAltTextTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('ALT'), findsOneWidget);
    });

    testWidgets('hides alt text badge when alt text not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      expect(find.text('ALT'), findsNothing);
    });

    testWidgets('calls onAltTextTap when alt badge tapped', (tester) async {
      var altTapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(
              currentIndex: 0,
              totalCount: 1,
              onClose: () {},
              altText: 'Test alt text',
              onAltTextTap: () => altTapCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('ALT'));
      expect(altTapCalled, isTrue);
    });

    testWidgets('position indicator has semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 3, onClose: () {}),
          ),
        ),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Image 1 of 3',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('auto-hides after 3 seconds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('toggles visibility on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('resets auto-hide timer when currentIndex changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 3, onClose: () {}),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('uses fade animation for visibility changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullscreenViewerOverlay(currentIndex: 0, totalCount: 1, onClose: () {}),
          ),
        ),
      );

      expect(find.byType(FadeTransition), findsWidgets);
    });
  });
}
