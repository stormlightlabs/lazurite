import 'dart:convert';
import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/search/presentation/semantic_search_tab.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';
import 'package:share_plus/share_plus.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key, required this.accountDid});

  final String accountDid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedPostsCubit(
        database: context.read<AppDatabase>(),
        accountDid: accountDid,
        postActionRepository: context.read<PostActionRepository>(),
      )..loadSavedPosts(),
      child: const _SavedPostsContent(),
    );
  }
}

class _SavedPostsContent extends StatefulWidget {
  const _SavedPostsContent();

  @override
  State<_SavedPostsContent> createState() => _SavedPostsContentState();
}

class _SavedPostsContentState extends State<_SavedPostsContent> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
        actions: [
          BlocBuilder<SavedPostsCubit, SavedPostsState>(
            builder: (context, state) {
              if (state.savedPosts.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _confirmClearAll(context),
                tooltip: 'Clear all saved posts',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Saved'),
            Tab(text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: const [_AllSavedTab(), SemanticSearchTab()]),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Saved Posts?'),
        content: const Text('This will remove all your saved posts. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SavedPostsCubit>().clearAllSaved();
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _AllSavedTab extends StatefulWidget {
  const _AllSavedTab();

  @override
  State<_AllSavedTab> createState() => _AllSavedTabState();
}

class _AllSavedTabState extends State<_AllSavedTab> {
  final Set<String> _seenPostUris = <String>{};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedPostsCubit, SavedPostsState>(
      builder: (context, state) {
        if (state.status == SavedPostsStatus.loading) {
          return const LoadingState();
        }

        if (state.status == SavedPostsStatus.error) {
          return ErrorState(
            title: 'Failed to load saved posts',
            message: state.error ?? 'Unknown error',
            onRetry: () => context.read<SavedPostsCubit>().loadSavedPosts(),
          );
        }

        if (state.savedPosts.isEmpty) {
          return const EmptyState(
            message: 'No saved posts',
            subtitle: 'Posts you save will appear here',
            icon: Icons.bookmark_outline,
          );
        }

        return AnimatedRefreshIndicator(
          onRefresh: () => context.read<SavedPostsCubit>().loadSavedPosts(),
          child: ListView.builder(
            itemCount: state.savedPosts.length,
            itemBuilder: (context, index) {
              final savedPost = state.savedPosts[index];
              return StaggeredEntrance(
                itemKey: savedPost.postUri,
                index: index,
                seenKeys: _seenPostUris,
                child: _SavedPostCard(
                  savedPost: savedPost,
                  onUnsave: () => context.read<SavedPostsCubit>().unsavePostById(savedPost.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SavedPostCard extends StatelessWidget {
  const _SavedPostCard({required this.savedPost, required this.onUnsave});

  final SavedPostEntry savedPost;
  final VoidCallback onUnsave;

  FeedViewPost? _deserializePost() {
    try {
      final json = jsonDecode(savedPost.postJson) as Map<String, dynamic>;
      return FeedViewPost(post: PostView.fromJson(json));
    } catch (e) {
      log.e('Failed to deserialize saved post', error: e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedViewPost = _deserializePost();
    final accountDid = context.read<String>();

    return Dismissible(
      key: ValueKey(savedPost.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: context.colorScheme.error,
        child: Icon(Icons.bookmark_remove, color: context.colorScheme.onError),
      ),
      onDismissed: (_) => onUnsave(),
      child: feedViewPost != null
          ? PostCardWithActions(feedViewPost: feedViewPost, accountDid: accountDid)
          : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.bookmark),
        title: const Text('Saved Post'),
        subtitle: Text('Saved on ${_formatDate(savedPost.savedAt)}', style: context.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => context.push('/post?uri=${Uri.encodeQueryComponent(savedPost.postUri)}'),
              tooltip: 'Open post',
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share(_convertAtUriToBskyUrl(savedPost.postUri)),
              tooltip: 'Share',
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onUnsave, tooltip: 'Remove'),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _convertAtUriToBskyUrl(String atUri) {
    try {
      final uri = Uri.parse(atUri);
      final parts = uri.pathSegments;
      if (parts.length >= 2) {
        final did = uri.host;
        final rkey = parts.last;
        return 'https://bsky.app/profile/$did/post/$rkey';
      }
    } catch (_) {
      log.d('failed to convert atUri to bskyUrl');
    }
    return atUri;
  }
}
