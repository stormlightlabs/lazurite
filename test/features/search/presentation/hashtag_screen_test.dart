import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/search/cubit/hashtag_cubit.dart';
import 'package:lazurite/features/search/data/hashtag_utils.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/presentation/hashtag_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/feed.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

PostView _post({required String uri, required String text}) => testPostView(
  uri: uri,
  author: testProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social', displayName: 'Author'),
  record: testPostRecordJson(text: text, createdAt: DateTime.utc(2026, 1, 1)),
  indexedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late MockSearchRepository searchRepository;

  setUp(() {
    searchRepository = MockSearchRepository();
  });

  GoRouter buildRouter({String initialLocation = '/hashtag?tag=atproto'}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/hashtag',
          builder: (context, state) {
            final tag = normalizeHashtag(state.uri.queryParameters['tag'] ?? '');
            return BlocProvider(
              key: ValueKey('hashtag-$tag'),
              create: (_) => HashtagCubit(searchRepository: searchRepository, tag: tag),
              child: HashtagScreen(tag: tag),
            );
          },
        ),
        GoRoute(
          path: '/profile/:actor',
          builder: (context, state) => Scaffold(body: Text('profile:${state.pathParameters['actor']}')),
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) => Scaffold(body: Text('post:${state.uri.queryParameters['uri']}')),
        ),
      ],
    );
  }

  testWidgets('renders hashtag title and top/latest tabs', (tester) async {
    when(
      () => searchRepository.searchPosts(
        query: '#atproto',
        sort: 'top',
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => SearchPostsResult(
        posts: [_post(uri: 'at://did:plc:author/app.bsky.feed.post/1', text: 'hello #atproto')],
      ),
    );

    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('#atproto'), findsOneWidget);
    expect(find.text('Top'), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
    verify(
      () => searchRepository.searchPosts(
        query: '#atproto',
        sort: 'top',
        cursor: any(named: 'cursor'),
        limit: 50,
      ),
    ).called(1);
  });

  testWidgets('switching to latest tab requests latest sort results', (tester) async {
    when(
      () => searchRepository.searchPosts(
        query: '#atproto',
        sort: 'top',
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => SearchPostsResult(
        posts: [_post(uri: 'at://did:plc:author/app.bsky.feed.post/1', text: 'top post')],
      ),
    );

    when(
      () => searchRepository.searchPosts(
        query: '#atproto',
        sort: 'latest',
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => SearchPostsResult(
        posts: [_post(uri: 'at://did:plc:author/app.bsky.feed.post/2', text: 'latest post')],
      ),
    );

    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Latest'));
    await tester.pumpAndSettle();

    verify(
      () => searchRepository.searchPosts(
        query: '#atproto',
        sort: 'latest',
        cursor: any(named: 'cursor'),
        limit: 50,
      ),
    ).called(1);
  });

  testWidgets('scrolling near bottom triggers load-more', (tester) async {
    final firstBatch = List.generate(
      20,
      (index) => _post(uri: 'at://did:plc:author/app.bsky.feed.post/$index', text: 'post $index #atproto'),
    );

    when(
      () => searchRepository.searchPosts(
        query: '#atproto',
        sort: 'top',
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((invocation) async {
      final cursor = invocation.namedArguments[#cursor] as String?;
      if (cursor == null) {
        return SearchPostsResult(posts: firstBatch, cursor: 'next-page');
      }
      return SearchPostsResult(
        posts: [_post(uri: 'at://did:plc:author/app.bsky.feed.post/99', text: 'loaded more')],
      );
    });

    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();

    verify(
      () => searchRepository.searchPosts(query: '#atproto', sort: 'top', cursor: 'next-page', limit: 50),
    ).called(1);
  });

  testWidgets('fab opens related tags sheet and jumps with route replacement', (tester) async {
    when(
      () => searchRepository.searchPosts(
        query: '#atproto',
        sort: 'top',
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => SearchPostsResult(
        posts: [
          _post(
            uri: 'at://did:plc:author/app.bsky.feed.post/1',
            text: 'Building things #atproto #openweb #decentralized',
          ),
        ],
      ),
    );

    when(
      () => searchRepository.searchPosts(
        query: '#openweb',
        sort: 'top',
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => SearchPostsResult(
        posts: [_post(uri: 'at://did:plc:author/app.bsky.feed.post/2', text: 'new timeline #openweb')],
      ),
    );

    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jump to hashtag'));
    await tester.pumpAndSettle();
    expect(find.text('Jump to hashtag'), findsAtLeastNWidgets(1));
    expect(find.text('#openweb'), findsOneWidget);

    await tester.tap(find.text('#openweb'));
    await tester.pumpAndSettle();
    expect(find.text('#openweb'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });
}
