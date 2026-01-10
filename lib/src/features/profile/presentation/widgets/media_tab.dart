import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/feed_post_card.dart';
import 'package:lazurite/src/features/profile/domain/profile.dart';

/// Tab content showing author's posts that contain media (images).
class MediaTab extends StatefulWidget {
  const MediaTab({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
    super.key,
  });

  final List<FeedItem> items;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback onLoadMore;

  @override
  State<MediaTab> createState() => _MediaTabState();
}

class _MediaTabState extends State<MediaTab> with AutomaticKeepAliveClientMixin {
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

  /// Filter items to only show posts with media authored by the profile.
  List<FeedItem> get _mediaItems {
    return widget.items.where((item) => item.hasMedia).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final mediaItems = _mediaItems;

    if (mediaItems.isEmpty && !widget.isLoading) {
      return const Center(child: Text('No media posts yet'));
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: mediaItems.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= mediaItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = mediaItems[index];
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
    );
  }
}
