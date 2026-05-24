import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/feed/presentation/widgets/public_post_card.dart';
import 'package:poptart_core/poptart_core.dart';

void main() {
  testWidgets('renders passive public counts and share action', (tester) async {
    await tester.pumpWidget(_buildSubject(_makePost(), variant: PostCardVariant.card));

    expect(find.byKey(const ValueKey('public_post_card_footer')), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.byTooltip('Share post'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline), findsNothing);
  });

  testWidgets('passes public footer into compact and grid card variants', (tester) async {
    await tester.pumpWidget(_buildSubject(_makePost(), variant: PostCardVariant.compact));

    expect(find.byKey(const ValueKey('public_post_card_footer')), findsOneWidget);
    expect(find.byTooltip('Share post'), findsOneWidget);

    await tester.pumpWidget(_buildSubject(_makePost(), variant: PostCardVariant.grid));

    expect(find.byKey(const ValueKey('public_post_card_footer')), findsOneWidget);
    expect(find.byTooltip('Share post'), findsOneWidget);
  });

  testWidgets('author taps preserve public provider context', (tester) async {
    final visitedProfileUris = <Uri>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: PublicPostCard(feedViewPost: _makePost(), providerKey: 'blacksky', variant: PostCardVariant.card),
          ),
        ),
        GoRoute(
          path: '/profile/:actor',
          builder: (_, state) {
            visitedProfileUris.add(state.uri);
            return const Scaffold(body: Text('profile'));
          },
        ),
      ],
    );

    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
    await tester.pumpWidget(MaterialApp.router(theme: theme, routerConfig: router));

    final avatar = tester.widget<GestureDetector>(find.byKey(const ValueKey('post_card_avatar')));
    avatar.onTap!();
    await tester.pumpAndSettle();

    expect(find.text('profile'), findsOneWidget);
    expect(visitedProfileUris.last.pathSegments, ['profile', 'did:plc:test']);
    expect(visitedProfileUris.last.queryParameters['provider'], 'blacksky');

    router.dispose();
  });

  testWidgets('post taps stack public route so back can return to previous location', (tester) async {
    final visitedPostUris = <Uri>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: PublicPostCard(feedViewPost: _makePost(), providerKey: 'blacksky', variant: PostCardVariant.card),
          ),
        ),
        GoRoute(
          path: '/post',
          builder: (_, state) {
            visitedPostUris.add(state.uri);
            return const Scaffold(body: Text('post'));
          },
        ),
      ],
    );

    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
    await tester.pumpWidget(MaterialApp.router(theme: theme, routerConfig: router));

    final postInkWell = tester.widget<InkWell>(
      find.descendant(of: find.byType(PostCard), matching: find.byType(InkWell)).first,
    );
    postInkWell.onTap!();
    await tester.pumpAndSettle();

    expect(find.text('post'), findsOneWidget);
    expect(visitedPostUris.last.path, '/post');
    expect(visitedPostUris.last.queryParameters['provider'], 'blacksky');
    expect(router.canPop(), isTrue);

    router.dispose();
  });
}

Widget _buildSubject(FeedViewPost post, {required PostCardVariant variant}) => MaterialApp(
  theme: AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark),
  home: Scaffold(
    body: PublicPostCard(feedViewPost: post, providerKey: 'blacksky', variant: variant),
  ),
);

FeedViewPost _makePost() {
  final record = FeedPostRecord(text: 'Public post', createdAt: DateTime.utc(2026, 3, 16));
  return FeedViewPost(
    post: PostView(
      uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
      cid: 'cid-xyz',
      author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social', displayName: 'Test User'),
      record: record.toJson(),
      indexedAt: DateTime.utc(2026, 3, 16),
      replyCount: 2,
      repostCount: 3,
      likeCount: 5,
    ),
  );
}
