import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';

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
            appBar: AppBar(title: const Text('Home')),
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

        if (pinnedFeeds.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Home')),
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
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(icon: const Icon(Icons.dynamic_feed_outlined), onPressed: () => context.push('/feeds')),
            ],
          ),
          body: Column(
            children: [
              _buildTabBar(context, pinnedFeeds, prefsState, currentTabIndex),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _selectedFeedId = pinnedFeeds[index].id),
                  itemCount: pinnedFeeds.length,
                  itemBuilder: (context, index) =>
                      _FeedListView(feed: pinnedFeeds[index], key: ValueKey(pinnedFeeds[index].id)),
                ),
              ),
            ],
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

  Widget _buildTabBar(
    BuildContext context,
    List<SavedFeed> feeds,
    FeedPreferencesState prefsState,
    int currentTabIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: feeds.asMap().entries.map((entry) {
            final index = entry.key;
            final feed = entry.value;
            final isSelected = currentTabIndex == index;

            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _selectedFeedId = feed.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  prefsState.displayNameFor(feed),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
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
    _loadFeed();
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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final feedRepository = context.read<FeedRepository>();
      final result = await _fetchFeed(feedRepository, cursor: null);

      setState(() {
        _posts.clear();
        _posts.addAll(result.posts);
        _cursor = result.cursor;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _cursor == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final feedRepository = context.read<FeedRepository>();
      final result = await _fetchFeed(feedRepository, cursor: _cursor);

      setState(() {
        _posts.addAll(result.posts);
        _cursor = result.cursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
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

    if (_isLoading) {
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

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            );
          }

          return PostCard(feedViewPost: _posts[index]);
        },
      ),
    );
  }
}
