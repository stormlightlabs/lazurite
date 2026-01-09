import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/constants/layout_constants.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_embeds.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/features/search/presentation/widgets/recent_search_chips.dart';
import 'package:lazurite/src/features/search/presentation/widgets/search_bar_widget.dart';

/// Search screen with search input, recent searches, and results.
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates a search screen.
  const SearchScreen({this.initialQuery, this.initialTabIndex = 0, super.key});

  /// Optional initial query from route.
  final String? initialQuery;

  /// Optional initial tab index (0 for Posts, 1 for People).
  final int initialTabIndex;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  String _currentQuery = '';
  String _debouncedQuery = '';
  final _postsScrollController = ScrollController();
  final _peopleScrollController = ScrollController();
  late final TabController _tabController;
  Timer? _debounceTimer;

  /// Debounce duration for search input.
  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    if (widget.initialQuery != null) {
      _currentQuery = widget.initialQuery!;
      _debouncedQuery = widget.initialQuery!;
    }
    _postsScrollController.addListener(_onPostsScroll);
    _peopleScrollController.addListener(_onPeopleScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _postsScrollController.dispose();
    _peopleScrollController.dispose();
    super.dispose();
  }

  void _onPostsScroll() {
    if (_postsScrollController.position.pixels >=
        _postsScrollController.position.maxScrollExtent - 200) {
      if (_debouncedQuery.isNotEmpty) {
        ref.read(searchProvider(_debouncedQuery).notifier).loadMore();
      }
    }
  }

  void _onPeopleScroll() {
    if (_peopleScrollController.position.pixels >=
        _peopleScrollController.position.maxScrollExtent - 200) {
      if (_debouncedQuery.isNotEmpty) {
        ref.read(actorSearchProvider(_debouncedQuery).notifier).loadMore();
      }
    }
  }

  void _onQueryChanged(String query) {
    setState(() {
      _currentQuery = query;
    });
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      setState(() {
        _debouncedQuery = '';
      });
    } else {
      _debounceTimer = Timer(_debounceDuration, () {
        setState(() {
          _debouncedQuery = query;
        });
      });
    }
  }

  void _onSearch(String query) {
    _debounceTimer?.cancel();
    setState(() {
      _currentQuery = query;
      _debouncedQuery = query;
    });
  }

  void _onClear() {
    _debounceTimer?.cancel();
    setState(() {
      _currentQuery = '';
      _debouncedQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarWidget(
                initialQuery: _currentQuery,
                hintText: 'Search...',
                onSubmitted: _onSearch,
                onChanged: _onQueryChanged,
                onClear: _onClear,
              ),
            ),
            if (_debouncedQuery.isNotEmpty) ...[
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'People'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PostResultsView(
                      query: _debouncedQuery,
                      scrollController: _postsScrollController,
                    ),
                    _ActorResultsView(
                      query: _debouncedQuery,
                      scrollController: _peopleScrollController,
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(child: _RecentSearchesView(onSearch: _onSearch)),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchesView extends ConsumerWidget {
  const _RecentSearchesView({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearchesAsync = ref.watch(recentSearchesProvider);

    return recentSearchesAsync.when(
      data: (searches) {
        if (searches.isEmpty) {
          return const _EmptySearchState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Searches', style: Theme.of(context).textTheme.titleSmall),
                  TextButton(
                    onPressed: () {
                      ref.read(recentSearchesProvider.notifier).clearAll();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RecentSearchChips(
              searches: searches,
              onTap: onSearch,
              onDelete: (query) {
                ref.read(recentSearchesProvider.notifier).remove(query);
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _EmptySearchState(),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_outlined, size: 64, color: theme.colorScheme.primary.withAlpha(127)),
          const SizedBox(height: 16),
          Text('Search for posts and people', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Type a query to find posts or people',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostResultsView extends ConsumerWidget {
  const _PostResultsView({required this.query, required this.scrollController});

  final String query;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchProvider(query));
    final hasMore = ref.read(searchProvider(query).notifier).hasMore;

    return resultsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const _NoResultsView(message: 'No posts found');
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(searchProvider(query).notifier).refresh();
          },
          edgeOffset: kRefreshIndicatorEdgeOffset,
          displacement: kRefreshIndicatorDisplacement,
          child: ListView.separated(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: posts.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= posts.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final post = posts[index];
              return _SearchResultCard(post: post);
            },
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (error, _) => _ErrorView(
        error: error,
        onRetry: () => ref.read(searchProvider(query).notifier).refresh(),
      ),
    );
  }
}

class _ActorResultsView extends ConsumerWidget {
  const _ActorResultsView({required this.query, required this.scrollController});

  final String query;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(actorSearchProvider(query));
    final hasMore = ref.read(actorSearchProvider(query).notifier).hasMore;

    return resultsAsync.when(
      data: (actors) {
        if (actors.isEmpty) {
          return const _NoResultsView(message: 'No people found');
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(actorSearchProvider(query).notifier).refresh();
          },
          edgeOffset: kRefreshIndicatorEdgeOffset,
          displacement: kRefreshIndicatorDisplacement,
          child: ListView.separated(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: actors.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= actors.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final actor = actors[index];
              return _ActorSearchResultCard(actor: actor);
            },
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (error, _) => _ErrorView(
        error: error,
        onRetry: () => ref.read(actorSearchProvider(query).notifier).refresh(),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
          ),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final encodedUri = Uri.encodeComponent(post.uri);
        GoRouter.of(context).push('/search/t/$encodedUri');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: post.author.avatar != null
                      ? NetworkImage(post.author.avatar!)
                      : null,
                  child: post.author.avatar == null ? const Icon(Icons.person, size: 16) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.displayName ?? post.author.handle,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${post.author.handle}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.text,
              style: theme.textTheme.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.embed != null) ...[
              const SizedBox(height: 8),
              PostEmbeds(embed: post.embed!, authorDid: post.author.did, record: post.record),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionItem(icon: Icons.chat_bubble_outline, count: post.replyCount),
                const SizedBox(width: 24),
                _ActionItem(icon: Icons.repeat, count: post.repostCount),
                const SizedBox(width: 24),
                _ActionItem(icon: Icons.favorite_outline, count: post.likeCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActorSearchResultCard extends StatelessWidget {
  const _ActorSearchResultCard({required this.actor});

  final SearchActorItem actor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final encodedDid = Uri.encodeComponent(actor.did);
        GoRouter.of(context).push('/search/u/$encodedDid');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: actor.avatar != null ? NetworkImage(actor.avatar!) : null,
              child: actor.avatar == null ? const Icon(Icons.person, size: 24) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actor.displayName ?? actor.handle,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${actor.handle}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (actor.description != null && actor.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      actor.description!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${_formatCount(actor.followersCount)} followers',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatCount(actor.followsCount)} following',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      if (actor.allowIncoming != null && actor.allowIncoming != 'none') ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: actor.allowIncoming == 'all'
                              ? 'Open to DMs'
                              : 'DMs allowed from followers',
                          child: Icon(
                            actor.allowIncoming == 'all'
                                ? Icons.mail_outline
                                : Icons.mark_email_read_outlined,
                            size: 14,
                            color: theme.colorScheme.primary.withAlpha(200),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withAlpha(153)),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ],
    );
  }
}
