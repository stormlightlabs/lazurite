import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/cubit/similar_posts_cubit.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';

/// Opt-in section that shows posts related through shared public likes.
///
/// The section is intentionally collapsed until the user asks for it. That makes
/// the data flow visible to the user and prevents every thread open from paying
/// the Constellation/AppView cost. Once expanded, [SimilarPostsCubit] owns the
/// network flow and this widget only renders states.
const double _similarPostCardHeight = 220;
const Key similarPostCardScrollKey = Key('similar-post-card-scroll');

class SimilarPostsSection extends StatelessWidget {
  const SimilarPostsSection({super.key, required this.postUri});

  final String postUri;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimilarPostsCubit, SimilarPostsState>(
      builder: (context, state) {
        if (state.status == SimilarPostsStatus.idle) {
          return _SimilarPostsShell(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => context.read<SimilarPostsCubit>().load(postUri),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Show similar posts'),
              ),
            ),
          );
        }

        if (state.status == SimilarPostsStatus.loading) {
          return const _SimilarPostsShell(child: LinearProgressIndicator());
        }

        if (state.status == SimilarPostsStatus.error) {
          return _SimilarPostsShell(
            child: Row(
              children: [
                Expanded(child: Text(state.error ?? 'Similar posts are unavailable.')),
                TextButton(
                  onPressed: () => context.read<SimilarPostsCubit>().load(postUri),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.posts.isEmpty) {
          return const _SimilarPostsShell(child: Text('No similar posts found yet.'));
        }

        return _SimilarPostsShell(
          trailing: state.hasMore
              ? TextButton.icon(
                  onPressed: state.status == SimilarPostsStatus.loadingMore
                      ? null
                      : () => context.read<SimilarPostsCubit>().loadMore(),
                  icon: state.status == SimilarPostsStatus.loadingMore
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.expand_more),
                  label: const Text('Show more'),
                )
              : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth.clamp(272.0, 372.0).toDouble();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.posts
                      .map(
                        (post) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: cardWidth,
                            height: _similarPostCardHeight,
                            child: ClipRect(
                              child: SingleChildScrollView(
                                key: similarPostCardScrollKey,
                                primary: false,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minHeight: _similarPostCardHeight),
                                  child: CompactPostCard(
                                    feedViewPost: FeedViewPost(post: post),
                                    contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                    onTap: () => navigateToPost(context, post.uri.toString()),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SimilarPostsShell extends StatelessWidget {
  const _SimilarPostsShell({required this.child, this.trailing});

  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Similar posts', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'Liked by people who liked this post',
                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (trailing != null) Padding(padding: const EdgeInsetsDirectional.only(start: 12), child: trailing!),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
