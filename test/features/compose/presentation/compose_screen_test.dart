import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockComposeBloc extends MockBloc<ComposeEvent, ComposeState> implements ComposeBloc {}

class FakeDraftsCompanion extends Fake implements DraftsCompanion {}

DraftEntry _makeDraft({int id = 1, String content = 'Draft'}) => DraftEntry(
  id: id,
  accountDid: 'did:plc:test',
  content: content,
  mediaPaths: null,
  embedJson: null,
  replyUri: null,
  replyCid: null,
  rootUri: null,
  rootCid: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
  scheduledAt: null,
);

void main() {
  late MockComposeBloc mockBloc;

  setUp(() {
    registerFallbackValue(FakeDraftsCompanion());
    registerFallbackValue(const TextChanged(''));
    mockBloc = MockComposeBloc();
  });

  tearDown(() => mockBloc.close());

  Widget buildSubject() => MaterialApp(
    home: BlocProvider<ComposeBloc>.value(value: mockBloc, child: const ComposeScreen()),
  );

  void seedState(ComposeState state) {
    whenListen(mockBloc, Stream.value(state), initialState: state);
  }

  group('ComposeScreen', () {
    group('character counter (Bug #2)', () {
      testWidgets('shows 300 on empty compose screen', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('300'), findsOneWidget);
      });

      testWidgets('shows updated remaining count when graphemeCount changes', (tester) async {
        seedState(const ComposeState.ready(graphemeCount: 5));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('295'), findsOneWidget);
      });

      testWidgets('shows negative remaining count when over limit', (tester) async {
        seedState(const ComposeState.ready(graphemeCount: 305, isOverLimit: true));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('-5'), findsOneWidget);
      });

      testWidgets('prefills initial text and dispatches TextChanged when provided', (tester) async {
        seedState(const ComposeState.ready(text: '@river.bsky.social ', graphemeCount: 19, isEmpty: false));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ComposeBloc>.value(
              value: mockBloc,
              child: const ComposeScreen(initialText: '@river.bsky.social '),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('@river.bsky.social '), findsOneWidget);
        verify(() => mockBloc.add(const TextChanged('@river.bsky.social '))).called(1);
      });
    });

    group('inline drafts panel (Bug #3)', () {
      testWidgets('drafts panel is hidden initially', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Drafts'), findsNothing);
      });

      testWidgets('tapping drafts button shows inline panel without BottomSheet', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Drafts'), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
      });

      testWidgets('tapping drafts button again hides panel', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Drafts'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Drafts'), findsNothing);
      });

      testWidgets('shows empty state when no drafts loaded', (tester) async {
        seedState(const ComposeState.ready().copyWith(drafts: [], isLoadingDrafts: false));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('No drafts saved'), findsOneWidget);
      });

      testWidgets('shows draft items when drafts are loaded', (tester) async {
        seedState(
          const ComposeState.ready().copyWith(drafts: [_makeDraft(content: 'My saved draft')], isLoadingDrafts: false),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('My saved draft'), findsOneWidget);
      });

      testWidgets('shows loading indicator while drafts are loading', (tester) async {
        seedState(const ComposeState.ready().copyWith(isLoadingDrafts: true));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('fires DraftsRequested when panel opens', (tester) async {
        seedState(const ComposeState.ready());

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();

        verify(() => mockBloc.add(const DraftsRequested())).called(1);
      });

      testWidgets('tapping a draft fires DraftLoaded and closes panel', (tester) async {
        seedState(const ComposeState.ready().copyWith(drafts: [_makeDraft(id: 7, content: 'Tap to load me')]));

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.drive_file_rename_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Tap to load me'));
        await tester.pump();

        verify(() => mockBloc.add(const DraftLoaded(7))).called(1);
        expect(find.text('Drafts'), findsNothing);
      });
    });
  });
}
