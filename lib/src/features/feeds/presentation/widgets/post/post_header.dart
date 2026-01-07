import 'package:flutter/material.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
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
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '• ${indexedAt != null ? DateFormatter.formatRelative(indexedAt!) : ""}',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
