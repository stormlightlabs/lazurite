import 'dart:convert';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/embed/external.dart';
import 'package:bluesky_poptart/app/bsky/embed/images.dart';
import 'package:bluesky_poptart/app/bsky/embed/record.dart';
import 'package:bluesky_poptart/app/bsky/embed/record_with_media.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart' as bsky_labeler;
import 'package:bluesky_poptart/app/bsky/richtext/facet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> canLaunch(String url) async => true;
}

FeedViewPost _makePost({String text = 'Hello', UFeedViewPostReason? reason}) {
  final record = FeedPostRecord(text: text, createdAt: DateTime.utc(2026, 3, 16));
  return FeedViewPost(
    reason: reason,
    post: PostView(
      uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
      cid: 'cid-xyz',
      author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
      record: record.toJson(),
      indexedAt: DateTime.utc(2026, 3, 16),
    ),
  );
}

UFeedViewPostReason _makeRepostReason() {
  return UFeedViewPostReason.reasonRepost(
    data: ReasonRepost(
      by: const ProfileViewBasic(did: 'did:plc:reposter', handle: 'reposter.bsky.social', displayName: 'Reposter'),
      indexedAt: DateTime.utc(2026, 3, 17),
    ),
  );
}

UEmbedRecordViewRecordEmbeds _nestedQuoteEmbed({
  required String did,
  required String rkey,
  required String handle,
  required String text,
  List<UEmbedRecordViewRecordEmbeds>? embeds,
}) {
  return UEmbedRecordViewRecordEmbeds.embedRecordView(
    data: EmbedRecordView(
      record: UEmbedRecordViewRecord.embedRecordViewRecord(
        data: EmbedRecordViewRecord(
          uri: AtUri.parse('at://$did/app.bsky.feed.post/$rkey'),
          cid: 'cid-$rkey',
          author: ProfileViewBasic(did: did, handle: handle, displayName: handle.split('.').first),
          value: FeedPostRecord(text: text, createdAt: DateTime.utc(2026, 3, 15)).toJson(),
          embeds: embeds,
          indexedAt: DateTime.utc(2026, 3, 15),
        ),
      ),
    ),
  );
}

FeedViewPost _makeReplyPost({String handle = 'test.bsky.social'}) {
  final record = <String, dynamic>{
    r'$type': 'app.bsky.feed.post',
    'text': 'Hello',
    'reply': {
      r'$type': 'app.bsky.feed.post#replyRef',
      'root': {'uri': 'at://did:plc:root/app.bsky.feed.post/root', 'cid': 'cid-root'},
      'parent': {'uri': 'at://did:plc:parent/app.bsky.feed.post/parent', 'cid': 'cid-parent'},
    },
    'createdAt': DateTime.utc(2026, 3, 16).toIso8601String(),
  };

  return FeedViewPost(
    post: PostView(
      uri: const AtUri('at://did:plc:test/app.bsky.feed.post/reply'),
      cid: 'cid-reply',
      author: ProfileViewBasic(did: 'did:plc:test', handle: handle),
      record: record,
      indexedAt: DateTime.utc(2026, 3, 16),
    ),
  );
}

void main() {
  late _FakeUrlLauncher fakeUrlLauncher;

  setUp(() {
    fakeUrlLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
  });

  Widget buildSubject(FeedViewPost post, {VoidCallback? onTap}) {
    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: PostCard(feedViewPost: post, onTap: onTap),
      ),
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

  testWidgets('tapping bsky external embed routes to profile in app', (tester) async {
    String? pushedRoute;
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
              uri: 'https://bsky.app/profile/alice.bsky.social',
              title: 'Alice',
              description: 'Profile link',
            ),
          ),
        ),
      ),
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: PostCard(feedViewPost: post)),
        ),
        GoRoute(
          path: '/profile/:actor',
          builder: (context, state) {
            pushedRoute = state.uri.toString();
            return const Scaffold(body: Text('profile'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(pushedRoute, isNotNull);
    expect(Uri.parse(pushedRoute!).path, '/profile/alice.bsky.social');
    expect(fakeUrlLauncher.launchedUrls, isEmpty);
  });

  testWidgets('tapping non-matching external embed launches browser', (tester) async {
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
              title: 'External Article',
              description: 'External card',
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildSubject(post));
    await tester.pumpAndSettle();

    await tester.tap(find.text('External Article'));
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.launchedUrls, contains('https://example.com/article'));
  });

  testWidgets('uses themed serif styling for post body text', (tester) async {
    final post = _makePost(text: 'Styled body copy');

    await tester.pumpWidget(buildSubject(post));

    final richText = tester.widget<RichText>(
      find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText() == 'Styled body copy'),
    );
    final style = (richText.text as TextSpan).style;
    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);

    expect(style?.fontFamily, theme.textTheme.titleMedium?.fontFamily);
    expect(style?.color, theme.colorScheme.onSurface);
    expect(richText.maxLines, isNull);
  });

  testWidgets('calls onTap when content area is tapped', (tester) async {
    var tapped = false;
    final post = _makePost();

    await tester.pumpWidget(buildSubject(post, onTap: () => tapped = true));

    await tester.tap(find.text('test.bsky.social', findRichText: true).first);
    expect(tapped, isTrue);
  });

  testWidgets('does not call onTap when onTap is null', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(buildSubject(post));
    await tester.tap(find.text('test.bsky.social', findRichText: true).first);
    await tester.pump();
  });

  testWidgets('renders handle uppercase in header', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(buildSubject(post));

    expect(find.text('@TEST.BSKY.SOCIAL'), findsOneWidget);
  });

  testWidgets('renders repost context and navigates to reposter profile', (tester) async {
    final post = _makePost(reason: _makeRepostReason());
    String? pushedRoute;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: PostCard(feedViewPost: post)),
        ),
        GoRoute(
          path: '/profile/:actor',
          builder: (context, state) {
            pushedRoute = state.uri.toString();
            return const Scaffold(body: Text('profile'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byKey(const ValueKey('post_repost_context')), matching: find.byIcon(Icons.repeat)),
      findsOneWidget,
    );
    expect(find.text('Reposted by'), findsOneWidget);
    expect(find.text('Reposter'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('post_repost_context')));
    await tester.pumpAndSettle();

    expect(pushedRoute, contains('did%3Aplc%3Areposter'));
  });

  testWidgets('keeps the reply label within narrow thread widths', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              child: PostCard(
                feedViewPost: _makeReplyPost(handle: 'replying-user-with-a-very-long-handle.bsky.social'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(errors.where((error) => error.exceptionAsString().contains('A RenderFlex overflowed')), isEmpty);
    expect(find.text('Reply in a thread'), findsOneWidget);
  });

  testWidgets('renders PostCardFooter instead of CircleAvatar', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(buildSubject(post));

    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byType(PostCardFooter), findsOneWidget);
  });

  testWidgets('tapping quoted post navigates to /post with quoted uri', (tester) async {
    final quotedUri = AtUri.parse('at://did:plc:quoted/app.bsky.feed.post/quoted123');
    final record = FeedPostRecord(text: 'Main post', createdAt: DateTime.utc(2026, 3, 16));
    final quotedRecord = FeedPostRecord(text: 'Quoted text', createdAt: DateTime.utc(2026, 3, 15));
    final post = FeedViewPost(
      post: PostView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
        cid: 'cid-xyz',
        author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
        record: record.toJson(),
        indexedAt: DateTime.utc(2026, 3, 16),
        embed: UPostViewEmbed.embedRecordView(
          data: EmbedRecordView(
            record: UEmbedRecordViewRecord.embedRecordViewRecord(
              data: EmbedRecordViewRecord(
                uri: quotedUri,
                cid: 'cid-quoted',
                author: const ProfileViewBasic(did: 'did:plc:quoted', handle: 'quoted.bsky.social'),
                value: quotedRecord.toJson(),
                indexedAt: DateTime.utc(2026, 3, 15),
              ),
            ),
          ),
        ),
      ),
    );

    String? pushedRoute;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: PostCard(feedViewPost: post)),
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) {
            pushedRoute = state.uri.toString();
            return const Scaffold(body: Text('post thread'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quoted text', findRichText: true));
    await tester.pumpAndSettle();

    expect(pushedRoute, isNotNull);
    expect(Uri.parse(pushedRoute!).path, '/post');
    expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), quotedUri.toString());
  });

  testWidgets('renders quoted post text with serif styling and without truncation', (tester) async {
    final quotedRecord = FeedPostRecord(
      text: 'Quoted text that should fully expand inside the embed card',
      createdAt: DateTime.utc(2026, 3, 15),
    );
    final post = FeedViewPost(
      post: PostView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
        cid: 'cid-xyz',
        author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
        record: FeedPostRecord(text: 'Main post', createdAt: DateTime.utc(2026, 3, 16)).toJson(),
        indexedAt: DateTime.utc(2026, 3, 16),
        embed: UPostViewEmbed.embedRecordView(
          data: EmbedRecordView(
            record: UEmbedRecordViewRecord.embedRecordViewRecord(
              data: EmbedRecordViewRecord(
                uri: AtUri.parse('at://did:plc:quoted/app.bsky.feed.post/quoted123'),
                cid: 'cid-quoted',
                author: const ProfileViewBasic(did: 'did:plc:quoted', handle: 'quoted.bsky.social'),
                value: quotedRecord.toJson(),
                indexedAt: DateTime.utc(2026, 3, 15),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildSubject(post));

    final richText = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Quoted text that should fully expand inside the embed card',
      ),
    );
    final style = (richText.text as TextSpan).style;
    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);

    expect(style?.fontFamily, theme.textTheme.titleSmall?.fontFamily);
    expect(richText.maxLines, isNull);
  });

  testWidgets('renders nested quoted post context up to capped depth', (tester) async {
    final beyondCap = _nestedQuoteEmbed(
      did: 'did:plc:beyond',
      rkey: 'beyond',
      handle: 'beyond.bsky.social',
      text: 'Beyond capped quote',
    );
    final deepest = _nestedQuoteEmbed(
      did: 'did:plc:deepest',
      rkey: 'deepest',
      handle: 'deepest.bsky.social',
      text: 'Deepest visible quote',
      embeds: [beyondCap],
    );
    final second = _nestedQuoteEmbed(
      did: 'did:plc:second',
      rkey: 'second',
      handle: 'second.bsky.social',
      text: 'Second level quote',
      embeds: [deepest],
    );
    final firstRecord = FeedPostRecord(text: 'First level quote', createdAt: DateTime.utc(2026, 3, 15));
    final post = FeedViewPost(
      post: PostView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
        cid: 'cid-xyz',
        author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
        record: FeedPostRecord(text: 'Main post', createdAt: DateTime.utc(2026, 3, 16)).toJson(),
        indexedAt: DateTime.utc(2026, 3, 16),
        embed: UPostViewEmbed.embedRecordView(
          data: EmbedRecordView(
            record: UEmbedRecordViewRecord.embedRecordViewRecord(
              data: EmbedRecordViewRecord(
                uri: AtUri.parse('at://did:plc:first/app.bsky.feed.post/first'),
                cid: 'cid-first',
                author: const ProfileViewBasic(did: 'did:plc:first', handle: 'first.bsky.social', displayName: 'first'),
                value: firstRecord.toJson(),
                embeds: [second],
                indexedAt: DateTime.utc(2026, 3, 15),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildSubject(post));

    expect(find.text('First level quote', findRichText: true), findsOneWidget);
    expect(find.text('Second level quote', findRichText: true), findsOneWidget);
    expect(find.text('Deepest visible quote', findRichText: true), findsOneWidget);
    expect(find.text('Beyond capped quote', findRichText: true), findsNothing);
    expect(find.text('beyond @beyond.bsky.social ...'), findsOneWidget);
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
          path: '/profile/:actor',
          builder: (context, state) {
            pushedRoute = state.uri.toString();
            return const Scaffold(body: Text('profile'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('post_card_avatar')));
    await tester.pumpAndSettle();

    expect(pushedRoute, contains('did%3Aplc%3Atest'));
  });

  testWidgets('uses unique image hero tags across record-with-media and quoted embeds', (tester) async {
    final quotedRecord = FeedPostRecord(text: 'Quoted with image', createdAt: DateTime.utc(2026, 3, 15));
    final post = FeedViewPost(
      post: PostView(
        uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
        cid: 'cid-xyz',
        author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
        record: FeedPostRecord(text: 'Main post with media quote', createdAt: DateTime.utc(2026, 3, 16)).toJson(),
        indexedAt: DateTime.utc(2026, 3, 16),
        embed: UPostViewEmbed.embedRecordWithMediaView(
          data: EmbedRecordWithMediaView(
            media: const UEmbedRecordWithMediaViewMedia.embedImagesView(
              data: EmbedImagesView(
                images: [
                  EmbedImagesViewImage(
                    thumb: 'https://example.com/main-thumb.jpg',
                    fullsize: 'https://example.com/main-full.jpg',
                    alt: 'main image',
                  ),
                ],
              ),
            ),
            record: EmbedRecordView(
              record: UEmbedRecordViewRecord.embedRecordViewRecord(
                data: EmbedRecordViewRecord(
                  uri: AtUri.parse('at://did:plc:quoted/app.bsky.feed.post/quoted123'),
                  cid: 'cid-quoted',
                  author: const ProfileViewBasic(did: 'did:plc:quoted', handle: 'quoted.bsky.social'),
                  value: quotedRecord.toJson(),
                  embeds: [
                    const UEmbedRecordViewRecordEmbeds.embedImagesView(
                      data: EmbedImagesView(
                        images: [
                          EmbedImagesViewImage(
                            thumb: 'https://example.com/quoted-thumb.jpg',
                            fullsize: 'https://example.com/quoted-full.jpg',
                            alt: 'quoted image',
                          ),
                        ],
                      ),
                    ),
                  ],
                  indexedAt: DateTime.utc(2026, 3, 15),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: PostCard(feedViewPost: post)),
        ),
      ),
    );

    final heroTags = tester.widgetList<Hero>(find.byType(Hero)).map((hero) => hero.tag).toList();
    expect(heroTags.length, greaterThanOrEqualTo(2));
    expect(heroTags.toSet().length, heroTags.length);
  });

  testWidgets('renders starter pack record embeds and navigates to detail', (tester) async {
    final packUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack');
    final post = _makePostWithRecordEmbed(
      UEmbedRecordViewRecord.starterPackViewBasic(
        data: bsky_graph.StarterPackViewBasic(
          uri: packUri,
          cid: 'cid-pack',
          record: const {'name': 'Starter Pack Picks', 'description': 'People worth following'},
          creator: const ProfileViewBasic(
            did: 'did:plc:creator',
            handle: 'creator.bsky.social',
            displayName: 'Creator',
          ),
          listItemCount: 12,
          indexedAt: DateTime.utc(2026, 3, 15),
        ),
      ),
    );
    String? pushedRoute;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: PostCard(feedViewPost: post)),
        ),
        GoRoute(
          path: '/starter-pack',
          builder: (context, state) {
            pushedRoute = state.uri.toString();
            return const Scaffold(body: Text('starter pack detail'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('STARTER PACK'), findsOneWidget);
    expect(find.text('Starter Pack Picks'), findsOneWidget);
    expect(find.text('People worth following'), findsOneWidget);
    expect(find.text('12 members'), findsOneWidget);

    await tester.tap(find.text('Starter Pack Picks'));
    await tester.pumpAndSettle();

    expect(pushedRoute, isNotNull);
    expect(Uri.parse(pushedRoute!).path, '/starter-pack');
    expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), packUri.toString());
  });

  testWidgets('renders feed, list, labeler, and unknown record embeds', (tester) async {
    const creator = ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social', displayName: 'Creator');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                PostCard(
                  feedViewPost: _makePostWithRecordEmbed(
                    UEmbedRecordViewRecord.generatorView(
                      data: GeneratorView(
                        uri: AtUri.parse('at://did:plc:creator/app.bsky.feed.generator/feed'),
                        cid: 'cid-feed',
                        did: 'did:web:feed.example',
                        creator: creator,
                        displayName: 'News Feed',
                        description: 'Fresh posts',
                        likeCount: 1200,
                        indexedAt: DateTime.utc(2026, 3, 15),
                      ),
                    ),
                    rkey: 'feed',
                  ),
                ),
                PostCard(
                  feedViewPost: _makePostWithRecordEmbed(
                    UEmbedRecordViewRecord.listView(
                      data: bsky_graph.ListView(
                        uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list'),
                        cid: 'cid-list',
                        creator: creator,
                        name: 'Good Accounts',
                        purpose: const bsky_graph.ListPurpose.knownValue(
                          data: bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist,
                        ),
                        description: 'Useful people',
                        listItemCount: 42,
                        indexedAt: DateTime.utc(2026, 3, 15),
                      ),
                    ),
                    rkey: 'list',
                  ),
                ),
                PostCard(
                  feedViewPost: _makePostWithRecordEmbed(
                    UEmbedRecordViewRecord.labelerView(
                      data: bsky_labeler.LabelerView(
                        uri: AtUri.parse('at://did:plc:labeler/app.bsky.labeler.service/self'),
                        cid: 'cid-labeler',
                        creator: const ProfileView(
                          did: 'did:plc:labeler',
                          handle: 'labeler.bsky.social',
                          displayName: 'Labeler Service',
                        ),
                        likeCount: 7,
                        indexedAt: DateTime.utc(2026, 3, 15),
                      ),
                    ),
                    rkey: 'labeler',
                  ),
                ),
                PostCard(
                  feedViewPost: _makePostWithRecordEmbed(
                    const UEmbedRecordViewRecord.unknown(data: {r'$type': 'app.example.record'}),
                    rkey: 'unknown',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('FEED'), findsOneWidget);
    expect(find.text('News Feed'), findsOneWidget);
    expect(find.text('Fresh posts'), findsOneWidget);
    expect(find.text('1.2K likes'), findsOneWidget);
    expect(find.text('LIST'), findsOneWidget);
    expect(find.text('Good Accounts'), findsOneWidget);
    expect(find.text('42 members'), findsOneWidget);
    expect(find.text('LABELER'), findsOneWidget);
    expect(find.text('Labeler Service'), findsOneWidget);
    expect(find.text('7 likes'), findsOneWidget);
    expect(find.text('UNKNOWN'), findsOneWidget);
    expect(find.text('Quoted post is unavailable'), findsOneWidget);
  });

  testWidgets('feed, list, and labeler record embeds navigate through internal routes', (tester) async {
    const creator = ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social', displayName: 'Creator');
    final feedUri = AtUri.parse('at://did:plc:creator/app.bsky.feed.generator/feed');
    final listUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list');
    String? pushedRoute;

    await _pumpRecordEmbedRouter(
      tester,
      post: _makePostWithRecordEmbed(
        UEmbedRecordViewRecord.generatorView(
          data: GeneratorView(
            uri: feedUri,
            cid: 'cid-feed',
            did: 'did:web:feed.example',
            creator: creator,
            displayName: 'News Feed',
            indexedAt: DateTime.utc(2026, 3, 15),
          ),
        ),
      ),
      routePath: '/feed',
      onRoute: (uri) => pushedRoute = uri.toString(),
    );

    await tester.tap(find.text('News Feed'));
    await tester.pumpAndSettle();

    expect(Uri.parse(pushedRoute!).path, '/feed');
    expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), feedUri.toString());

    pushedRoute = null;
    await _pumpRecordEmbedRouter(
      tester,
      post: _makePostWithRecordEmbed(
        UEmbedRecordViewRecord.listView(
          data: bsky_graph.ListView(
            uri: listUri,
            cid: 'cid-list',
            creator: creator,
            name: 'Good Accounts',
            purpose: const bsky_graph.ListPurpose.knownValue(
              data: bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist,
            ),
            indexedAt: DateTime.utc(2026, 3, 15),
          ),
        ),
      ),
      routePath: '/list',
      onRoute: (uri) => pushedRoute = uri.toString(),
    );

    await tester.tap(find.text('Good Accounts'));
    await tester.pumpAndSettle();

    expect(Uri.parse(pushedRoute!).path, '/list');
    expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), listUri.toString());

    pushedRoute = null;
    await _pumpRecordEmbedRouter(
      tester,
      post: _makePostWithRecordEmbed(
        UEmbedRecordViewRecord.labelerView(
          data: bsky_labeler.LabelerView(
            uri: AtUri.parse('at://did:plc:labeler/app.bsky.labeler.service/self'),
            cid: 'cid-labeler',
            creator: const ProfileView(
              did: 'did:plc:labeler',
              handle: 'labeler.bsky.social',
              displayName: 'Labeler Service',
            ),
            indexedAt: DateTime.utc(2026, 3, 15),
          ),
        ),
      ),
      routePath: '/settings/moderation/detail',
      onRoute: (uri) => pushedRoute = uri.toString(),
    );

    await tester.tap(find.text('Labeler Service'));
    await tester.pumpAndSettle();

    expect(Uri.parse(pushedRoute!).path, '/settings/moderation/detail');
    expect(Uri.parse(pushedRoute!).queryParameters['did'], 'did:plc:labeler');
  });

  testWidgets('renders unknown top-level embed fallback', (tester) async {
    final post = _makePostWithEmbed(const UPostViewEmbed.unknown(data: {r'$type': 'com.example.embed'}));

    await tester.pumpWidget(buildSubject(post));

    expect(find.text('UNKNOWN'), findsOneWidget);
  });
}

FeedViewPost _makePostWithRecordEmbed(UEmbedRecordViewRecord record, {String rkey = 'record'}) => _makePostWithEmbed(
  UPostViewEmbed.embedRecordView(data: EmbedRecordView(record: record)),
  rkey: rkey,
);

FeedViewPost _makePostWithEmbed(UPostViewEmbed embed, {String rkey = 'record'}) => FeedViewPost(
  post: PostView(
    uri: AtUri.parse('at://did:plc:test/app.bsky.feed.post/$rkey'),
    cid: 'cid-$rkey',
    author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
    record: FeedPostRecord(text: 'Main post', createdAt: DateTime.utc(2026, 3, 16)).toJson(),
    indexedAt: DateTime.utc(2026, 3, 16),
    embed: embed,
  ),
);

Future<void> _pumpRecordEmbedRouter(
  WidgetTester tester, {
  required FeedViewPost post,
  required String routePath,
  required ValueChanged<Uri> onRoute,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: PostCard(feedViewPost: post)),
      ),
      GoRoute(
        path: routePath,
        builder: (context, state) {
          onRoute(state.uri);
          return const Scaffold(body: Text('destination'));
        },
      ),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}
