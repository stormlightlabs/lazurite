import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/application/autocomplete_provider.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/autocomplete_overlay.dart';
import 'package:lazurite/src/features/search/domain/search_actor.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('AutocompleteOverlay', () {
    testWidgets('does not show when visible is false', (tester) async {
      await tester.pumpApp(
        AutocompleteOverlay(visible: false, text: '@test', onSuggestionSelected: (_) {}),
      );

      expect(find.byType(AutocompleteOverlay), findsOneWidget);
      expect(find.byType(AutocompleteSuggestionTile), findsNothing);
    });
  });

  group('AutocompleteSuggestionTile', () {
    testWidgets('displays mention with avatar and details', (tester) async {
      final suggestion = AutocompleteSuggestion.mention(
        const SearchActorItem(
          did: 'did:plc:test',
          handle: 'test.bsky.social',
          displayName: 'Test User',
          avatar: 'https://example.com/avatar.jpg',
        ),
      );

      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteSuggestionTile(suggestion: suggestion, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('@test.bsky.social'), findsOneWidget);
    });

    testWidgets('displays hashtag with icon', (tester) async {
      final suggestion = AutocompleteSuggestion.hashtag('flutter');

      await tester.pumpApp(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteSuggestionTile(suggestion: suggestion, onTap: () {}),
          ),
        ),
      );

      expect(find.text('#flutter'), findsOneWidget);
      expect(find.byIcon(Icons.tag), findsOneWidget);
    });
  });
}
