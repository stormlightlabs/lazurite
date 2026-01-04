import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:lazurite/src/features/timeline/application/timeline_notifier.dart';

import 'widgets/post_card.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final ScrollController _scrollController = ScrollController();

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
    final timelineState = ref.watch(timelineProvider);

    return Scaffold(
      body: PullToRefreshWrapper(
        onRefresh: () async {
          await ref.read(timelineProvider.notifier).refresh();
        },
        child: timelineState.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('No posts yet'));
            }
            return ListView.separated(
              controller: _scrollController,
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return PostCard(item: items[index]);
              },
            );
          },
          loading: () => const LoadingView(),
          error: (err, stack) => ErrorView(
            title: 'Failed to load timeline',
            message: err.toString(),
            onRetry: () => ref.read(timelineProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
