import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/public/data/public_provider_context.dart';
import 'package:lazurite/features/public/presentation/public_navigation.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

import '../../../helpers/widget_harness.dart';

void main() {
  testWidgets('public navigation helpers append provider query context', (tester) async {
    const context = PublicProviderContext(providerKey: AppViewProviders.blackskyKey);
    late BuildContext buttonContext;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            buttonContext = context;
            return const Scaffold(body: Text('home'));
          },
        ),
        GoRoute(
          path: '/feed',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
        GoRoute(
          path: '/post',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
        GoRoute(
          path: '/profile/:actor',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
      ],
    );

    await pumpTestRouterApp(tester, router);

    final feedNavigation = navigateToPublicFeed(buttonContext, _feed(), context);
    await tester.pumpAndSettle();
    expect(find.textContaining('provider=blacksky'), findsOneWidget);
    expect(find.textContaining('/feed?'), findsOneWidget);
    expect(router.canPop(), isTrue);

    router.pop();
    await feedNavigation;
    router.go('/');
    await tester.pumpAndSettle();
    final postNavigation = navigateToPublicPost(buttonContext, 'at://did:plc:alice/app.bsky.feed.post/abc', context);
    await tester.pumpAndSettle();
    expect(find.textContaining('provider=blacksky'), findsOneWidget);
    expect(find.textContaining('/post?'), findsOneWidget);
    expect(router.canPop(), isTrue);

    router.pop();
    await postNavigation;
    router.go('/');
    await tester.pumpAndSettle();
    navigateToPublicProfile(buttonContext, 'alice.bsky.social', context);
    await tester.pumpAndSettle();
    expect(find.text('/profile/alice.bsky.social?provider=blacksky'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });
}

GeneratorView _feed() => GeneratorView(
  uri: atcore.AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/news'),
  cid: 'cid',
  did: 'did:web:feeds.example',
  creator: const ProfileView(did: 'did:plc:feed', handle: 'feeds.example'),
  displayName: 'News',
  indexedAt: DateTime.utc(2026, 5, 18),
);
