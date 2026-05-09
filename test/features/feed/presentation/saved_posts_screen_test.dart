import 'dart:async';
import 'dart:convert';

import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_lex/app/bsky/bookmark/get_bookmarks.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/saved_posts_screen.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

PostView _makePostView({
  String did = 'did:plc:author',
  String handle = 'author.bsky.social',
  String rkey = 'abc123',
  String text = 'Hello world',
}) {
  return PostView(
    uri: AtUri('at://$did/app.bsky.feed.post/$rkey'),
    cid: 'cid-$rkey',
    author: ProfileViewBasic(did: did, handle: handle),
    record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': DateTime.utc(2026, 3, 15).toIso8601String()},
    indexedAt: DateTime.utc(2026, 3, 15),
  );
}

SavedPostEntry _makeEntry({
  int id = 1,
  String postUri = 'at://did:plc:author/app.bsky.feed.post/abc123',
  required String postJson,
}) {
  return SavedPostEntry(
    id: id,
    accountDid: 'did:plc:me',
    postUri: postUri,
    postJson: postJson,
    saveType: 'local',
    savedAt: DateTime.utc(2026, 3, 15),
  );
}

void main() {
  late MockAppDatabase mockDatabase;
  late MockPostActionRepository mockPostActionRepository;
  late MockConnectivityCubit connectivityCubit;

  const testAccountDid = 'did:plc:me';

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockPostActionRepository = MockPostActionRepository();
    connectivityCubit = MockConnectivityCubit();
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );

    when(() => mockDatabase.watchSavedPostsWithType(testAccountDid)).thenAnswer((_) => Stream.value({}));
    when(() => mockDatabase.getSavedPosts(testAccountDid)).thenAnswer((_) => Future.value([]));
    when(
      () => mockPostActionRepository.getBookmarks(
        limit: any(named: 'limit'),
        cursor: any(named: 'cursor'),
      ),
    ).thenAnswer((_) async => const BookmarkGetBookmarksOutput(bookmarks: []));
  });

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: mockDatabase),
        RepositoryProvider<PostActionRepository>.value(value: mockPostActionRepository),
        RepositoryProvider<PostActionCache>(create: (_) => PostActionCache()),
        RepositoryProvider<String>.value(value: testAccountDid),
      ],
      child: BlocProvider<ConnectivityCubit>.value(
        value: connectivityCubit,
        child: const MaterialApp(home: SavedPostsScreen(accountDid: testAccountDid)),
      ),
    );
  }

  testWidgets('shows empty state when no saved posts', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('No bookmarks'), findsOneWidget);
    expect(find.text('Posts you bookmark will appear here'), findsOneWidget);
  });

  testWidgets('renders PostCardWithActions for a saved post with valid postJson', (tester) async {
    final postView = _makePostView(text: 'Saved post content');
    final postJson = jsonEncode(postView.toJson());
    final entry = _makeEntry(postUri: postView.uri.toString(), postJson: postJson);

    when(() => mockDatabase.getSavedPosts(testAccountDid)).thenAnswer((_) => Future.value([entry]));
    when(
      () => mockDatabase.watchSavedPostsWithType(testAccountDid),
    ).thenAnswer((_) => Stream.value({postView.uri.toString(): 'local'}));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(PostCardWithActions), findsOneWidget);
  });

  testWidgets('renders fallback card when postJson is invalid', (tester) async {
    final entry = _makeEntry(postJson: 'not valid json {{{');

    when(() => mockDatabase.getSavedPosts(testAccountDid)).thenAnswer((_) => Future.value([entry]));
    when(
      () => mockDatabase.watchSavedPostsWithType(testAccountDid),
    ).thenAnswer((_) => Stream.value({entry.postUri: 'local'}));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Bookmarked Post'), findsOneWidget);
    expect(find.byType(PostCardWithActions), findsNothing);
  });

  testWidgets('swipe to dismiss calls unsavePostById', (tester) async {
    final postView = _makePostView();
    final postJson = jsonEncode(postView.toJson());
    final entry = _makeEntry(postUri: postView.uri.toString(), postJson: postJson);

    var callCount = 0;
    when(() => mockDatabase.getSavedPosts(testAccountDid)).thenAnswer((_) {
      callCount++;
      return Future.value(callCount == 1 ? [entry] : <SavedPostEntry>[]);
    });
    when(
      () => mockDatabase.watchSavedPostsWithType(testAccountDid),
    ).thenAnswer((_) => Stream.value({postView.uri.toString(): 'local'}));
    when(() => mockDatabase.unsavePostById(entry.id)).thenAnswer((_) => Future.value(1));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(Dismissible), findsOneWidget);

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    verify(() => mockDatabase.unsavePostById(entry.id)).called(1);
  });

  testWidgets('shows loading indicator while loading', (tester) async {
    final completer = Completer<List<SavedPostEntry>>();
    when(() => mockDatabase.getSavedPosts(testAccountDid)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });
}
