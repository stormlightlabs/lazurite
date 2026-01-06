import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_images.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const MaterialApp());
  });

  group('EmbedImages', () {
    testWidgets('renders single image', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {'thumb': 'https://example.com/1.jpg', 'fullsize': 'https://example.com/1.jpg'},
                ],
              ),
            ),
          ),
        );
      });

      expect(find.byType(AspectRatio), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('renders two images', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {'thumb': '1.jpg'},
                  {'thumb': '2.jpg'},
                ],
              ),
            ),
          ),
        );
      });
      expect(find.byIcon(Icons.download), findsNWidgets(2));
    });

    testWidgets('renders download button', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {'thumb': '1.jpg'},
                ],
              ),
            ),
          ),
        );
      });
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('shows ALT badge when alt text is provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {
                    'thumb': 'https://example.com/1.jpg',
                    'alt': 'A beautiful sunset over the ocean',
                  },
                ],
              ),
            ),
          ),
        );
      });

      expect(find.text('ALT'), findsOneWidget);
    });

    testWidgets('hides ALT badge when alt text is empty', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {'thumb': 'https://example.com/1.jpg', 'alt': ''},
                ],
              ),
            ),
          ),
        );
      });

      expect(find.text('ALT'), findsNothing);
    });

    testWidgets('hides ALT badge when alt text is null', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {'thumb': 'https://example.com/1.jpg'},
                ],
              ),
            ),
          ),
        );
      });

      expect(find.text('ALT'), findsNothing);
    });

    testWidgets('tap on ALT badge shows dialog with alt text', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {
                    'thumb': 'https://example.com/1.jpg',
                    'alt': 'A beautiful sunset over the ocean',
                  },
                ],
              ),
            ),
          ),
        );
      });

      await tester.tap(find.text('ALT'));
      await tester.pumpAndSettle();

      expect(find.text('Image Description'), findsOneWidget);
      expect(find.text('A beautiful sunset over the ocean'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Image Description'), findsNothing);
    });

    testWidgets('image has semantic label for accessibility', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {'thumb': 'https://example.com/1.jpg', 'alt': 'A beautiful sunset'},
                ],
              ),
            ),
          ),
        );
      });

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'A beautiful sunset',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('uses dynamic aspect ratio when provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {
                    'thumb': 'https://example.com/1.jpg',
                    'aspectRatio': {'width': 4, 'height': 3},
                  },
                ],
              ),
            ),
          ),
        );
      });

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, closeTo(4 / 3, 0.01));
    });

    testWidgets('defaults to 16:9 when aspect ratio is missing', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedImages(
                images: [
                  {'thumb': 'https://example.com/1.jpg'},
                ],
              ),
            ),
          ),
        );
      });

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, closeTo(16 / 9, 0.01));
    });
  });
}
