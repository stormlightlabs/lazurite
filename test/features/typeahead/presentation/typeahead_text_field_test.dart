import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:lazurite/features/typeahead/presentation/typeahead_text_field.dart';

void main() {
  group('TypeaheadTextField', () {
    testWidgets('overlay appears after typing and renders results', (tester) async {
      final controller = TextEditingController();
      final repository = _FakeTypeaheadRepository(
        searchHandler: ({required String query, int limit = 10}) async {
          expect(query, 'alice');
          expect(limit, 8);
          return const [TypeaheadResult(did: 'did:plc:alice', handle: 'alice.bsky.social', displayName: 'Alice')];
        },
      );

      await tester.pumpWidget(_buildSubject(controller: controller, repository: repository, onSelected: (_) {}));

      await tester.enterText(find.byType(TextFormField), 'alice');
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('@alice.bsky.social'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('tap result calls onSelected and dismisses overlay', (tester) async {
      final controller = TextEditingController();
      TypeaheadResult? selected;

      final repository = _FakeTypeaheadRepository(
        searchHandler: ({required String query, int limit = 10}) async {
          return const [TypeaheadResult(did: 'did:plc:alice', handle: 'alice.bsky.social', displayName: 'Alice')];
        },
      );

      await tester.pumpWidget(
        _buildSubject(controller: controller, repository: repository, onSelected: (result) => selected = result),
      );

      await tester.enterText(find.byType(TextFormField), 'alice');
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.did, 'did:plc:alice');
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('tap outside dismisses overlay', (tester) async {
      final controller = TextEditingController();
      final repository = _FakeTypeaheadRepository(
        searchHandler: ({required String query, int limit = 10}) async {
          return const [TypeaheadResult(did: 'did:plc:alice', handle: 'alice.bsky.social', displayName: 'Alice')];
        },
      );

      await tester.pumpWidget(_buildSubject(controller: controller, repository: repository, onSelected: (_) {}));

      await tester.enterText(find.byType(TextFormField), 'alice');
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);

      await tester.tapAt(const Offset(10, 500));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('does not query when input is shorter than minChars', (tester) async {
      final controller = TextEditingController();
      var queryCount = 0;

      final repository = _FakeTypeaheadRepository(
        searchHandler: ({required String query, int limit = 10}) async {
          queryCount += 1;
          return const [];
        },
      );

      await tester.pumpWidget(_buildSubject(controller: controller, repository: repository, onSelected: (_) {}));

      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pumpAndSettle();

      expect(queryCount, 0);
    });

    testWidgets('shows and hides input loading spinner while fetching suggestions', (tester) async {
      final controller = TextEditingController();
      final completer = Completer<List<TypeaheadResult>>();
      final repository = _FakeTypeaheadRepository(
        searchHandler: ({required String query, int limit = 10}) => completer.future,
      );

      await tester.pumpWidget(_buildSubject(controller: controller, repository: repository, onSelected: (_) {}));

      await tester.enterText(find.byType(TextFormField), 'alice');
      await tester.pump(const Duration(milliseconds: 5));

      expect(find.byKey(const ValueKey('typeahead-input-loading-spinner')), findsOneWidget);

      completer.complete(const [TypeaheadResult(did: 'did:plc:alice', handle: 'alice.bsky.social')]);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('typeahead-input-loading-spinner')), findsNothing);
    });
  });
}

Widget _buildSubject({
  required TextEditingController controller,
  required TypeaheadRepository repository,
  required ValueChanged<TypeaheadResult> onSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TypeaheadTextField(
              controller: controller,
              repository: repository,
              onSelected: onSelected,
              debounceMs: 1,
              minChars: 2,
              limit: 8,
              decoration: const InputDecoration(labelText: 'Handle'),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
  );
}

class _FakeTypeaheadRepository extends TypeaheadRepository {
  _FakeTypeaheadRepository({required this.searchHandler}) : super(provider: TypeaheadRepository.communityProvider);

  final Future<List<TypeaheadResult>> Function({required String query, int limit}) searchHandler;

  @override
  Future<List<TypeaheadResult>> search({required String query, int limit = 10}) {
    return searchHandler(query: query, limit: limit);
  }
}
