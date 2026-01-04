import 'package:flutter/material.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';

/// A row widget for displaying an actor (user profile).
class ActorRow extends StatelessWidget {
  const ActorRow({
    required this.did,
    required this.handle,
    this.displayName,
    this.avatar,
    this.description,
    this.onTap,
    this.trailing,
    super.key,
  });

  /// The actor's DID.
  final String did;

  /// The actor's handle.
  final String handle;

  /// Optional display name.
  final String? displayName;

  /// Optional avatar URL.
  final String? avatar;

  /// Optional description/bio.
  final String? description;

  /// Callback when the row is tapped.
  final VoidCallback? onTap;

  /// Optional trailing widget (e.g., follow button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(imageUrl: avatar, radius: 24, heroTag: 'actor_avatar_$did'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName ?? handle,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@$handle',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withAlpha(153),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                    ],
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
