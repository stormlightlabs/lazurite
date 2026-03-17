import 'package:atproto/com_atproto_repo_listrecords.dart';
import 'package:atproto_core/atproto_core.dart';
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
    when(() => mockDevToolsCubit.loadCollection(any())).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.loadRecord(any())).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.loadMoreRecords()).thenAnswer((_) async {});
    when(() => mockDevToolsCubit.goBackToRepo()).thenReturn(null);
    when(() => mockDevToolsCubit.goBackToCollection()).thenReturn(null);
    when(() => mockDevToolsCubit.clearInput()).thenReturn(null);

    whenListen(mockDevToolsCubit, const Stream<DevToolsState>.empty(), initialState: const DevToolsState());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<DevToolsCubit>.value(value: mockDevToolsCubit, child: const DevToolsScreen()),
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

      expect(find.text('test.bsky.social'), findsOneWidget);
      expect(find.text('did:plc:test'), findsOneWidget);
      expect(find.text('2 collections'), findsOneWidget);
      expect(find.text('5 records'), findsOneWidget);
      expect(find.text('app.bsky.feed.post'), findsOneWidget);
      expect(find.text('app.bsky.feed.like'), findsOneWidget);
    });

    testWidgets('submitting search calls cubit resolve', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextField), 'alice.bsky.social');
      await tester.tap(find.text('Resolve'));

      verify(() => mockDevToolsCubit.resolve('alice.bsky.social')).called(1);
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
  });
}
