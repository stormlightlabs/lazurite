import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';

/// Tab content showing author's posts with infinite scroll.
class ProfilePostsTab extends StatefulWidget {
  const ProfilePostsTab({
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
  State<ProfilePostsTab> createState() => _ProfilePostsTabState();
}

class _ProfilePostsTabState extends State<ProfilePostsTab> {
  final _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return const Center(child: Text('No posts yet'));
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = widget.items[index];
          return _ProfilePostCard(item: item);
        },
      ),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final encodedUri = Uri.encodeComponent(item.uri);
        GoRouter.of(context).push('/home/t/$encodedUri');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.text,
              style: theme.textTheme.bodyMedium,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionItem(icon: Icons.chat_bubble_outline, count: item.replyCount),
                const SizedBox(width: 24),
                _ActionItem(icon: Icons.repeat, count: item.repostCount),
                const SizedBox(width: 24),
                _ActionItem(icon: Icons.favorite_outline, count: item.likeCount),
                const Spacer(),
                if (item.indexedAt != null)
                  Text(
                    DateFormatter.formatRelative(item.indexedAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(127),
                    ),
                  ),
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
