import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/embed/images.dart';
import 'package:bluesky_poptart/app/bsky/embed/record.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:poptart_core/poptart_core.dart';

FeedViewPost _makePost({UFeedViewPostReason? reason, UPostViewEmbed? embed}) {
  final record = FeedPostRecord(text: 'Compact post', createdAt: DateTime.utc(2026, 3, 16));
  return FeedViewPost(
    reason: reason,
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

UFeedViewPostReason _makeRepostReason() {
  return UFeedViewPostReason.reasonRepost(
    data: ReasonRepost(
      by: const ProfileViewBasic(did: 'did:plc:reposter', handle: 'reposter.bsky.social', displayName: 'Reposter'),
      indexedAt: DateTime.utc(2026, 3, 17),
    ),
  );
}

Widget _buildSubject(FeedViewPost post) {
  final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: CompactPostCard(feedViewPost: post)),
  );
}

UPostViewEmbed _quotedPostEmbed({String text = 'Quoted context', List<UEmbedRecordViewRecordEmbeds>? embeds}) {
  return UPostViewEmbed.embedRecordView(
    data: EmbedRecordView(
      record: UEmbedRecordViewRecord.embedRecordViewRecord(
        data: EmbedRecordViewRecord(
          uri: AtUri.parse('at://did:plc:quoted/app.bsky.feed.post/quoted'),
          cid: 'cid-quoted',
          author: const ProfileViewBasic(
            did: 'did:plc:quoted',
            handle: 'quoted.bsky.social',
            displayName: 'Quoted User',
          ),
          value: FeedPostRecord(text: text, createdAt: DateTime.utc(2026, 3, 15)).toJson(),
          embeds: embeds,
          indexedAt: DateTime.utc(2026, 3, 15),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders repost context', (tester) async {
    await tester.pumpWidget(_buildSubject(_makePost(reason: _makeRepostReason())));

    expect(
      find.descendant(of: find.byKey(const ValueKey('post_repost_context')), matching: find.byIcon(Icons.repeat)),
      findsOneWidget,
    );
    expect(find.text('Reposted by'), findsOneWidget);
    expect(find.text('Reposter'), findsOneWidget);
  });

  testWidgets('uses tight shell spacing for compact layout', (tester) async {
    await tester.pumpWidget(_buildSubject(_makePost()));

    final card = tester.widget<Card>(find.byType(Card));
    expect(card.margin, EdgeInsets.zero);

    final contentPadding = find.byWidgetPredicate(
      (widget) => widget is Padding && widget.padding == const EdgeInsets.fromLTRB(12, 10, 12, 10),
    );
    expect(contentPadding, findsOneWidget);

    final avatar = tester.widget<ProfileAvatar>(find.byType(ProfileAvatar).first);
    expect(avatar.size, 36);
  });

  testWidgets('uses serif styling for compact post text', (tester) async {
    await tester.pumpWidget(_buildSubject(_makePost()));

    final richText = tester.widget<RichText>(
      find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText() == 'Compact post'),
    );
    final style = (richText.text as TextSpan).style;
    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);

    expect(style?.fontFamily, theme.textTheme.titleSmall?.fontFamily);
    expect(style?.fontSize, theme.textTheme.bodySmall?.fontSize);
  });

  testWidgets('renders quoted post context in compact layout', (tester) async {
    await tester.pumpWidget(_buildSubject(_makePost(embed: _quotedPostEmbed())));

    final quotedText = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == 'Quoted context',
    );

    expect(find.text('Quoted User'), findsOneWidget);
    expect(find.text('@quoted.bsky.social'), findsOneWidget);
    expect(quotedText, findsOneWidget);

    final richText = tester.widget<RichText>(quotedText);
    final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
    final style = (richText.text as TextSpan).style;
    expect(style?.fontSize, theme.textTheme.bodySmall?.fontSize);
    expect(style?.fontFamily, theme.textTheme.titleSmall?.fontFamily);
    expect(richText.maxLines, 6);
  });

  testWidgets('uses small thumbnails for quoted image media in compact layout', (tester) async {
    await tester.pumpWidget(
      _buildSubject(
        _makePost(
          embed: _quotedPostEmbed(
            embeds: const [
              UEmbedRecordViewRecordEmbeds.embedImagesView(
                data: EmbedImagesView(
                  images: [
                    EmbedImagesViewImage(
                      thumb: 'https://example.com/thumb.jpg',
                      fullsize: 'https://example.com/full.jpg',
                      alt: 'quoted image',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byWidgetPredicate((widget) => widget is SizedBox && widget.height == 88), findsOneWidget);
  });
}
