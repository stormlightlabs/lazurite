import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../infrastructure/db/daos/timeline_dao.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.item, this.onTap});

  final TimelineFeedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final record = jsonDecode(item.post.record) as Map<String, dynamic>;
    final text = record['text'] as String? ?? '';
    final createdAt = DateTime.tryParse(record['createdAt'] as String? ?? '');

    final reasonJson = item.item.reason != null
        ? jsonDecode(item.item.reason!) as Map<String, dynamic>
        : null;
    final isRepost =
        reasonJson != null && reasonJson[r'$type'] == 'app.bsky.feed.defs#reasonRepost';
    final reposter = isRepost ? reasonJson['by'] as Map<String, dynamic>? : null;

    return InkWell(
      onTap: onTap,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  /// TODO: Navigate to profile
                  onTap: () {
                    return;
                  },
                  child: Avatar(imageUrl: item.author.avatar, radius: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.author.displayName ?? item.author.handle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '@${item.author.handle}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '• ${_formatTime(createdAt)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(text, style: const TextStyle(fontSize: 15)),
                      // TODO: Embeds
                      // TODO: Actions
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          Icon(Icons.repeat, size: 18, color: AppColors.textSecondary),
                          Icon(Icons.favorite_border, size: 18, color: AppColors.textSecondary),
                          Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
