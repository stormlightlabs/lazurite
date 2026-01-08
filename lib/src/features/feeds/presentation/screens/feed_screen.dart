import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/animations/animation_utils.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_cleanup_controller.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_notifier.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_selector_tab.dart';

import 'widgets/feed_post_card.dart';

/// Main screen for displaying feed content.
///
/// Shows the user's active feed with pull-to-refresh and infinite scroll.
/// Displays a FeedSelectorTab in the app bar for switching between feeds.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _lastRequestedFeed;
  bool _isFeedSelectorExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final activeFeedUri = ref.read(activeFeedProvider);
      ref.read(feedContentProvider(activeFeedUri).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(feedContentCleanupControllerProvider);
    final activeFeedUri = ref.watch(activeFeedProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthStateAuthenticated;

    if (isAuthenticated) {
      final pinnedFeedsAsync = ref.watch(pinnedFeedsProvider);
      if (pinnedFeedsAsync.isLoading) {
        return const Scaffold(body: LoadingView(key: ValueKey('pinned-feeds-loading')));
      }
    }

    final feedContentState = ref.watch(feedContentProvider(activeFeedUri));
    _ensureFeedLoaded(activeFeedUri);

    return Scaffold(
      body: AnimatedContentSwitcher(
        child: feedContentState.when(
          data: (items) {
            return PullToRefreshWrapper(
              key: const ValueKey('feed_list'),
              onRefresh: () async {
                await ref.read(feedContentProvider(activeFeedUri).notifier).refresh();
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lazurite', style: Theme.of(context).textTheme.displaySmall),
                        if (isAuthenticated)
                          ScaleButton(
                            child: IconButton(
                              icon: Icon(
                                _isFeedSelectorExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isFeedSelectorExpanded = !_isFeedSelectorExpanded;
                                });
                              },
                              tooltip: _isFeedSelectorExpanded ? 'Hide feeds' : 'Show feeds',
                            ),
                          ),
                      ],
                    ),
                    floating: true,
                    snap: true,
                    bottom: isAuthenticated
                        ? PreferredSize(
                            preferredSize: Size.fromHeight(_isFeedSelectorExpanded ? 56 : 0),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: _isFeedSelectorExpanded
                                  ? const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: FeedSelectorTab(),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          )
                        : null,
                  ),
                  if (items.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('No posts yet')),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return AnimatedItem(
                          index: index,
                          child: FeedPostCard(item: items[index]),
                        );
                      }, childCount: items.length),
                    ),
                ],
              ),
            );
          },
          loading: () => const LoadingView(key: ValueKey('loading')),
          error: (err, stack) => ErrorView(
            key: const ValueKey('error'),
            title: 'Failed to load feed',
            message: err.toString(),
            onRetry: () => ref.read(feedContentProvider(activeFeedUri).notifier).refresh(),
          ),
        ),
      ),
    );
  }

  void _ensureFeedLoaded(String feedUri) {
    if (_lastRequestedFeed == feedUri) {
      return;
    }
    _lastRequestedFeed = feedUri;
    Future.microtask(() {
      if (!mounted) return;
      ref.read(feedContentProvider(feedUri).notifier).refresh();
    });
  }
}
