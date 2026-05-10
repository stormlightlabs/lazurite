import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/embed/external.dart';
import 'package:poptart_lex/app/bsky/embed/images.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/feed/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/presentation/widgets/grid_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';

FeedViewPost _makePost({String text = 'Hello', UPostViewEmbed? embed}) {
  final record = FeedPostRecord(text: text, createdAt: DateTime.utc(2026, 3, 16));
  return FeedViewPost(
    post: PostView(
      uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
      cid: 'cid-xyz',
      author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social', displayName: 'Test User'),
      record: record.toJson(),
      indexedAt: DateTime.utc(2026, 3, 16),
      embed: embed,
    ),
  );
}

Widget _buildSubject(FeedViewPost post, {VoidCallback? onTap, Size size = const Size(390, 844)}) {
  final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
  return MaterialApp(
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(
        body: SingleChildScrollView(
          child: GridPostCard(feedViewPost: post, onTap: onTap),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders author handle uppercase', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(_buildSubject(post));

    expect(find.text('@TEST.BSKY.SOCIAL'), findsOneWidget);
  });

  testWidgets('renders author display name', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(_buildSubject(post));

    expect(find.text('Test User'), findsOneWidget);
  });

  testWidgets('renders body text', (tester) async {
    final post = _makePost(text: 'Short post text');
    await tester.pumpWidget(_buildSubject(post));

    final richTextFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().contains('Short post text'),
    );
    expect(richTextFinder, findsOneWidget);
  });

  testWidgets('renders PostCardFooter', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(_buildSubject(post));

    expect(find.byType(PostCardFooter), findsOneWidget);
  });

  testWidgets('calls onTap when card tapped', (tester) async {
    var tapped = false;
    final post = _makePost();

    await tester.pumpWidget(_buildSubject(post, onTap: () => tapped = true));

    await tester.tap(find.text('@TEST.BSKY.SOCIAL'));
    expect(tapped, isTrue);
  });

  testWidgets('tapping footer reply does not trigger card onTap', (tester) async {
    var cardTapped = false;
    var replyTapped = false;
    final post = _makePost();

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: GridPostCard(
                feedViewPost: post,
                onTap: () => cardTapped = true,
                footer: PostCardFooter(timestamp: '1H', onReply: () => replyTapped = true),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pump();

    expect(replyTapped, isTrue);
    expect(cardTapped, isFalse);
  });

  testWidgets('text-only posts have no image AspectRatio', (tester) async {
    final post = _makePost(text: 'Text-only post content');
    await tester.pumpWidget(_buildSubject(post));

    expect(find.byType(AspectRatio), findsNothing);

    final richTextFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().contains('Text-only post content'),
    );
    expect(richTextFinder, findsOneWidget);
  });

  testWidgets('renders image region for posts with images', (tester) async {
    final post = _makePost(
      embed: const UPostViewEmbed.embedImagesView(
        data: EmbedImagesView(
          images: [
            EmbedImagesViewImage(
              thumb: 'https://example.com/thumb.jpg',
              fullsize: 'https://example.com/full.jpg',
              alt: '',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(_buildSubject(post));

    expect(find.byType(AspectRatio), findsOneWidget);
    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('caps non-image embed previews inside grid cards', (tester) async {
    final post = _makePost(
      text: 'Read this',
      embed: const UPostViewEmbed.embedExternalView(
        data: EmbedExternalView(
          external: EmbedExternalViewExternal(
            uri: 'https://example.com/article',
            title: 'Example Article',
            description: 'A useful external card',
          ),
        ),
      ),
    );

    await tester.pumpWidget(_buildSubject(post));

    expect(find.text('Example Article'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is SizedBox && widget.height == 240), findsNothing);
  });

  testWidgets('keeps capped embed previews on wider compact grid layouts', (tester) async {
    final post = _makePost(
      text: 'Read this',
      embed: const UPostViewEmbed.embedExternalView(
        data: EmbedExternalView(
          external: EmbedExternalViewExternal(
            uri: 'https://example.com/article',
            title: 'Example Article',
            description: 'A useful external card',
          ),
        ),
      ),
    );

    await tester.pumpWidget(_buildSubject(post, size: const Size(900, 1200)));

    expect(find.byWidgetPredicate((widget) => widget is SizedBox && widget.height == 240), findsOneWidget);
  });

  testWidgets('uses themed serif styling for embed-bearing posts on phone widths', (tester) async {
    final post = _makePost(
      text: 'Serif body copy with an external preview',
      embed: const UPostViewEmbed.embedExternalView(
        data: EmbedExternalView(
          external: EmbedExternalViewExternal(
            uri: 'https://example.com/article',
            title: 'Example Article',
            description: 'A useful external card',
          ),
        ),
      ),
    );

    await tester.pumpWidget(_buildSubject(post));

    final richText = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == 'Serif body copy with an external preview',
      ),
    );
    final style = (richText.text as TextSpan).style;
    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);

    expect(style?.fontFamily, theme.textTheme.titleMedium?.fontFamily);
    expect(style?.color, theme.colorScheme.onSurface);
    expect(richText.maxLines, isNull);
  });

  testWidgets('uses square container for avatar — no CircleAvatar', (tester) async {
    final post = _makePost();
    await tester.pumpWidget(_buildSubject(post));

    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('tapping avatar navigates to author profile', (tester) async {
    final post = _makePost();
    String? pushedRoute;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: SingleChildScrollView(child: GridPostCard(feedViewPost: post)),
          ),
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

    await tester.tap(find.byKey(const ValueKey('grid_post_card_avatar')));
    await tester.pumpAndSettle();

    expect(pushedRoute, contains('did%3Aplc%3Atest'));
  });

  testWidgets('accepts custom footer widget', (tester) async {
    const customFooter = SizedBox(key: Key('custom_footer'), height: 30);
    final post = _makePost();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GridPostCard(feedViewPost: post, footer: customFooter),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('custom_footer')), findsOneWidget);
    expect(find.byType(PostCardFooter), findsNothing);
  });
}
