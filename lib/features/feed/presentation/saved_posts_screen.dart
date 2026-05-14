import 'dart:async';

import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/l10n/l10n.dart';
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
import 'package:lazurite/shared/utils/format_utils.dart';

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
        title: Text(context.l10n.labelBookmarksAndLikes),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.labelBookmarks),
            Tab(text: context.l10n.labelLiked),
            Tab(text: context.l10n.labelSearch),
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
            title: context.l10n.errorFailedToLoadBookmarks,
            message: state.error ?? context.l10n.errorUnknown,
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
          return EmptyState(
            message: context.l10n.messageNoBookmarks,
            subtitle: context.l10n.messageNoBookmarksSubtitle,
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
                    Expanded(
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          Tab(text: context.l10n.labelLocal),
                          Tab(text: context.l10n.labelBluesky),
                        ],
                      ),
                    ),
                    if (localPosts.isNotEmpty)
                      PopupMenuButton<_BookmarksMenuAction>(
                        tooltip: context.l10n.labelBookmarkActions,
                        onSelected: (action) {
                          if (action == _BookmarksMenuAction.clearLocal) {
                            _confirmClearLocal(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: _BookmarksMenuAction.clearLocal,
                            child: ListTile(
                              leading: const Icon(Icons.delete_sweep_outlined),
                              title: Text(context.l10n.labelClearLocalBookmarks),
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
          children: [
            const SizedBox(height: 80),
            EmptyState(
              message: context.l10n.messageNoBookmarksInSource,
              subtitle: context.l10n.messageNoBookmarksInSourceSubtitle,
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
        title: Text(context.l10n.dialogClearLocalBookmarksTitle),
        content: Text(context.l10n.dialogClearLocalBookmarksContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(context.l10n.buttonCancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SavedPostsCubit>().clearLocalSaved();
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            child: Text(context.l10n.buttonClearLocal),
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
  String? _syncWarning;
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
        _error = context.l10n.messageLikedPostsUnavailable;
      });
      return;
    }

    await _loadCachedLikes();
    unawaited(_syncAndReload());
  }

  Future<void> _loadCachedLikes() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    final accountDid = context.read<String>();
    try {
      final likedPosts = await repository.getLikedPosts(accountDid, limit: 200);
      if (!mounted) {
        return;
      }
      setState(() {
        _likedPosts = likedPosts;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = context.l10n.errorFailedToLoadLikedPostsDetails(e);
      });
    }
  }

  Future<void> _syncAndReload() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    final accountDid = context.read<String>();

    if (mounted) {
      setState(() {
        _isSyncing = true;
        _syncWarning = null;
        if (_likedPosts.isEmpty) {
          _error = null;
        }
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
        _error = null;
        _syncWarning = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      if (_likedPosts.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _isSyncing = false;
          _syncWarning = context.l10n.errorFailedToRefreshLikedPosts(e);
        });
        return;
      }
      setState(() {
        _isLoading = false;
        _isSyncing = false;
        _error = context.l10n.errorFailedToLoadLikedPostsDetails(e);
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
    await _loadCachedLikes();
    await _syncAndReload();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_error != null && _likedPosts.isEmpty) {
      return ErrorState(
        title: context.l10n.errorFailedToLoadLikedPosts,
        message: _error!,
        onRetry: () => _syncAndReload(),
      );
    }

    if (_likedPosts.isEmpty) {
      return AnimatedRefreshIndicator(
        onRefresh: _syncAndReload,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            EmptyState(
              message: context.l10n.messageNoLikedPosts,
              subtitle: context.l10n.messageNoLikedPostsSubtitle,
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
            itemCount: _likedPosts.length + (_syncWarning == null ? 0 : 1),
            itemBuilder: (context, index) {
              if (_syncWarning != null && index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Material(
                    color: context.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        _syncWarning!,
                        style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onErrorContainer),
                      ),
                    ),
                  ),
                );
              }

              final likedPost = _likedPosts[_syncWarning == null ? index : index - 1];
              final listIndex = _syncWarning == null ? index : index - 1;
              return StaggeredEntrance(
                itemKey: likedPost.postUri,
                index: listIndex,
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
      return PoptartCacheCodecs.decodeSavedOrLikedPost(savedPost.postJson);
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
        title: Text(context.l10n.labelBookmarkedPost),
        subtitle: Text(
          context.l10n.formatSavedOn(_formatDate(context, savedPost.savedAt)),
          style: context.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => context.push('/post?uri=${Uri.encodeQueryComponent(savedPost.postUri)}'),
              tooltip: context.l10n.labelOpenPost,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => ShareHelper.shareText(
                context,
                AppViewWebLinks.postFromAtUri(savedPost.postUri, appViewProvider: _resolveAppViewProvider(context)),
              ),
              tooltip: context.l10n.buttonShare,
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onUnsave, tooltip: context.l10n.buttonRemove),
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
      return PoptartCacheCodecs.decodeSavedOrLikedPost(likedPost.postJson);
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
        title: Text(context.l10n.labelLikedPost),
        subtitle: Text(
          context.l10n.formatLikedOn(_formatDate(context, likedPost.likedAt)),
          style: context.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => context.push('/post?uri=${Uri.encodeQueryComponent(likedPost.postUri)}'),
              tooltip: context.l10n.labelOpenPost,
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onRemove, tooltip: context.l10n.buttonRemove),
          ],
        ),
      ),
    );
  }
}

String _formatDate(BuildContext context, DateTime date) =>
    formatRelativeTime(date, includeAgo: true, locale: Localizations.localeOf(context).toString());
