import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theme.dart';

class PostActionsRow extends StatelessWidget {
  const PostActionsRow({this.replyCount = 0, this.repostCount = 0, this.likeCount = 0, super.key});

  final int replyCount;
  final int repostCount;
  final int likeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(icon: Icons.chat_bubble_outline, count: replyCount),
        _ActionItem(icon: Icons.repeat, count: repostCount),
        _ActionItem(icon: Icons.favorite_border, count: likeCount),
        const Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            _formatCount(count),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}
