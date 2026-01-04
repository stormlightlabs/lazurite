import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/features/search/presentation/widgets/recent_search_chips.dart';
import 'package:lazurite/src/features/search/presentation/widgets/search_bar_widget.dart';

/// Search screen with search input, recent searches, and results.
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates a search screen.
  const SearchScreen({this.initialQuery, super.key});

  /// Optional initial query from route.
  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _currentQuery = '';
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _currentQuery = widget.initialQuery!;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_currentQuery.isNotEmpty) {
        ref.read(searchProvider(_currentQuery).notifier).loadMore();
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      _currentQuery = query;
    });
  }

  void _onClear() {
    setState(() {
      _currentQuery = '';
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
                hintText: 'Search posts...',
                onSubmitted: _onSearch,
                onClear: _onClear,
              ),
            ),
            Expanded(
              child: _currentQuery.isEmpty
                  ? _RecentSearchesView(onSearch: _onSearch)
                  : _SearchResultsView(query: _currentQuery, scrollController: _scrollController),
            ),
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
          Text('Search for posts', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Type a query to find posts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({required this.query, required this.scrollController});

  final String query;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchProvider(query));
    final hasMore = ref.read(searchProvider(query).notifier).hasMore;

    return resultsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
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
                Text('No results found', style: Theme.of(context).textTheme.headlineSmall),
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

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(searchProvider(query).notifier).refresh();
          },
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
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(searchProvider(query).notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.post});

  final SearchPostItem post;

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
                  backgroundImage: post.authorAvatar != null
                      ? NetworkImage(post.authorAvatar!)
                      : null,
                  child: post.authorAvatar == null ? const Icon(Icons.person, size: 16) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorDisplayName ?? post.authorHandle,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${post.authorHandle}',
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
