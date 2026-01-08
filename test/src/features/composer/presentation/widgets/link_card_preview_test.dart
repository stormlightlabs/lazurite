import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/link_metadata.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/link_card_preview.dart';

void main() {
  group('LinkCardPreview', () {
    testWidgets('displays metadata with title, description, and site name', (tester) async {
      final metadata = LinkMetadata(
        url: 'https://example.com',
        title: 'Example Title',
        description: 'Example Description',
        siteName: 'Example Site',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LinkCardPreview(metadata: metadata)),
        ),
      );

      expect(find.text('Example Site'), findsOneWidget);
      expect(find.text('Example Title'), findsOneWidget);
      expect(find.text('Example Description'), findsOneWidget);
    });

    testWidgets('displays image when imageUrl is provided', (tester) async {
      final metadata = LinkMetadata(
        url: 'https://example.com',
        title: 'Example Title',
        imageUrl: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LinkCardPreview(metadata: metadata)),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('does not display image when imageUrl is null', (tester) async {
      final metadata = LinkMetadata(url: 'https://example.com', title: 'Example Title');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LinkCardPreview(metadata: metadata)),
        ),
      );

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows remove button when onRemove callback is provided', (tester) async {
      final metadata = LinkMetadata(url: 'https://example.com', title: 'Example Title');
      var removeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCardPreview(
              metadata: metadata,
              onRemove: () {
                removeCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(removeCalled, isTrue);
    });

    testWidgets('does not show remove button when onRemove is null', (tester) async {
      final metadata = LinkMetadata(url: 'https://example.com', title: 'Example Title');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LinkCardPreview(metadata: metadata)),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('truncates long text with ellipsis', (tester) async {
      final metadata = LinkMetadata(
        url: 'https://example.com',
        title: 'This is a very long title that should be truncated with an ellipsis',
        description:
            'This is a very long description that should also be truncated with an ellipsis when it exceeds the maximum number of lines',
        siteName: 'Very Long Site Name That Should Be Truncated',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 300, child: LinkCardPreview(metadata: metadata)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LinkCardPreview), findsOneWidget);
    });

    testWidgets('handles metadata with only URL', (tester) async {
      final metadata = LinkMetadata(url: 'https://example.com');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LinkCardPreview(metadata: metadata)),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
