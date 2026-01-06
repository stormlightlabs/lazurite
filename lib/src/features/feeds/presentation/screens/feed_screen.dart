import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';
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
    final feedContentState = ref.watch(feedContentProvider(activeFeedUri));
    _ensureFeedLoaded(activeFeedUri);

    return Scaffold(
      body: feedContentState.when(
        data: (items) {
          return PullToRefreshWrapper(
            onRefresh: () async {
              await ref.read(feedContentProvider(activeFeedUri).notifier).refresh();
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverAppBar(
                  title: Text('Lazurite'),
                  floating: true,
                  snap: true,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: FeedSelectorTab(),
                    ),
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No posts yet')),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index.isOdd) {
                        return const Divider(height: 1);
                      }
                      final itemIndex = index ~/ 2;
                      return FeedPostCard(item: items[itemIndex]);
                    }, childCount: items.length * 2 - 1),
                  ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          title: 'Failed to load feed',
          message: err.toString(),
          onRetry: () => ref.read(feedContentProvider(activeFeedUri).notifier).refresh(),
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
