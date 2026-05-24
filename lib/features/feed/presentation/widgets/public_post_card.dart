import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_web_links.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/grid_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/public/presentation/public_navigation.dart';
import 'package:lazurite/shared/presentation/helpers/share_helper.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:lazurite/shared/utils/parse_utils.dart';

class PublicPostCard extends StatelessWidget {
  const PublicPostCard({
    super.key,
    required this.feedViewPost,
    required this.providerKey,
    this.variant = PostCardVariant.adaptive,
  });

  final FeedViewPost feedViewPost;
  final String providerKey;
  final PostCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final resolvedVariant = variant == PostCardVariant.adaptive ? PostCardVariant.card : variant;
    final footer = PublicPostCardFooter(feedViewPost: feedViewPost, providerKey: providerKey);

    Future<void> onTap() async {
      await context.push('/post?uri=${Uri.encodeQueryComponent(feedViewPost.post.uri.toString())}&provider=$providerKey');
    }

    final card = switch (resolvedVariant) {
      PostCardVariant.grid => GridPostCard(feedViewPost: feedViewPost, footer: footer, onTap: onTap),
      PostCardVariant.compact => CompactPostCard(feedViewPost: feedViewPost, footer: footer, onTap: onTap),
      _ => PostCard(feedViewPost: feedViewPost, actionBar: footer, onTap: onTap),
    };

    return PublicProviderScope(providerKey: providerKey, child: card);
  }
}

class PublicPostCardFooter extends StatelessWidget {
  const PublicPostCardFooter({super.key, required this.feedViewPost, required this.providerKey});

  final FeedViewPost feedViewPost;
  final String providerKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final post = feedViewPost.post;
    final record = tryParseRecord(post.record);
    final timestamp = formatPostTime(record?.createdAt ?? post.indexedAt, nowLabel: context.l10n.labelNow);

    return Container(
      key: const ValueKey('public_post_card_footer'),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 280;
          final metrics = Wrap(
            spacing: compact ? 4 : 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _PublicMetric(icon: Icons.chat_bubble_outline, count: post.replyCount ?? 0, label: 'Replies'),
              _PublicMetric(icon: Icons.repeat, count: post.repostCount ?? 0, label: 'Reposts'),
              _PublicMetric(icon: Icons.favorite_outline, count: post.likeCount ?? 0, label: 'Likes'),
            ],
          );
          final trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timestamp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('public_post_card_share_button'),
                tooltip: 'Share post',
                icon: const Icon(Icons.ios_share_outlined),
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                onPressed: () => ShareHelper.shareText(
                  context,
                  AppViewWebLinks.postFromAtUri(post.uri.toString(), appViewProvider: providerKey),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                metrics,
                const SizedBox(height: 2),
                Align(alignment: Alignment.centerRight, child: trailing),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: metrics),
              trailing,
            ],
          );
        },
      ),
    );
  }
}

class _PublicMetric extends StatelessWidget {
  const _PublicMetric({required this.icon, required this.count, required this.label});

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.onSurfaceVariant;
    return Semantics(
      label: '$label ${formatCount(count)}',
      button: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(formatCount(count), style: context.textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
