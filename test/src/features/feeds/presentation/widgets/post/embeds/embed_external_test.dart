import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/embeds/embed_external.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('EmbedExternal', () {
    testWidgets('renders title and description', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedExternal(
                external: {
                  'uri': 'https://example.com/article',
                  'title': 'Example Article Title',
                  'description': 'This is a description of the article.',
                },
              ),
            ),
          ),
        );
      });

      expect(find.text('Example Article Title'), findsOneWidget);
      expect(find.text('This is a description of the article.'), findsOneWidget);
    });

    testWidgets('extracts and displays domain from URI', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedExternal(
                external: {'uri': 'https://www.example.com/path/to/article', 'title': 'Test'},
              ),
            ),
          ),
        );
      });

      expect(find.text('www.example.com'), findsOneWidget);
    });

    testWidgets('renders thumbnail when provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedExternal(
                external: {
                  'uri': 'https://example.com',
                  'title': 'Test',
                  'thumb': 'https://example.com/thumb.jpg',
                },
              ),
            ),
          ),
        );
      });

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('handles missing optional fields gracefully', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: EmbedExternal(external: {'uri': 'https://example.com'})),
          ),
        );
      });

      expect(find.byType(EmbedExternal), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
    });

    testWidgets('shows link icon', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedExternal(external: {'uri': 'https://example.com', 'title': 'Test'}),
            ),
          ),
        );
      });

      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('is tappable when URI is provided', (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmbedExternal(external: {'uri': 'https://example.com', 'title': 'Test'}),
            ),
          ),
        );
      });

      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}
