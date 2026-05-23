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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth.clamp(260.0, 360.0).toDouble();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: state.posts
                          .map(
                            (post) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: cardWidth,
                                child: CompactPostCard(
                                  feedViewPost: FeedViewPost(post: post),
                                  onTap: () => navigateToPost(context, post.uri.toString()),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  );
                },
              ),
              if (state.hasMore)
                TextButton.icon(
                  onPressed: state.status == SimilarPostsStatus.loadingMore
                      ? null
                      : () => context.read<SimilarPostsCubit>().loadMore(),
                  icon: state.status == SimilarPostsStatus.loadingMore
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.expand_more),
                  label: const Text('Show more'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SimilarPostsShell extends StatelessWidget {
  const _SimilarPostsShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Similar posts', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            'Liked by people who liked this post',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
