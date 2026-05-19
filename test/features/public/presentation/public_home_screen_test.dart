import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/unspecced/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/public/presentation/public_home_screen.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

class MockPublicContentRepository extends Mock implements PublicContentRepository {}

void main() {
  late MockPublicContentRepository repository;

  setUp(() {
    repository = MockPublicContentRepository();
    when(
      () => repository.loadDiscover(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => PublicDiscoverResult(feeds: [_feed('discover')], cursor: 'cursor-1'));
    when(
      () => repository.loadFeeds(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => PublicFeedsResult(feeds: [_feed('suggested')], cursor: 'cursor-1'));
    when(
      () => repository.searchFeeds(
        query: any(named: 'query'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((invocation) async {
      final query = invocation.namedArguments[#query] as String;
      return PublicFeedsResult(feeds: [_feed(query)]);
    });
  });

  Widget buildSubject({
    String providerKey = AppViewProviders.blueskyKey,
    PublicContentTab contentTab = PublicContentTab.discover,
  }) {
    final router = GoRouter(
      initialLocation: '/public/$providerKey/${contentTab.routeValue}',
      routes: [
        GoRoute(
          path: '/public/:provider/:tab',
          builder: (context, state) => RepositoryProvider<PublicContentRepository>.value(
            value: repository,
            child: PublicHomeScreen(providerKey: providerKey, contentTab: contentTab),
          ),
        ),
        GoRoute(
          path: '/feed',
          builder: (_, _) => const Scaffold(body: Text('feed-detail')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('loads BlueSky Discover feeds and opens feed details with provider context', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('BlueSky Discover'), findsOneWidget);
    expect(find.text('Feed discover'), findsOneWidget);

    await tester.tap(find.text('Feed discover'));
    await tester.pumpAndSettle();

    expect(find.text('feed-detail'), findsOneWidget);
  });

  testWidgets('renders BlackSky Trending from public trend data', (tester) async {
    when(
      () => repository.loadDiscover(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => PublicDiscoverResult(trends: [_trend('Cookout Etiquette Debate')]));

    await tester.pumpWidget(buildSubject(providerKey: AppViewProviders.blackskyKey));
    await tester.pumpAndSettle();

    expect(find.text('BlackSky Trending'), findsOneWidget);
    expect(find.text('Cookout Etiquette Debate'), findsOneWidget);
  });

  testWidgets('loads public Feeds and searches through SearchRepository path', (tester) async {
    await tester.pumpWidget(buildSubject(contentTab: PublicContentTab.feeds));
    await tester.pumpAndSettle();

    expect(find.text('BlueSky Feeds'), findsOneWidget);
    expect(find.text('Feed suggested'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey<String>('public-bluesky-feed-search')), 'news');
    await tester.tap(find.byTooltip('Search feeds'));
    await tester.pumpAndSettle();

    expect(find.text('Feed news'), findsOneWidget);
    verify(() => repository.searchFeeds(query: 'news', cursor: null, limit: 25)).called(1);
  });

  testWidgets('shows loading and empty states for public feeds', (tester) async {
    final completer = Completer<PublicFeedsResult>();
    when(
      () => repository.loadFeeds(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildSubject(contentTab: PublicContentTab.feeds));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('public-bluesky-feeds-loading')), findsOneWidget);

    completer.complete(const PublicFeedsResult(feeds: []));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('public-bluesky-feeds-empty')), findsOneWidget);
  });
}

GeneratorView _feed(String rkey) {
  return GeneratorView(
    uri: atcore.AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/$rkey'),
    cid: 'cid-$rkey',
    did: 'did:web:feeds.example',
    creator: const ProfileView(did: 'did:plc:feed', handle: 'feeds.example', displayName: 'Feeds'),
    displayName: 'Feed $rkey',
    indexedAt: DateTime.utc(2026, 5, 18),
  );
}

TrendView _trend(String topic) {
  return TrendView(
    topic: topic,
    displayName: topic,
    link: '/topic/1972',
    startedAt: DateTime.utc(2026, 5, 18),
    postCount: 212,
    category: 'culture',
    actors: const [],
  );
}
