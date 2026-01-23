import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/widgets/feed_post_card.dart';

/// Tab content showing author's replies (posts that are replies to others).
class RepliesTab extends StatefulWidget {
  const RepliesTab({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
    super.key,
  });

  final List<Post> items;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback onLoadMore;

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

  /// Filter items to only show replies authored by the profile.
  List<Post> get _replies {
    return widget.items.where((item) => item.isReply && !item.isRepost && !item.isQuote).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final replies = _replies;

    if (replies.isEmpty && !widget.isLoading) {
      return const Center(child: Text('No replies yet'));
    }

    return ListView.builder(
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
          post: item,
          onTap: () {
            final encodedUri = Uri.encodeComponent(item.uri);
            GoRouter.of(context).push('/home/t/$encodedUri');
          },
          onAvatarTap: () {
            final encodedDid = Uri.encodeComponent(item.author.did);
            GoRouter.of(context).push('/home/u/$encodedDid');
          },
        );
      },
    );
  }
}
