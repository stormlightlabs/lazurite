import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/inline_composer_launcher.dart';

void main() {
  group('InlineComposerLauncher', () {
    testWidgets('renders avatar and placeholder text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InlineComposerLauncher(avatarUrl: 'avatar.jpg')),
        ),
      );

      expect(find.text("What's up?"), findsOneWidget);
    });

    testWidgets('triggers onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineComposerLauncher(avatarUrl: 'avatar.jpg', onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(InlineComposerLauncher));
      expect(tapped, isTrue);
    });
  });
}
