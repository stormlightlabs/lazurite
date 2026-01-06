import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/verification_badge.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({
    required this.author,
    required this.indexedAt,
    this.onAvatarTap,
    this.verificationStatus,
    super.key,
  });

  final Profile author;
  final DateTime? indexedAt;
  final VoidCallback? onAvatarTap;

  /// Optional verification status to display badge next to author name.
  final String? verificationStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onAvatarTap,
          child: Avatar(imageUrl: author.avatar, radius: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  author.displayName ?? author.handle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (verificationStatus != null) ...[
                const SizedBox(width: 4),
                VerificationBadge(verificationStatus: verificationStatus, size: 14),
              ],
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '@${author.handle}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '• ${_formatTime(indexedAt)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
