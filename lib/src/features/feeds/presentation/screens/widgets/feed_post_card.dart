import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/core/domain/content_label.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/content_warning.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_actions_row.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_body.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_embeds.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_header.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';

/// A post card widget for displaying feed content items.
///
/// Adapts [FeedPost] data to display a rich post card with
/// author info, post text, embeds, and action counts.
class FeedPostCard extends StatelessWidget {
  const FeedPostCard({required this.item, this.onTap, super.key});

  final FeedPost item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? record;
    try {
      final decoded = jsonDecode(item.post.record);
      if (decoded is Map<String, dynamic>) {
        record = decoded;
      }
    } catch (_) {
      /* Invalid JSON, use empty record */
    }
    final text = record?['text'] as String? ?? '';
    final createdAt = DateTime.tryParse(item.post.indexedAt?.toIso8601String() ?? '');

    final labels = ContentLabel.parseFromJsonString(item.post.labels);
    final hasWarningLabels = labels.any((l) => l.shouldWarn || l.shouldHide);

    Map<String, dynamic>? reasonJson;
    if (item.reason != null) {
      try {
        final decoded = jsonDecode(item.reason!);
        if (decoded is Map<String, dynamic>) {
          reasonJson = decoded;
        }
      } catch (_) {
        /* Invalid JSON, skip reason */
      }
    }

    final isRepost =
        reasonJson != null && reasonJson[r'$type'] == 'app.bsky.feed.defs#reasonRepost';

    Map<String, dynamic>? reposter;
    if (isRepost) {
      final byJson = reasonJson['by'];
      if (byJson is Map<String, dynamic>) {
        reposter = byJson;
      }
    }

    Widget postContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostBody(text: text),
        if (item.post.embed != null) ...[
          const SizedBox(height: 8),
          PostEmbeds(
            embed: jsonDecode(item.post.embed!) as Map<String, dynamic>,
            authorDid: item.author.did,
            record: jsonDecode(item.post.record) as Map<String, dynamic>,
          ),
        ],
        const SizedBox(height: 12),
        PostActionsRow(
          replyCount: item.post.replyCount,
          repostCount: item.post.repostCount,
          likeCount: item.post.likeCount,
        ),
      ],
    );

    if (hasWarningLabels) {
      postContent = ContentWarning(labels: labels, child: postContent);
    } else if (labels.isNotEmpty) {
      postContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelChips(labels: labels),
          const SizedBox(height: 8),
          postContent,
        ],
      );
    }

    return InkWell(
      onTap:
          onTap ??
          () {
            final encodedUri = Uri.encodeComponent(item.post.uri);
            GoRouter.of(context).push('/home/t/$encodedUri');
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRepost && reposter != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 28.0),
                child: Row(
                  children: [
                    const Icon(Icons.repeat, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Reposted by ${reposter['displayName'] as String? ?? reposter['handle'] as String? ?? 'someone'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            PostHeader(
              author: item.author,
              indexedAt: createdAt,
              onAvatarTap: () {
                final encodedDid = Uri.encodeComponent(item.author.did);
                GoRouter.of(context).push('/home/u/$encodedDid');
              },
            ),
            Padding(padding: const EdgeInsets.only(left: 52.0), child: postContent),
          ],
        ),
      ),
    );
  }
}
