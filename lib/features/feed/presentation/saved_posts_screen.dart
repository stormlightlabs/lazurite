import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_web_links.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/liked_posts_repository.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/search/presentation/semantic_search_tab.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/shared/presentation/helpers/share_helper.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

enum SavedPostsInitialTab { bookmarks, liked, search }

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key, required this.accountDid, this.initialTab = SavedPostsInitialTab.bookmarks});

  final String accountDid;
  final SavedPostsInitialTab initialTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedPostsCubit(
        database: context.read<AppDatabase>(),
        accountDid: accountDid,
        postActionRepository: context.read<PostActionRepository>(),
      )..loadSavedPosts(),
      child: _SavedPostsContent(initialTab: initialTab),
    );
  }
}

class _SavedPostsContent extends StatefulWidget {
  const _SavedPostsContent({required this.initialTab});

  final SavedPostsInitialTab initialTab;

  @override
  State<_SavedPostsContent> createState() => _SavedPostsContentState();
}

class _SavedPostsContentState extends State<_SavedPostsContent> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab.index);
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
        title: const Text('Bookmarks & Likes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bookmarks'),
            Tab(text: 'Liked'),
            Tab(text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_AllSavedTab(), _LikedPostsTab(), SemanticSearchTab()],
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
  final Set<String> _seenLocalPostUris = <String>{};
  final Set<String> _seenCloudPostUris = <String>{};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedPostsCubit, SavedPostsState>(
      builder: (context, state) {
        if (state.status == SavedPostsStatus.loading) {
          return const LoadingState();
        }

        if (state.status == SavedPostsStatus.error) {
          return ErrorState(
            title: 'Failed to load bookmarks',
            message: state.error ?? 'Unknown error',
            onRetry: () => context.read<SavedPostsCubit>().loadSavedPosts(),
          );
        }

        final localPosts = state.savedPosts
            .where((p) => p.saveType == 'local' || p.saveType == 'both')
            .toList(growable: false);
        final cloudPosts = state.savedPosts
            .where((p) => p.saveType == 'cloud' || p.saveType == 'both')
            .toList(growable: false);

        if (localPosts.isEmpty && cloudPosts.isEmpty) {
          return const EmptyState(
            message: 'No bookmarks',
            subtitle: 'Posts you bookmark will appear here',
            icon: Icons.bookmark_outline,
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          Tab(text: 'Local'),
                          Tab(text: 'Bluesky'),
                        ],
                      ),
                    ),
                    if (localPosts.isNotEmpty)
                      PopupMenuButton<_BookmarksMenuAction>(
                        tooltip: 'Bookmark actions',
                        onSelected: (action) {
                          if (action == _BookmarksMenuAction.clearLocal) {
                            _confirmClearLocal(context);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _BookmarksMenuAction.clearLocal,
                            child: ListTile(
                              leading: Icon(Icons.delete_sweep_outlined),
                              title: Text('Clear local bookmarks'),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBookmarksList(
                      posts: localPosts,
                      seenKeys: _seenLocalPostUris,
                      onRefresh: () => context.read<SavedPostsCubit>().loadSavedPosts(),
                    ),
                    _buildBookmarksList(
                      posts: cloudPosts,
                      seenKeys: _seenCloudPostUris,
                      onRefresh: () => context.read<SavedPostsCubit>().loadSavedPosts(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookmarksList({
    required List<SavedPostEntry> posts,
    required Set<String> seenKeys,
    required Future<void> Function() onRefresh,
  }) {
    if (posts.isEmpty) {
      return AnimatedRefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            EmptyState(
              message: 'No bookmarks in this source',
              subtitle: 'Try switching tabs or saving posts to this source',
              icon: Icons.bookmark_border,
            ),
          ],
        ),
      );
    }

    return AnimatedRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final savedPost = posts[index];
          return StaggeredEntrance(
            itemKey: '${savedPost.postUri}-${savedPost.saveType}',
            index: index,
            seenKeys: seenKeys,
            child: _SavedPostCard(
              savedPost: savedPost,
              onUnsave: () => context.read<SavedPostsCubit>().unsavePostById(savedPost.id),
            ),
          );
        },
      ),
    );
  }

  void _confirmClearLocal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear local bookmarks?'),
        content: const Text(
          'This removes only local bookmarks from this device. Bluesky cloud bookmarks will not be deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SavedPostsCubit>().clearLocalSaved();
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            child: const Text('Clear Local'),
          ),
        ],
      ),
    );
  }
}

enum _BookmarksMenuAction { clearLocal }

class _LikedPostsTab extends StatefulWidget {
  const _LikedPostsTab();

  @override
  State<_LikedPostsTab> createState() => _LikedPostsTabState();
}

class _LikedPostsTabState extends State<_LikedPostsTab> {
  final Set<String> _seenPostUris = <String>{};
  List<LikedPostEntry> _likedPosts = const [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;
  LikedPostsRepository? _repository;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    try {
      _repository = context.read<LikedPostsRepository>();
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Liked posts are unavailable right now.';
      });
      return;
    }

    await _syncAndReload(initial: true);
  }

  Future<void> _syncAndReload({bool initial = false}) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    final accountDid = context.read<String>();

    if (mounted) {
      setState(() {
        _isLoading = initial;
        _isSyncing = !initial;
        _error = null;
      });
    }

    try {
      await repository.syncLikes(accountDid);
      final likedPosts = await repository.getLikedPosts(accountDid, limit: 200);
      if (!mounted) {
        return;
      }
      setState(() {
        _likedPosts = likedPosts;
        _isLoading = false;
        _isSyncing = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _isSyncing = false;
        _error = 'Failed to load liked posts: $e';
      });
    }
  }

  Future<void> _removeLike(LikedPostEntry entry) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    final accountDid = context.read<String>();
    await repository.removeLike(accountDid, entry.postUri);
    await _syncAndReload();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_error != null) {
      return ErrorState(title: 'Failed to load liked posts', message: _error!, onRetry: () => _syncAndReload());
    }

    if (_likedPosts.isEmpty) {
      return AnimatedRefreshIndicator(
        onRefresh: _syncAndReload,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            EmptyState(
              message: 'No liked posts',
              subtitle: 'Posts you like will appear here after sync',
              icon: Icons.favorite_outline,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        AnimatedRefreshIndicator(
          onRefresh: _syncAndReload,
          child: ListView.builder(
            itemCount: _likedPosts.length,
            itemBuilder: (context, index) {
              final likedPost = _likedPosts[index];
              return StaggeredEntrance(
                itemKey: likedPost.postUri,
                index: index,
                seenKeys: _seenPostUris,
                child: _LikedPostCard(likedPost: likedPost, onRemove: () => _removeLike(likedPost)),
              );
            },
          ),
        ),
        if (_isSyncing)
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
      ],
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
      if (json.containsKey('post')) {
        return FeedViewPost.fromJson(json);
      }
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
        title: const Text('Bookmarked Post'),
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
              onPressed: () => ShareHelper.shareText(
                context,
                AppViewWebLinks.postFromAtUri(savedPost.postUri, appViewProvider: _resolveAppViewProvider(context)),
              ),
              tooltip: 'Share',
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onUnsave, tooltip: 'Remove'),
          ],
        ),
      ),
    );
  }

  String _resolveAppViewProvider(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.appViewProvider;
    } catch (_) {
      return AppViewProviders.defaultKey;
    }
  }
}

class _LikedPostCard extends StatelessWidget {
  const _LikedPostCard({required this.likedPost, required this.onRemove});

  final LikedPostEntry likedPost;
  final VoidCallback onRemove;

  FeedViewPost? _deserializePost() {
    try {
      final json = jsonDecode(likedPost.postJson) as Map<String, dynamic>;
      if (json.containsKey('post')) {
        return FeedViewPost.fromJson(json);
      }
      return FeedViewPost(post: PostView.fromJson(json));
    } catch (e) {
      log.e('Failed to deserialize liked post', error: e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedViewPost = _deserializePost();
    final accountDid = context.read<String>();

    return Dismissible(
      key: ValueKey('liked-${likedPost.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: context.colorScheme.error,
        child: Icon(Icons.favorite_border, color: context.colorScheme.onError),
      ),
      onDismissed: (_) => onRemove(),
      child: feedViewPost != null
          ? PostCardWithActions(feedViewPost: feedViewPost, accountDid: accountDid)
          : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.favorite_outline),
        title: const Text('Liked Post'),
        subtitle: Text('Liked on ${_formatDate(likedPost.likedAt)}', style: context.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => context.push('/post?uri=${Uri.encodeQueryComponent(likedPost.postUri)}'),
              tooltip: 'Open post',
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onRemove, tooltip: 'Remove'),
          ],
        ),
      ),
    );
  }
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
