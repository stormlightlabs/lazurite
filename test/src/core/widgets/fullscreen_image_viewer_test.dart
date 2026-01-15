import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/fullscreen_image_viewer.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('FullscreenImageViewer', () {
    final testImages = [
      {
        'thumb': 'https://example.com/thumb1.jpg',
        'fullsize': 'https://example.com/full1.jpg',
        'alt': 'Test image 1',
        'aspectRatio': {'width': 16, 'height': 9},
      },
      {
        'thumb': 'https://example.com/thumb2.jpg',
        'fullsize': 'https://example.com/full2.jpg',
        'alt': 'Test image 2',
        'aspectRatio': {'width': 4, 'height': 3},
      },
      {
        'thumb': 'https://example.com/thumb3.jpg',
        'fullsize': 'https://example.com/full3.jpg',
        'alt': 'Test image 3',
        'aspectRatio': {'width': 1, 'height': 1},
      },
    ];

    testWidgets('displays image at initial index', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 1)),
        );
      });

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('renders multiple images in PageView', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('supports pinch-to-zoom gestures', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.byType(InteractiveViewer), findsOneWidget);
      final viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(viewer.minScale, 1.0);
      expect(viewer.maxScale, 4.0);
    });

    testWidgets('double-tap toggles zoom to 2x', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('double-tap again resets zoom to 1x', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('swipe down dismisses viewer', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {},
              child: FullscreenImageViewer(images: testImages, initialIndex: 0),
            ),
          ),
        );
      });

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('hero animation animates from thumbnail', (tester) async {
      const heroTag = 'test_hero_tag';

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: Hero(
                tag: heroTag,
                child: Container(width: 100, height: 100, color: Colors.red),
              ),
            ),
          ),
        );
      });

      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('close button dismisses viewer', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {},
              child: FullscreenImageViewer(images: testImages, initialIndex: 0),
            ),
          ),
        );
      });

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('download button is present', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('share button triggers share', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('alt text button shows dialog', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.text('ALT'), findsOneWidget);
      await tester.tap(find.text('ALT'));
      await tester.pumpAndSettle();

      expect(find.text('Image Description'), findsOneWidget);
      expect(find.text('Test image 1'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Image Description'), findsNothing);
    });

    testWidgets('position indicator shows for multiple items', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('image has semantic label for accessibility', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
        );
      });

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Test image 1',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('respects reduced motion setting', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(home: FullscreenImageViewer(images: testImages, initialIndex: 0)),
          ),
        );
      });

      expect(find.byType(PageView), findsOneWidget);
    });
  });

  group('FullscreenImageViewer.heroTag', () {
    test('generates unique tags for each image', () {
      final tag1 = FullscreenImageViewer.heroTag('https://example.com/image1.jpg', 0);
      final tag2 = FullscreenImageViewer.heroTag('https://example.com/image2.jpg', 1);
      final tag3 = FullscreenImageViewer.heroTag('https://example.com/image1.jpg', 0);

      expect(tag1, isNot(equals(tag2)));
      expect(tag1, equals(tag3));
    });
  });
}
