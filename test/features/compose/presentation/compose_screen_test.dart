import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockComposeBloc extends MockBloc<ComposeEvent, ComposeState> implements ComposeBloc {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

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
  late MockConnectivityCubit connectivityCubit;

  setUp(() {
    registerFallbackValue(FakeDraftsCompanion());
    registerFallbackValue(const TextChanged(''));
    registerFallbackValue(
      const EditContextSet(
        postUri: 'at://did:plc:test/app.bsky.feed.post/fallback',
        postCid: 'cid-fallback',
        record: {r'$type': 'app.bsky.feed.post', 'text': 'fallback', 'createdAt': '2026-04-14T10:00:00.000Z'},
      ),
    );
    mockBloc = MockComposeBloc();
    connectivityCubit = MockConnectivityCubit();
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildSubject({ComposeScreen screen = const ComposeScreen()}) => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<ComposeBloc>.value(value: mockBloc),
        BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
      ],
      child: screen,
    ),
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

        await tester.pumpWidget(buildSubject(screen: const ComposeScreen(initialText: '@river.bsky.social ')));
        await tester.pump();

        expect(find.text('@river.bsky.social '), findsOneWidget);
        verify(() => mockBloc.add(const TextChanged('@river.bsky.social '))).called(1);
      });
    });

    group('edit mode', () {
      testWidgets('shows edit title, save action, and algorithm notice banner', (tester) async {
        seedState(
          const ComposeState.ready(
            text: 'Updated text',
            graphemeCount: 12,
            isEmpty: false,
            editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
            editPostCid: 'cid-current',
            editRecord: {
              r'$type': 'app.bsky.feed.post',
              'text': 'Original text',
              'createdAt': '2026-04-14T10:00:00.000Z',
            },
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Edit Post'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);
        expect(
          find.text(
            'Edits are saved by replacing the record while keeping this post URI. Ranking, counts, and visibility may '
            'shift while networks re-index.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('hides unsupported controls while editing', (tester) async {
        seedState(
          const ComposeState.ready(
            text: 'Updated text',
            graphemeCount: 12,
            isEmpty: false,
            editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
            editPostCid: 'cid-current',
            editRecord: {
              r'$type': 'app.bsky.feed.post',
              'text': 'Original text',
              'createdAt': '2026-04-14T10:00:00.000Z',
            },
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Save Draft'), findsNothing);
        expect(find.byIcon(Icons.image_outlined), findsNothing);
        expect(find.byIcon(Icons.videocam_outlined), findsNothing);
        expect(find.byIcon(Icons.drive_file_rename_outline), findsNothing);
        expect(find.byIcon(Icons.schedule), findsNothing);
      });

      testWidgets('dispatches EditContextSet on init when edit args are provided', (tester) async {
        seedState(
          const ComposeState.ready(
            text: 'Original text',
            graphemeCount: 13,
            isEmpty: false,
            editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
            editPostCid: 'cid-current',
            editRecord: {
              r'$type': 'app.bsky.feed.post',
              'text': 'Original text',
              'createdAt': '2026-04-14T10:00:00.000Z',
            },
          ),
        );

        await tester.pumpWidget(
          buildSubject(
            screen: const ComposeScreen(
              initialText: 'Original text',
              editPostUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
              editPostCid: 'cid-current',
              editRecord: {
                r'$type': 'app.bsky.feed.post',
                'text': 'Original text',
                'createdAt': '2026-04-14T10:00:00.000Z',
              },
            ),
          ),
        );
        await tester.pump();

        verify(
          () => mockBloc.add(
            const EditContextSet(
              postUri: 'at://did:plc:test/app.bsky.feed.post/abc123',
              postCid: 'cid-current',
              record: {
                r'$type': 'app.bsky.feed.post',
                'text': 'Original text',
                'createdAt': '2026-04-14T10:00:00.000Z',
              },
              initialText: 'Original text',
            ),
          ),
        ).called(1);
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
