import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';

import 'post_actions_row.dart';
import 'post_body.dart';
import 'post_embeds.dart';
import 'post_header.dart';

class PostCard extends StatelessWidget {
  const PostCard({required this.item, this.onTap, super.key});

  final TimelineFeedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final record = jsonDecode(item.post.record) as Map<String, dynamic>;
    final text = record['text'] as String? ?? '';
    final createdAt = DateTime.tryParse(item.post.indexedAt?.toIso8601String() ?? '');

    final reasonJson = item.item.reason != null
        ? jsonDecode(item.item.reason!) as Map<String, dynamic>
        : null;
    final isRepost =
        reasonJson != null && reasonJson[r'$type'] == 'app.bsky.feed.defs#reasonRepost';
    final reposter = isRepost ? reasonJson['by'] as Map<String, dynamic>? : null;

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
                      'Reposted by ${reposter['displayName'] ?? reposter['handle']}',
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
            Padding(
              padding: const EdgeInsets.only(left: 52.0),
              child: Column(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
