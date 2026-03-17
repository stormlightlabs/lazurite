import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:share_plus/share_plus.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key, required this.accountDid});

  final String accountDid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SavedPostsCubit(database: context.read<AppDatabase>(), accountDid: accountDid)..loadSavedPosts(),
      child: const _SavedPostsContent(),
    );
  }
}

class _SavedPostsContent extends StatelessWidget {
  const _SavedPostsContent();

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
      ),
      body: BlocBuilder<SavedPostsCubit, SavedPostsState>(
        builder: (context, state) {
          if (state.status == SavedPostsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SavedPostsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.error ?? 'Failed to load saved posts'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<SavedPostsCubit>().loadSavedPosts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.savedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No saved posts',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posts you save will appear here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SavedPostsCubit>().loadSavedPosts(),
            child: ListView.builder(
              itemCount: state.savedPosts.length,
              itemBuilder: (context, index) {
                final savedPost = state.savedPosts[index];
                return _SavedPostCard(
                  savedPost: savedPost,
                  onUnsave: () => context.read<SavedPostsCubit>().unsavePostById(savedPost.id),
                );
              },
            ),
          );
        },
      ),
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
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _SavedPostCard extends StatelessWidget {
  const _SavedPostCard({required this.savedPost, required this.onUnsave});

  final SavedPostEntry savedPost;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(savedPost.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      onDismissed: (_) => onUnsave(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Saved Post'),
          subtitle: Text('Saved on ${_formatDate(savedPost.savedAt)}', style: Theme.of(context).textTheme.bodySmall),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _openPost(context),
                tooltip: 'Open post',
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _sharePost(context),
                tooltip: 'Share',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmUnsave(context),
                tooltip: 'Remove',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPost(BuildContext context) => context.push('/post/${Uri.encodeComponent(savedPost.postUri)}');

  void _sharePost(BuildContext context) {
    final bskyUrl = _convertAtUriToBskyUrl(savedPost.postUri);
    Share.share(bskyUrl);
  }

  void _confirmUnsave(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Saved Post?'),
        content: const Text('This will remove the post from your saved list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onUnsave();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
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
