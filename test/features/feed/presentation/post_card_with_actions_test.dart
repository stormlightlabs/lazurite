import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart';

import '../../../helpers/fixtures/feed.dart';
import '../../../helpers/connectivity_helpers.dart';

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

FeedViewPost _makePostView() => testFeedViewPost(
  uri: 'at://did:plc:author/app.bsky.feed.post/abc123',
  cid: 'cid-abc123',
  record: testPostRecordJson(text: 'Hello world'),
);

void main() {
  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.feed.post/fallback'));
  });

  late MockPostActionRepository postActionRepository;
  late MockSavedPostsCubit savedPostsCubit;
  late MockConnectivityCubit connectivityCubit;

  setUp(() {
    postActionRepository = MockPostActionRepository();
    savedPostsCubit = MockSavedPostsCubit();
    connectivityCubit = MockConnectivityCubit();

    when(() => savedPostsCubit.state).thenReturn(const SavedPostsState());
    whenListen(savedPostsCubit, const Stream<SavedPostsState>.empty(), initialState: const SavedPostsState());

    stubConnectivityCubit(connectivityCubit, state: const ConnectivityState.online());
  });

  testWidgets('keeps optimistic like loading state across parent rebuilds', (tester) async {
    final likeCompleter = Completer<String>();
    when(
      () => postActionRepository.likePost(
        uri: any(named: 'uri'),
        cid: any(named: 'cid'),
      ),
    ).thenAnswer((_) => likeCompleter.future);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PostActionRepository>.value(value: postActionRepository),
          RepositoryProvider<PostActionCache>(create: (_) => PostActionCache()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SavedPostsCubit>.value(value: savedPostsCubit),
            BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
          ],
          child: const MaterialApp(home: _RebuildHarness()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite_outline));
    await tester.pump();

    verify(
      () => postActionRepository.likePost(
        uri: any(named: 'uri'),
        cid: any(named: 'cid'),
      ),
    ).called(1);

    await tester.tap(find.byKey(const ValueKey('rebuild-parent')));
    await tester.pump();

    expect(find.byIcon(Icons.favorite_outline), findsNothing);

    likeCompleter.complete('at://did:plc:author/app.bsky.feed.like/like123');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}

class _RebuildHarness extends StatefulWidget {
  const _RebuildHarness();

  @override
  State<_RebuildHarness> createState() => _RebuildHarnessState();
}

class _RebuildHarnessState extends State<_RebuildHarness> {
  final FeedViewPost _feedViewPost = _makePostView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            key: const ValueKey('rebuild-parent'),
            onPressed: () => setState(() {}),
            child: const Text('Rebuild Parent'),
          ),
          Expanded(
            child: PostCardWithActions(feedViewPost: _feedViewPost, accountDid: 'did:plc:me'),
          ),
        ],
      ),
    );
  }
}
