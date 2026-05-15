import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';
import 'package:lazurite/features/search/cubit/hashtag_cubit.dart';
import 'package:lazurite/features/search/data/hashtag_utils.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

class HashtagScreen extends StatefulWidget {
  const HashtagScreen({super.key, required this.tag});

  final String tag;

  @override
  State<HashtagScreen> createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenPostUris = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HashtagCubit>().initialize();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<HashtagCubit>().loadMoreCurrent();
    }
  }

  void _onSortChanged(HashtagSort sort) {
    context.read<HashtagCubit>().switchSort(sort);
  }

  void _openHashtagJumpSheet(HashtagState state) {
    final inputController = TextEditingController();
    final suggestions = extractRelatedHashtags(state.currentTimeline.posts, currentTag: state.tag);

    Future<void> jumpToTag(String rawTag) async {
      final normalized = normalizeHashtag(rawTag);
      if (normalized.isEmpty) {
        return;
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      context.go('/hashtag?tag=${Uri.encodeQueryComponent(normalized)}');
    }

    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jump to hashtag', style: sheetContext.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: inputController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Hashtag',
                  hintText: 'atproto',
                  prefixText: '#',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: jumpToTag,
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Related', style: sheetContext.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in suggestions) ActionChip(label: Text('#$tag'), onPressed: () => jumpToTag(tag)),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(sheetContext).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => jumpToTag(inputController.text), child: const Text('Open')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tag.isEmpty ? 'Hashtag' : '#${widget.tag}')),
      floatingActionButton: BlocBuilder<HashtagCubit, HashtagState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: state.isMissingTag ? null : () => _openHashtagJumpSheet(state),
            icon: const Icon(Icons.tag),
            label: const Text('Jump to hashtag'),
          ).animateIfAllowed(
            context,
            effects: const [
              FadeEffect(duration: Anim.feedItem, curve: Anim.enter),
              ScaleEffect(begin: Offset(0, 0), end: Offset(1, 1), duration: Anim.feedItem, curve: Anim.emphasis),
            ],
          );
        },
      ),
      body: widget.tag.isEmpty
          ? const Center(child: Text('Missing hashtag.'))
          : BlocBuilder<HashtagCubit, HashtagState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildSortToggle(context, state),
                    Expanded(child: _buildBody(context, state)),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSortToggle(BuildContext context, HashtagState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text(
            'Sort by',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortOption(context, HashtagSort.top, state),
                _buildSortOption(context, HashtagSort.latest, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, HashtagSort sort, HashtagState state) {
    final isSelected = state.currentSort == sort;
    final theme = Theme.of(context);
    final labelColor = isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => _onSortChanged(sort),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          sort.label,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: labelColor),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HashtagState state) {
    final timeline = state.currentTimeline;

    if (timeline.isLoading && timeline.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (timeline.hasError && timeline.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(timeline.errorMessage ?? 'Failed to load posts.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => context.read<HashtagCubit>().refreshCurrent(), child: const Text('Retry')),
          ],
        ),
      );
    }

    if (timeline.posts.isEmpty) {
      return Center(child: Text('No posts found for #${state.tag}.'));
    }

    return AnimatedRefreshIndicator(
      onRefresh: () => context.read<HashtagCubit>().refreshCurrent(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: timeline.posts.length + (timeline.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == timeline.posts.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            );
          }
          final post = timeline.posts[index];
          return StaggeredEntrance(
            itemKey: post.uri.toString(),
            index: index,
            seenKeys: _seenPostUris,
            child: CompactPostCard(
              feedViewPost: FeedViewPost(post: post),
              onTap: () => context.push('/post?uri=${Uri.encodeQueryComponent(post.uri.toString())}'),
              footer: PostCardFooter(
                timestamp: formatPostTime(post.indexedAt),
                replyCount: post.replyCount ?? 0,
                repostCount: post.repostCount ?? 0,
                likeCount: post.likeCount ?? 0,
                showCounts: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
