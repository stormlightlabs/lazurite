import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/feed/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';

FeedViewPost _makePost({UFeedViewPostReason? reason}) {
  final record = FeedPostRecord(text: 'Compact post', createdAt: DateTime.utc(2026, 3, 16));
  return FeedViewPost(
    reason: reason,
    post: PostView(
      uri: const AtUri('at://did:plc:test/app.bsky.feed.post/xyz'),
      cid: 'cid-xyz',
      author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social', displayName: 'Test User'),
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

Widget _buildSubject(FeedViewPost post) {
  final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: CompactPostCard(feedViewPost: post)),
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
}
