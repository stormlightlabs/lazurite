import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/features/search/cubit/hashtag_cubit.dart';
import 'package:lazurite/features/search/data/hashtag_utils.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class HashtagScreen extends StatefulWidget {
  const HashtagScreen({super.key, required this.tag});

  final String tag;

  @override
  State<HashtagScreen> createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> {
  final ScrollController _scrollController = ScrollController();

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
              Text('Jump to hashtag', style: Theme.of(sheetContext).textTheme.titleMedium),
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
                Text('Related', style: Theme.of(sheetContext).textTheme.titleSmall),
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

    return RefreshIndicator(
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
          return _HashtagPostCard(post: timeline.posts[index]);
        },
      ),
    );
  }
}

class _HashtagPostCard extends StatelessWidget {
  const _HashtagPostCard({required this.post});

  final PostView post;

  @override
  Widget build(BuildContext context) {
    final record = _tryParseRecord(post.record);
    final createdAt = record?.createdAt ?? post.indexedAt;
    final moderationService = maybeModerationService(context);
    final postUi =
        moderationService?.postUi(post, bsky_moderation.ModerationBehaviorContext.contentList) ??
        const bsky_moderation.ModerationUI();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: ModeratedBlurOverlay(
        ui: postUi,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, post.author, createdAt),
              if (postUi.alert || postUi.inform) ...[const SizedBox(height: 10), ModerationBadgeRow(ui: postUi)],
              if (record != null && record.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                FacetText(text: record.text, facets: record.facets, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 12),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileViewBasic author, DateTime createdAt) {
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileBasicUi(author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return InkWell(
      onTap: () => _navigateToProfile(context, author.did),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModeratedAvatar(
            size: 44,
            ui: avatarUi,
            imageUrl: author.avatar,
            initials: formatInitials(author.displayName ?? author.handle),
            shape: BoxShape.circle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.displayName ?? author.handle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${author.handle} · ${formatRelativeTime(createdAt)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(context, Icons.chat_bubble_outline, '${post.replyCount ?? 0}'),
        _buildActionButton(context, Icons.repeat, '${post.repostCount ?? 0}'),
        _buildActionButton(context, Icons.favorite_border, '${post.likeCount ?? 0}'),
        _buildActionButton(context, Icons.share_outlined, ''),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String count) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(count, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor)),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String did) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('/profile/view?actor=${Uri.encodeQueryComponent(did)}');
    }
  }

  FeedPostRecord? _tryParseRecord(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record);
    } catch (_) {
      return null;
    }
  }
}
