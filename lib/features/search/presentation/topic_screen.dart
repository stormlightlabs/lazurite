import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/feed/presentation/widgets/public_post_card.dart';
import 'package:lazurite/features/search/cubit/topic_cubit.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key, required this.topic, this.publicProviderKey});

  final String topic;
  final String? publicProviderKey;

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenPostUris = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TopicCubit>().initialize();
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
      context.read<TopicCubit>().loadMoreCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        final title = state.displayName?.trim().isNotEmpty == true ? state.displayName! : state.topic;
        return Scaffold(
          appBar: AppBar(title: Text(title.isEmpty ? 'Topic' : title)),
          body: Column(
            children: [
              _buildSortToggle(context, state),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortToggle(BuildContext context, TopicState state) {
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
              children: TopicSort.values
                  .map((sort) {
                    final isSelected = state.currentSort == sort;
                    final labelColor = isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;

                    return GestureDetector(
                      onTap: () => context.read<TopicCubit>().switchSort(sort),
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
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TopicState state) {
    final timeline = state.currentTimeline;
    final publicProviderKey = widget.publicProviderKey;
    final accountDid = publicProviderKey == null ? context.read<AuthBloc>().state.tokens?.did : null;
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
            FilledButton(onPressed: () => context.read<TopicCubit>().refreshCurrent(), child: const Text('Retry')),
          ],
        ),
      );
    }

    if (timeline.posts.isEmpty) {
      return const Center(child: Text('No posts found for this topic.'));
    }

    return AnimatedRefreshIndicator(
      onRefresh: () => context.read<TopicCubit>().refreshCurrent(),
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
          final postUri = post.uri.toString();
          return StaggeredEntrance(
            itemKey: postUri,
            index: index,
            seenKeys: _seenPostUris,
            child: publicProviderKey == null
                ? PostCardWithActions(
                    feedViewPost: FeedViewPost(post: post),
                    accountDid: accountDid,
                  )
                : PublicPostCard(
                    feedViewPost: FeedViewPost(post: post),
                    providerKey: publicProviderKey,
                  ),
          );
        },
      ),
    );
  }
}
