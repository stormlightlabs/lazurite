import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/domain/content_label.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/post_interaction_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/content_warning.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_actions_row.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_body.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_embeds.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_header.dart';
import 'package:lazurite/src/features/settings/application/label_filter_provider.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';

/// A post card widget for displaying feed content items.
///
/// Adapts [FeedPost] data to display a rich post card with
/// author info, post text, embeds, and action counts.
class FeedPostCard extends ConsumerWidget {
  const FeedPostCard({
    required this.item,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    super.key,
  });

  final FeedPost item;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterService = ref.watch(labelFilterServiceProvider);
    final interactionAsync = ref.watch(postInteractionStateProvider(item.post.uri));
    final interaction = interactionAsync.value;
    final logger = ref.read(loggerProvider('[FeedPostCard|${item.post.uri}]'));

    Map<String, dynamic>? record;
    try {
      final decoded = jsonDecode(item.post.record);
      if (decoded is Map<String, dynamic>) {
        record = decoded;
      }
    } catch (e) {
      logger.warning('Failed to parse record ${item.post.record}: ${e.toString()}');
    }

    final text = record?['text'] as String? ?? '';
    final createdAt = DateTime.tryParse(item.post.indexedAt?.toIso8601String() ?? '');

    final labels = ContentLabel.parseFromJsonString(item.post.labels);

    final hasWarningLabels = filterService != null
        ? filterService.anyLabelWarns(labels) || filterService.anyLabelHides(labels)
        : labels.any((l) => l.shouldWarn || l.shouldHide);

    Map<String, dynamic>? reasonJson;
    if (item.reason != null) {
      try {
        final decoded = jsonDecode(item.reason!);
        if (decoded is Map<String, dynamic>) {
          reasonJson = decoded;
        }
      } catch (e) {
        logger.warning('Failed to parse reason ${item.reason}: ${e.toString()}');
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
          viewerLikeUri:
              interaction?.likeUri ?? item.interaction?.likeUri ?? item.post.viewerLikeUri,
          viewerRepostUri:
              interaction?.repostUri ?? item.interaction?.repostUri ?? item.post.viewerRepostUri,
          viewerBookmarked:
              interaction?.bookmarked ??
              item.interaction?.bookmarked ??
              item.post.viewerBookmarked,
          onReply: () {
            final encodedUri = Uri.encodeComponent(item.post.uri);
            GoRouter.of(context).push('/compose?replyTo=$encodedUri');
          },
          onRepost: () async {
            final repo = ref.read(postInteractionRepositoryProvider);
            final auth = ref.read(authProvider);
            final ownerDid = (auth is AuthStateAuthenticated) ? auth.session.did : null;
            if (ownerDid == null) return;

            final repostUri = item.interaction?.repostUri ?? item.post.viewerRepostUri;
            if (repostUri != null) {
              await repo.unrepost(item.post.uri, repostUri, ownerDid);
            } else {
              await repo.repost(item.post.uri, item.post.cid, ownerDid);
            }
          },
          onLike: () async {
            final repo = ref.read(postInteractionRepositoryProvider);
            final auth = ref.read(authProvider);
            final ownerDid = (auth is AuthStateAuthenticated) ? auth.session.did : null;
            if (ownerDid == null) return;

            final likeUri = item.interaction?.likeUri ?? item.post.viewerLikeUri;
            if (likeUri != null) {
              await repo.unlike(item.post.uri, likeUri, ownerDid);
            } else {
              await repo.like(item.post.uri, item.post.cid, ownerDid);
            }
          },
          onBookmark: () async {
            final repo = ref.read(postInteractionRepositoryProvider);
            final auth = ref.read(authProvider);
            final ownerDid = (auth is AuthStateAuthenticated) ? auth.session.did : null;
            if (ownerDid == null) return;

            final bookmarked = item.interaction?.bookmarked ?? item.post.viewerBookmarked;
            if (bookmarked) {
              final bookmarkUri = item.interaction?.bookmarkUri;
              if (bookmarkUri != null) {
                await repo.unbookmark(item.post.uri, bookmarkUri, ownerDid);
              }
            } else {
              await repo.bookmark(item.post.uri, item.post.cid, ownerDid);
            }
          },
        ),
      ],
    );

    if (hasWarningLabels) {
      postContent = ContentWarning(
        labels: labels,
        filterService: filterService,
        child: postContent,
      );
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

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: margin,
      elevation: 2,
      child: InkWell(
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
                      Icon(
                        Icons.repeat,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reposted by ${reposter['displayName'] as String? ?? reposter['handle'] as String? ?? 'someone'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}
