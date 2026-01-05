import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/feed_post_card.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';

/// Tab content showing author's replies (posts that are replies to others).
class RepliesTab extends StatefulWidget {
  const RepliesTab({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
    required this.onRefresh,
    super.key,
  });

  final List<FeedItem> items;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  State<RepliesTab> createState() => _RepliesTabState();
}

class _RepliesTabState extends State<RepliesTab> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

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
      widget.onLoadMore();
    }
  }

  /// Filter items to only show replies.
  List<FeedItem> get _replies => widget.items.where((item) => item.isReply).toList();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final replies = _replies;

    if (replies.isEmpty && !widget.isLoading) {
      return const Center(child: Text('No replies yet'));
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: replies.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= replies.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = replies[index];
          return FeedPostCard(
            uri: item.uri,
            authorDid: item.authorDid,
            authorHandle: item.authorHandle,
            authorDisplayName: item.authorDisplayName,
            authorAvatar: item.authorAvatar,
            text: item.text,
            indexedAt: item.indexedAt,
            replyCount: item.replyCount,
            repostCount: item.repostCount,
            likeCount: item.likeCount,
            onTap: () {
              final encodedUri = Uri.encodeComponent(item.uri);
              GoRouter.of(context).push('/home/t/$encodedUri');
            },
            onAvatarTap: () {
              final encodedDid = Uri.encodeComponent(item.authorDid);
              GoRouter.of(context).push('/home/u/$encodedDid');
            },
          );
        },
      ),
    );
  }
}
