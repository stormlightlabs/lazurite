import 'package:poptart_lex/com/atproto/repo/list_records.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';
import 'package:lazurite/features/devtools/presentation/dev_tools_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockDevToolsCubit extends MockCubit<DevToolsState> implements DevToolsCubit {}

class FakeDevToolsState extends Fake implements DevToolsState {}

late MockDevToolsCubit mockDevToolsCubit;

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDevToolsState());
    registerFallbackValue(
      const RepoListRecordsRecord(
        uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
        cid: 'cid123',
        value: {'text': 'Test'},
      ),
    );
  });

  setUp(() {
    mockDevToolsCubit = MockDevToolsCubit();

    when(() => mockDevToolsCubit.state).thenReturn(const DevToolsState());
    when(() => mockDevToolsCubit.resolve(any())).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.queryTypeahead(any())).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.loadCollection(any())).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.loadRecord(any())).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.loadMoreRecords()).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.goBackToRepo()).thenReturn(null);
    when(() => mockDevToolsCubit.goBackToCollection()).thenReturn(null);
    when(() => mockDevToolsCubit.clearTypeahead()).thenReturn(null);
    when(() => mockDevToolsCubit.clearInput()).thenReturn(null);

    whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: const DevToolsState());
  });

  Widget buildSubject({String? initialQuery}) {
    return MaterialApp(
      home: BlocProvider<DevToolsCubit>.value(
        value: mockDevToolsCubit,
        child: DevToolsScreen(initialQuery: initialQuery),
      ),
    );
  }

  group('DevToolsScreen', () {
    testWidgets('renders empty state initially', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('PDS Explorer'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Enter a handle, DID, or AT-URI'), findsOneWidget);
      expect(find.text('Inspired by pds.ls'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      when(() => mockDevToolsCubit.state).thenReturn(const DevToolsState(status: DevToolsStatus.loading));
      whenListen(
        mockDevToolsCubit,
        const Stream<DevToolsState>.empty(),
        initialState: const DevToolsState(status: DevToolsStatus.loading),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      when(
        () => mockDevToolsCubit.state,
      ).thenReturn(const DevToolsState(status: DevToolsStatus.error, errorMessage: 'Test error'));
      whenListen(
        mockDevToolsCubit,
        const Stream<DevToolsState>.empty(),
        initialState: const DevToolsState(status: DevToolsStatus.error, errorMessage: 'Test error'),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('renders repo overview with collection counts', (tester) async {
      const state = DevToolsState(
        status: DevToolsStatus.repoLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        collections: [
          CollectionSummary('app.bsky.feed.post', recordCount: 2),
          CollectionSummary('app.bsky.feed.like', recordCount: 3),
        ],
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());

      expect(find.text('test.bsky.social'), findsAtLeastNWidgets(1));
      expect(find.text('did:plc:test'), findsOneWidget);
      expect(find.text('2 collections'), findsOneWidget);
      expect(find.text('5 records'), findsOneWidget);
      expect(find.text('app.bsky.feed.post'), findsOneWidget);
      expect(find.text('app.bsky.feed.like'), findsOneWidget);
    });

    testWidgets('renders repo overview while record counts are loading', (tester) async {
      const state = DevToolsState(
        status: DevToolsStatus.repoLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post')],
        isCollectionCountsLoading: true,
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());

      expect(find.text('Counting records...'), findsOneWidget);
    });

    testWidgets('renders repo overview when record counts are unavailable', (tester) async {
      const state = DevToolsState(
        status: DevToolsStatus.repoLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post')],
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());

      expect(find.text('Record counts unavailable'), findsOneWidget);
    });

    testWidgets('submitting search calls cubit resolve', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextField), 'alice.bsky.social');
      await tester.tap(find.text('Resolve'));

      verify(() => mockDevToolsCubit.resolve('alice.bsky.social')).called(1);
    });

    testWidgets('typing @handle triggers typeahead query', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextField), '@ali');
      await tester.pump();

      verify(() => mockDevToolsCubit.queryTypeahead('@ali')).called(1);
    });

    testWidgets('tapping a typeahead suggestion resolves the selected handle', (tester) async {
      const state = DevToolsState(
        typeaheadActors: [ProfileViewBasic(did: 'did:plc:alice', handle: 'alice.bsky.social', displayName: 'Alice')],
      );
      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());
      await tester.enterText(find.byType(TextField), '@a');
      await tester.pump();

      await tester.tap(find.text('Alice'));

      verify(() => mockDevToolsCubit.resolve('alice.bsky.social')).called(1);
      verify(() => mockDevToolsCubit.clearTypeahead()).called(1);
    });

    testWidgets('initial query prefills the input and resolves automatically', (tester) async {
      await tester.pumpWidget(buildSubject(initialQuery: 'did:plc:test'));
      await tester.pump();

      expect(find.widgetWithText(TextField, 'did:plc:test'), findsOneWidget);
      verify(() => mockDevToolsCubit.resolve('did:plc:test')).called(1);
    });

    testWidgets('tapping a record calls cubit loadRecord', (tester) async {
      const record = RepoListRecordsRecord(
        uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
        cid: 'cid123',
        value: {'text': 'Summary'},
      );
      const state = DevToolsState(
        status: DevToolsStatus.collectionLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        records: [record],
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('123'));

      verify(() => mockDevToolsCubit.loadRecord(record)).called(1);
    });

    testWidgets('renders breadcrumbs for record navigation', (tester) async {
      const state = DevToolsState(
        status: DevToolsStatus.recordLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        selectedRecord: RecordInfo(
          uri: 'at://did:plc:test/app.bsky.feed.post/123',
          cid: 'cid123',
          value: {'text': 'Summary'},
        ),
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const ValueKey('dev-tools-breadcrumb-repo')), findsOneWidget);
      expect(find.byKey(const ValueKey('dev-tools-breadcrumb-collection')), findsOneWidget);
      expect(find.byKey(const ValueKey('dev-tools-breadcrumb-record')), findsOneWidget);
      expect(find.text('test.bsky.social'), findsAtLeastNWidgets(1));
      expect(find.text('app.bsky.feed.post'), findsAtLeastNWidgets(1));
      expect(find.text('123'), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping repo breadcrumb calls cubit goBackToRepo', (tester) async {
      const state = DevToolsState(
        status: DevToolsStatus.collectionLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        records: [
          RepoListRecordsRecord(
            uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
            cid: 'cid123',
            value: {'text': 'Summary'},
          ),
        ],
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byKey(const ValueKey('dev-tools-breadcrumb-repo')));

      verify(() => mockDevToolsCubit.goBackToRepo()).called(1);
    });

    testWidgets('tapping collection breadcrumb calls cubit goBackToCollection', (tester) async {
      const state = DevToolsState(
        status: DevToolsStatus.recordLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        selectedRecord: RecordInfo(
          uri: 'at://did:plc:test/app.bsky.feed.post/123',
          cid: 'cid123',
          value: {'text': 'Summary'},
        ),
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byKey(const ValueKey('dev-tools-breadcrumb-collection')));

      verify(() => mockDevToolsCubit.goBackToCollection()).called(1);
    });

    testWidgets('shows breadcrumb progress without full-screen spinner during record navigation', (tester) async {
      const state = DevToolsState(
        status: DevToolsStatus.collectionLoaded,
        did: 'did:plc:test',
        handle: 'test.bsky.social',
        repoHandle: 'test.bsky.social',
        collections: [CollectionSummary('app.bsky.feed.post', recordCount: 1)],
        selectedCollection: 'app.bsky.feed.post',
        records: [
          RepoListRecordsRecord(
            uri: AtUri('at://did:plc:test/app.bsky.feed.post/123'),
            cid: 'cid123',
            value: {'text': 'Summary'},
          ),
        ],
        isRecordLoading: true,
      );

      when(() => mockDevToolsCubit.state).thenReturn(state);
      whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: state);

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const ValueKey('app-breadcrumbs-loading')), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('123'), findsOneWidget);
    });
  });
}
