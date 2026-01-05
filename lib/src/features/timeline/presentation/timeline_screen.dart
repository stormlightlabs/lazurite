import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_selector_tab.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/timeline/application/timeline_cleanup_controller.dart';
import 'package:lazurite/src/features/timeline/application/timeline_notifier.dart';

import 'widgets/post_card.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
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
      ref.read(timelineProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(timelineCleanupControllerProvider);
    final timelineState = ref.watch(timelineProvider);
    final activeFeedUri = ref.watch(activeFeedProvider);
    _ensureFeedLoaded(activeFeedUri);

    return Scaffold(
      body: timelineState.when(
        data: (items) {
          return PullToRefreshWrapper(
            onRefresh: () async {
              await ref.read(timelineProvider.notifier).refresh();
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
                      return PostCard(item: items[itemIndex]);
                    }, childCount: items.length * 2 - 1),
                  ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          title: 'Failed to load timeline',
          message: err.toString(),
          onRetry: () => ref.read(timelineProvider.notifier).refresh(),
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
      ref.read(timelineProvider.notifier).refresh();
    });
  }
}
