import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_embed_external.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';

FeedViewPost _makePost({String text = 'Hello'}) {
  final record = FeedPostRecord(text: text, createdAt: DateTime.utc(2026, 3, 16));
  return FeedViewPost(
    post: PostView(
      uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
      cid: 'cid-xyz',
      author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
      record: record.toJson(),
      indexedAt: DateTime.utc(2026, 3, 16),
    ),
  );
}

void main() {
  Widget buildSubject(FeedViewPost post, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(body: PostCard(feedViewPost: post, onTap: onTap)),
    );
  }

  testWidgets('renders UTF-8 facet ranges without corrupting text', (tester) async {
    const text = 'Launch 🚀 #tag';
    final start = utf8.encode('Launch 🚀 ').length;
    final end = utf8.encode(text).length;

    final record = FeedPostRecord(
      text: text,
      createdAt: DateTime.utc(2026, 3, 16),
      facets: [
        RichtextFacet(
          index: RichtextFacetByteSlice(byteStart: start, byteEnd: end),
          features: const [URichtextFacetFeatures.richtextFacetTag(data: RichtextFacetTag(tag: 'tag'))],
        ),
      ],
    );

    final post = FeedViewPost(
      post: PostView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
        cid: 'cid-xyz',
        author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
        record: record.toJson(),
        indexedAt: DateTime.utc(2026, 3, 16),
      ),
    );

    await tester.pumpWidget(buildSubject(post));

    final richTextFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == 'Launch 🚀 #tag',
    );

    expect(richTextFinder, findsOneWidget);
  });

  testWidgets('renders external link card embeds', (tester) async {
    final record = FeedPostRecord(text: 'Read this', createdAt: DateTime.utc(2026, 3, 16));
    final post = FeedViewPost(
      post: PostView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
        cid: 'cid-xyz',
        author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
        record: record.toJson(),
        indexedAt: DateTime.utc(2026, 3, 16),
        embed: const UPostViewEmbed.embedExternalView(
          data: EmbedExternalView(
            external: EmbedExternalViewExternal(
              uri: 'https://example.com/article',
              title: 'Example Article',
              description: 'A useful external card',
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildSubject(post));

    expect(find.text('Example Article'), findsOneWidget);
    expect(find.text('A useful external card'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
  });

  testWidgets('calls onTap when content area is tapped', (tester) async {
    var tapped = false;
    final post = _makePost();

    await tester.pumpWidget(buildSubject(post, onTap: () => tapped = true));

    // Tap the author handle which is in the content InkWell (not the action bar).
    await tester.tap(find.text('test.bsky.social', findRichText: true).first);
    expect(tapped, isTrue);
  });

  testWidgets('does not call onTap when onTap is null', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(buildSubject(post));
    // Should not throw when tapping without a callback.
    await tester.tap(find.text('test.bsky.social', findRichText: true).first);
    await tester.pump();
  });

  testWidgets('tapping avatar navigates to author profile', (tester) async {
    final post = _makePost();
    String? pushedRoute;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: PostCard(feedViewPost: post)),
        ),
        GoRoute(
          path: '/profile/view',
          builder: (context, state) {
            pushedRoute = state.uri.toString();
            return const Scaffold(body: Text('profile'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    expect(pushedRoute, contains('did%3Aplc%3Atest'));
  });
}
