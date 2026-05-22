import 'dart:async';

import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/unspecced/defs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/cache/lazurite_image_cache.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/feed/presentation/widgets/public_post_card.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/public/data/public_provider_context.dart';
import 'package:lazurite/features/public/presentation/public_navigation.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key, required this.providerKey, required this.contentTab});

  final String providerKey;
  final PublicContentTab contentTab;

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeProviderIndex = _providerIndex(widget.providerKey);
    final activeContentIndex = widget.contentTab.index;
    final activeIndex = activeProviderIndex * PublicContentTab.values.length + activeContentIndex;

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 48,
                    colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.appTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.labelRoamTheAtmosphere,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    key: const ValueKey<String>('public-provider-switch'),
                    segments: const [
                      ButtonSegment<String>(
                        value: AppViewProviders.blueskyKey,
                        label: _ProviderLabel(assetPath: 'assets/bluesky.svg', name: 'BlueSky'),
                      ),
                      ButtonSegment<String>(
                        value: AppViewProviders.blackskyKey,
                        label: _ProviderLabel(assetPath: 'assets/blacksky.svg', name: 'BlackSky'),
                      ),
                    ],
                    selected: {widget.providerKey},
                    onSelectionChanged: (selection) => _go(context, providerKey: selection.first),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<PublicContentTab>(
                    key: const ValueKey<String>('public-content-switch'),
                    segments: [
                      ButtonSegment<PublicContentTab>(
                        value: PublicContentTab.discover,
                        icon: Icon(
                          widget.providerKey == AppViewProviders.blackskyKey
                              ? Icons.trending_up
                              : Icons.travel_explore_outlined,
                        ),
                        label: Text(
                          widget.providerKey == AppViewProviders.blackskyKey ? 'Trending' : 'Discover',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const ButtonSegment<PublicContentTab>(
                        value: PublicContentTab.feeds,
                        icon: Icon(Icons.rss_feed_outlined),
                        label: Text('Feeds', maxLines: 1, softWrap: false, overflow: TextOverflow.fade),
                      ),
                    ],
                    selected: {widget.contentTab},
                    onSelectionChanged: (selection) => _go(context, contentTab: selection.first),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: PageStorage(
                bucket: _bucket,
                child: IndexedStack(
                  key: const ValueKey<String>('public-home-indexed-stack'),
                  index: activeIndex,
                  children: const [
                    _PublicDiscoverTab(providerKey: AppViewProviders.blueskyKey),
                    _PublicFeedsTab(providerKey: AppViewProviders.blueskyKey),
                    _PublicDiscoverTab(providerKey: AppViewProviders.blackskyKey),
                    _PublicFeedsTab(providerKey: AppViewProviders.blackskyKey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _providerIndex(String providerKey) => providerKey == AppViewProviders.blackskyKey ? 1 : 0;

  void _go(BuildContext context, {String? providerKey, PublicContentTab? contentTab}) {
    final route = PublicRouteState(
      providerKey: providerKey ?? widget.providerKey,
      contentTab: contentTab ?? widget.contentTab,
    );
    context.go(route.location);
  }
}

class _PublicDiscoverTab extends StatefulWidget {
  const _PublicDiscoverTab({required this.providerKey});

  final String providerKey;

  @override
  State<_PublicDiscoverTab> createState() => _PublicDiscoverTabState();
}

class _PublicDiscoverTabState extends State<_PublicDiscoverTab> with AutomaticKeepAliveClientMixin {
  PublicDiscoverResult? _result;
  Object? _error;
  var _loading = true;
  var _loadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repository(context, widget.providerKey).loadDiscover();
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final cursor = _result?.cursor;
    if (_loadingMore || cursor == null || cursor.isEmpty) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final next = await _repository(context, widget.providerKey).loadDiscover(cursor: cursor);
      if (!mounted) {
        return;
      }
      setState(() {
        _result = PublicDiscoverResult(
          posts: [...?_result?.posts, ...next.posts],
          feeds: [...?_result?.feeds, ...next.feeds],
          trends: [...?_result?.trends, ...next.trends],
          cursor: next.cursor,
        );
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final label = widget.providerKey == AppViewProviders.blackskyKey ? 'BlackSky Trending' : 'BlueSky Discover';
    if (_loading) {
      return LoadingState(key: ValueKey<String>('public-${widget.providerKey}-discover-loading'));
    }
    final error = _error;
    if (error != null) {
      return ErrorState(title: 'Failed to load $label', message: '$error', onRetry: _load);
    }
    final result = _result;
    if (result == null || result.isEmpty) {
      return EmptyState(
        key: ValueKey<String>('public-${widget.providerKey}-discover-empty'),
        message: 'No public ${widget.providerKey == AppViewProviders.blackskyKey ? 'trends' : 'feeds'} available',
        icon: Icons.travel_explore_outlined,
      );
    }

    final children = <Widget>[_PublicSectionHeader(label: label)];
    children.addAll(
      result.posts.map(
        (post) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PublicPostCard(feedViewPost: post, providerKey: widget.providerKey, variant: PostCardVariant.card),
        ),
      ),
    );
    children.addAll(result.trends.map((trend) => _TrendCard(trend: trend, providerKey: widget.providerKey)));
    children.addAll(result.feeds.map((feed) => _FeedCard(feed: feed, providerKey: widget.providerKey)));
    if (result.cursor != null) {
      children.add(_LoadMoreButton(loading: _loadingMore, onPressed: _loadMore));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        key: PageStorageKey<String>('public-${widget.providerKey}-discover-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: children,
      ),
    );
  }
}

class _PublicFeedsTab extends StatefulWidget {
  const _PublicFeedsTab({required this.providerKey});

  final String providerKey;

  @override
  State<_PublicFeedsTab> createState() => _PublicFeedsTabState();
}

class _PublicFeedsTabState extends State<_PublicFeedsTab> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  PublicFeedsResult? _result;
  Object? _error;
  var _loading = true;
  var _loadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({String? cursor}) async {
    final query = _searchController.text.trim();
    setState(() {
      if (cursor == null) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
      _error = null;
    });
    try {
      final repository = _repository(context, widget.providerKey);
      final result = query.isEmpty
          ? await repository.loadFeeds(cursor: cursor)
          : await repository.searchFeeds(query: query, cursor: cursor);
      if (!mounted) {
        return;
      }
      setState(() {
        _result = cursor == null
            ? result
            : PublicFeedsResult(feeds: [...?_result?.feeds, ...result.feeds], cursor: result.cursor);
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _submitSearch() => _load();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final label = widget.providerKey == AppViewProviders.blackskyKey ? 'BlackSky Feeds' : 'BlueSky Feeds';
    final error = _error;
    final result = _result;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        key: PageStorageKey<String>('public-${widget.providerKey}-feeds-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _PublicSectionHeader(label: label),
          TextField(
            key: ValueKey<String>('public-${widget.providerKey}-feed-search'),
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search feeds',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Search feeds',
                icon: const Icon(Icons.arrow_forward),
                onPressed: _submitSearch,
              ),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => unawaited(_submitSearch()),
          ),
          const SizedBox(height: 12),
          if (_loading)
            LoadingState(key: ValueKey<String>('public-${widget.providerKey}-feeds-loading'))
          else if (error != null)
            ErrorState(title: 'Failed to load $label', message: '$error', onRetry: _load)
          else if (result == null || result.feeds.isEmpty)
            EmptyState(
              key: ValueKey<String>('public-${widget.providerKey}-feeds-empty'),
              message: 'No public feeds available',
              icon: Icons.rss_feed_outlined,
            )
          else ...[
            ...result.feeds.map((feed) => _FeedCard(feed: feed, providerKey: widget.providerKey)),
            if (result.cursor != null)
              _LoadMoreButton(
                loading: _loadingMore,
                onPressed: () => _load(cursor: result.cursor),
              ),
          ],
        ],
      ),
    );
  }
}

PublicContentRepository _repository(BuildContext context, String providerKey) {
  try {
    return context.read<PublicContentRepositoryResolver>().repositoryFor(providerKey);
  } catch (_) {
    return context.read<PublicContentRepository>();
  }
}

class _ProviderLabel extends StatelessWidget {
  const _ProviderLabel({required this.assetPath, required this.name});

  static const _blackSkyAssetPath = 'assets/blacksky.svg';
  static const _blackSkyDarkModeColor = Color(0xFF6868B6);

  final String assetPath;
  final String name;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset(
        assetPath,
        height: 16,
        colorFilter: assetPath == _blackSkyAssetPath && Theme.of(context).brightness == Brightness.dark
            ? const ColorFilter.mode(_blackSkyDarkModeColor, BlendMode.srcIn)
            : null,
      ),
      const SizedBox(width: 8),
      Text(name),
    ],
  );
}

class _PublicSectionHeader extends StatelessWidget {
  const _PublicSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.feed, required this.providerKey});

  final GeneratorView feed;
  final String providerKey;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = feed.avatar ?? feed.creator.avatar;
    final description = feed.description?.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        key: ValueKey<String>('public-feed-${feed.uri}'),
        onTap: () => navigateToPublicFeed(context, feed, PublicProviderContext(providerKey: providerKey)),
        leading: _FeedAvatar(avatarUrl: avatarUrl),
        title: Text(_feedDisplayName(feed)),
        subtitle: Text(
          [
            'by ${feed.creator.displayName ?? feed.creator.handle}',
            if (description != null && description.isNotEmpty) description,
            if (feed.likeCount != null) '${feed.likeCount} likes',
          ].join('\n'),
        ),
        isThreeLine: description != null && description.isNotEmpty,
        trailing: const Text('Open'),
      ),
    );
  }

  String _feedDisplayName(GeneratorView feed) {
    final displayName = feed.displayName.trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }
    return feed.uri.toString();
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend, required this.providerKey});

  final TrendView trend;
  final String providerKey;

  @override
  Widget build(BuildContext context) {
    final category = trend.category?.trim();
    final displayName = trend.displayName.trim();
    final topic = displayName.isNotEmpty ? displayName : trend.topic;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        key: ValueKey<String>('public-trend-${trend.topic}'),
        onTap: () {
          final link = trend.link.trim();
          if (link.startsWith('/topic/')) {
            final topicId = link.substring('/topic/'.length);
            context.go('/topic?topic=${Uri.encodeQueryComponent(topicId)}&provider=$providerKey');
          }
        },
        leading: const Icon(Icons.trending_up),
        title: Text(topic),
        subtitle: Text(['${trend.postCount} posts', if (category != null && category.isNotEmpty) category].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _FeedAvatar extends StatelessWidget {
  const _FeedAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF08BDBA), Color(0xFF3DDBD9)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: url == null || url.isEmpty
          ? const Icon(Icons.rss_feed, color: Colors.white)
          : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: url,
                cacheManager: LazuriteImageCacheManager.instance,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const Icon(Icons.rss_feed, color: Colors.white),
              ),
            ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: OutlinedButton(
          key: const ValueKey<String>('public-load-more-button'),
          onPressed: loading ? null : onPressed,
          child: loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Load more'),
        ),
      ),
    );
  }
}
