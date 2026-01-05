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
  });
}
