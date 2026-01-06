import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_actions_row.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_body.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_embeds.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_header.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

class PinnedPostCard extends ConsumerWidget {
  const PinnedPostCard(this.postUri, {super.key});

  final String postUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final postAsync = ref.watch(pinnedPostProvider(postUri));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.push_pin, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Pinned Post',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        postAsync.when(
          data: (item) {
            if (item == null) return const SizedBox.shrink();

            final author = Profile(
              did: item.authorDid,
              handle: item.authorHandle,
              displayName: item.authorDisplayName,
              avatar: item.authorAvatar,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostHeader(author: author, indexedAt: item.indexedAt, onAvatarTap: () => ()),
                  const SizedBox(height: 8),
                  PostBody(text: item.text),
                  if (item.embed != null && item.record != null) ...[
                    const SizedBox(height: 8),
                    PostEmbeds(
                      embed: item.embed!,
                      authorDid: item.authorDid,
                      record: item.record!,
                    ),
                  ],
                  const SizedBox(height: 8),
                  PostActionsRow(
                    replyCount: item.replyCount,
                    repostCount: item.repostCount,
                    likeCount: item.likeCount,
                    viewerLikeUri: item.viewerLikeUri,
                    viewerRepostUri: item.viewerRepostUri,
                    viewerBookmarked: item.viewerBookmarked,
                  ),
                ],
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
