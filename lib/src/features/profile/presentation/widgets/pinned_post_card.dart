import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/post_interaction_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_actions_row.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_body.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_embeds.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_header.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';

class PinnedPostCard extends ConsumerWidget {
  const PinnedPostCard(this.postUri, {super.key});

  final String postUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final postAsync = ref.watch(pinnedPostProvider(postUri));
    final interaction = ref.watch(postInteractionStateProvider(postUri)).value;

    final logger = ref.watch(loggerProvider('[PinnedPostCard]'));

    return postAsync.when(
      data: (item) {
        logger.info('item: $item');
        if (item == null) return const SizedBox.shrink();

        return Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                const SizedBox(height: 8),
                PostHeader(author: item.author, indexedAt: item.indexedAt, onAvatarTap: () => ()),
                const SizedBox(height: 8),
                PostBody(text: item.text),
                if (item.embed != null && item.record != null) ...[
                  const SizedBox(height: 8),
                  PostEmbeds(embed: item.embed!, authorDid: item.author.did, record: item.record!),
                ],
                const SizedBox(height: 8),
                PostActionsRow(
                  replyCount: item.replyCount,
                  repostCount: item.repostCount,
                  likeCount: item.likeCount,
                  viewerLikeUri: interaction?.likeUri ?? item.viewerLikeUri,
                  viewerRepostUri: interaction?.repostUri ?? item.viewerRepostUri,
                  viewerBookmarked: interaction?.bookmarked ?? item.viewerBookmarked,
                  onReply: () {
                    final encodedUri = Uri.encodeComponent(postUri);
                    GoRouter.of(context).push('/compose?replyTo=$encodedUri');
                  },
                  onRepost: () async {
                    final repo = ref.read(postInteractionRepositoryProvider);
                    final auth = ref.read(authProvider);
                    final ownerDid = (auth is AuthStateAuthenticated) ? auth.session.did : null;
                    if (ownerDid == null) return;

                    final repostUri = interaction?.repostUri ?? item.viewerRepostUri;
                    if (repostUri != null) {
                      await repo.unrepost(postUri, repostUri, ownerDid);
                    } else {
                      await repo.repost(postUri, item.cid, ownerDid);
                    }
                  },
                  onLike: () async {
                    final repo = ref.read(postInteractionRepositoryProvider);
                    final auth = ref.read(authProvider);
                    final ownerDid = (auth is AuthStateAuthenticated) ? auth.session.did : null;
                    if (ownerDid == null) return;

                    final likeUri = interaction?.likeUri ?? item.viewerLikeUri;
                    if (likeUri != null) {
                      await repo.unlike(postUri, likeUri, ownerDid);
                    } else {
                      await repo.like(postUri, item.cid, ownerDid);
                    }
                  },
                  onBookmark: () async {
                    final repo = ref.read(postInteractionRepositoryProvider);
                    final auth = ref.read(authProvider);
                    final ownerDid = (auth is AuthStateAuthenticated) ? auth.session.did : null;
                    if (ownerDid == null) return;

                    final bookmarked = interaction?.bookmarked ?? item.viewerBookmarked;
                    if (bookmarked) {
                      final bookmarkUri = interaction?.bookmarkUri;
                      if (bookmarkUri != null) {
                        await repo.unbookmark(postUri, bookmarkUri, ownerDid);
                      }
                    } else {
                      await repo.bookmark(postUri, item.cid, ownerDid);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
