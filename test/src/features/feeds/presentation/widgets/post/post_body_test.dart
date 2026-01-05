import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_body.dart';

void main() {
  group('PostBody', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PostBody(text: 'Hello world')),
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('renders nothing when text is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PostBody(text: '')),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });
  });
}
