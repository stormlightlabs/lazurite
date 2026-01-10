import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_notifier.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/widgets/feed_post_card.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  final ScrollController _scrollController = ScrollController();
  static const String _kBookmarksFeedKey = '__internal:bookmarks';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;

    try {
      await ref
          .read(feedContentRepositoryProvider)
          .fetchBookmarks(ownerDid: authState.session.did);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh bookmarks: ${e.toString()}'),
            action: SnackBarAction(label: 'Retry', onPressed: _refresh),
          ),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthStateAuthenticated) return;

    final cursor = await ref
        .read(feedContentRepositoryProvider)
        .getCursor(_kBookmarksFeedKey, authState.session.did);
    if (cursor != null) {
      await ref
          .read(feedContentRepositoryProvider)
          .fetchBookmarks(ownerDid: authState.session.did, cursor: cursor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(feedContentProvider(_kBookmarksFeedKey));

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: PullToRefreshWrapper(
        onRefresh: _refresh,
        child: bookmarksAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No bookmarks yet'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return FeedPostCard(item: items[index]);
                  }, childCount: items.length),
                ),
              ],
            );
          },
          loading: () => const LoadingView(),
          error: (e, st) => ErrorView(
            title: 'Failed to load bookmarks',
            message: e.toString(),
            onRetry: _refresh,
          ),
        ),
      ),
    );
  }
}
