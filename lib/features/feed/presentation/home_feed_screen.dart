import 'dart:math' as math;

import 'package:lazurite/features/feed/presentation/constants.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/compose/presentation/widgets/compose_fab.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/feed_layout_view.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

/// Returns the number of grid columns for [width] per the responsive
/// breakpoints defined in the UI spec.
int feedColumnCount(double width) {
  if (width >= 1200) return 4;
  if (width >= 840) return 3;
  if (width >= 600) return 2;
  return 1;
}

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late final PageController _pageController;
  final Map<String, int> _reloadCommandByFeed = <String, int>{};
  final Map<String, int> _jumpToTopCommandByFeed = <String, int>{};
  String? _selectedFeedId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget withEntrance(Widget child) => AppScreenEntrance(child: child);

    return BlocBuilder<FeedPreferencesCubit, FeedPreferencesState>(
      builder: (context, prefsState) {
        if (prefsState.status == FeedPreferencesStatus.initial || prefsState.status == FeedPreferencesStatus.loading) {
          return withEntrance(const Scaffold(body: LoadingState()));
        }

        if (prefsState.status == FeedPreferencesStatus.error) {
          return withEntrance(
            Scaffold(
              appBar: const LazuriteAppBar(sectionLabel: 'Home'),
              body: ErrorState(
                title: 'Failed to load feeds',
                message: prefsState.message ?? 'Unknown error',
                onRetry: () => context.read<FeedPreferencesCubit>().loadPreferences(),
              ),
            ),
          );
        }

        final pinnedFeeds = prefsState.pinnedFeeds;
        final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);

        if (pinnedFeeds.isEmpty) {
          return withEntrance(
            Scaffold(
              appBar: const LazuriteAppBar(sectionLabel: 'Home'),
              body: EmptyState(
                message: 'No feeds pinned',
                icon: Icons.rss_feed_outlined,
                subtitle: 'Pin a timeline or custom feed to build your home tabs.',
                action: FilledButton(onPressed: () => context.push('/feeds'), child: const Text('Manage Feeds')),
              ),
            ),
          );
        }

        final currentTabIndex = _selectedIndexFor(pinnedFeeds);
        _syncSelectedFeed(pinnedFeeds, currentTabIndex);

        return withEntrance(
          Scaffold(
            appBar: LazuriteAppBar(
              sectionLabel: 'Home',
              actions: [
                IconButton(
                  icon: const Icon(Icons.trending_up_outlined),
                  tooltip: context.l10n.labelTrending,
                  onPressed: () => context.push('/trending'),
                ),
                IconButton(
                  icon: const Icon(Icons.rss_feed),
                  tooltip: 'Manage Feeds',
                  onPressed: () => context.push('/feeds'),
                ),
              ],
              bottom: _FeedTabBar(
                feeds: pinnedFeeds,
                prefsState: prefsState,
                currentTabIndex: currentTabIndex,
                onTabTapped: (index) {
                  final tappedFeed = pinnedFeeds[index];
                  final isRetap = currentTabIndex == index;
                  if (isRetap) {
                    setState(() {
                      _reloadCommandByFeed[tappedFeed.id] = (_reloadCommandByFeed[tappedFeed.id] ?? 0) + 1;
                    });
                    return;
                  }
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _selectedFeedId = tappedFeed.id);
                },
              ),
            ),
            body: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _selectedFeedId = pinnedFeeds[index].id),
              itemCount: pinnedFeeds.length,
              itemBuilder: (context, index) => _FeedListView(
                feed: pinnedFeeds[index],
                isActive: index == currentTabIndex,
                reloadCommand: _reloadCommandByFeed[pinnedFeeds[index].id] ?? 0,
                jumpToTopCommand: _jumpToTopCommandByFeed[pinnedFeeds[index].id] ?? 0,
                key: ValueKey('feed-list-${pinnedFeeds[index].id}'),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: _buildFloatingButtons(context, pinnedFeeds, currentTabIndex, isOffline),
          ),
        );
      },
    );
  }

  Widget _buildFloatingButtons(BuildContext context, List<SavedFeed> pinnedFeeds, int currentTabIndex, bool isOffline) {
    final currentFeedId = pinnedFeeds[currentTabIndex].id;

    final jumpToTopButton = FloatingActionButton.small(
      heroTag: 'home-jump-top-fab',
      tooltip: 'Jump to top',
      onPressed: () {
        setState(() {
          _jumpToTopCommandByFeed[currentFeedId] = (_jumpToTopCommandByFeed[currentFeedId] ?? 0) + 1;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      elevation: 1.5,
      child: const Icon(Icons.arrow_upward, size: 18),
    );

    final composeButton = ComposeFab(
      heroTag: 'home-compose-fab',
      tooltip: isOffline ? offlineActionMessage('compose a post') : 'Compose',
      onPressed: isOffline ? null : () => context.push('/compose'),
      shape: const CircleBorder(),
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [const SizedBox(width: 24), jumpToTopButton, const Spacer(), composeButton, const SizedBox(width: 24)],
    );
  }

  void _syncSelectedFeed(List<SavedFeed> feeds, int currentTabIndex) {
    final selectedFeedId = feeds[currentTabIndex].id;
    if (_selectedFeedId != selectedFeedId) {
      _selectedFeedId = selectedFeedId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final roundedPage = _pageController.page?.round();
      if (roundedPage == currentTabIndex) {
        return;
      }

      _pageController.jumpToPage(currentTabIndex);
    });
  }

  int _selectedIndexFor(List<SavedFeed> feeds) {
    if (feeds.isEmpty) {
      return 0;
    }

    final index = feeds.indexWhere((feed) => feed.id == _selectedFeedId);
    return index >= 0 ? index : 0;
  }
}

class _FeedTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _FeedTabBar({
    required this.feeds,
    required this.prefsState,
    required this.currentTabIndex,
    required this.onTabTapped,
  });

  final List<SavedFeed> feeds;
  final FeedPreferencesState prefsState;
  final int currentTabIndex;
  final ValueChanged<int> onTabTapped;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: preferredSize.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: feeds.asMap().entries.map((entry) {
            final index = entry.key;
            final feed = entry.value;
            final isSelected = currentTabIndex == index;
            return GestureDetector(
              onTap: () => onTabTapped(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 2),
                  ),
                ),
                child: Text(
                  prefsState.displayNameFor(feed).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FeedListView extends StatefulWidget {
  const _FeedListView({
    required this.feed,
    required this.isActive,
    required this.reloadCommand,
    required this.jumpToTopCommand,
    super.key,
  });

  final SavedFeed feed;
  final bool isActive;
  final int reloadCommand;
  final int jumpToTopCommand;

  @override
  State<_FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<_FeedListView> with AutomaticKeepAliveClientMixin {
  final List<FeedViewPost> _posts = [];
  String? _cursor;
  bool _isLoading = false;
  bool _showInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenPostUris = <String>{};
  late int _lastReloadCommand;
  late int _lastJumpToTopCommand;

  @override
  bool get wantKeepAlive => widget.isActive;

  @override
  void initState() {
    super.initState();
    _lastReloadCommand = widget.reloadCommand;
    _lastJumpToTopCommand = widget.jumpToTopCommand;
    _scrollController.addListener(_onScroll);
    _primeFeed();
  }

  @override
  void didUpdateWidget(covariant _FeedListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      updateKeepAlive();
      if (!widget.isActive) {
        _trimRetainedPosts(inactiveRetainedFeedPosts, keepTail: false);
      }
    }

    if (widget.reloadCommand != _lastReloadCommand) {
      _lastReloadCommand = widget.reloadCommand;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _setStateIfMounted(() {
          _hasError = false;
          _errorMessage = null;
        });
        _loadFeed();
      });
    }

    if (widget.jumpToTopCommand != _lastJumpToTopCommand) {
      _lastJumpToTopCommand = widget.jumpToTopCommand;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        jumpToTop();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_scrollController.position.hasContentDimensions) {
      return;
    }
    if (_isLoading || _showInitialLoading) {
      return;
    }
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - loadMoreExtentThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadFeed() async {
    await _loadFeedInternal(showLoading: _posts.isEmpty, showOfflineFeedback: true);
  }

  Future<void> _primeFeed() async {
    try {
      final cachedResult = await _loadCachedFeed();
      if (cachedResult != null) {
        _setStateIfMounted(() {
          _posts
            ..clear()
            ..addAll(_uniquePosts(cachedResult.posts).take(maxRetainedFeedPosts));
          _seenPostUris
            ..clear()
            ..addAll(_posts.take(animatedEntranceItemLimit).map((post) => post.post.uri.toString()));
          _cursor = cachedResult.cursor;
          _hasError = false;
          _errorMessage = null;
          _showInitialLoading = false;
        });
      }

      await _loadFeedInternal(showLoading: cachedResult == null, showOfflineFeedback: false);
    } catch (e) {
      _setStateIfMounted(() {
        _isLoading = false;
        _isLoadingMore = false;
        _showInitialLoading = false;
        if (_posts.isEmpty) {
          _hasError = true;
          _errorMessage = e.toString();
        }
      });
    }
  }

  Future<void> _loadFeedInternal({required bool showLoading, required bool showOfflineFeedback}) async {
    if (_isLoading) return;
    if (context.read<ConnectivityCubit>().state.isOffline) {
      if (_posts.isEmpty) {
        _setStateIfMounted(() {
          _hasError = true;
          _errorMessage = offlineActionMessage('refresh your feed');
          _isLoading = false;
          _showInitialLoading = false;
        });
      } else if (showOfflineFeedback) {
        showOfflineSnackBar(context, action: 'refresh your feed');
      }
      return;
    }

    _setStateIfMounted(() {
      _isLoading = true;
      _isLoadingMore = false;
      _showInitialLoading = showLoading;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final feedRepository = context.read<FeedRepository>();
      final result = await _fetchFeed(feedRepository, cursor: null);

      _setStateIfMounted(() {
        _posts.clear();
        _posts.addAll(_uniquePosts(result.posts).take(maxRetainedFeedPosts));
        _seenPostUris.clear();
        _cursor = result.cursor;
        _isLoading = false;
        _showInitialLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (_posts.isNotEmpty) {
        _setStateIfMounted(() {
          _isLoading = false;
          _isLoadingMore = false;
          _showInitialLoading = false;
        });
        return;
      }

      _setStateIfMounted(() {
        _isLoading = false;
        _isLoadingMore = false;
        _showInitialLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<FeedResult?> _loadCachedFeed() {
    return context.read<FeedRepository>().getCachedFeedPage(FeedRepository.cacheKeyForSavedFeed(widget.feed));
  }

  Future<void> _loadMore() async {
    if (_isLoading || _showInitialLoading || _isLoadingMore || _cursor == null) return;
    if (context.read<ConnectivityCubit>().state.isOffline) {
      return;
    }

    _setStateIfMounted(() => _isLoadingMore = true);

    try {
      final feedRepository = context.read<FeedRepository>();
      final result = await _fetchFeed(feedRepository, cursor: _cursor);

      _setStateIfMounted(() {
        _appendUniquePosts(result.posts);
        _cursor = result.cursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      _setStateIfMounted(() => _isLoadingMore = false);
    }
  }

  void _appendUniquePosts(List<FeedViewPost> posts) {
    final existingUris = _posts.map((post) => post.post.uri.toString()).toSet();
    for (final post in posts) {
      final uri = post.post.uri.toString();
      if (existingUris.add(uri)) {
        _posts.add(post);
      }
    }
    _trimRetainedPosts(maxRetainedFeedPosts, keepTail: true);
  }

  List<FeedViewPost> _uniquePosts(List<FeedViewPost> posts) {
    final seenUris = <String>{};
    return [
      for (final post in posts)
        if (seenUris.add(post.post.uri.toString())) post,
    ];
  }

  void _trimRetainedPosts(int maxRetainedPosts, {required bool keepTail}) {
    if (_posts.length <= maxRetainedPosts) {
      return;
    }

    final removeCount = _posts.length - maxRetainedPosts;
    if (!keepTail) {
      final removedPosts = _posts
          .skip(maxRetainedPosts)
          .map((post) => post.post.uri.toString())
          .toList(growable: false);
      _posts.removeRange(maxRetainedPosts, _posts.length);
      _seenPostUris.removeAll(removedPosts);
      return;
    }

    final previousScrollExtent = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : null;
    final previousOffset = _scrollController.hasClients ? _scrollController.offset : null;
    final averageItemExtent = previousScrollExtent != null && _posts.isNotEmpty
        ? previousScrollExtent / math.max(_posts.length, 1)
        : 0.0;

    final removedPosts = _posts.take(removeCount).map((post) => post.post.uri.toString()).toList(growable: false);
    _posts.removeRange(0, removeCount);
    _seenPostUris.removeAll(removedPosts);

    if (previousOffset == null || previousOffset <= 0 || !_scrollController.hasClients) {
      return;
    }

    final adjustedOffset = math.max(0.0, previousOffset - (averageItemExtent * removeCount));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final maxOffset = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(adjustedOffset.clamp(0.0, maxOffset));
    });
  }

  Future<void> jumpToTop() async {
    if (!_scrollController.hasClients) {
      return;
    }

    final currentOffset = _scrollController.offset;
    if (currentOffset <= 0) {
      return;
    }

    await _scrollController.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
  }

  void _setStateIfMounted(VoidCallback fn) {
    if (!mounted) {
      return;
    }

    setState(fn);
  }

  Future<FeedResult> _fetchFeed(FeedRepository repo, {String? cursor}) async {
    final feedType = widget.feed.type;
    if (feedType is SavedFeedTypeKnownValue) {
      if (feedType.data == KnownSavedFeedType.timeline) {
        return repo.getTimeline(cursor: cursor);
      }
    }

    final feedUri = AtUri.parse(widget.feed.value);
    return repo.getFeed(feedUri: feedUri, cursor: cursor);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_showInitialLoading) {
      return const LoadingState();
    }

    if (_hasError) {
      return ErrorState(
        title: 'Failed to load feed',
        message: _errorMessage ?? 'Unknown error',
        onRetry: _loadFeed,
        icon: Icons.sync_problem_outlined,
      );
    }

    if (_posts.isEmpty) {
      return const EmptyState(message: 'No posts yet', icon: Icons.article_outlined);
    }

    final accountDid = context.select((AuthBloc bloc) => bloc.state.tokens?.did);

    Widget buildCard(int index, PostCardVariant variant) {
      final post = _posts[index];
      final postUri = post.post.uri.toString();
      return StaggeredEntrance(
        itemKey: postUri,
        index: index,
        seenKeys: _seenPostUris,
        enabled: index < animatedEntranceItemLimit,
        child: PostCardWithActions(
          feedViewPost: post,
          accountDid: accountDid,
          variant: variant,
          onDeleted: () {
            _setStateIfMounted(() => _posts.removeWhere((p) => p.post.uri.toString() == postUri));
          },
        ),
      );
    }

    return FeedLayoutView(
      itemCount: _posts.length,
      scrollController: _scrollController,
      isLoadingMore: _isLoadingMore,
      onRefresh: _loadFeed,
      itemKeyBuilder: (index) => ValueKey(_posts[index].post.uri.toString()),
      storageKey: PageStorageKey('home-feed-scroll-${widget.feed.id}'),
      gridItemBuilder: (context, index) => buildCard(index, PostCardVariant.compact),
      linearItemBuilder: (context, index) => buildCard(index, PostCardVariant.card),
    );
  }
}
