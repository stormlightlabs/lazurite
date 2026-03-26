import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/feed_layout_view.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';

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
    return BlocBuilder<FeedPreferencesCubit, FeedPreferencesState>(
      builder: (context, prefsState) {
        if (prefsState.status == FeedPreferencesStatus.initial || prefsState.status == FeedPreferencesStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (prefsState.status == FeedPreferencesStatus.error) {
          return Scaffold(
            appBar: const LazuriteAppBar(sectionLabel: 'Home'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load feeds', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(prefsState.message ?? 'Unknown error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<FeedPreferencesCubit>().loadPreferences(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final pinnedFeeds = prefsState.pinnedFeeds;
        final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);

        if (pinnedFeeds.isEmpty) {
          return Scaffold(
            appBar: const LazuriteAppBar(sectionLabel: 'Home'),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No feeds pinned', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Pin a timeline or custom feed to build your home tabs.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () => context.push('/feeds'), child: const Text('Manage Feeds')),
                  ],
                ),
              ),
            ),
          );
        }

        final currentTabIndex = _selectedIndexFor(pinnedFeeds);
        _syncSelectedFeed(pinnedFeeds, currentTabIndex);

        return Scaffold(
          appBar: LazuriteAppBar(
            sectionLabel: 'Home',
            showAvatar: false,
            actions: [
              IconButton(icon: const Icon(Icons.rss_feed), onPressed: () => context.push('/feeds')),
              const AppBarMessagesButton(),
              const SizedBox(width: 8),
            ],
            bottom: _FeedTabBar(
              feeds: pinnedFeeds,
              prefsState: prefsState,
              currentTabIndex: currentTabIndex,
              onTabTapped: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _selectedFeedId = pinnedFeeds[index].id);
              },
            ),
          ),
          body: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedFeedId = pinnedFeeds[index].id),
            itemCount: pinnedFeeds.length,
            itemBuilder: (context, index) =>
                _FeedListView(feed: pinnedFeeds[index], key: ValueKey(pinnedFeeds[index].id)),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'home-compose-fab',
            tooltip: isOffline ? offlineActionMessage('compose a post') : 'Compose',
            onPressed: isOffline ? null : () => context.push('/compose'),
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        );
      },
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
  const _FeedListView({required this.feed, super.key});

  final SavedFeed feed;

  @override
  State<_FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<_FeedListView> with AutomaticKeepAliveClientMixin {
  final List<FeedViewPost> _posts = [];
  String? _cursor;
  bool _isLoading = false;
  bool _showInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _primeFeed();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFeed() async {
    await _loadFeedInternal(showLoading: _posts.isEmpty);
  }

  Future<void> _primeFeed() async {
    final cachedResult = await _loadCachedFeed();
    if (cachedResult != null) {
      _setStateIfMounted(() {
        _posts
          ..clear()
          ..addAll(cachedResult.posts);
        _cursor = cachedResult.cursor;
        _hasError = false;
        _errorMessage = null;
      });
    }

    await _loadFeedInternal(showLoading: cachedResult == null);
  }

  Future<void> _loadFeedInternal({required bool showLoading}) async {
    if (_isLoading) return;

    _setStateIfMounted(() {
      _isLoading = true;
      _showInitialLoading = showLoading;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final feedRepository = context.read<FeedRepository>();
      final result = await _fetchFeed(feedRepository, cursor: null);

      _setStateIfMounted(() {
        _posts.clear();
        _posts.addAll(result.posts);
        _cursor = result.cursor;
        _isLoading = false;
        _showInitialLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (_posts.isNotEmpty) {
        _setStateIfMounted(() {
          _isLoading = false;
          _showInitialLoading = false;
        });
        return;
      }

      _setStateIfMounted(() {
        _isLoading = false;
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
    if (_isLoadingMore || _cursor == null) return;

    _setStateIfMounted(() => _isLoadingMore = true);

    try {
      final feedRepository = context.read<FeedRepository>();
      final result = await _fetchFeed(feedRepository, cursor: _cursor);

      _setStateIfMounted(() {
        _posts.addAll(result.posts);
        _cursor = result.cursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      _setStateIfMounted(() => _isLoadingMore = false);
    }
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load feed', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadFeed, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(child: Text('No posts yet', style: Theme.of(context).textTheme.bodyLarge));
    }

    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';

    PostCardWithActions buildCard(int index, PostCardVariant variant) {
      final post = _posts[index];
      return PostCardWithActions(
        feedViewPost: post,
        accountDid: accountDid,
        variant: variant,
        onDeleted: () {
          final uri = post.post.uri.toString();
          _setStateIfMounted(() => _posts.removeWhere((p) => p.post.uri.toString() == uri));
        },
      );
    }

    return FeedLayoutView(
      itemCount: _posts.length,
      scrollController: _scrollController,
      isLoadingMore: _isLoadingMore,
      onRefresh: _loadFeed,
      gridItemBuilder: (context, index) => buildCard(index, PostCardVariant.grid),
      linearItemBuilder: (context, index) => buildCard(index, PostCardVariant.linear),
    );
  }
}
