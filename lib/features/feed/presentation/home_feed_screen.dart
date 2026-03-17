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
  int _currentTabIndex = 0;

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
        final pinnedFeeds = prefsState.pinnedFeeds;

        if (pinnedFeeds.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: const Center(child: Text('No feeds pinned. Add feeds from settings.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/feeds'))],
          ),
          body: Column(
            children: [
              _buildTabBar(context, pinnedFeeds),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentTabIndex = index),
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

  Widget _buildTabBar(BuildContext context, List<SavedFeed> feeds) {
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
            final isSelected = _currentTabIndex == index;

            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentTabIndex = index);
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
                  _getFeedName(feed),
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

  String _getFeedName(SavedFeed feed) {
    if (feed.type is SavedFeedTypeKnownValue) {
      final knownType = (feed.type as SavedFeedTypeKnownValue).data;
      if (knownType == KnownSavedFeedType.timeline) {
        return 'Following';
      }
    }
    return feed.value.split('/').lastOrNull ?? 'Feed';
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
